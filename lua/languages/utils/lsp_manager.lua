local global = require("core.global")
local funcs = require("core.funcs")
local mason_registry = require("mason-registry")
local ui_config = require("lvim-ui-config.config")
local select = require("lvim-ui-config.select")
local notify = require("lvim-ui-config.notify")
local efm_base = require("languages.base.languages._efm")
local efm_user = require("languages.user.languages._efm")
local efm_manager = require("languages.utils.efm_manager")

local M = {}

-- Централизирано проследяване на състоянието на LSP сървърите
_G.lsp_servers_status = _G.lsp_servers_status or {}

M.efm = funcs.merge(efm_base, efm_user)
M.dependencies_ready = true
M.current_language = ""
M.tools_to_install = {}
M.servers_to_install = {}
M.debuggers_to_install = {}
M.lsp_to_start = {}
M.ordered_keys = {}

-- Функция за проверка дали LSP сървър е вече инициализиран
M.is_server_initialized = function(server_name)
    return _G.lsp_servers_status[server_name] == true
end

-- Функция за маркиране на LSP сървър като инициализиран
M.mark_server_initialized = function(server_name)
    _G.lsp_servers_status[server_name] = true
end

-- Автоматично прикачване на буферите към всички активни LSP сървъри
M.setup_bufenter_autocmd = function()
    local augroup = vim.api.nvim_create_augroup("LspAutoAttach", { clear = true })
    vim.api.nvim_create_autocmd("BufEnter", {
        group = augroup,
        callback = function(args)
            local bufnr = args.buf
            if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buftype == "" then
                local ft = vim.bo[bufnr].filetype
                if ft ~= "" then
                    -- Проверка за прикачане на стандартни LSP сървъри
                    for server_name, _ in pairs(_G.lsp_servers_status) do
                        local clients = vim.lsp.get_clients({ name = server_name })
                        if #clients > 0 then
                            local client = clients[1]
                            -- Проверка дали клиентът вече е прикрепен към този буфер
                            local is_attached = false
                            for _, attached_client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
                                if attached_client.id == client.id then
                                    is_attached = true
                                    break
                                end
                            end

                            if not is_attached then
                                vim.lsp.buf_attach_client(bufnr, client.id)
                            end
                        end
                    end

                    -- Проверка специално за EFM сървъра
                    local efm_manager = require("languages.utils.efm_manager")
                    if type(efm_manager.attach_buffer) == "function" then
                        efm_manager.attach_buffer(bufnr)
                    end
                end
            end
        end,
        desc = "Auto-attach LSP clients to buffers",
    })
end

-- Функция за закачане на LSP клиент към подходящите буфери
M.attach_client_to_buffers = function(client_name, filetypes)
    local clients = vim.lsp.get_clients({ name = client_name })
    if #clients > 0 then
        local client = clients[1]

        -- Обхождаме всички буфери и закачаме клиента към подходящите
        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(bufnr) then
                local buf_ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
                for _, ft in ipairs(filetypes) do
                    if buf_ft == ft then
                        -- Проверка дали клиентът вече е прикрепен към този буфер
                        local is_attached = false
                        for _, attached_client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
                            if attached_client.id == client.id then
                                is_attached = true
                                break
                            end
                        end

                        if not is_attached then
                            vim.lsp.buf_attach_client(bufnr, client.id)
                            notify.info(client_name .. " LSP attached to buffer: " .. bufnr, {
                                title = "LVIM IDE",
                            })
                        end
                    end
                end
            end
        end
    else
        notify.warn("No " .. client_name .. " LSP client found to attach", {
            title = "LVIM IDE",
        })
    end
end

-- Използваме efm_manager за efm_update
M.efm_update = function()
    -- Делегираме управлението на EFM към efm_manager
    efm_manager.restart_efm()
end

M.update_mason = function()
    -- Update Mason itself
    vim.cmd(":MasonUpdate")
    -- Update registry
    mason_registry.refresh()
    -- Force registry update
    mason_registry.update()
    notify.info("Mason has been updated. Please restart LVIM IDE for changes to take effect.", {
        title = "LVIM IDE",
        timeout = 5000,
    })
