-- Overseer task template: run the current JavaScript file with Node.js.
-- Filetype-gated (javascript); executes `node <file>` in the file's directory.
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
