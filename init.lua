if vim.fn.has("nvim-0.7") == 1 then
    require("core")
else
    print("LVIM IDE required Neovim >= 0.7.0")
end