end

M.install_all_packages = function()
    -- First ensure Mason is up to date
    if not mason_registry.is_installed("mason-registry") then
        M.update_mason()
        return
    end

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
        if file ~= nil and file["dependencies"] ~= nil then
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
    -- Check if the package is already installed
    if mason_registry.is_installed(package[1]) then
        -- If it's installed and we need to start the server
        if package[2] ~= nil and action then
            -- Check if the server is already running
            local is_running = false
            for _, client in ipairs(vim.lsp.get_clients()) do
                if client.name == package[2] then
                    is_running = true
                    break
                end
            end

            -- Only start if not already running
            if not is_running then
                local binary_path = ""
                -- Get the binary path
                local install_path = vim.fn.stdpath("data") .. "/mason/packages/" .. package[1]
                binary_path = install_path .. "/bin/" .. package[1]
                -- Проверка дали бинарният файл съществува в очаквания път
                if vim.fn.filereadable(binary_path) ~= 1 then
                    -- Търсене в bin директорията
                    local binaries = vim.fn.glob(install_path .. "/bin/*")
                    if binaries ~= "" then
                        binary_path = vim.fn.split(binaries, "\n")[1]
                    else
                        -- Връщаме към име на пакета и оставяме PATH да го намери
                        binary_path = package[1]
                    end
                end

                -- Use the resolved binary path or custom cmd configuration
                local cmd = package[3].cmd or { binary_path }

                -- Debugging: print the command and settings
                local server_name_to_display = package[2] or package[1]
                notify.info("Starting LSP server: " .. server_name_to_display, {
                    title = "LVIM IDE",
                })

                vim.lsp.start({
                    name = package[2],
                    cmd = cmd,
                    root_dir = vim.loop.cwd(),
                    settings = package[3].settings,
                })
            end
        elseif package[2] == "efm" then
            -- Използваме efm_manager за стартиране на efm
            efm_manager.setup_efm()
        end
        return
    end

    -- If not installed, proceed with installation
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
                    -- Използваме efm_manager след инсталация
                    efm_manager.setup_efm()
                elseif package[2] ~= nil and action then
                    -- Check if the server is already running
                    local is_running = false
                    for _, client in ipairs(vim.lsp.get_clients()) do
                        if client.name == package[2] then
                            is_running = true
                            break
                        end
                    end

                    if not is_running then
                        -- Use mason to get the installed binary path
                        local binary_path = ""
                        -- Get the binary path
                        local install_path = vim.fn.stdpath("data") .. "/mason/packages/" .. package[1]
                        binary_path = install_path .. "/bin/" .. package[1]
                        -- Проверка дали бинарният файл съществува в очаквания път
                        if vim.fn.filereadable(binary_path) ~= 1 then
                            -- Търсене в bin директорията
                            local binaries = vim.fn.glob(install_path .. "/bin/*")
                            if binaries ~= "" then
                                binary_path = vim.fn.split(binaries, "\n")[1]
                            else
                                -- Връщаме към име на пакета и оставяме PATH да го намери
                                binary_path = package[1]
                            end
                        end

                        -- Use the resolved binary path or custom cmd configuration
                        local cmd = package[3].cmd or { binary_path }
                        -- Debug information
                        notify.info("Starting LSP server: " .. package[2], {
                            title = "LVIM IDE",
                        })

                        vim.lsp.start({
                            name = package[2],
                            cmd = cmd,
                            root_dir = vim.loop.cwd(),
                            settings = package[3].settings,
                        })
                    end
                end
                vim.defer_fn(function()
                    global.install_proccess = false
                end, 500)
            end)
        )
    end
end

-- Инициализираме автоматичното прикачване на буфери
M.setup_bufenter_autocmd()

