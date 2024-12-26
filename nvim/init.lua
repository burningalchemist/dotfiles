---@diagnostic disable: missing-fields, undefined-global

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

-- Local scoped functions
local lsp = vim.lsp

-- # NVim Settings
-- ## Global Options
vim.opt.mouse:append("a")
vim.opt.rtp:append("~/.fzf")
vim.opt.rtp:prepend(lazypath)
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.textwidth = 119
vim.opt.colorcolumn = "+1"
vim.opt.linebreak = true
vim.opt.laststatus = 3
vim.opt.cmdheight = 0
vim.opt.termguicolors = true
vim.opt.autochdir = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.smoothscroll = true
vim.opt.showmatch = false
vim.opt.sessionoptions = "buffers,curdir,folds,globals,tabpages,winpos,winsize"
vim.opt.list = false
vim.go.showcmd = true
vim.go.hlsearch = true
vim.go.incsearch = true
vim.go.inccommand = "split"
vim.go.ignorecase = true
vim.go.smartcase = true
vim.go.ruler = true
vim.go.wildmenu = true
vim.go.title = true
vim.go.listchars = "tab:▏ ,trail:▓"
--vim.go.listchars = "tab:▒░,trail:▓,nbsp:░"
vim.g.mapleader = "\\"
-- ## Window Options
vim.wo.number = true
vim.wo.relativenumber = true
vim.wo.scrolloff = 3
vim.wo.cursorline = true
-- ## Cmd Options
vim.cmd.syntax("off")


-- # Plugins
-- ## Lazy Plugin Manager Settings
local lazy_opts = {
    performance = {
        cache = { enabled = true },
        rtp = {
            reset = true, -- reset the runtime path to $VIMRUNTIME and your config directory
            disabled_plugins = {
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
                "gzip"
            },
        },
    },
    ui = {
        border = "single"
    },
    rocks = {
        enabled = false
    }
}

