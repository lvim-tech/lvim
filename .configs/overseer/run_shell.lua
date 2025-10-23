return {
    name = "SHELL RUN",
    builder = function()
        local file = vim.fn.expand("%:p")
        local cwd = vim.fn.expand("%:p:h")
        return {
            cmd = { "bash", file },
            cwd = cwd,
        }
    end,
    condition = {
        filetype = { "sh", "bash", "zsh" },
    },
}