M.setup_languages = function(packages_data)
    local function install_package()
        if
            next(M.servers_to_install) ~= nil
            or next(M.tools_to_install) ~= nil
            or next(M.debuggers_to_install) ~= nil
        then
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
                    -- Подготвяме информация за efm_manager
                    local formatters = {}

                    -- Initialize global.efm if it doesn't exist or is not a table
                    if type(global.efm) ~= "table" then
                        global.efm = {
                            filetypes = {},
                            settings = {
                                languages = {},
                            },
                        }
                    end

                    -- Ensure settings and languages fields exist
                    if not global.efm.settings then
                        global.efm.settings = {}
                    end

                    if not global.efm.settings.languages then
                        global.efm.settings.languages = {}
                    end

                    -- Добавяме filetypes в global.efm
                    for c = 1, #M.current_ft do
                        local found = false
                        for _, ft in ipairs(global.efm.filetypes) do
                            if ft == M.current_ft[c] then
                                found = true
                                break
                            end
                        end

                        if not found then
                            table.insert(global.efm.filetypes, M.current_ft[c])
                        end
                    end

                    -- Добавяме formatters в global.efm и масива за efm_manager
                    for a = 1, #v do
                        table.insert(formatters, v[a])

                        for t = 1, #M.current_ft do
                            if not global.efm.settings.languages[M.current_ft[t]] then
                                global.efm.settings.languages[M.current_ft[t]] = {}
                            end

                            -- Проверяваме дали форматера вече не съществува
                            local already_added = false
                            for _, existing_formatter in ipairs(global.efm.settings.languages[M.current_ft[t]]) do
                                if
                                    existing_formatter.formatCommand
                                    and M.efm[v[a]].formatCommand
                                    and existing_formatter.formatCommand == M.efm[v[a]].formatCommand
                                then
                                    already_added = true
                                    break
                                end
                            end

                            if not already_added then
                                table.insert(global.efm.settings.languages[M.current_ft[t]], M.efm[v[a]])
                            end
                        end

                        if not mason_registry.is_installed(v[a]) then
                            global.install_proccess = true
                            table.insert(M.tools_to_install, { v[a], "efm" })
                        end
                    end

                    -- Използваме efm_manager вместо директно стартиране
                    efm_manager.update_formatters(M.current_ft, formatters)
                    efm_manager.setup_efm()
                elseif k == "dap" then
                    for a = 1, #v do
                        if not mason_registry.is_installed(v[a]) then
                            global.install_proccess = true
                            table.insert(M.debuggers_to_install, { v[a] })
                        end
                    end
                else
                    -- Handle the case where key is the package name and value is either [server_name, config] or just config
                    local server_name = k
                    local config = v

                    -- Check if v is a table with numeric indices (old format) or just a config object (new format)
                    if v[1] and type(v[1]) == "string" then
                        -- Old format: value is [server_name, config]
                        server_name = v[1]
                        config = v[2]
                    end

                    table.insert(M.lsp_to_start, { k, server_name, config })
                    if not mason_registry.is_installed(k) then
                        global.install_proccess = true
                        table.insert(M.servers_to_install, { k, server_name, config })
                    else
                        -- Проверка дали сървърът вече е маркиран като инициализиран в глобалното състояние
                        local is_running = M.is_server_initialized(v[1])
                        -- Допълнителна проверка дали сървърът е активен
                        if not is_running then
                            local clients = vim.lsp.get_clients()
                            for _, client in ipairs(clients) do
                                if client.name == v[1] then
                                    is_running = true
                                    M.mark_server_initialized(v[1])
                                    notify.info("Server " .. v[1] .. " is already running", {
                                        title = "LVIM IDE",
                                    })
                                    break
                                end
                            end
                        end

                        -- Получаване на правилния път към изпълнимия файл
                        local function get_executable_path(server_name)
                            if mason_registry.is_installed(server_name) then
                                -- Use direct path construction instead of package object
                                local install_path = vim.fn.stdpath("data") .. "/mason/packages/" .. server_name

                                -- Проверяваме първо в bin директорията
                                local bin_path = install_path .. "/bin/" .. server_name
                                if vim.fn.executable(bin_path) == 1 then
                                    return bin_path
                                end

                                -- Проверяваме за други изпълними файлове
                                local files = vim.fn.glob(install_path .. "/bin/*")
                                if files ~= "" then
                                    local executables = vim.fn.split(files, "\n")
                                    for _, exec in ipairs(executables) do
                                        if vim.fn.executable(exec) == 1 then
                                            return exec
                                        end
                                    end
                                end
                            end

                            -- Връщаме оригиналното име като fallback
                            return server_name
                        end

                        -- Конфигурация за сървъра
                        local config = v
                        if v[1] and type(v[1]) == "string" then
                            config = v[2]
                        end

                        -- Определяне на командата за стартиране
                        local cmd
                        if config.cmd then
                            cmd = config.cmd
                        else
                            local exec_path = get_executable_path(k)
                            cmd = { exec_path }

                            -- Специална обработка за lua-language-server
                            if k == "lua-language-server" then
                                local mason_path = vim.fn.stdpath("data") .. "/mason"
                                local lua_server_path = mason_path
                                    .. "/packages/lua-language-server/bin/lua-language-server"

                                if vim.fn.executable(lua_server_path) == 1 then
                                    cmd = { lua_server_path }
                                end
                            end
                        end

                        local server_name_to_display = server_name or k
                        notify.info(
                            string.format(
                                "Starting LSP server: %s with command: %s",
                                server_name_to_display,
                                vim.inspect(cmd)
                            ),
                            {
                                title = "LVIM IDE",
                            }
                        )

                        local start_ok, start_err = pcall(function()
                            local server_name = (type(v) == "table" and v[1]) and v[1] or k
                            local settings = (type(v) == "table" and v[2]) and v[2].settings or v.settings or {}

                            -- Създаване на базова конфигурация
                            local server_config = {
                                name = server_name,
                                cmd = cmd,
                                root_dir = vim.loop.cwd(),
                                settings = settings,
                                flags = {
                                    debounce_text_changes = 150,
                                },
                                capabilities = vim.lsp.protocol.make_client_capabilities(),
                            }

                            -- Копираме всички допълнителни полета от конфигурацията
                            for k, v in pairs(config) do
                                if k ~= "cmd" and k ~= "name" and type(v) ~= "function" then
                                    server_config[k] = v
                                end
                            end

                            -- Добавяне на допълнителни capabilities ако са налични
                            if config.capabilities then
                                server_config.capabilities =
                                    vim.tbl_deep_extend("force", server_config.capabilities, config.capabilities)
                            end

                            -- Добавяме on_attach callback ако съществува
                            if config.on_attach and type(config.on_attach) == "function" then
                                local original_on_attach = config.on_attach
                                server_config.on_attach = function(client, bufnr)
                                    original_on_attach(client, bufnr)
                                end
                            end

                            vim.lsp.start(server_config)
                        end)

                        if not start_ok then
                            notify.error("Failed to start " .. v[1] .. ": " .. tostring(start_err), {
                                title = "LVIM IDE Error",
                            })
                        end

                        local server_name = k
                        if v[1] and type(v[1]) == "string" then
                            server_name = v[1]
                        end
                        M.mark_server_initialized(server_name)

                        -- Закачаме клиента към всички подходящи буфери
                        vim.defer_fn(function()
                            local server_name = k
                            if v[1] and type(v[1]) == "string" then
                                server_name = v[1]
                            end
                            M.attach_client_to_buffers(server_name, M.current_ft)
                        end, 300)
                    end
                end
            end
        end
    end
    vim.defer_fn(function()
        for i = 1, #M.lsp_to_start do
            -- Only install/start if not installed yet
            if not mason_registry.is_installed(M.lsp_to_start[i][1]) then
                M.package_to_install(M.lsp_to_start[i], true)
            end
        end
        install_package()
    end, 500)
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