-- ## Lazy Plugins Configuration
local lazy_plugins = {
    {
        "rose-pine/neovim",
        name = "rose-pine"
    },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            require("catppuccin").setup({
                compile_path = vim.fn.stdpath "cache" .. "/catppuccin",
                flavour = "mocha",
                transparent_background = false,
                integrations = {
                    aerial = true,
                    cmp = true,
                    gitsigns = true,
                    neotree = true,
                    neogit = true,
                    telescope = true,
                    treesitter = true,
                    treesitter_context = true,
                    octo = true,
                    which_key = false,
                    indent_blankline = { enabled = true },
                    leap = true,
                    neotest = true,
                    diffview = true,
                    nvim_surround = true,
                    render_markdown = true
                },
            })
            vim.cmd.colorscheme("catppuccin")
        end,
    },
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        opts = {
            options = {
                theme = "catppuccin",
                icons_enabled = false,
                disabled_filetypes = { "neo-tree" },
                ignore_focus = { "neo-tree" },
                section_separators = "",
            },
            extensions = { "neo-tree", "lazy" },
            sections = {
                lualine_c = {
                    { "filename", path = 4 },
                    -- Replace LSP progress in cmdline with notifications, only keep active clients
                    -- "require('lsp-progress').progress()",
                    { function()
                        local active_clients = vim.lsp.get_clients()
                        local client_names = {}
                        for _, client in ipairs(active_clients) do
                            if client and client.name ~= "" then
                                table.insert(client_names, "[" .. client.name .. "]")
                            end
                        end
                        return #active_clients > 0 and "LSP: " .. table.concat(client_names) or ""
                    end
                    },
                }
            }
        },
    },
    { "nvim-lua/plenary.nvim",       lazy = true },
    { "nvim-tree/nvim-web-devicons", lazy = true },
    { "MunifTanjim/nui.nvim",        lazy = true },
    {
        "nvim-treesitter/nvim-treesitter-context",
        enabled = true,
        opts = {
            on_attach = function(bufnr)
                -- FIXME: For whatever reason having `nvim-treesitter-context` enabled for `rust` is constantly
                -- triggering LSP/Rust_Analyzer metadata re-indexing and so on. Let's disable it specifically for this
                -- language.
                return vim.bo[bufnr].filetype ~= 'rust'
            end
        },
        config = function(_, opts)
            require('treesitter-context').setup(opts)
        end
    },
    {
        "linrongbin16/lsp-progress.nvim",
        lazy = true,
        config = function()
            require('lsp-progress').setup({})
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = true,
        event = { "BufRead", "BufEnter" },
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
                "vue"
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
                enable = true,

                -- list of language that will be disabled
                --disable = { "c", "rust" },

                -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
                -- Using this option may slow down your editor, and you may see some duplicate highlights.
                -- Instead of true it can also be a list of languages
                additional_vim_regex_highlighting = false,
            },

            indent = { enable = true, disable = { "yaml" } },
            autopairs = { enable = true },
        },
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
            vim.treesitter.language.register("bash", "zsh")
        end,
    },
    {
        "nvim-telescope/telescope.nvim",
        lazy = true,
        branch = "0.1.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "olimorris/persisted.nvim",
            "ahmedkhalf/project.nvim"
        },
        cmd = "Telescope",
        opts = {
            defaults = {
                file_ignore_patterns = { ".git/", ".cache", "%.o", "%.a", "%.out", "%.class", "%.pdf", "%.mkv", "%.mp4", "%.zip" }
            }
        },
        config = function(_, opts)
            require("telescope").setup(opts)
            require("telescope").load_extension("neoclip")
            --    require("telescope").load_extension("persisted")
            --    require('telescope').load_extension('projects')
        end
    },
    {
        "nvim-neo-tree/neo-tree.nvim",
        lazy = true,
        cmd = "Neotree",
        branch = "v3.x",
        dependencies = {
            "mrbjarksen/neo-tree-diagnostics.nvim",
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        opts = {
            sources = {
                "filesystem",
                "buffers",
                "git_status",
                "diagnostics",
            },
            close_if_last_window = true,
            filesystem = {
                bind_to_cwd = false,
                follow_current_file = {
                    enabled = true,
                },
                window = {
                    mappings = {
                        -- disable fuzzy finder
                        ["/"] = "noop",
                        -- cd to current root
                        ["="] = {
                            function(state)
                                local path = state.path
                                vim.cmd("cd " .. path)
                                vim.notify("cd to current root: " .. path)
                            end,
                            desc = "cd to current root",
                        },
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
            "petertriho/cmp-git",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            { "hrsh7th/cmp-vsnip",      commit = "1ae05c6c867d9ad44bce811056e861e0d5c531cb" },
            { "zbirenbaum/copilot-cmp", opts = {} },
            "onsails/lspkind.nvim",
            "hrsh7th/vim-vsnip",
            "rafamadriz/friendly-snippets"
        },
        config = function()
            local cmp = require("cmp")
            local lspkind = require("lspkind")
            local cmp_git = require("cmp_git")
            cmp_git.setup()
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
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<M-Esc>"] = cmp.mapping.complete({
                        config = {
                            sources = {
                                { name = "nvim_lsp" },
                                { name = "vsnip" },
                            }
                        }
                    }),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<CR>"] = cmp.mapping.confirm(),
                    ["<C-l>"] = cmp.mapping.complete_common_string(),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "vsnip" },
                }, {
                    { name = "buffer" },
                    { name = "copilot" }
                })
            })
            -- Set configuration for specific filetype.
            cmp.setup.filetype("gitcommit", {
                sources = cmp.config.sources({
                    { name = "git" },
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
    {
        "lukas-reineke/indent-blankline.nvim",
        lazy = true,
        event = { "BufReadPost", "BufNewFile", "BufWritePre" },
        main = "ibl",
        opts = {
            indent = {
                char = "▏"
            },
            exclude = {
                filetypes = {
                    "help",
                    "alpha",
                    "dashboard",
                    "neo-tree",
                    "Trouble",
                    "trouble",
                    "lazy",
                    "mason",
                    "notify",
                    "toggleterm",
                    "lazyterm",
                }
            }
        }
    },
    {
        "NeogitOrg/neogit",
        cmd = "Neogit",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim",
            "sindrets/diffview.nvim",
        },
        config = true
    },
    {
        "sindrets/diffview.nvim",
        lazy = true,
        keys = {
            { "<leader>dd", "<cmd>DiffviewOpen<cr>",        desc = "DiffviewOpen" },
            { "<leader>dc", "<cmd>DiffviewClose<cr>",       desc = "DiffviewClose" },
            { "<leader>dh", "<cmd>DiffviewFileHistory<cr>", desc = "DiffviewFilesHistory" },
        },

    },
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        cmd = { "LspInfo", "LspInstall", "LspUninstall" },
        dependencies = {
            { "folke/neodev.nvim", opts = {} },
            "linrongbin16/lsp-progress.nvim"
        },
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end,
        opts = {}
    },
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        lazy = true,
        config = function()
            require("gitsigns").setup {
                on_attach = function(bufnr)
                    local gitsigns = require('gitsigns')

                    local function map(mode, l, r, opts)
                        opts = opts or {}
                        opts.buffer = bufnr
                        vim.keymap.set(mode, l, r, opts)
                    end

                    -- Navigation
                    map('n', ']c', function()
                        if vim.wo.diff then
                            vim.cmd.normal({ ']c', bang = true })
                        else
                            gitsigns.nav_hunk('next')
                        end
                    end)

                    map('n', '[c', function()
                        if vim.wo.diff then
                            vim.cmd.normal({ '[c', bang = true })
                        else
                            gitsigns.nav_hunk('prev')
                        end
                    end)

                    -- Actions
                    map('n', '<leader>hs', gitsigns.stage_hunk, { desc = "Stage hunk" })
                    map('n', '<leader>hr', gitsigns.reset_hunk, { desc = "Reset hunk" })
                    map('v', '<leader>hs', function() gitsigns.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
                        { desc = "Stage hunk" })
                    map('v', '<leader>hr', function() gitsigns.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
                        { desc = "Reset hunk" })
                    map('n', '<leader>hS', gitsigns.stage_buffer, { desc = "Stage buffer" })
                    map('n', '<leader>hu', gitsigns.undo_stage_hunk, { desc = "Undo stage hunk" })
                    map('n', '<leader>hR', gitsigns.reset_buffer, { desc = "Reset buffer" })
                    map('n', '<leader>hp', gitsigns.preview_hunk, { desc = "Preview hunk" })
                    map('n', '<leader>hb', function() gitsigns.blame_line { full = true } end, { desc = "Blame line" })
                    map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = "Toggle blame line" })
                    map('n', '<leader>hd', gitsigns.diffthis, { desc = "Diff this" })
                    map('n', '<leader>hD', function() gitsigns.diffthis('~') end, { desc = "Diff this (reverse)" })
                    map('n', '<leader>td', gitsigns.toggle_deleted, { desc = "Toggle deleted" })
                    map('n', '<leader>gb', gitsigns.blame, { desc = "Toggle git blame" })

                    -- Text object
                    map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
                end
            }
        end,
    },
    {
        "kylechui/nvim-surround",
        version = "*", -- Use for stability; omit to use `main` branch for the latest features
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup({
                --    keymaps = {
                --        insert          = '<C-g>z',
                --        insert_line     = 'gC-ggZ',
                --        normal          = 'gz',
                --        normal_cur      = 'gZ',
                --        normal_line     = 'gzgz',
                --        normal_cur_line = 'gZgZ',
                --        visual          = 'gz',
                --        visual_line     = 'gZ',
                --        delete          = 'gzd',
                --        change          = 'gzc',
                --    }
            })
        end
    },
    {
        "windwp/nvim-autopairs",
        lazy = true,
        event = "InsertEnter",
        opts = {
            check_ts = true,
        },
    },
    {
        "pwntester/octo.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim",
            "nvim-tree/nvim-web-devicons",
        },
        lazy = true,
        cmd = "Octo",
        opts = {
            enable_builtin = true,
        }
    },
    {
        "olimorris/persisted.nvim",
        enabled = false,
        lazy = false,
        keys = {
            { "<leader>fs", "<cmd>Telescope persisted<cr>", desc = "Telescope persisted" }
        },
        opts = {}
    },
    {
        "ahmedkhalf/project.nvim",
        enabled = false,
        lazy = false,
        keys = {
            { "<leader>fp", "<cmd>Telescope projects<cr>", desc = "Telescope projects" }
        },
        opts = {},
        config = function(_, opts)
            require("project_nvim").setup(opts)
        end
    },
    {
        'stevearc/aerial.nvim',
        opts = {},
        keys = {
            { "<leader>a", "<cmd>AerialToggle!<cr>", desc = "Toggle symbols" }
        },
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons"
        },
    },
    {
        "ggandor/leap.nvim",
        config = function()
            require("leap").add_default_mappings()
        end
    },
    {
        'mrcjkb/rustaceanvim',
        version = '^5', -- Recommended
        lazy = false,
        init = function()
            -- Configure rustaceanvim here
            vim.g.rustaceanvim = {
                tools = {
                    float_win_config = {
                        border = "single",
                    },
                },
                server = {
                    on_attach = function(_, bufnr)
                        vim.keymap.set("n", "<leader>cR", function()
                            vim.cmd.RustLsp("codeAction")
                        end, { desc = "Code Action", buffer = bufnr })
                        vim.keymap.set("n", "<leader>dr", function()
                            vim.cmd.RustLsp("debuggables")
                        end, { desc = "Rust Debuggables", buffer = bufnr })
                    end,

                    settings = {
                        ["rust-analyzer"] = {
                            cargo = {
                                allFeatures = true,
                                loadOutDirsFromCheck = true,
                                buildScripts = {
                                    enable = true,
                                },
                            },
                            -- Add clippy lints for Rust.
                            checkOnSave = true,
                            procMacro = {
                                enable = true,
                                ignored = {
                                    -- ["async-trait"] = { "async_trait" },
                                    ["napi-derive"] = { "napi" },
                                    ["async-recursion"] = { "async_recursion" },
                                },
                            },
                            -- We have to set watcher to client, otherwise it's 'Roots Scanned' loop (fseventd related)
                            files = {
                                watcher = 'client'
                            }
                        },
                    },
                    capabilities = {
                        workspace = {
                            didChangeConfiguration = {
                                dynamicRegistration = true,
                            },
                        },
                        textDocument = {
                            completion = {
                                completionItem = {
                                    snippetSupport = false,
                                },
                            }
                        },
                    },
                },
            }
        end
    },
    {
        "j-hui/fidget.nvim",
        version = "^1",
        opts = {
            notification = {
                -- Automatically override vim.notify() with Fidget
                override_vim_notify = true,
            },
        }
    },
    {
        "nvim-pack/nvim-spectre",
        opts = {
            replace_engine = {
                ["sed"] = {
                    cmd = "sed",
                    args = {
                        "-i",
                        "",
                        "-E",
                    },
                },
            },
        },
        keys = {
            { "<leader>sr", function() require("spectre").open() end, desc = "Replace in files (Spectre)" },
        },
    },
    {
        "zbirenbaum/copilot.lua",
        enabled = true,
        cmd = "Copilot",
        event = "InsertEnter",
        opts = {
            suggestion = { enabled = false },
            panel = { enabled = false },
        },
    },
    {
        "michaelrommel/nvim-silicon",
        lazy = true,
        cmd = "Silicon",
        config = function()
            require("silicon").setup({
                -- Configuration here, or leave empty to use defaults
                font = "CozetteVector",
                background = "#00000000",
                theme = "Monokai Extended"
            })
        end
    },
    {
        'MeanderingProgrammer/render-markdown.nvim',
        lazy = true,
        ft = { 'markdown', 'markdown_inline' },
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
            'nvim-tree/nvim-web-devicons'
        }
    },
    {
        "AckslD/nvim-neoclip.lua",
        lazy = true,
        keys = {
            { "<leader>fc", "<cmd>Telescope neoclip<cr>", desc = "Telescope clipboard manager" }
        },
        opts = {},
        dependencies = {
            'nvim-telescope/telescope.nvim'
        },
    },
    {
        "nvim-neotest/neotest",
        lazy = true,
        cmd = "Neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-neotest/neotest-go",
        },
        config = function()
            require("neotest").setup({
                adapters = {
                    require('neotest-go')
                },
                quickfix = {
                    open = false,
                    enabled = false,
                },
                status = {
                    enabled = true,
                    signs = true, -- Sign after function signature
                    virtual_text = false
                },
                icons = {
                    child_indent = "│",
                    child_prefix = "├",
                    collapsed = "─",
                    expanded = "╮",
                    failed = "✘",
                    final_child_indent = " ",
                    final_child_prefix = "╰",
                    non_collapsible = "─",
                    passed = "✓",
                    running = "",
                    running_animated = { "/", "|", "\\", "-", "/", "|", "\\", "-" },
                    skipped = "↓",
                    unknown = ""
                },
                floating = {
                    border = "rounded",
                    max_height = 0.9,
                    max_width = 0.9,
                    options = {}
                },
                summary = {
                    open = "botright vsplit | vertical resize 60",
                    mappings = {
                        attach = "a",
                        clear_marked = "M",
                        clear_target = "T",
                        debug = "d",
                        debug_marked = "D",
                        expand = { "<CR>", "<2-LeftMouse>" },
                        expand_all = "e",
                        jumpto = "i",
                        mark = "m",
                        next_failed = "J",
                        output = "o",
                        prev_failed = "K",
                        run = "r",
                        run_marked = "R",
                        short = "O",
                        stop = "u",
                        target = "t",
                        watch = "w"
                    },
                },
                highlights = {
                    adapter_name = "NeotestAdapterName",
                    border = "NeotestBorder",
                    dir = "NeotestDir",
                    expand_marker = "NeotestExpandMarker",
                    failed = "NeotestFailed",
                    file = "NeotestFile",
                    focused = "NeotestFocused",
                    indent = "NeotestIndent",
                    marked = "NeotestMarked",
                    namespace = "NeotestNamespace",
                    passed = "NeotestPassed",
                    running = "NeotestRunning",
                    select_win = "NeotestWinSelect",
                    skipped = "NeotestSkipped",
                    target = "NeotestTarget",
                    test = "NeotestTest",
                    unknown = "NeotestUnknown"
                }
            })
        end
    }
}

