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
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if not client then return end

        -- Check if blink.cmp is loaded, if not try to load it. If loading fails, notify the user and exit the
        -- callback.
        if not package.loaded['blink.cmp'] then
            local success, _ = pcall(vim.pack.add,
                { 'https://github.com/saghen/blink.lib', 'https://github.com/saghen/blink.cmp' })
            if not success then
                vim.notify("Failed to load blink.cmp for LSP capabilities", vim.log.levels.ERROR)
                return
            end
        end
        local my_caps = require('blink.cmp').get_lsp_capabilities()

        -- 2. Safely merge capabilities
        client.capabilities = vim.tbl_deep_extend('force', client.capabilities or {}, my_caps)


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
        local clients = vim.lsp.get_clients({ name = "copilot" })

        for _, client in ipairs(clients) do
            client.stop(client, true)
        end

        local copilot_client = package.loaded["copilot.client"]
        if copilot_client and type(copilot_client.teardown) == "function" then
            pcall(copilot_client.teardown)
        end
    end,
    desc = "Graceful Copilot teardown",
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


-- Package Updates with rebuilds
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

-- Make TS install a parser for each new filetype. To only use specific filetypes change pattern to a list of preferred
-- filetypes (not languages).
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "*" },
    callback = function(args)
        local ft = vim.bo[args.buf].filetype
        local lang = vim.treesitter.language.get_lang(ft)

        -- Check if nvim-treesitter is loaded, if not try to load it. If loading fails, notify the user and exit the
        -- callback.
        if not package.loaded['nvim-treesitter'] then
            local success, _ = pcall(vim.pack.add, { 'https://github.com/nvim-treesitter/nvim-treesitter' })
            if not success then
                vim.notify("Failed to load nvim-treesitter", vim.log.levels.ERROR)
                return
            end
        end

        if lang ~= nil and not vim.treesitter.language.add(lang) then
            local available = vim.g.ts_available
                or require("nvim-treesitter").get_available()
            if not vim.g.ts_available then
                vim.g.ts_available = available
            end
            if vim.tbl_contains(available, lang) then
                require("nvim-treesitter").install(lang)
            end
        end

        if lang ~= nil and vim.treesitter.language.add(lang) then
            vim.treesitter.start(args.buf, lang)
            -- vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            -- vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
            -- vim.wo[0][0].foldmethod = "expr"
        end
    end,
})
