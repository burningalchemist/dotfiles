-- # Key Mappings
-- ## General
vim.keymap.set("n", "<S-t>", "<cmd>tabnew<cr>")
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")

-- Helper function that finds the first delimiter and swaps text around it
local function swap_around_delimiter(text)
    local delimiters = {
        " %- ",    -- ' - '
        ":%s+",    -- ': ' (colon followed by spaces)
        ",%s+",    -- ', ' (comma followed by spaces)
        "%s*=%s*", -- '=' (with optional spaces around it)
        " | ",     -- ' | '
    }

    local first_pos = math.huge
    local chosen_delim = nil

    for _, delim in ipairs(delimiters) do
        local pos = text:find(delim)
        if pos and pos < first_pos then
            first_pos = pos
            chosen_delim = delim
        end
    end

    if chosen_delim then
        -- Swap logic: (leading spaces)(left side)(delimiter)(right side)
        local swapped = text:gsub("^(%s*)(.-)(" .. chosen_delim .. ")(.*)$", "%1%4%3%2", 1)
        return swapped, true
    end

    return text, false
end

-- 1. Normal Mode: Swaps based on the entire current line
vim.keymap.set('n', '<M-t>', function()
    local line = vim.api.nvim_get_current_line()
    local swapped, success = swap_around_delimiter(line)

    if success then
        vim.api.nvim_set_current_line(swapped)
    else
        vim.notify("No recognized delimiter found on line", vim.log.levels.WARN)
    end
end, { desc = "Transpose values around delimiter (Line)" })

-- 2. Visual Mode: Handles both single-line chunks and multi-line blocks
vim.keymap.set('x', '<M-t>', function()
    -- Exit visual mode synchronously to lock in the '< and '> marks
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'x', false)

    -- Fetch the start and end coordinates of the selection
    local r1, c1 = unpack(vim.api.nvim_buf_get_mark(0, '<'))
    local r2, c2 = unpack(vim.api.nvim_buf_get_mark(0, '>'))

    local start_row = r1 - 1
    local end_row = r2 - 1

    if start_row == end_row then
        -- SINGLE LINE SELECTION: Swap only the specifically highlighted text
        local line_text = vim.api.nvim_buf_get_lines(0, start_row, start_row + 1, false)[1]

        -- Cap the column if the user used visual-line mode (V)
        local end_col = math.min(c2, #line_text - 1)

        -- Extract the selected text chunk
        local text = string.sub(line_text, c1 + 1, end_col + 1)
        local swapped, success = swap_around_delimiter(text)

        if success then
            -- Stitch the line back together
            local new_line = string.sub(line_text, 1, c1) .. swapped .. string.sub(line_text, end_col + 2)
            vim.api.nvim_buf_set_lines(0, start_row, start_row + 1, false, { new_line })
        else
            vim.notify("No recognized delimiter found in selection", vim.log.levels.WARN)
        end
    else
        -- MULTI-LINE SELECTION: Swap each line in the block independently
        local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row + 1, false)
        local new_lines = {}
        local swapped_any = false

        for _, line in ipairs(lines) do
            local swapped, success = swap_around_delimiter(line)
            table.insert(new_lines, swapped)
            if success then swapped_any = true end
        end

        if swapped_any then
            vim.api.nvim_buf_set_lines(0, start_row, end_row + 1, false, new_lines)
        else
            vim.notify("No recognized delimiters found in selection block", vim.log.levels.WARN)
        end
    end
end, { desc = "Transpose values around delimiter (Selection/Block)" })


