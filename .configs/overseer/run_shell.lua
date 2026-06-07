-- Overseer task template: run the current shell script with `bash`.
-- Filetype-gated (sh/bash/zsh); always invoked through bash regardless of shebang.
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
