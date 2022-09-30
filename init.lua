-- if vim.fn.has("mac") == 1 then
--     vim.fn.setenv("MACOSX_DEPLOYMENT_TARGET", "10.15")
-- end
local nvim_version = vim.version()
if nvim_version.major == 0 and nvim_version.minor < 8 then
    print("LVIM IDE required Neovim >= 0.8.0")
else
    pcall(require, "impatient")
    require("core")
end
