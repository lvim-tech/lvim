-- DAP utilities for LVIM IDE.
-- Provides an fzf-based process picker for attach-style debug configurations
-- and a local DAP config loader that reads project-local nvim-dap.lua files.
--
---@module "modules.base.configs.languages.lsp.dap_utils"

local M = {}

--- Opens an fzf picker listing running processes and returns the selected PID.
--- Must be called from inside a coroutine (nvim-dap does this automatically).
---@return integer|nil pid
M.fzf_process_picker = function()
    local process_list = require("dap.utils").get_processes()
    local items = {}
    local processes = {}
    for _, p in pairs(process_list) do
        local display = string.format("%d: %s", p.pid, p.name)
        table.insert(items, display)
        processes[display] = p.pid
    end
    local co = coroutine.running()
    if co then
        require("fzf-lua").fzf_exec(items, {
            prompt = "Select process> ",
            actions = {
                ["default"] = function(selected)
                    if #selected > 0 then
                        coroutine.resume(co, processes[selected[1]])
                    else
                        coroutine.resume(co, nil)
                    end
                end,
            },
        })
        return coroutine.yield()
    else
        print("Error: Failed to create coroutine")
        return nil
    end
end

--- Loads a project-local DAP configuration file if one exists.
--- Looks for `.nvim-dap/nvim-dap.lua`, `.nvim-dap.lua`, or `.nvim/nvim-dap.lua`
--- in the current working directory and sources it via `:luafile`.
---@return nil
M.dap_local = function()
    local config_paths = { "./.nvim-dap/nvim-dap.lua", "./.nvim-dap.lua", "./.nvim/nvim-dap.lua" }
    if not pcall(require, "dap") then
        vim.notify("Not found DAP plugin!", vim.log.levels.ERROR, { title = "LVIM IDE" })
        return
    end
    local project_config = ""
    for _, p in ipairs(config_paths) do
        local f = io.open(p)
        if f ~= nil then
            f:close()
            project_config = p
            break
        end
    end
    if project_config == "" then
        vim.notify(
            "You can define DAP configuration in './.nvim-dap/nvim-dap.lua', './.nvim-dap.lua', './.nvim/nvim-dap.lua'",
            vim.log.levels.INFO,
            { title = "LVIM IDE" }
        )
        return
    end
    vim.notify("Found DAP configuration at " .. project_config, vim.log.levels.INFO, { title = "LVIM IDE" })
    vim.cmd(":luafile " .. project_config)
end

return M
