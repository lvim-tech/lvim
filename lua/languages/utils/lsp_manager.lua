local global = require("core.global")
local funcs = require("core.funcs")
local lspconfig = require("lspconfig")
local lspconfigs = require("lspconfig/configs")
local mason_registry = require("mason-registry")
local ui_config = require("lvim-ui-config.config")
local select = require("lvim-ui-config.select")
local notify = require("lvim-ui-config.notify")
local efm_base = require("languages.base.languages._efm")
local efm_user = require("languages.user.languages._efm")

local M = {}

M.efm = funcs.merge(efm_base, efm_user)
M.dependencies_ready = true
M.current_language = ""
M.tools_to_install = {}
M.servers_to_install = {}
M.debuggers_to_install = {}
M.lsp_to_start = {}
M.ordered_keys = {}

M.efm_update = function()
    local clients = vim.lsp.get_active_clients()
    local efmClient = nil
    for _, client in ipairs(clients) do
        if client.name == "efm" then
            efmClient = client.id
            break
        end
    end
    if efmClient then
        pcall(function()
            vim.cmd("LspRestart efm " .. efmClient)
        end)
    end
end

M.install_all_packages = function()
    local ft_base = require("languages.base.ft")
    local ft_user = require("languages.user.ft")
    local fts = funcs.merge(ft_base, ft_user)
    local packages = {}
    local function has_value(val)
        for _, value in ipairs(packages) do
            if value == val then
                return true
            end
        end
        return false
    end
    for k, _ in pairs(fts) do
        local file = nil
        if funcs.file_exists(global.lvim_path .. "/lua/languages/user/languages/" .. k .. ".lua") then
            file = require("languages.user.languages." .. k)
        elseif funcs.file_exists(global.lvim_path .. "/lua/languages/base/languages/" .. k .. ".lua") then
            file = require("languages.base.languages." .. k)
        end
        if file["dependencies"] ~= nil then
            for _, dependency in pairs(file["dependencies"]) do
                if not has_value(dependency) then
                    table.insert(packages, dependency)
                end
            end
        end
    end
    vim.cmd(":Mason")
    for i = 1, #packages do
        if not mason_registry.is_installed(packages[i]) then
            local ok, p = pcall(function()
                return mason_registry.get_package(packages[i])
            end)
            if not ok then
                notify.error("Package " .. packages[i] .. " not available", {
                    title = "LVIM IDE",
                })
            else
                p:install():once("closed", vim.schedule_wrap(function() end))
            end
        end
    end
end

M.package_to_install = function(package, action)
    local ok, p = pcall(function()
        return mason_registry.get_package(package[1])
    end)
    if not ok then
        notify.error("Package " .. package[1] .. " not available", {
            title = "LVIM IDE",
        })
    else
        global.install_proccess = true
        vim.defer_fn(function()
            vim.cmd(":Mason")
        end, 100)
        p:install():once(
            "closed",
            vim.schedule_wrap(function()
                if package[2] == "efm" then
                    lspconfig.efm.setup(global.efm)
                elseif package[2] ~= nil and action then
                    lspconfig[package[2]].setup(package[3])
                    vim.cmd("LspStart " .. package[2])
                end
                vim.defer_fn(function()
                    global.install_proccess = false
                end, 500)
            end)
        )
    end
end

