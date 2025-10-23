return {
    name = "PHP RUN",
    builder = function()
        local file = vim.fn.expand("%:p")
        local cwd = vim.fn.expand("%:p:h")
        return {
            cmd = { "php", file },
            cwd = cwd,
        }
    end,
    condition = {
        filetype = { "php" },
    },
}
