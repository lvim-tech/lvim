_G.LVIM_NVIM_VERSION = vim.version()
if
    (_G.LVIM_NVIM_VERSION.major == 0 and _G.LVIM_NVIM_VERSION.minor == 11 and _G.LVIM_NVIM_VERSION.patch >= 4)
    or (_G.LVIM_NVIM_VERSION.major == 0 and _G.LVIM_NVIM_VERSION.minor == 12)
then
    require("core")
else
    print("LVIM IDE required Neovim >= 0.11.4")
end
