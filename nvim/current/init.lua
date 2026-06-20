---@diagnostic disable: missing-fields, undefined-global

-- (!) Magic Optimizer
vim.loader.enable()
require('vim._core.ui2').enable({ {
    enable = true,
    msg = {
        target = "msg",
    }
} })

-- Import lua modules
require("main")
require("keymaps")
require("custom_func")
require("plugins")
require("autocmd")
require("lsp")
