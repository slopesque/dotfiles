-- Clipboard
-- NOTE: delayed to `UiEnter` as it increases startup time
vim.schedule(
    function()
        vim.o.clipboard = "unnamedplus"
    end
)

-- History
vim.opt.undofile = true

-- Identation Options
vim.opt.autoindent = true
vim.opt.breakindent = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.tabstop = 4

-- Interactivity
vim.opt.confirm = true
vim.opt.inccommand = "split"

-- Leader Key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Performance
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Search mode
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Splitting mode
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Visual Options - Text
vim.opt.list = false

-- Visual Options - Window
vim.wo.colorcolumn = "80"
vim.wo.cursorline = true
vim.wo.number = true
vim.opt.scrolloff = 10
vim.opt.signcolumn = "auto"
