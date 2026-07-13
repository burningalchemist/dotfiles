local lsp = vim.lsp

-- # LSP Configuration

-- ## Inlay Hints
lsp.inlay_hint.enable()

-- ## Common
lsp.enable({
    "lua_ls",
    "gopls",
    "ts_ls",
    "vue_ls",
    "basedpyright",
    "ruff",
    "zls",
    "terraformls",
    "terragrunt_ls",
    "dprint"
})

-- ## Lua
lsp.config.lua_ls = {
    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT",
            },
            diagnostics = {
                globals = { "vim", "use" },
            },
            workspace = {
                checkThirdParty = false,
                library = vim.api.nvim_get_runtime_file('', true),
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
            hints          = {
                compositeLiteralFields = true,
                constantValues         = true,
                parameterNames         = true,
                assignedVariables      = true,
            },
            staticcheck    = true,
            gofumpt        = true,
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
            -- hybridMode currently doesn't work well when it comes to using DocumentSymbols with tsserver, or should be
            -- configured better
            hybridMode = false,
        }
    }
}

-- ## Python
lsp.config.basedpyright = {
    settings = {
        basedpyright = {
            analysis = {
                diagnosticMode              = 'openFilesOnly',
                typeCheckingMode            = 'basic',
                useLibraryCodeForTypes      = true,
                diagnosticSeverityOverrides = {
                    autoSearchPaths            = true,
                    enableTypeIgnoreComments   = false,
                    reportGeneralTypeIssues    = 'none',
                    reportArgumentType         = 'none',
                    reportUnknownMemberType    = 'none',
                    reportAssignmentType       = 'none',
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

-- ## Dprint (JSON, YAML, Markdown, TOML, Dockerfiles formatter)
lsp.config.dprint = {
    filetypes = { 'json', 'jsonc', 'markdown', 'toml', 'yaml', 'dockerfile' },
}

-- Prohibit gitlab_duo and flow that might automatically install and run the lsp server on your machine via npx
lsp.config.flow = {
    cmd = { "false" },
    filetypes = {},
}
lsp.config.gitlab_duo = {
    cmd = { "false" },
    filetypes = {},
}
