vim.bo.shiftwidth = 2
vim.bo.tabstop = 2
require('lsp.global.languages.lua')
vim.api.nvim_command(':LspStart sumneko_lua')
