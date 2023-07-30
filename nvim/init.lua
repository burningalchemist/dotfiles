-- # LazyVIM Init
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system(
    { "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git",
      "--branch=stable",
      lazypath })
end

-- # NVim Settings

-- ## General Options
vim.opt.syntax = "off"
vim.opt.mouse:append("a")
vim.opt.rtp:append("~/.fzf")
vim.opt.rtp:prepend(lazypath)
vim.opt.expandtab = true
vim.opt.colorcolumn = "120"

-- ## Global Options
vim.go.showcmd = true
vim.go.hlsearch = true
vim.go.showmatch = true
vim.go.ignorecase = true
vim.go.smartcase = true
vim.go.ruler = true
vim.go.wildmenu = true
vim.go.title = true
vim.go.incommand = "split"
vim.go.splitbelow = "splitright"
vim.g.mapleader = "\\"

-- ## Window Options
vim.wo.number = true
vim.wo.relativenumber = true
vim.wo.scrolloff = 3
vim.wo.cursorline = true
vim.wo.list = true
vim.wo.listchars = "tab:▒░,trail:▓,nbsp:░"

-- ## Autocommands
vim.api.nvim_create_autocmd("OptionSet", {
  pattern = "number",
  command = "if v:option_new | set showbreak= | else | set showbreak=↪ | endif"
})

-- ### Fix weird yaml indent shifts
vim.api.nvim_create_autocmd("Filetype", {
  pattern = "yaml",
  command = "setlocal indentexpr="
})

-- # Plugins

-- ## Plugin List (via LazyVIM)
require("lazy").setup({
  { "catppuccin/nvim", name = "catppuccin" },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate"},
  { "nvim-lualine/lualine.nvim",
        dependencies = {
                "nvim-tree/nvim-web-devicons"
        }
  },
  { "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = {
                "nvim-lua/plenary.nvim",
                "nvim-telescope/telescope-file-browser.nvim",
                "nvim-telescope/telescope-github.nvim"
        }
  },
  { "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
                "nvim-lua/plenary.nvim",
                "nvim-tree/nvim-web-devicons",
                "MunifTanjim/nui.nvim"
        }
  },
  { "junegunn/fzf", build = "fzf#install()"},
  { "hrsh7th/nvim-cmp",
        dependencies = {
                "hrsh7th/cmp-nvim-lsp",
                "hrsh7th/cmp-nvim-lua",
                "hrsh7th/cmp-buffer",
                "hrsh7th/cmp-path",
                "hrsh7th/cmp-cmdline",
                "hrsh7th/cmp-vsnip",
                "hrsh7th/vim-vsnip",
                "folke/neodev.nvim",
        }
  },
  "junegunn/fzf.vim",
  "tpope/vim-fugitive",
  "junegunn/gv.vim",
  "neovim/nvim-lspconfig",
  "folke/which-key.nvim",
  "lewis6991/gitsigns.nvim",
})

-- ## TreeSitter Config
function TreeSitterConfig()
  require 'nvim-treesitter.configs'.setup {
    -- This line exists just to please Lua Language Server
    modules = {},
    -- One of "all", "maintained" (parsers with maintainers), or a list of languages
    ensure_installed = { "yaml", "hcl", "terraform", "dockerfile" },

    -- Install languages synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- Automatically install missing parsers when entering buffer
    -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
    auto_install = true,

    -- List of parsers to ignore installing
    ignore_install = { "javascript" },

    highlight = {
      -- `false` will disable the whole extension
      enable = true,

      -- list of language that will be disabled
      disable = { "c", "rust" },

      -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
      -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
      -- Using this option may slow down your editor, and you may see some duplicate highlights.
      -- Instead of true it can also be a list of languages
      additional_vim_regex_highlighting = false
    },

    indent = {
      disable = { 'yaml' }
    }
  }
end

TreeSitterConfig()

-- # Key Mappings
-- ## General
vim.keymap.set('n', '<S-t>', '<cmd>tabnew<cr>')
vim.keymap.set('t', '<S-Esc>', '<C-\\><C-n>')

-- ## Telescope
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>')
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>')
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<cr>')
vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<cr>')

-- ## NeoTree
vim.keymap.set('n', '<leader>nf', '<cmd>Neotree toggle focus filesystem left<cr>')
vim.keymap.set('n', '<leader>nb', '<cmd>Neotree toggle focus buffers right<cr>')
vim.keymap.set('n', '<leader>ng', '<cmd>Neotree float git_status<cr>')

vim.cmd.colorscheme('catppuccin')

-- # Extra Settings
-- ## Folding
vim.o.foldmethod = "expr"
vim.o.foldlevelstart = 20
vim.o.foldexpr = "nvim_treesitter#foldexpr()"

-- ## Plugin Auto Settings
require("which-key").setup()
require("gitsigns").setup()

-- ## Lualine Config
require("lualine").setup({
  options = {
          theme = "auto",
          icons_enabled = false,
          disabled_filetypes = { "neo-tree" },
          ignore_focus = { "neo-tree" },
          globalstatus = true,
        },
        winbar = {
             lualine_a = {},
             lualine_b = {},
             lualine_c = {{'filename', path = 1, file_status = true }},
             lualine_x = {},
             lualine_y = {},
             lualine_z = {}
           },
        inactive_winbar = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = {{'filename', path = 1, file_status = true }},
            lualine_x = {},
            lualine_y = {},
            lualine_z = {}
        }
})

-- ## NVim Completion (via nvim-cmp)
local cmp = require 'cmp'

cmp.setup({
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end
    },
    window = {
        -- completion = cmp.config.window.bordered(),
        -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-`>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({
            select = true
        }) -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({{
        name = 'nvim_lsp'
    }, {
        name = 'vsnip'
    }}, {{
        name = 'buffer'
    }})
})


-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({{
        name = 'git'
    } -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
    }, {{
        name = 'buffer'
    }})
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({'/', '?'}, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {{
        name = 'buffer'
    }}
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({{
        name = 'path'
    }}, {{
        name = 'cmdline'
    }})
})

-- # LSP Configuration

local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- ## Golang
require'lspconfig'.gopls.setup {}

-- ## Lua
require'lspconfig'.lua_ls.setup {
    capabilities = capabilities,
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT'
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = {'vim'}
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false
            }
        }
    }
}
