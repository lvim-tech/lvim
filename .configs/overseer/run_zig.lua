-- Overseer task template: run the current Zig file via `zig run`.
-- Filetype-gated (zig); executes in the file's directory. Returns a task spec.
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
