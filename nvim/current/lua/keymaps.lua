-- # Key Mappings
-- ## General
vim.keymap.set("n", "<S-t>", "<cmd>tabnew<cr>")
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")

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
vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = -1 }) end,
    { desc = "Move to the next diagnostic in the buffer" })
vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist,
    { desc = "Add diagnostics to the location list" })

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
vim.keymap.set("n", "<leader>fg", "<Plug>(artio-grep)", { desc = "Live grep" })
vim.keymap.set("n", "<leader>fh", "<Plug>(artio-helptags)", { desc = "Tags" })
vim.keymap.set("n", "<leader>fb", "<Plug>(artio-buffers)", { desc = "Buffers" })
vim.keymap.set("n", "<leader>f/", "<Plug>(artio-buffergrep)", { desc = "Grep in open buffers" })
vim.keymap.set("n", "<leader>fr", "<Plug>(artio-oldfiles)", { desc = "Recent files" })
vim.keymap.set("n", "<leader>fd", "<Plug>(artio-diagnostics-buffer)",
    { desc = "Diagnostics for buffer" })
-- ## Artio Custom Pickers
vim.keymap.set("n", "<leader>gd", function() require('artio_lsp').definitions() end, {
    desc = "LSP Definitions" })
vim.keymap.set("n", "<leader>gr", function() require('artio_lsp').references() end, {
    desc = "LSP References" })
vim.keymap.set("n", "<leader>yl", function() require('artio_lsp').neoclip() end, {
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

-- ## NeoTree
vim.keymap.set("n", "<leader>nf", "<cmd>Neotree reveal_force_cwd toggle focus filesystem left<cr>")
vim.keymap.set("n", "<leader>nb", "<cmd>Neotree reveal_force_cwd toggle focus buffers right<cr>")
vim.keymap.set("n", "<leader>ng", "<cmd>Neotree reveal float git_status<cr>")
vim.keymap.set("n", "<leader>nd", "<cmd>Neotree reveal toggle diagnostics bottom<cr>")

-- ## Remap Macro Recording
vim.keymap.set('n', 'q', '<nop>', { noremap = true })
vim.keymap.set('n', 'Q', 'q', { noremap = true, desc = 'Record macro' })
vim.keymap.set('n', '<M-q>', 'Q', { noremap = true, desc = 'Replay last register' })

-- ## Leap Mappings (like `s` in vim-sneak, :help leap-mappings)
vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Plug>(leap)')
vim.keymap.set('n', 'S', '<Plug>(leap-from-window)')

-- ## Aerial
vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>", { desc = "Toggle symbols" })

-- ## Vimpack
vim.keymap.set("n", "<leader>vu", function() vim.pack.update() end, { desc = "Update packages" })


