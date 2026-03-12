_G.LVIM_NVIM_VERSION = vim.version()
if vim.version.ge(_G.LVIM_NVIM_VERSION, { 0, 11, 4 }) then
    require("core")
else
    print("LVIM IDE required Neovim >= 0.11.4")
end
