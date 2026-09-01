---@diagnostic disable: missing-fields, undefined-global


-- Enabled loader allows to load Lua modules more efficiently by caching their bytecode.
vim.loader.enable()

require('vim._core.ui2').enable({ {
    enable = true,
    msg = {
        target = "msg",
    }
} })

-- Import lua modules
require("main")
require("custom_func")
require("keymaps")
require("plugins")
require("autocmd")
require("lsp")