-- ## Delete without yanking
vim.keymap.set("n", "x", [["_x]])
vim.keymap.set("n", "X", [["_X]])

vim.keymap.set("x", "p", [["_dP]], { desc = "Paste from yank register" })
vim.keymap.set("x", "<leader>y", [["+y]], { desc = "Yank to system clipboard" })

-- ## Diagnostics
vim.keymap.set("n", "<space>e", vim.diagnostic.open_float,
    { desc = "Show diagnostics in a floating window" })
vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = 1 }) end,
    { desc = "Move to the previous diagnostic in the buffer" })
vim.keymap.set("n", "{d", function() vim.diagnostic.jump({ count = -1 }) end,
    { desc = "Move to the next diagnostic in the buffer" })
vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist,
    { desc = "Add diagnostics to the location list" })

-- ## Quickfix
vim.keymap.del("n", "]q") -- Remove default for next quickfix list navigation
vim.keymap.set("n", "{q", function() vim.cmd.cnext() end, { desc = "cnext" })

-- ## Detach Neovim from the remote server
vim.keymap.set("n", "<leader>rd", function()
    for _, ui in pairs(vim.api.nvim_list_uis()) do
        if ui.chan and not ui.stdout_tty then
            vim.fn.chanclose(ui.chan)
        end
    end
end, { noremap = true, desc = "Detach TUI from the remote RPC server" })

-- ## Toggle auto-wrapping by textwidth value
vim.keymap.set("n", "<leader>tw", function()
    if vim.opt.formatoptions:get().t == nil then
        vim.opt.formatoptions:append("t")
        vim.notify("Text auto-wrapping is enabled", vim.log.levels.INFO)
    else
        vim.opt.formatoptions:remove("t")
        vim.notify("Text auto-wrapping is disabled", vim.log.levels.INFO)
    end
end, { desc = "Toggle auto-wrapping by textwidth" })

-- ## Toggle between line numbers and relative line numbers
vim.keymap.set("n", "<leader>tn", function()
    local on = vim.wo.statuscolumn == ""
    vim.opt.number = true
    vim.opt.relativenumber = not on
    vim.wo.statuscolumn = on and "%=%{v:lnum} " or ""
end, { desc = "Toggle line numbers" })

-- ## Artio
-- TODO: artio-grep needs to become async so that it can be used without pain.
vim.keymap.set("n", "<leader>fb", "<Plug>(artio-buffers)", { desc = "Buffers" })
vim.keymap.set("n", "<leader>fg", "<Plug>(artio-buffergrep)", { desc = "Grep in open buffers" })
vim.keymap.set("n", "<leader>fr", "<Plug>(artio-oldfiles)", { desc = "Recent files" })
vim.keymap.set("n", "<leader>gg", "<Plug>(artio-diagnostics-buffer)",
    { desc = "LSP Diagnostics (buffer)" })
-- ## Artio Custom Pickers
vim.keymap.set("n", "<leader>fe", function() require('artio_ext').livegrep() end, {
    desc = "Live grep" })
vim.keymap.set("n", "<leader>gd", function() require('artio_ext').definitions() end, {
    desc = "LSP Definitions" })
vim.keymap.set("n", "<leader>gr", function() require('artio_ext').references() end, {
    desc = "LSP References" })
vim.keymap.set("n", "<leader>gi", function() require('artio_ext').implementations() end, {
    desc = "LSP Implementations" })
vim.keymap.set("n", "<leader>gD", function() require('artio_ext').declarations() end, {
    desc = "LSP Implementations" })
vim.keymap.set("n", "<leader>gq", function() require('artio_ext').qflist() end, {
    desc = "Switch quickfix list",
})
vim.keymap.set("n", "<leader>yl", function() require('artio_ext').neoclip() end, {
    desc = "Yank history",
})
vim.keymap.set("n", "<leader>ff", function()
    local depth_limit = ""
    if vim.fn.getcwd() == vim.fn.expand("~") then
        depth_limit = "-d 3"
    end
    require('artio.builtins').smart({
        findprg = [[ fd -p -a --color=never -E go -E Library ]] ..
            depth_limit .. ' -- '
    })
end, { desc = "Smart picker" })
-- ## Custom Ripgrep search using libuv pipes dumping output to quickfix list
vim.keymap.set("n", "<leader>fq", RgSearch, { desc = "Grep to quickfix" })
vim.keymap.set({ 'n', 'x' }, '<leader>fs', function()
    require('grug-far').open({ visualSelectionUsage = 'operate-within-range' })
end, { desc = 'Search and replace' })

-- ## Nvimtree
vim.keymap.set("n", "<leader>nf", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file explorer" })
vim.keymap.set("n", "<leader>nr", "<cmd>NvimTreeRefresh<cr>", { desc = "Refresh file explorer" })

-- ## Remap Macro Recording
vim.keymap.set('n', 'q', '<nop>', { noremap = true })
vim.keymap.set('n', 'Q', 'q', { noremap = true, desc = 'Record macro' })
vim.keymap.set('n', '<M-q>', 'Q', { noremap = true, desc = 'Replay last register' })

-- ## Leap Mappings (like `s` in vim-sneak, :help leap-mappings)
vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Plug>(leap)')
vim.keymap.set('n', 'S', '<Plug>(leap-from-window)')

-- ## Aerial
vim.keymap.del("n", "gO") -- Remove default mapping for document symbols as we use Aerial instead
vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>", { desc = "Toggle symbols" })

-- ## Vimpack
vim.keymap.set("n", "<leader>vu", function() vim.pack.update() end, { desc = "Update packages" })

-- ## Mjolnr
vim.keymap.set("n", "<leader>mo", "<cmd>MjolnrTaskOwnedView type=unclosed<cr>",
    { desc = "Mjolnr: List Unclosed owned tasks" })
vim.keymap.set("n", "<leader>md", "<cmd>MjolnrTaskOwnedView status=Done<cr>",
    { desc = "Mjolnr: List Done owned tasks" })
vim.keymap.set("n", "<leader>ma", "<cmd>MjolnrTaskAssignedView type=unclosed<cr>",
    { desc = "Mjolnr: List Unclosed assigned tasks" })
vim.keymap.set("n", "<leader>mc", "<cmd>MjolnrTaskCreatedView type=unclosed<cr>",
    { desc = "Mjolnr: List Unclosed created tasks" })

-- Create user command to load copilotchat plugin when we type CopilotChat command
vim.api.nvim_create_user_command("CChat", function()
    if not package.loaded["CopilotChat"] then
        local success, _ = pcall(vim.pack.add,
            { "https://github.com/CopilotC-Nvim/CopilotChat.nvim", "https://github.com/nvim-lua/plenary.nvim" })
        if not success then
            vim.notify("Failed to load CopilotChat plugin", vim.log.levels.ERROR)
            return
        end
    end
    local chat = require("CopilotChat")
    chat.toggle({ model = "claude-sonnet-5.5" })
end, {
    desc = "Open Copilot Chat",
})
