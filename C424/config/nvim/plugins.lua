--indentmini.nvim config
require('indentmini').setup({
   char = '│',
   exclude = {
      'markdown',
   }
})
vim.cmd.highlight('IndentLine guifg=#333333')
vim.cmd.highlight('IndentLineCurrent guifg=#4d9bc1')
