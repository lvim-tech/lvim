return {
    name = "JS RUN",
    builder = function()
        local file = vim.fn.expand("%:p")
        local cwd = vim.fn.expand("%:p:h")
        return {
            cmd = { "node", file },
            cwd = cwd,
        }
    end,
    condition = {
        filetype = { "javascript" },
    },
}
