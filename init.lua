pcall(require, "impatient")
vim.fn.setenv("MACOSX_DEPLOYMENT_TARGET", "10.15")
if vim.fn.has("nvim-0.7") == 1 then
    require("core")
else
    print("LVIM IDE required Neovim >= 0.7.0")
end
