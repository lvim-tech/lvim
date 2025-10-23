return {
    name = "GO RUN",
    builder = function()
        local file = vim.fn.expand("%:p")
        local cwd = vim.fn.expand("%:p:h")
        return {
            cmd = { "go", "run", file },
            cwd = cwd,
        }
    end,
    condition = {
        filetype = { "go" },
    },
}
