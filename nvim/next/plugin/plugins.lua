-- This file can be loaded by calling `lua require("plugins")` from your init.vim

vim.pack.add({
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/MunifTanjim/nui.nvim",
    "https://github.com/nvim-tree/nvim-web-devicons",
    "https://github.com/kylechui/nvim-surround",
    "https://github.com/stevearc/aerial.nvim",
    "https://github.com/esmuellert/codediff.nvim",
    "https://github.com/neogitOrg/neogit",
    "https://github.com/folke/which-key.nvim",
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/nvim-telescope/telescope.nvim",
    "https://github.com/AckslD/nvim-neoclip.lua",
    "https://github.com/lewis6991/gitsigns.nvim",
    "https://github.com/j-hui/fidget.nvim",
    "https://github.com/neovim/nvim-lspconfig",
    "https://codeberg.org/andyg/leap.nvim",
    "https://github.com/nvim-pack/nvim-spectre",
    "https://github.com/CopilotC-Nvim/CopilotChat.nvim",
    "https://github.com/MeanderingProgrammer/render-markdown.nvim",
    "https://github.com/hat0uma/csvview.nvim",
    "https://github.com/catppuccin/nvim",
    "https://github.com/rose-pine/neovim",
    "https://github.com/mrbjarksen/neo-tree-diagnostics.nvim",
    "https://github.com/nvim-neo-tree/neo-tree.nvim",
    "https://github.com/zbirenbaum/copilot.lua",
    "https://github.com/fang2hou/blink-copilot",
    "https://github.com/Kaiser-Yang/blink-cmp-git",
    "https://github.com/nvim-lualine/lualine.nvim",
    { src = 'https://github.com/Saghen/blink.cmp', version = vim.version.range('*') }
})


-- Catppuccin theme
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
        codediff = true,
        nvim_surround = true,
        render_markdown = true
    },
})
-- Catppuccin Theme
vim.cmd.colorscheme("catppuccin-nvim")

-- Treesitter
vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
        local name, kind = ev.data.spec.name, ev.data.kind
        if name == 'nvim-treesitter' and kind == 'update' then
            if not ev.data.active then vim.cmd.packadd('nvim-treesitter') end
            vim.cmd('TSUpdate')
        end
        if name == 'copilotchat' and kind == 'update' then
            if not ev.data.active then vim.cmd.packadd('copilotchat') end
            vim.cmd('make tiktoken')
        end
    end
})


require("telescope").setup({
    defaults = {
        file_ignore_patterns = {
            ".git/",
            ".cache",
            "%.o",
            "%.a",
            "%.out",
            "%.class",
            "%.pdf",
            "%.mkv",
            "%.mp4",
            "%.zip"
        }
    }
}
)

require("neo-tree").setup({
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
})

require("copilot").setup({
    suggestion = { enabled = false },
    panel = { enabled = true },
    copilot_model = "gpt-41-copilot"
})

-- Lazy load on first insert mode entry (may not necessary)
local group = vim.api.nvim_create_augroup("BlinkCmpLazyLoad", { clear = true })
vim.api.nvim_create_autocmd("InsertEnter", {
    pattern = "*",
    group = group,
    once = true,
    callback = function()
        require("blink.cmp").setup({
            --            keymap = { preset = "default" },
            appearance = {
                nerd_font_variant = "mono",
                use_nvim_cmp_as_default = true,
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
    end,
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
        map('n', '<leader>gb', gitsigns.blame, { desc = "Toggle git blame" })

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
    end
})

require("fidget").setup({
    notification = {
        -- Automatically override vim.notify() with Fidget
        override_vim_notify = true,
    },
})

require('leap').opts.preview = function(ch0, ch1, ch2)
    return not (
        ch1:match('%s')
        or (ch0:match('%a') and ch1:match('%a') and ch2:match('%a'))
    )
end
require('leap').opts.equivalence_classes = {
    ' \t\r\n', '([{', ')]}', '\'"`'
}

require("lualine").setup({
    options = {
        theme = "catppuccin-nvim",
        icons_enabled = false,
        disabled_filetypes = { "neo-tree" },
        ignore_focus = { "neo-tree" },
        section_separators = "",
    },
    extensions = { "neo-tree", "lazy" },
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

-- Make it load for markdown docs only
require("render-markdown").setup({
    yaml = { enabled = false },
})

require("csvview").setup({
    parser = { comments = { "#", "//" } },
    view = {
        max_col_width = 50,
        min_col_width = 8,
        auto_resize = true,
        display_mode = "border",
    },
    keymaps = {
        -- Text objects for selecting fields
        textobject_field_inner = { "if", mode = { "o", "x" } },
        textobject_field_outer = { "af", mode = { "o", "x" } },
        -- Excel-like navigation:
        -- Use <Tab> and <S-Tab> to move horizontally between fields.
        -- Use <Enter> and <S-Enter> to move vertically between rows and place the cursor at the end of the field.
        -- Note: In terminals, you may need to enable CSI-u mode to use <S-Tab> and <S-Enter>.
        jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
        jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
        jump_next_row = { "<Enter>", mode = { "n", "v" } },
        jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
    },
})

require("spectre").setup({
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
})

require("CopilotChat").setup({
    model = "claude-sonnet-4.6",
})

require('neoclip').setup()
