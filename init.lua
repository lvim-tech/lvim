_G.LVIM_NVIM_VERSION = vim.version()
if _G.LVIM_NVIM_VERSION.major == 0 and _G.LVIM_NVIM_VERSION.minor < 8 then
    print("LVIM IDE required Neovim >= 0.8.0")
else
    require("core")
end
