-- https://neovim.io/doc/user/options.html
vim.syntax = 'on'
vim.filetype.indent = 'on'

vim.o.number = true
vim.o.ruler = true
vim.o.termguicolors = true
vim.o.laststatus = 2
vim.o.showtabline = 2
vim.o.cursorline = true
vim.o.pumheight = 20
vim.o.showmode = true
vim.o.colorcolumn = '100'
vim.o.wrap = true

vim.o.clipboard = 'unnamedplus'
vim.o.completeopt = 'menuone,noselect'

vim.o.encoding = 'utf-8'
-- vim.o.fileencoding = 'utf-8'

vim.o.hlsearch = true
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.expandtab = true
vim.o.smarttab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.smartindent = true
vim.o.autoindent = true

vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false

vim.opt.list = true
vim.opt.listchars:append('space:⋅')
