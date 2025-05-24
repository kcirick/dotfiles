local vim = vim
local Plug = vim.fn['plug#']

-- Plugin section ---
vim.call('plug#begin')
   Plug('nvim-tree/nvim-web-devicons')
   Plug('nvimdev/indentmini.nvim')
   Plug('alvarosevilla95/luatab.nvim')
   --Plug('crispgm/nvim-tabline')
   --Plug 'akinsho/bufferline.nvim'
   --Plug 'romgrk/barbar.nvim '
   Plug('nvim-lualine/lualine.nvim')
vim.call('plug#end')

-- Load plugins ---
require('plugins')

-- Basic vim settings ---
vim.o.mouse = "nv"

vim.o.number = true
vim.o.ruler = true
vim.o.showtabline = 2

vim.o.tabstop = 3
vim.o.shiftwidth = 3
vim.o.expandtab = true

vim.o.syntax = "on"