require("lazy").setup(lazy_plugins, lazy_opts)
-- # Key Mappings
-- ## General
vim.keymap.set("n", "<S-t>", "<cmd>tabnew<cr>")
vim.keymap.set("t", "<S-Esc>", "<C-\\><C-n>")
vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, { desc = "Show diagnostics in a floating window" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Move to the previous diagnostic in the buffer" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Move to the next diagnostic in the buffer" })
vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, { desc = "Add diagnostics to the location list" })

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
    local format_opts = vim.opt.formatoptions:get()
    if format_opts.t == nil then
        vim.opt.formatoptions:append("t")
        vim.print("Text auto-wrapping is enabled")
    else
        vim.opt.formatoptions:remove("t")
        vim.print("Text auto-wrapping is disabled")
    end
end, { noremap = true, desc = "Toggle auto-wrapping by textwidth" })

-- ## Telescope
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>")
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>")
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>")
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>")
vim.keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>")
vim.keymap.set("n", "<leader>fw", "<cmd>Telescope grep_string<cr>")

-- ## NeoTree
vim.keymap.set("n", "<leader>nf", "<cmd>Neotree reveal_force_cwd toggle focus filesystem left<cr>")
vim.keymap.set("n", "<leader>nb", "<cmd>Neotree reveal_force_cwd toggle focus buffers right<cr>")
vim.keymap.set("n", "<leader>ng", "<cmd>Neotree reveal float git_status<cr>")
vim.keymap.set("n", "<leader>nd", "<cmd>Neotree reveal toggle diagnostics bottom<cr>")


