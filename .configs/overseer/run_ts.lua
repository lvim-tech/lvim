-- Overseer task template: compile and run the current TypeScript file.
-- Filetype-gated (typescript); transpiles with `tsc` to a sibling .js file, then
-- runs it with `node`. Returns a single Overseer task spec.
return {
    name = "TS Build & Run",
    builder = function()
        local file = vim.fn.expand("%:p")
        local cwd = vim.fn.expand("%:p:h")
        local outfile = cwd .. "/" .. vim.fn.expand("%:t:r") .. ".js"
        return {
            cmd = {
                "sh",
                "-c",
                "tsc '" .. file .. "' --outFile '" .. outfile .. "' && node '" .. outfile .. "'",
            },
            cwd = cwd,
        }
    end,
    condition = {
        filetype = { "typescript" },
    },
}
