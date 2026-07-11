local artio = require("artio")
local config = require("artio.config")
local utils = require("artio.utils")

local base_dir = vim.fn.getcwd(0)
local active_job = nil
local active_stdout = nil

local function resolve_locs(results)
    local locs = {}
    for _, client_result in pairs(results or {}) do
        for _, loc in ipairs(client_result.result or {}) do
            local uri = loc.uri or loc.targetUri
            local range = loc.range or loc.targetSelectionRange
            if uri and range then
                local filename = vim.uri_to_fname(uri)
                locs[#locs + 1] = {
                    filename = filename,
                    bufnr = vim.fn.bufadd(filename),
                    lnum = range.start.line + 1,
                    col = range.start.character,
                }
            end
        end
    end
    return locs
end

local function kill_zombie_search()
    if active_job and not active_job:is_closing() then
        active_job:kill(15)
        active_job:close()
        active_job = nil
    end
    if active_stdout and not active_stdout:is_closing() then
        active_stdout:read_stop()
        active_stdout:close()
        active_stdout = nil
    end
end

local function rg_async(input, opts)
    kill_zombie_search() -- Instantly terminate the previous ripgrep process

    opts = opts or {}
    if opts.cwd == vim.fn.expand("$HOME") or base_dir == "/" then
        vim.notify("Search blocked: Refusing to crash on home/root directory.", vim.log.levels.WARN)
        return {}
    end

    local prg = vim.split(opts.cmd, " ")
    local max_items = 1000 -- Never load more than 1000 items into memory
    local args = { "--no-heading", "--no-mmap", "--max-columns=" .. max_items, "-j", "2", "--",
        input, opts.cwd }
    args = vim.list_extend(vim.list_slice(prg, 2), args)
    local items = {}
    local partial_line = ""
    local is_done = false -- Flag to signal when the async stream is complete
    active_stdout = vim.uv.new_pipe(false)

    active_job, _ = vim.uv.spawn(prg[1],
        ---@diagnostic disable-next-line: missing-fields
        {
            args = args,
            stdio = { nil, active_stdout, nil },
            cwd = base_dir
        }, vim.schedule_wrap(function(_, _)
            kill_zombie_search()
        end))

    -- Stream data line-by-line
    vim.uv.read_start(active_stdout, function(err, data)
        assert(not err, err)
        if data then
            if #items >= max_items then return end

            local chunk = partial_line .. data
            local from = 1
            while true do
                local find_start, find_end = string.find(chunk, "\n", from, true)
                if not find_start then break end

                local line = string.sub(chunk, from, find_start - 1)
                from = find_end + 1

                local file, lnum, col, _ = string.match(line, "([^:]+):(%d+):(%d+):(.*)")
                if file and lnum then
                    table.insert(items, {
                        id = #items + 1,
                        v = { vim.fs.abspath(file), tonumber(lnum), tonumber(col) },
                        text = line
                    })
                end

                if #items >= max_items then
                    vim.schedule(function()
                        kill_zombie_search()
                        is_done = true
                    end)
                    break
                end
            end
            partial_line = string.sub(chunk, from)
        else
            if active_stdout and not active_stdout:is_closing() then
                active_stdout:read_stop()
                active_stdout:close()
            end
            is_done = true
        end
    end)

    local wait_success = vim.wait(200, function()
        return is_done == true
    end, 10)

    if not wait_success then
        kill_zombie_search()
        vim.notify("Search timed out. Results may be incomplete.", vim.log.levels.WARN)
    end

    return items
end

local function make_livegrep(props)
    props = props or {}
    props.grepprg = props.grepprg or vim.o.grepprg

    base_dir = props.base_dir or vim.fn.getcwd(0)

    return artio.pick({
        items = {},
        prompt = "grep",
        get_items = function(input)
            if input == "" then
                return {}
            end

            return rg_async(input, { cmd = props.grepprg, cwd = base_dir })
        end,
        fn = artio.sorter,
        on_close = function(item, _)
            artio.schedule(function()
                local win = vim.api.nvim_get_current_win()
                utils.edit(item[1], { win = win })
                vim.api.nvim_win_set_cursor(win, { item[2], item[3] })
            end)
        end,
        preview_item = function(item)
            return { buf = vim.fn.bufadd(item[1]), pos = { item[2], 0 } }
        end,
        get_icon = config.get().opts.use_icons and function(item)
            return require("mini.icons").get("file", item.v[1])
        end or nil,
        hl_item = utils.hl_qfitem,
        actions = utils.make_setqflistactions(function(item)
            return { filename = item.v[1], lnum = item.v[2], col = item.v[3], text = item.text }
        end)
    })
end


local function await_lsp_request(buf, method, params)
    local thread = coroutine.running()
    assert(thread, "Must be called inside an active coroutine thread")

    vim.lsp.buf_request(buf, method, params, function(err, results, ctx)
        coroutine.resume(thread, err, results, ctx)
    end)

    return coroutine.yield()
end

