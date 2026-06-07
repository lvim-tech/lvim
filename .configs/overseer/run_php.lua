-- Overseer task template: run the current PHP file via the `php` CLI.
-- Filetype-gated (php); executes in the file's directory. Returns a task spec.
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
