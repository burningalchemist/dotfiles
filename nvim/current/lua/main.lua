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
vim.opt.completeopt:append("popup")
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
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- ## Cmd Options
vim.cmd.syntax("off")
-- Enable Undotree
vim.cmd("packadd nvim.undotree")


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
