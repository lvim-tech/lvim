return {
    name = "ZIG RUN",
    builder = function()
        local file = vim.fn.expand("%:p")
        local cwd = vim.fn.expand("%:p:h")
        return {
            cmd = { "zig", "run", file },
            components = { "default" },
            cwd = cwd,
        }
    end,
    condition = {
        filetype = { "zig" },
    },
}
