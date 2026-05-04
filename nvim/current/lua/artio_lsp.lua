local artio = require("artio")
local utils = require("artio.utils")
local config = require("artio.config")

local base_dir = vim.fn.getcwd(0)

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

local function make_lsp_picker(method, prompt, extra_params)
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_win_get_buf(win)
    local params = vim.lsp.util.make_position_params(win, 'utf-8')
    vim.tbl_extend("force", params, extra_params or {})

    local results = vim.lsp.buf_request_sync(buf, method, params, 2000)
    local locs = resolve_locs(results)

    if #locs == 0 then
        vim.notify("[artio] No " .. prompt .. " found.", vim.log.levels.INFO)
        return
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
        actions = utils.make_setqflistactions(function(item)
            return { filename = item.v.filename, lnum = item.v.lnum, col = item.v.col + 1, text = item.text }
        end),
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
    return make_lsp_picker("textDocument/definition", "lsp definitions")
end

function custom_pickers.references()
    return make_lsp_picker("textDocument/references", "lsp references", {
        context = { includeDeclaration = false },
    })
end

function custom_pickers.neoclip()
    return make_neoclip_picker()
end

return custom_pickers
