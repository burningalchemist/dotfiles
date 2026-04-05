---@diagnostic disable: missing-fields, undefined-global

-- (!) Magic Optimizer
vim.loader.enable()
require('vim._core.ui2').enable({ {
    enable = true,
    msg = {
        target = "msg",
    }
} })

-- # Local scoped functions
local lsp = vim.lsp
-- # NVim Settings
-- ## Global Options
vim.opt.mouse:append("a")
vim.opt.rtp:append("~/.fzf")
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
vim.opt.iskeyword:append({ '-' })
vim.opt.list = false
vim.opt.signcolumn = "yes"
vim.opt.fixeol = false
vim.opt.fillchars = "foldopen:,foldclose:,fold: ,foldsep: ,eob:~,diff:╱"
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
vim.o.winborder = "rounded"
vim.o.diffopt = "internal,filler,closeoff,algorithm:patience,indent-heuristic,linematch:40"
vim.o.undofile = true
vim.o.conceallevel = 2
-- ## Cmd Options
vim.cmd.syntax("off")
-- Enable Undotree
vim.cmd("packadd nvim.undotree")

-- # Key Mappings
-- ## General
vim.keymap.set("n", "<S-t>", "<cmd>tabnew<cr>")
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")
vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, { desc = "Show diagnostics in a floating window" })
vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = 1 }) end,
    { desc = "Move to the previous diagnostic in the buffer" })
vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = -1 }) end,
    { desc = "Move to the next diagnostic in the buffer" })
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
vim.keymap.set("n", "<leader>ff", "<Plug>(artio-smart)", { desc = "Smart file picker" })
vim.keymap.set("n", "<leader>fh", "<Plug>(artio-helptags)", { desc = "Tags" })
vim.keymap.set("n", "<leader>fb", "<Plug>(artio-buffers)", { desc = "Buffers" })
vim.keymap.set("n", "<leader>f/", "<Plug>(artio-buffergrep)", { desc = "Grep in open buffers" })
vim.keymap.set("n", "<leader>fr", "<Plug>(artio-oldfiles)", { desc = "Recent files" })
vim.keymap.set("n", "<leader>fd", "<Plug>(artio-diagnostics-buffer)", { desc = "Diagnostics for buffer" })
-- ## Artio Custom Pickers
vim.keymap.set("n", "<leader>gd", function() require('artio_lsp').definitions() end, { desc = "LSP Definitions" })
vim.keymap.set("n", "<leader>gr", function() require('artio_lsp').references() end, { desc = "LSP References" })

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


-- # Extra Settings
-- ## Diagnostics
vim.diagnostic.config {
    --    virtual_text = false,
    --    update_in_insert = true,
    float = {
        -- UI
        border = "single",
        focusable = true
    },
    jump = {
        on_jump = function()
            vim.diagnostic.open_float({ border = "single", focusable = true })
        end
    },

    virtual_lines = {
        current_line = true,
        severity = { min = vim.diagnostic.severity.WARN },
        format = function(diagnostic)
            return string.format("%s: %s", diagnostic.source, diagnostic.message)
        end
    }
}

-- ## Folding
vim.o.foldenable = true
vim.o.foldcolumn = "0"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"

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

vim.api.nvim_create_autocmd("RecordingEnter", {
    callback = function(ctx)
        vim.opt.cmdheight = 1
        local msg = string.format("Key:  %s\nFile: %s", vim.fn.reg_recording(), ctx.file)
        vim.notify(msg, vim.log.levels.INFO, {
            annote = "Recording"
        })
    end
})

vim.api.nvim_create_autocmd("RecordingLeave", {
    callback = function()
        vim.opt.cmdheight = 0
    end
})

