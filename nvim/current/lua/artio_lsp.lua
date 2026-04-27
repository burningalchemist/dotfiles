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

local lsp_pickers = {}

function lsp_pickers.definitions()
    return make_lsp_picker("textDocument/definition", "lsp definitions")
end

function lsp_pickers.references()
    return make_lsp_picker("textDocument/references", "lsp references", {
        context = { includeDeclaration = false },
    })
end

return lsp_pickers