-- # Extra Settings

-- ## Diagnostics
vim.diagnostic.config {
    --    virtual_text = false,
    --    virtual_lines = false,
    --    update_in_insert = true,
    float = {
        -- UI
        border = 'single',
        focusable = true
    }
}
-- ## Folding
vim.o.foldmethod = "expr"
vim.o.foldlevelstart = 20
vim.o.foldexpr = "nvim_treesitter#foldexpr()"

-- ## Autocommands
-- ### Show the break character if `number` option is enabled
vim.api.nvim_create_autocmd("OptionSet", {
    pattern = "number",
    command = "if v:option_new | set showbreak= | else | set showbreak=↪ | endif",
})

-- ### Set formatoptions to adjust comment formatting and wrapping, enable auto-wrapping on textwidth
vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        vim.opt.formatoptions = vim.opt.formatoptions - { "c", "r", "o", "t" }
    end
})

-- ### Fix weird yaml indent shifts
vim.api.nvim_create_autocmd("Filetype", {
    pattern = "yaml",
    command = "setlocal indentexpr=",
})

-- ### Set gitcommit filetype for Neogit to enable cmp-git
vim.api.nvim_create_augroup("neogit", {})
vim.api.nvim_create_autocmd("FileType", {
    group = "neogit",
    pattern = "NeogitCommitMessage",
    command = "silent! set filetype=gitcommit",
})

