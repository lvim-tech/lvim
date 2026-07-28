-- DAP utilities for LVIM IDE.
-- Provides an lvim-ui process picker for attach-style debug configurations
-- and a local DAP config loader that reads project-local nvim-dap.lua files.
-- The debug engine is lvim-dap (the lvim-tech DAP client).
--
---@module "modules.base.configs.languages.lsp.dap_utils"

local M = {}

--- Lists running processes (`ps`), or an empty list when `ps` fails.
---@return { pid: integer, name: string }[]
local function get_processes()
    local out = vim.fn.systemlist({ "ps", "-e", "-o", "pid=,comm=" })
    if vim.v.shell_error ~= 0 then
        return {}
    end
    local procs = {}
    for _, line in ipairs(out) do
        local pid, name = line:match("^%s*(%d+)%s+(.+)$")
        if pid then
            procs[#procs + 1] = { pid = tonumber(pid), name = name }
        end
    end
    return procs
end

--- Opens an lvim-ui picker listing running processes and returns the selected PID.
--- Must be called from inside a coroutine (the DAP engine's config-variable
--- expansion calls function values there automatically).
---@return integer|nil pid
M.process_picker = function()
    local procs = get_processes()
    local items = {}
    for _, p in ipairs(procs) do
        items[#items + 1] = { label = string.format("%d: %s", p.pid, p.name) }
    end
    local co = coroutine.running()
    if not co then
        vim.notify("Process picker must run inside a coroutine", vim.log.levels.ERROR, { title = "LVIM IDE" })
        return nil
    end
    require("lvim-ui").select({
        title = " Select process ",
        items = items,
        callback = function(confirmed, index)
            if confirmed and index then
                coroutine.resume(co, procs[index].pid)
            else
                coroutine.resume(co, nil)
            end
        end,
    })
    return coroutine.yield()
end

--- Loads a project-local DAP configuration file if one exists.
--- Looks for `.nvim-dap/nvim-dap.lua`, `.nvim-dap.lua`, or `.nvim/nvim-dap.lua`
--- in the current working directory and sources it via `:luafile`. Inside that
--- file use require("lvim-dap") to register adapters/configurations.
---@return nil
M.dap_local = function()
    local config_paths = { "./.nvim-dap/nvim-dap.lua", "./.nvim-dap.lua", "./.nvim/nvim-dap.lua" }
    if not pcall(require, "lvim-dap") then
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
