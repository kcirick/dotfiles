-- -----------------------
-- indentmini.nvim config
-- -----------------------
require('indentmini').setup({
   char ='│',
   exclude = {
      'mardown',
   }
})

vim.cmd.highlight('IndentLine guifg=#333333')
vim.cmd.highlight('IndentLineCurrent guifg=#4d9bc1')

-- --------------
-- luatab config
-- --------------
local function my_modified(bufnr)
    return vim.fn.getbufvar(bufnr, '&modified') == 1 and '+ ' or ''
end

local function my_cell_fn(index)
   local isSelected = vim.fn.tabpagenr() == index
   local buflist = vim.fn.tabpagebuflist(index)
   local winnr = vim.fn.tabpagewinnr(index)
   local bufnr = buflist[winnr]
   local hl = (isSelected and '%#TabLineSel#' or '%#TabLine#')

   local M = require'luatab.init'

   return hl .. '%' .. index .. 'T ' .. index .. ': ' ..
      M.helpers.windowCount(index) ..
      M.helpers.devicon(bufnr, isSelected) ..
      M.helpers.title(bufnr) .. ' ' ..
      my_modified(bufnr) .. '%T' ..
      M.helpers.separator(index)
end

require('luatab').setup({
   cell = my_cell_fn,
})

vim.cmd.highlight('TabLineSel guibg=#111111 guifg=#4d9bc1')
vim.cmd.highlight('TabLine guibg=#333333 guifg=#AAAAAA')
vim.cmd.highlight('TabLineFill guibg=#333333')

-- ---------------
-- lualine config
-- ---------------
local function search_result()
   if vim.v.hlsearch == 0 then
      return ''
   end
   local last_search = vim.fn.getreg('/')
   if not last_search or last_search == '' then
      return ''
   end
   local searchcount = vim.fn.searchcount { maxcount = 9999 }
   return last_search .. '(' .. searchcount.current .. '/' .. searchcount.total .. ')'
end

require('lualine').setup({
   options = {
      icons_enabled = true,
      component_separators = '|',
      section_separators = { left=' ', right=' ' },
      --section_separators = { left="\ue0BD", right="\ue0BE" },
      theme = 'mytheme',
   },
   --sections = {
      --lualine_y = {search_result, 'progress'},
   --},
   tabline = {},
})
