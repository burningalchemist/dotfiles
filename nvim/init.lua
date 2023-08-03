---@diagnostic disable: missing-fields, undefined-global

-- TODO:
-- 1. Try to lazy load neotree
-- 2. Add LSP status to lualine
-- 3. Check moving diagnostic to quickfix list


-- # LazyVIM Init
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end

-- # NVim Settings

-- ## Global Options
vim.opt.syntax = "off"
vim.opt.mouse:append("a")
vim.opt.rtp:append("~/.fzf")
vim.opt.rtp:prepend(lazypath)
vim.opt.expandtab = true
vim.opt.colorcolumn = "120"
vim.opt.laststatus = 3
vim.opt.cmdheight = 0
vim.opt.termguicolors = true
vim.opt.autochdir = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.go.showcmd = true
vim.go.hlsearch = true
vim.go.showmatch = true
vim.go.ignorecase = true
vim.go.smartcase = true
vim.go.ruler = true
vim.go.wildmenu = true
vim.go.title = true
vim.go.incommand = "split"
vim.go.listchars = "tab:▒░,trail:▓,nbsp:░"
vim.g.mapleader = "\\"

-- ## Window Options
vim.wo.number = true
vim.wo.relativenumber = true
vim.wo.scrolloff = 3
vim.wo.cursorline = true
vim.wo.list = true

-- ## Autocommands
vim.api.nvim_create_autocmd("OptionSet", {
    pattern = "number",
    command = "if v:option_new | set showbreak= | else | set showbreak=↪ | endif",
})

-- ### Fix weird yaml indent shifts
vim.api.nvim_create_autocmd("Filetype", {
    pattern = "yaml",
    command = "setlocal indentexpr=",
})

-- # Plugins

-- ## Lazy Plugin Manager Settings
local lazy_opts = {
    performance = {
        rtp = {
            reset = true, -- reset the runtime path to $VIMRUNTIME and your config directory
            disabled_plugins = {
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
}

-- ## Lazy Plugins Configuration
local lazy_plugins = {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("catppuccin")
        end,
    },
    {
        "nvim-lualine/lualine.nvim",
        opts = {
            options = {
                icons_enabled = false,
                disabled_filetypes = { "neo-tree" },
                ignore_focus = { "neo-tree" },
                section_separators = "",
            },
            extensions = { "neo-tree", "lazy" },
        },
    },
    {
        "folke/neodev.nvim",
        ft = "lua",
        opts = {}
    },
    { "nvim-lua/plenary.nvim",       lazy = true },
    { "nvim-tree/nvim-web-devicons", lazy = true },
    { "MunifTanjim/nui.nvim",        lazy = true },
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = true,
        event = "BufRead",
        build = ":TSUpdate",
        opts = {
            -- One of "all", "maintained" (parsers with maintainers), or a list of languages
            ensure_installed = {
                "yaml",
                "hcl",
                "terraform",
                "dockerfile",
                "go",
                "gomod",
                "markdown",
                "markdown_inline",
            },
            -- Install languages synchronously (only applied to `ensure_installed`)
            sync_install = false,

            -- Automatically install missing parsers when entering buffer
            -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
            auto_install = true,

            -- List of parsers to ignore installing
            ignore_install = { "javascript" },

            highlight = {
                -- `false` will disable the whole extension
                enable = false,

                -- list of language that will be disabled
                disable = { "c", "rust" },

                -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
                -- Using this option may slow down your editor, and you may see some duplicate highlights.
                -- Instead of true it can also be a list of languages
                additional_vim_regex_highlighting = false,
            },

            indent = { enable = true, disable = { "yaml" } },
            autopairs = { enable = true },
        },
    },
    {
        "nvim-telescope/telescope.nvim",
        lazy = true,
        branch = "0.1.x",
        dependencies = {
            -- "nvim-telescope/telescope-github.nvim",
            "nvim-lua/plenary.nvim",
        },
        cmd = "Telescope",
        opts = {}
    },
    {
        "nvim-neo-tree/neo-tree.nvim",
        lazy = true,
        cmd = "Neotree",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        opts = {
            filesystem = {
                window = {
                    mappings = {
                        -- disable fuzzy finder
                        ["/"] = "noop",
                    },
                },
            },
        },
    },
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        version = false,
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-nvim-lua",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-vsnip",
            "onsails/lspkind.nvim",
            "hrsh7th/vim-vsnip",
        },
        config = function()
            local cmp = require("cmp")
            local lspkind = require("lspkind")
            cmp.setup({
                completion = {
                    completeopt = "menu,menuone,noinsert",
                },
                formatting = {
                    format = lspkind.cmp_format(),
                },
                snippet = {
                    expand = function(args)
                        vim.fn["vsnip#anonymous"](args.body)
                    end,
                },
                window = {
                    -- completion = cmp.config.window.bordered(),
                    -- documentation = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["§"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "vsnip" },
                }, {
                    { name = "buffer" },
                })
            })
            -- Set configuration for specific filetype.
            cmp.setup.filetype("gitcommit", {
                sources = cmp.config.sources({
                    { name = "git" }, -- Need to install https://github.com/petertriho/cmp-git
                }, {
                    { name = "buffer" }
                }),
            })
            -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
            cmp.setup.cmdline({ "/", "?" }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = "buffer" }
                },
            })
            -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
            cmp.setup.cmdline(":", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = "path" }
                }, {
                    { name = "cmdline" }
                }),
            })
        end,
    },
    { "tpope/vim-fugitive", lazy = true, cmd = "Git" },
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        cmd = { "LspInfo", "LspInstall", "LspUninstall" },
        dependencies = {
            "folke/neodev.nvim",
        },
    },
    {
        "folke/which-key.nvim",
        lazy = false,
        -- event = "VeryLazy",
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end,
        opts = {},
    },
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        lazy = true,
        config = function()
            require("gitsigns").setup()
        end,
    },
    {
        "tpope/vim-surround",
        lazy = true,
        keys = { "cs", "ds" },
    },
    {
        "windwp/nvim-autopairs",
        opts = {
            check_ts = true,
        },
    },
}

require("lazy").setup(lazy_plugins, lazy_opts)

-- # Key Mappings
-- ## General
vim.keymap.set("n", "<S-t>", "<cmd>tabnew<cr>")
vim.keymap.set("t", "<S-Esc>", "<C-\\><C-n>")

-- ## Telescope
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>")
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>")
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>")
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>")
vim.keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>")

-- ## NeoTree
vim.keymap.set("n", "<leader>nf", "<cmd>Neotree toggle focus filesystem left<cr>")
vim.keymap.set("n", "<leader>nb", "<cmd>Neotree toggle focus buffers right<cr>")
vim.keymap.set("n", "<leader>ng", "<cmd>Neotree float git_status<cr>")

-- # Extra Settings
-- ## Folding
vim.o.foldmethod = "expr"
vim.o.foldlevelstart = 20
vim.o.foldexpr = "nvim_treesitter#foldexpr()"

-- # LSP Configuration
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- ## Golang
require("lspconfig").gopls.setup({})

-- ## Lua
require("lspconfig").lua_ls.setup({
    capabilities = capabilities,
    settings = {
        Lua = {
            diagnostics = {
                globals = { "vim" },
            },
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
            },
            telemetry = {
                enable = false,
            },
        },
    },
})
