-- Overseer task template: run the current Lua file with the standalone `lua` interpreter.
-- Filetype-gated (lua); note this uses system Lua, not Neovim's embedded runtime.
return {
    name = "LUA RUN",
    builder = function()
        local file = vim.fn.expand("%:p")
        local cwd = vim.fn.expand("%:p:h")
        return {
            cmd = { "lua", file },
            components = { "default" },
            cwd = cwd,
        }
    end,
    condition = {
        filetype = { "lua" },
    },
}