local function make_lsp_picker(method, prompt, extra_params)
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_win_get_buf(win)
    local params = vim.lsp.util.make_position_params(win, 'utf-8')
    params = vim.tbl_extend("force", params, extra_params or {})

    local err, results, ctx = await_lsp_request(buf, method, params)

    if err then
        vim.notify("[artio] LSP Error: " .. tostring(err.message), vim.log.levels.ERROR)
        return
    end

    local locs = resolve_locs({ [ctx.client_id] = { result = results } })
    if #locs == 0 then
        vim.notify("[artio] No " .. prompt .. " found.", vim.log.levels.INFO)
        return
    end

    for _, loc in ipairs(locs) do
        if loc.bufnr and not vim.api.nvim_buf_is_loaded(loc.bufnr) then
            vim.fn.bufload(loc.bufnr)
        end
    end

    return artio.pick({
        items = locs,
        prompt = prompt,
        fn = artio.sorter,
        format_item = function(loc)
            local rel = vim.fs.relpath(base_dir, loc.filename) or loc.filename
            local line = vim.api.nvim_buf_get_lines(loc.bufnr, loc.lnum - 1, loc.lnum, false)[1] or ""
            return ("%s:%d:%d: %s"):format(rel, loc.lnum, loc.col, vim.trim(line))
        end,
        on_close = function(loc, _)
            vim.schedule(function()
                if vim.api.nvim_buf_is_loaded(loc.bufnr) then
                    vim.api.nvim_set_current_buf(loc.bufnr)
                    vim.api.nvim_win_set_cursor(0, { loc.lnum, loc.col })
                    return
                end
                vim.cmd.edit(loc.filename)
                vim.api.nvim_win_set_cursor(0, { loc.lnum, loc.col })
            end)
        end,
        preview_item = function(loc)
            vim.fn.bufload(loc.bufnr)
            return loc.bufnr, function(w)
                vim.api.nvim_set_option_value("cursorline", true, { scope = "local", win = w })
                vim.api.nvim_win_set_cursor(w, { loc.lnum, loc.col })
            end
        end,
        get_icon = config.get().opts.use_icons and function(item)
            return require("mini.icons").get("file", item.v.filename)
        end or nil,
    })
end

local function make_qflist_picker()
    -- Get the current active list index and the total number of lists
    local current_nr = vim.fn.getqflist({ nr = 0 }).nr
    local last_nr = vim.fn.getqflist({ nr = "$" }).nr

    local lists = {}
    local items = {}

    -- Scrape the titles/commands of all stored lists
    for i = 1, last_nr do
        local qf = vim.fn.getqflist({ nr = i, title = 1 })
        local title = (qf.title ~= "") and qf.title or ("Search List #" .. i)

        table.insert(lists, { nr = i, title = title })

        -- Add a visual marker showing which list is currently active
        local marker = (i == current_nr) and "➔ " or "  "
        table.insert(items, string.format("%s%d: %s", marker, i, title))
    end

    return artio.pick({
        items = items,
        prompt = "quickfix lists",
        fn = artio.sorter,
        format_item = function(item)
            return item -- Already formatted in the items table
        end,
        on_close = function(_, idx)
            if not idx then return end

            local target_nr = lists[idx].nr
            local delta = target_nr - current_nr

            -- Calculate the relative step delta and execute the correct history shift
            if delta < 0 then
                vim.cmd(math.abs(delta) .. "colder")
            elseif delta > 0 then
                vim.cmd(delta .. "cnewer")
            end
        end,
    })
end

local function make_neoclip_picker()
    local ok, storage = pcall(require, "neoclip.storage")
    if not ok then
        vim.notify("[artio] Neoclip is not loaded.", vim.log.levels.WARN)
        return
    end

    local yanks = storage.get().yanks
    if not yanks or #yanks == 0 then
        vim.notify("[artio] No yanks found in Neoclip.", vim.log.levels.INFO)
        return
    end

    local handlers = require("neoclip.handlers")
    local items = {}
    for i, entry in ipairs(yanks) do
        local preview_text = table.concat(entry.contents, "\n")
        local preview_lines = vim.split(preview_text, "\n")
        local first_line = (entry.contents[1] or ""):gsub("\n", " ")
        local display = first_line .. (#entry.contents > 1 and " ..." or "")

        local type_label = entry.regtype == "l" and "linewise" or entry.regtype == "c" and "charwise" or "blockwise"

        table.insert(items, {
            idx = i,
            text = preview_text,
            line_count = #preview_lines,
            display = display,
            type_label = type_label,
            entry = entry,
            preview = { text = preview_text, ft = entry.filetype or "" },
        })
    end

    local function paste_as(item, regtype)
        vim.schedule(function()
            local entry = vim.tbl_extend("force", {}, item.entry)
            entry.regtype = regtype
            handlers.paste(entry, "p")
        end)
    end

    return artio.pick({
        items = items,
        prompt = "yank history",
        fn = artio.sorter,
        format_item = function(item)
            return ("%s %s (%d lines)"):format(item.display, item.type_label, item.line_count)
        end,
        preview_item = function(item)
            local buf = vim.api.nvim_create_buf(false, true)

            vim.bo[buf].bufhidden = "wipe"
            vim.bo[buf].buftype = "help"

            local lines = vim.split(item.preview.text or "", "\n")
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

            if item.preview and item.preview.ft then
                vim.bo[buf].filetype = item.preview.ft
            end
            return { buf = buf }
        end,
        on_close = function(item, _)
            paste_as(item, "c")
        end,
    })
end


local custom_pickers = {}

function custom_pickers.definitions()
    return coroutine.wrap(function()
        make_lsp_picker("textDocument/definition", "lsp definitions")
    end)()
end

function custom_pickers.declarations()
    return coroutine.wrap(function()
        make_lsp_picker("textDocument/declaration", "lsp declarations")
    end)()
end

function custom_pickers.implementations()
    return coroutine.wrap(function()
        make_lsp_picker("textDocument/implementation", "lsp implementations")
    end)()
end

function custom_pickers.references()
    return coroutine.wrap(function()
        make_lsp_picker("textDocument/references", "lsp references", {
            context = {
                includeDeclaration = true
            }
        })
    end)()
end

function custom_pickers.neoclip()
    return make_neoclip_picker()
end

function custom_pickers.qflist()
    return make_qflist_picker()
end

function custom_pickers.livegrep()
    return make_livegrep()
end

return custom_pickers
