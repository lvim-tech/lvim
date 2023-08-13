local dependencies_ft = require("modules.base.configs.ui.hydra.dependencies_ft")

local M = {}

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
    group = "LvimIDE",
    callback = function()
        local current_buf = vim.api.nvim_get_current_buf()
        local file_path = vim.api.nvim_buf_get_name(current_buf)
        local file_name = vim.fn.fnamemodify(file_path, ":t")
        if file_name == "package.json" then
            dependencies_ft.package_info()
        elseif file_name == "Cargo.toml" then
            dependencies_ft.crates()
        elseif file_name == "pubspec.yaml" then
            dependencies_ft.pubspec_assist()
        end
    end,
})

return M
