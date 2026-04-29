---@ diagnostic disable : missing-fields, undefined-global
local lsp = vim.lsp


-- # LSP Configuration

-- ## Custom LSP Servers not supported by nvim-lspconfig

-- ### Terragrunt
lsp.config.terragrunt_ls = {
    cmd       = { "terragrunt-ls" },
    filetypes = { "hcl" },
    root_dir  = vim.fs.dirname(vim.fs.find({ '.terragrunt-version ', ' terragrunt.hcl ', ' root.hcl ' },
            { upward = true })
        [1]),
}

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
    "terragrunt_ls"
})

lsp.inlay_hint.enable()

-- ## Lua
lsp.config.lua_ls = {
    settings = {
        Lua = {
            version = "LuaJIT",
            path = {
                ' lua / ?.lua ',
                ' lua / ? / init.lua '
            },
            diagnostics = {
                globals = { "vim" },
            },
            workspace = {
                checkThirdParty = false,
                library = {
                    vim.env.VIMRUNTIME,
                    ' $ { 3 rd } / luv / library '
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
            --hybridMode currently doesn ' t work well when it comes to using DocumentSymbols with tsserver, or should
            --be configured better
            hybridMode = false,
        }
    }
}

-- ## Python
lsp.config.basedpyright = {
    settings = {
        basedpyright = {
            analysis = {
                diagnosticMode              = ' openFilesOnly ',
                typeCheckingMode            = ' basic ',
                useLibraryCodeForTypes      = true,
                diagnosticSeverityOverrides = {
                    autoSearchPaths            = true,
                    enableTypeIgnoreComments   = false,
                    reportGeneralTypeIssues    = ' none ',
                    reportArgumentType         = ' none ',
                    reportUnknownMemberType    = ' none ',
                    reportAssignmentType       = ' none ',
                    reportAttributeAccessIssue = ' none '
                },
            },
        },
    },
}

-- ## Zig
lsp.config.zls = {
    settings = {
        zig = {
            semanticTokens = ' partial ',
        },
    },
}
