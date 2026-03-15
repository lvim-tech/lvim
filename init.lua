-- Entry point for LVIM IDE.
-- Initialises the global _G.LVIM namespace, validates the Neovim version,
-- and delegates all further setup to the core module.
---@type LvimNamespace
_G.LVIM = { _float_index = 1 }
_G.LVIM.nvim_version = vim.version()

if vim.version.ge(_G.LVIM.nvim_version, { 0, 11, 4 }) then
    require("core")
else
    print("LVIM IDE required Neovim >= 0.11.4")
end
