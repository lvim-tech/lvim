-- if vim.fn.has("mac") == 1 then
--     vim.fn.setenv("MACOSX_DEPLOYMENT_TARGET", "10.15")
-- end
_G.LVIM_NVIM_VERSION = vim.version()
if _G.LVIM_NVIM_VERSION.major == 0 and _G.LVIM_NVIM_VERSION.minor < 8 then
    print("LVIM IDE required Neovim >= 0.8.0")
else
    pcall(require, "impatient")
    require("core")
end