-- ### Open Neotree when Nvim started with a directory argument
vim.api.nvim_create_augroup("neotree", {})
vim.api.nvim_create_autocmd("UiEnter", {
    desc = "Open Neotree automatically",
    group = "neotree",
    callback = function()
        local stats = vim.loop.fs_stat(vim.api.nvim_buf_get_name(0))
        if stats and stats.type == "directory" then require("neo-tree.setup.netrw").hijack() end
    end,
})

-- ### Use LspAttach autocommand to only map the following keys after the language server attaches to the current
-- buffer
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = function(desc)
            return { buffer = ev.buf, desc = desc }
        end
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts("Jump to the symbol declaration"))
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts("Jump to the symbol definition"))
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts("Display info about the symbol"))
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts("List symbol implementations"))
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts("Jump to the type definition of the symbol"))
        vim.keymap.set('n', '<space>d', vim.lsp.buf.definition, opts("Jump to the symbol definition"))
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts("Rename all references of the symbol"))
        vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts("Select an available code action"))
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts("Show all references to the symbol in quickfix list"))
        vim.keymap.set('n', '<space>f', function()
            vim.lsp.buf.format { async = true }
        end, opts("Format code with the attached language"))
        vim.keymap.set('i', '<C-s>', vim.lsp.buf.signature_help, opts("Show the signature help for the symbol"))
    end,
})


