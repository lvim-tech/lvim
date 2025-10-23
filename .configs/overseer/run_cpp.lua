return {
    name = "CPP RUN",
    builder = function()
        local file = vim.fn.expand("%:p")
        local cwd = vim.fn.expand("%:p:h")
        local outfile = cwd .. "/" .. vim.fn.expand("%:t:r")
        return {
            cmd = {
                "sh",
                "-c",
                "g++ '" .. file .. "' -o '" .. outfile .. "' && '" .. outfile .. "'",
            },
            cwd = cwd,
        }
    end,
    condition = {
        filetype = { "cpp" },
    },
}
