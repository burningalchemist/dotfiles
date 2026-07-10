-- # Custom functions

-- ## Float input prompt
---@ diagnostic disable: unused-function,unused-local
local function float_input(opts, on_confirm)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].buftype = "prompt"
    vim.bo[buf].bufhidden = "wipe"

    -- Keymaps for prompt buffer
    vim.keymap.set({ "i", "n" }, "<CR>", "<CR><ESC><CMD>close!<CR><CMD>stopinsert<CR>", { buffer = buf, silent = true })
    vim.keymap.set("n", "u", "<CMD>undo<CR>", { buffer = buf, silent = true })
    for _, key in ipairs({ "<esc>", "q" }) do
        vim.keymap.set("n", key, "<CMD>close!<CR>", { buffer = buf, silent = true })
    end

    vim.fn.prompt_setprompt(buf, " ")
    vim.fn.prompt_setcallback(buf, function(input)
        vim.defer_fn(function() on_confirm(input) end, 10)
    end)

    local default_text = opts.default or ""
    local win_opts = {
        col = 0,
        focusable = true,
        height = 1,
        relative = "cursor",
        row = 1,
        style = "minimal",
        width = math.max(30, #default_text + 2),
        title = { { opts.prompt, "FloatTitle" } },
        title_pos = "left",
    }

    local win = vim.api.nvim_open_win(buf, true, win_opts)
    vim.cmd("startinsert")

    vim.defer_fn(function()
        vim.api.nvim_buf_set_text(buf, 0, 1, 0, 1, { default_text })
        vim.api.nvim_win_set_cursor(win, { 1, #default_text + 1 })
        vim.cmd("startinsert")
    end, 10)
end

-- ## Count instances and files in a workspace edit
local function count(edit)
    local files, instances = 0, 0
    if edit.documentChanges then
        for _, f in pairs(edit.documentChanges) do
            files = files + 1
            instances = instances + #f.edits
        end
    elseif edit.changes then
        for _, f in pairs(edit.changes) do
            files = files + 1
            instances = instances + #f
        end
    end
    return instances, files
end

-- ## Ripgrep search using libuv pipes dumping output to quickfix list
local function rgqf(search_term)
    if not search_term or search_term == "" then
        return
    end

    local qf_title = "Ripgrep to qflist: " .. search_term
    -- Clear quickfix list immediately
    vim.fn.setqflist({}, ' ', { title = qf_title, items = {} })

    -- Initialize libuv pipes for stdout and stderr
    local stdout = vim.uv.new_pipe(false)
    local stderr = vim.uv.new_pipe(false)

    local chunks = {}
    local err_chunks = {}

    local cmd = "rg"
    local args = { "--vimgrep", "--smart-case", "--no-heading", "--no-messages", "--", search_term, "." }

    -- Spawn the process asynchronously
    local handle, pid
    handle, pid = vim.uv.spawn(cmd, {
        args = args,
        stdio = { nil, stdout, stderr },
        cwd = vim.fn.getcwd()
    }, function(code, signal)
        stdout:read_stop()
        stderr:read_stop()
        stdout:close()
        stderr:close()
        handle:close()

        -- Schedule UI updates back to the Neovim main event loop
        vim.schedule(function()
            if code == 0 or code == 1 then
                local full_output = table.concat(chunks)
                local lines = vim.split(full_output, "\n", { trimempty = true })

                vim.fn.setqflist({}, 'r', { title = qf_title, lines = lines })
                vim.cmd("copen")

                vim.notify(string.format("Found %d matches.", #lines), vim.log.levels.INFO)
            else
                local err_output = table.concat(err_chunks)
                vim.notify(string.format("Ripgrep failed (Code %d): %s", code, err_output), vim.log.levels.ERROR)
            end
        end)
    end)

    -- If the process failed to even start
    if not handle then
        vim.notify("Failed to spawn ripgrep: " .. tostring(pid), vim.log.levels.ERROR)
        return
    end

    -- Start reading streaming data from stdout pipe asynchronously
    vim.uv.read_start(stdout, function(err, data)
        assert(not err, err)
        if data then
            table.insert(chunks, data)
        end
    end)

    -- Start reading streaming data from stderr pipe asynchronously
    vim.uv.read_start(stderr, function(err, data)
        assert(not err, err)
        if data then
            table.insert(err_chunks, data)
        end
    end)
end

-- Exported function to prompt user for a search term and call rgqf
function RgSearch()
    vim.ui.input({ prompt = "Ripgrep term: " }, function(input)
        if input then
            rgqf(input)
        end
    end)
end