-- ### Fix weird yaml indent shifts
vim.api.nvim_create_autocmd("FileType", {
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
vim.api.nvim_create_autocmd("UIEnter", {
    desc = "Open Neotree automatically",
    group = "neotree",
    callback = function()
        local stats = vim.uv.fs_stat(vim.api.nvim_buf_get_name(0))
        if stats and stats.type == "directory" then require("neo-tree.setup.netrw").hijack() end
    end,
})

-- ### Use LspAttach autocommand to only map the following keys after the language server attaches to the current
--     buffer
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
        vim.keymap.set('n', 'K', function() vim.lsp.buf.hover({ max_width = 100 }) end,
            opts("Display info about the symbol"))
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts("List symbol implementations"))
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts("Jump to the type definition of the symbol"))
        vim.keymap.set('n', '<space>d', vim.lsp.buf.definition, opts("Jump to the symbol definition"))
        vim.keymap.set('n', '<space>rn', LspRename, opts("Rename all references of the symbol"))
        vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts("Select an available code action"))
        --        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts("Show all references to the symbol in quickfix list"))
        vim.keymap.set('n', '<space>f', function()
            vim.lsp.buf.format { async = true }
        end, opts("Format code with the attached language"))
        vim.keymap.set('i', '<C-s>',
            function() vim.lsp.buf.signature_help({ title = 'Signature', max_width = 100 }) end,
            opts("Show the signature help for the symbol"))
    end,
})

-- ## Disable line wrapping in markdown files
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown", "markdown_inline" },
    callback = function()
        vim.opt_local.wrap = false
    end,
})

-- ## Stop Copilot LSP on exit to prevent potential issues with hanging processes
vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
        require("copilot.client").teardown()
    end,
    desc = "Stop Copilot LSP on exit",
})

-- ## Zoom in the split under the cursor when it's focused using Ctrl-W z, then zoom out when the same key combination is used again
vim.api.nvim_create_autocmd("WinEnter", {
    callback = function()
        if vim.fn.winnr('$') == 1 then
            vim.cmd("wincmd z")
        end
    end,
    desc = "Zoom in the split under the cursor when it's focused",
})



-- # LSP Configuration
-- ## Common
lsp.enable({
    "lua_ls",
    "gopls",
    "ts_ls",
    "vue_ls",
    "basedpyright",
    "ruff",
    "zls"
})

lsp.inlay_hint.enable()

lsp.config('*', {
    capabilities = capabilities
})

-- ## Lua
lsp.config.lua_ls = {
    settings = {
        Lua = {
            version = "LuaJIT",
            path = {
                'lua/?.lua',
                'lua/?/init.lua'
            },
            diagnostics = {
                globals = { "vim" },
            },
            workspace = {
                checkThirdParty = false,
                library = {
                    vim.env.VIMRUNTIME,
                    '${3rd}/luv/library'
                },
            },
            telemetry = {
                enable = false,
            },
        },
    },
}

-- ## Golang
lsp.config.gopls = {
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
            semanticTokens = true
        },
    }
}

-- ## VueJS
lsp.config.vue_ls = {
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
lsp.config.basedpyright = {
    settings = {
        basedpyright = {
            analysis = {
                diagnosticMode = 'openFilesOnly',
                typeCheckingMode = 'basic',
                useLibraryCodeForTypes = true,
                diagnosticSeverityOverrides = {
                    autoSearchPaths = true,
                    enableTypeIgnoreComments = false,
                    reportGeneralTypeIssues = 'none',
                    reportArgumentType = 'none',
                    reportUnknownMemberType = 'none',
                    reportAssignmentType = 'none',
                    reportAttributeAccessIssue = 'none'
                },
            },
        },
    },
}

-- ## Zig
lsp.config.zls = {
    settings = {
        zig = {
            semanticTokens = 'partial',
        },
    },
}

-- # Custom functions
-- ## Float input prompt
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

-- ## Float Window Rename
function LspRename()
    local curr = vim.fn.expand("<cword>")
    float_input({ prompt = " Rename symbol › ", default = curr }, function(new_name)
        if not new_name or new_name == "" or new_name == curr then return end

        local client = lsp.get_clients({ bufnr = 0 })[1]
        if not client then return end
        local enc = client.offset_encoding or "utf-16"
        local params = {
            textDocument = vim.lsp.util.make_text_document_params(0),
            position = vim.lsp.util.make_position_params(0, enc).position,
            newName = new_name,
        }
        vim.lsp.buf_request(0, "textDocument/rename", params, function(err, res)
            if err or not res then return end
            vim.lsp.util.apply_workspace_edit(res, client.offset_encoding)
            local n, f = count(res)
            vim.notify(string.format(
                "%d occurrence%s renamed in %d file%s%s",
                n,
                n == 1 and "" or "s",
                f,
                f == 1 and "" or "s",
                f > 0 and ".  :wa to save" or ""
            ))
        end)
    end)
end
