-- This file can be loaded by calling `lua require("plugins")` from your init.vim
vim.pack.add({
    { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },

    "https://github.com/nvim-mini/mini.misc",
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/MunifTanjim/nui.nvim",
    "https://github.com/nvim-tree/nvim-web-devicons",
    "https://github.com/nvim-mini/mini.icons",
    "https://github.com/j-hui/fidget.nvim",
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/nvim-treesitter/nvim-treesitter",

    "https://github.com/nvim-lualine/lualine.nvim",
    "https://codeberg.org/comfysage/artio.nvim",
    "https://github.com/nvim-neo-tree/neo-tree.nvim",
    "https://github.com/esmuellert/codediff.nvim",
    "https://github.com/lewis6991/gitsigns.nvim",
})

-- Load Misc early for utility functions and event handling
local misc = require('mini.misc')
local later = function(f) misc.safely('later', f) end
local on_event = function(ev, f) misc.safely('event:' .. ev, f) end


-- Catppuccin theme
require("catppuccin").setup({
    compile_path = vim.fn.stdpath "cache" .. "/catppuccin",
    flavour = "mocha",
    transparent_background = false,
    integrations = {
        aerial = true,
        treesitter = true,
        treesitter_context = true,
        octo = true,
        which_key = true,
        leap = true,
        neotest = true,
        codediff = true,
        nvim_surround = true,
        snacks = true,
        fidget = true,

    },
})
vim.cmd.colorscheme("catppuccin-nvim")

require("fidget").setup({
    notification = {
        -- Automatically override vim.notify() with Fidget
        override_vim_notify = true,
    },
})

require("lualine").setup({
    options = {
        theme = "catppuccin-nvim",
        icons_enabled = false,
        disabled_filetypes = { "neo-tree" },
        ignore_focus = { "neo-tree" },
        section_separators = "",
    },
    sections = {
        lualine_c = {
            { "filename", path = 4 },
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
})

require("gitsigns").setup({
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
        map('n', '<leader>hR', gitsigns.reset_buffer, { desc = "Reset buffer" })
        map('n', '<leader>hp', gitsigns.preview_hunk, { desc = "Preview hunk" })
        map('n', '<leader>hb', function() gitsigns.blame_line { full = true } end, { desc = "Blame line" })
        map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = "Toggle blame line" })
        map('n', '<leader>hd', gitsigns.diffthis, { desc = "Diff this" })
        map('n', '<leader>hD', function() gitsigns.diffthis('~') end, { desc = "Diff this (reverse)" })
        map('n', '<leader>hw', gitsigns.preview_hunk_inline, { desc = "Preview hunk inline" })
        map('n', '<leader>gb', gitsigns.blame, { desc = "Open git blame" })

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
    end
})

