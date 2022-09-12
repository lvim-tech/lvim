pcall(require, "impatient")
-- For osx bigsur bug
-- Issue: [Luarocks fails to install on macOS BigSur #180](https://github.com/wbthomason/packer.nvim/issues/180)
-- if vim.fn.has("mac") == 1 then
--     vim.fn.setenv("MACOSX_DEPLOYMENT_TARGET", "10.15")
-- end
if vim.fn.has("nvim-0.7") == 1 then
    require("core")
else
    print("LVIM IDE required Neovim >= 0.7.0")
end
