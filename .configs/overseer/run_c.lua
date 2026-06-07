-- Overseer task template: compile and run the current C file.
-- Filetype-gated (c); builds with `gcc` to a sibling binary (basename without
-- extension) and executes it. Returns a single Overseer task spec.
return {
    name = "C RUN",
    builder = function()
        local file = vim.fn.expand("%:p")
        local cwd = vim.fn.expand("%:p:h")
        local outfile = cwd .. "/" .. vim.fn.expand("%:t:r")
        return {
            cmd = {
                "sh",
                "-c",
                "gcc '" .. file .. "' -o '" .. outfile .. "' && '" .. outfile .. "'",
            },
            cwd = cwd,
        }
    end,
    condition = {
        filetype = { "c" },
    },
}