require("neo-tree").setup({
    sources = {
        "filesystem",
        "buffers",
        "git_status",
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
})



-- ## Load the rest  of the plugins after startup to improve startup time
later(function()
    vim.pack.add({
        "https://github.com/rose-pine/neovim",
        "https://github.com/neogitOrg/neogit",
        "https://github.com/kylechui/nvim-surround",
        "https://github.com/AckslD/nvim-neoclip.lua",
        "https://github.com/stevearc/aerial.nvim",
        "https://github.com/MeanderingProgrammer/render-markdown.nvim",
        "https://codeberg.org/andyg/leap.nvim",
        "https://github.com/folke/which-key.nvim",
        "https://github.com/hat0uma/csvview.nvim",
        "https://github.com/stevearc/oil.nvim",
    })

    require("mini.icons").setup()
    require("artio").setup({
        opts = {
            preselect = true, -- whether to preselect the first match
            bottom = true, -- whether to draw the prompt at the bottom
            shrink = true, -- whether the window should shrink to fit the matches
            promptprefix = "", -- prefix for the prompt
            prompt_title = true, -- whether to draw the prompt title
            pointer = "", -- pointer for the selected match
            marker = "│", -- prefix for marked items
            infolist = { "list" }, -- index: [1] list: (4/5)
            use_icons = true, -- requires mini.icons
        },
        win = {
            height = 12,
            hidestatusline = false, -- works best with laststatus=3
        },
        -- NOTE: if you override the mappings, make sure to provide keys for all actions
        mappings = {
            ["<down>"] = "down",
            ["<up>"] = "up",
            ["<cr>"] = "accept",
            ["<esc>"] = "cancel",
            ["<tab>"] = "mark",
            ["<c-g>"] = "togglelive",
            ["<c-l>"] = "togglepreview",
            ["<c-q>"] = "setqflist",
            ["<m-q>"] = "setqflistmark",
        },
    })
    -- Use Artio for UI select and input
    vim.ui.select = require("artio").select


    -- Make it load for markdown docs only
    require("render-markdown").setup({
        yaml = { enabled = false },
        latex = { enabled = false },
    })

    require("csvview").setup({
        parser = {
            delimiter = {
                ft = {},
            },
        },

        view = {
            min_col_width = 8,
            display_mode = "border",
        },
    })


    require('neoclip').setup()

    require('leap').opts.preview = function(ch0, ch1, ch2)
        return not (
            ch1:match('%s')
            or (ch0:match('%a') and ch1:match('%a') and ch2:match('%a'))
        )
    end
    require('leap').opts.equivalence_classes = {
        ' \t\r\n', '([{', ')]}', '\'"`'
    }

    require('aerial').setup({
        on_attach = function(bufnr)
            -- Jump forwards/backwards with '{' and '}'
            vim.keymap.set("n", "(", "<cmd>AerialPrev<CR>", { buffer = bufnr })
            vim.keymap.set("n", ")", "<cmd>AerialNext<CR>", { buffer = bufnr })
        end,
    })

    require("oil").setup({
        default_file_explorer = false,
        delete_to_trash = true,
        skip_confirm_for_simple_edits = false,
        columns = { 'icon', 'permissions', 'size' },
        view_options = {
            show_hidden = true,
            is_always_hidden = function(name, _)
                return name == '..' or name == '.git'
            end,
        },
        win_options = {
            signcolumn = "yes",
            foldcolumn = "0",
            conceallevel = 3,
            concealcursor = "nvic",
        },
        watch_for_changes = true,
        use_default_keymaps = true,
    })
end)

on_event("InsertEnter", function()
    vim.pack.add({
        "https://github.com/zbirenbaum/copilot.lua",
        "https://github.com/CopilotC-Nvim/CopilotChat.nvim",
        "https://github.com/fang2hou/blink-copilot",
        "https://github.com/Kaiser-Yang/blink-cmp-git",
        {
            src = 'https://github.com/Saghen/blink.cmp',
            version = vim.version.range('*')
        },
    })
    require("copilot").setup({
        suggestion = { enabled = false },
        panel = { enabled = true },
        copilot_model = "gpt-41-copilot"
    })
    require("blink.cmp").setup({
        keymap = {
            preset = "default",
            ['<M-Esc>'] = { 'show', 'show_documentation', 'hide_documentation' },
            ['C-CR>'] = { 'select_and_accept', 'fallback' },
            ['<C-Space>'] = false,
            ['<C-y>'] = false,
        },
        appearance = {
            nerd_font_variant = "mono",
        },
        completion = {
            documentation = { auto_show = false },
        },
        sources = {
            default = { "git", "lsp", "path", "snippets", "buffer", "copilot" },
            providers = {
                copilot = {
                    name = "copilot",
                    module = "blink-copilot",
                    score_offset = 100,
                    async = true,
                },
                git = {
                    module = 'blink-cmp-git',
                    enabled = function()
                        return vim.tbl_contains({ 'octo', 'gitcommit', 'markdown' }, vim.bo.filetype)
                    end,
                    name = 'Git',
                    opts = {
                        -- options for the blink-cmp-git
                    },
                },
            }
        },
        fuzzy = { implementation = "prefer_rust_with_warning" },
    })
    require("CopilotChat").setup({
        model = "claude-sonnet-4.6",
    })
end)

-- Neotest is a bit special because we want it to load only for test files or when explicitly triggered.
local function setup_neotest()
    -- Using package.loaded check because safely() ensures 'f' runs only once,
    -- but it's good practice if this function is ever called manually.
    if package.loaded['neotest'] then return end

    -- Add to runtimepath via vim.pack
    vim.pack.add({
        { src = 'https://github.com/nvim-neotest/neotest' },
        { src = 'https://github.com/nvim-neotest/nvim-nio' },
        { src = 'https://github.com/nvim-lua/plenary.nvim' },
        { src = 'https://github.com/antoinemadec/FixCursorHold.nvim' },
        { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
        -- Add your specific adapters here
        { src = 'https://github.com/fredrikaverpil/neotest-golang' },
    })

    -- Refresh runtimepath so require() finds the new modules
    vim.cmd('packloadall')

    require('neotest').setup({
        adapters = {
            require('neotest-golang')({
                root_files = { "go.mod", ".git" }
            }),
        },
        discovery = {
            enabled = true,
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

    vim.schedule(function()
        vim.cmd('doautocmd BufRead')
    end)
end

-- Trigger A: For languages with built-in testing (like Go)
-- This fires as soon as a .go file is opened and handles ftdetect.
misc.safely('filetype:go', setup_neotest)

-- Trigger B: For specific test file patterns (the "necessary files")
-- Fires when opening files matching common test naming conventions.
misc.safely('event:BufReadPost~*_test.go,test_*.py,*.spec.*,*.test.*', setup_neotest)

-- In case we need it in a file that doesn't match the triggers above.
vim.keymap.set('n', '<leader>tn', function()
    -- We call setup_neotest() here; if safely() already ran it,
    -- our package.loaded check prevents a double setup.
    setup_neotest()
    require('neotest').run.run()
end, { desc = 'Run nearest test (Manual/Lazy)' })

vim.keymap.set('n', '<leader>ts', function()
    setup_neotest()
    require('neotest').summary.toggle()
end, { desc = 'Toggle Test Summary' })

local group = vim.api.nvim_create_augroup("NeotestConfig", {})
vim.api.nvim_create_autocmd("FileType", {
    pattern = "neotest-output",
    group = group,
    callback = function(opts)
        vim.keymap.set("n", "q", function()
            pcall(vim.api.nvim_win_close, 0, true)
        end, {
            buffer = opts.buf,
        })
    end,
})

--        'mrcjkb/rustaceanvim',
--        version = '^6', -- Recommended
--        lazy = false,
--        init = function()
--            -- Configure rustaceanvim here
--        end
--    },

local function setup_rustaceanvim()
    if package.loaded['rustaceanvim'] then return end

    -- Add to runtimepath via vim.pack
    vim.pack.add { {
        src = 'https://github.com/mrcjkb/rustaceanvim',
        version = vim.version.range('^9')
    } }
   
    -- Refresh runtimepath so require() finds the new modules
    vim.cmd('packloadall')
 
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

misc.safely('filetype:rust', setup_rustaceanvim)
