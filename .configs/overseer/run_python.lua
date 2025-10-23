return {
    name = "PYTHON RUN",
    builder = function()
        local file = vim.fn.expand("%:p")
        local cwd = vim.fn.expand("%:p:h")
        return {
            cmd = { "python3", "-u", file },
            components = { "default" },
            cwd = cwd,
        }
    end,
    condition = {
        filetype = { "python" },
    },
}