M.setup_languages = function(packages_data)
    local function install_package()
        if next(M.servers_to_install) ~= nil or next(M.tools_to_install) or next(M.debuggers_to_install) then
            if global.lvim_packages == false then
                vim.defer_fn(function()
                    local opts = ui_config.select({
                        "Install packages for " .. M.current_language,
                        "Install packages for all languages",
                        "Don't ask me again",
                        "Cancel",
                    }, { prompt = "LVIM IDE need to install some packages" }, {})
                    select(opts, function(choice)
                        if choice == "Install packages for " .. M.current_language then
                            funcs.close_float_windows()
                            for i = 1, #M.servers_to_install do
                                M.package_to_install(M.servers_to_install[i], true)
                            end
                            for i = 1, #M.tools_to_install do
                                M.package_to_install(M.tools_to_install[i])
                            end
                            for i = 1, #M.debuggers_to_install do
                                M.package_to_install(M.debuggers_to_install[i])
                            end
                        elseif choice == "Install packages for all languages" then
                            global.install_proccess = true
                            M.servers_to_install = {}
                            M.tools_to_install = {}
                            M.debuggers_to_install = {}
                            funcs.close_float_windows()
                            vim.defer_fn(function()
                                M.install_all_packages()
                            end, 100)
                        elseif choice == "Don't ask me again" then
                            funcs.write_file(global.cache_path .. "/.lvim_packages", "")
                            notify.error(
                                "To enable ask again run command:\n:AskForPackagesFile\nand restart LVIM IDE",
                                {
                                    timeout = 10000,
                                    title = "LVIM IDE",
                                }
                            )
                        elseif choice == "Cancel" then
                            notify.error("Need restart LVIM IDE to install packages for this filetype", {
                                timeout = 10000,
                                title = "LVIM IDE",
                            })
                        end
                    end)
                end, 1000)
            end
        end
    end
    local function init(packages)
        if global.install_proccess then
            vim.defer_fn(function()
                init(packages)
            end, 500)
        else
            M.servers_to_install = {}
            M.tools_to_install = {}
            M.debuggers_to_install = {}
            M.lsp_to_start = {}
            M.ordered_keys = {}
            for k in pairs(packages) do
                table.insert(M.ordered_keys, k)
            end
            local order = { "language", "ft", "efm", "dap" }
            table.sort(M.ordered_keys, funcs.custom_sort(order))
            for i = 1, #M.ordered_keys do
                local k, v = M.ordered_keys[i], packages[M.ordered_keys[i]]
                if k == "language" then
                    M.current_language = v
                elseif k == "ft" then
                    M.current_ft = v
                elseif k == "efm" then
                    for c = 1, #M.current_ft do
                        table.insert(global["efm"]["filetypes"], M.current_ft[c])
                    end
                    for a = 1, #v do
                        for t = 1, #M.current_ft do
                            if not global["efm"]["settings"]["languages"][M.current_ft[t]] then
                                global["efm"]["settings"]["languages"][M.current_ft[t]] = {}
                            end
                            table.insert(global["efm"]["settings"]["languages"][M.current_ft[t]], M.efm[v[a]])
                        end
                        if not mason_registry.is_installed(v[a]) then
                            global.install_proccess = true
                            table.insert(M.tools_to_install, { v[a], "efm" })
                        end
                    end
                    lspconfigs.efm = {
                        default_config = global.efm,
                    }
                    M.efm_update()
                elseif k == "dap" then
                    for a = 1, #v do
                        if not mason_registry.is_installed(v[a]) then
                            global.install_proccess = true
                            table.insert(M.debuggers_to_install, { v[a] })
                        end
                    end
                else
                    table.insert(M.lsp_to_start, { k, v[1], v[2] })
                    if not mason_registry.is_installed(k) then
                        global.install_proccess = true
                        table.insert(M.servers_to_install, { k, v[1], v[2] })
                    else
                        if v[1] ~= nil and v[2] ~= nil then
                            lspconfig[v[1]].setup(v[2])
                            vim.cmd("LspStart " .. v[1])
                        end
                    end
                end
            end
            vim.schedule(function()
                vim.defer_fn(function()
                    install_package()
                end, 1000)
            end)
        end
    end
    init(packages_data)
end

M.dap_local = function()
    local config_paths = { "./.nvim-dap/nvim-dap.lua", "./.nvim-dap.lua", "./.nvim/nvim-dap.lua" }
    if not pcall(require, "dap") then
        notify.error("Not found DAP plugin!", {
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
        notify.info(
            "You can define DAP configuration in './.nvim-dap/nvim-dap.lua', './.nvim-dap.lua', './.nvim/nvim-dap.lua'",
            {
                title = "LVIM IDE",
            }
        )
        return
    end
    notify.info("Found DAP configuration at " .. project_config, {
        title = "LVIM IDE",
    })
    require("dap").adapters = (function()
        return {}
    end)()
    require("dap").configurations = (function()
        return {}
    end)()
    vim.cmd(":luafile " .. project_config)
end

return M