-- # LSP Configuration
-- ## Common
local capabilities = require("cmp_nvim_lsp").default_capabilities()
-- Disable hover in favor of Pyright
--local pyright_on_attach = function(client, bufnr)
--    client.server_capabilities.hoverProvider = false
--end
-- Configure borders for LspInfo
require('lspconfig.ui.windows').default_options.border = 'single'
-- -- Configure LPS Handlers
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'single', max_width = 100 })
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help,
    { title = 'Signature', border = 'single', max_width = 100 })

lsp.inlay_hint.enable()

-- ## Golang
require("lspconfig").gopls.setup({
    capabilities = capabilities,
    settings = {
        gopls = {
            hints = {
                compositeLiteralFields = true,
                constantValues = true,
                parameterNames = true,
                assignedVariables = true,

            },
            staticcheck = true,
            gofumpt = true,
        },
    },
})

-- ## Typescript
--local vue_language_server_path = '/Users/sergei/Library/pnpm/global/5/node_modules/@vue/language-server'
require("lspconfig").ts_ls.setup({
    capabilities = capabilities,
    filetypes = {
        'typescript',
        'javascript',
    },
})


require("lspconfig").volar.setup {
    capabilities = capabilities,
    filetypes = { 'typescript', 'javascript', 'vue' },
    init_options = {
        typescript = {
            tsdk = "/Users/sergei/Library/pnpm/global/5/node_modules/typescript/lib",
        },
        vue = {
            -- hybridMode currently doesn't work well when it comes to using DocumentSymbols with tsserver, or should
            -- be configured better
            hybridMode = false,
        }
    }
}

-- ## Python
require("lspconfig").ruff.setup({
    capabilities = capabilities,
    on_attach = function(client)
        client.server_capabilities.hoverProvider = false
    end
})
require("lspconfig").pyright.setup({
    capabilities = capabilities
})

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
                -- https://github.com/LuaLS/lua-language-server/pull/2406
                checkThirdParty = "Disable",
            },
            telemetry = {
                enable = false,
            },
        },
    },
})
