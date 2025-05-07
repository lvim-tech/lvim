local M = {}
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
                        local pid = processes[selected[1]]
                        coroutine.resume(co, pid)
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

M.dap_local = function()
    local config_paths = { "./.nvim-dap/nvim-dap.lua", "./.nvim-dap.lua", "./.nvim/nvim-dap.lua" }
    if not pcall(require, "dap") then
        vim.notify("Not found DAP plugin!", vim.log.levels.ERROR, {
            title = "LVIM IDE",
        })
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
            {
                title = "LVIM IDE",
            }
        )
        return
    end
    vim.notify("Found DAP configuration at " .. project_config, vim.log.levels.INFO, {
        title = "LVIM IDE",
    })
    require("dap").adapters = (function()
        return {}
    end)()
    require("dap").configurations = (function()
        return function() end
    end)()
    vim.cmd(":luafile " .. project_config)
end
return M
