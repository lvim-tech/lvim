local global = require("core.global")
local funcs = require("core.funcs")
local notify = require("lvim-ui-config.notify")
local mason_registry = require("mason-registry")
local efm_base = require("languages.base.languages._efm")
local efm_user = require("languages.user.languages._efm")

local M = {}

-- Ниво на подробност на логването (1-3)
local log_level = 3

-- Лог функция с нива
local function log(level, msg, opts)
    if level <= log_level then
        if level == 1 then
            notify.error(msg, opts or { title = "EFM Error" })
        elseif level == 2 then
            notify.warn(msg, opts or { title = "EFM Warning" })
        else
            notify.info(msg, opts or { title = "EFM Info" })
        end
    end
end

-- Проверка дали пътят съществува
local function path_exists(path)
    local f = io.open(path, "r")
    if f then
        f:close()
        return true
    end
    return false
end

-- Намираме efm-langserver
local function find_efm_executable()
    local mason_path = vim.fn.stdpath("data") .. "/mason"
    local efm_paths = {
        mason_path .. "/bin/efm-langserver",
        mason_path .. "/packages/efm-langserver/bin/efm-langserver",
        mason_path .. "/packages/efm/bin/efm-langserver",
        "efm-langserver",
    }

    for _, path in ipairs(efm_paths) do
        if vim.fn.executable(path) == 1 then
            log(3, "Found efm-langserver at: " .. path)
            return { path }
        end
    end

    log(2, "efm-langserver not found in standard paths, using default")
    return { "efm-langserver" }
end

-- Форматираме буфер
M.format_buffer = function(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")

    log(3, "Formatting buffer " .. bufnr .. " with filetype " .. filetype)

    -- Проверяваме дали има efm клиент, прикрепен към буфера
    local clients = vim.lsp.get_clients({
        bufnr = bufnr,
        name = "efm",
    })

    if #clients == 0 then
        log(2, "No EFM client attached to buffer " .. bufnr .. ", attempting to attach...")

        -- Проверяваме дали EFM сървърът е стартиран
        local running_clients = vim.lsp.get_clients({ name = "efm" })
        if #running_clients == 0 then
            log(2, "EFM server not running, starting it...")
            M.setup_efm()

            -- Опитваме отново след малко
            vim.defer_fn(function()
                M.attach_buffer(bufnr)
                vim.defer_fn(function()
                    M.format_buffer(bufnr)
                end, 300)
            end, 500)
            return
        else
            -- Прикрепяме буфера към съществуващ сървър
            M.attach_buffer(bufnr)
            vim.defer_fn(function()
                M.format_buffer(bufnr)
            end, 300)
            return
        end
    end

    -- Проверяваме дали имаме форматиращи инструменти за този тип файл
    if not global.efm.settings.languages[filetype] or #global.efm.settings.languages[filetype] == 0 then
        log(1, "No formatters configured for filetype: " .. filetype)
        return
    end

    -- Извикваме форматирането
    log(3, "Executing format command")
    local ok, err = pcall(function()
        vim.lsp.buf.format({
            bufnr = bufnr,
            filter = function(client)
                return client.name == "efm"
            end,
            timeout_ms = 5000,
        })
    end)

    if not ok then
        log(1, "Format error: " .. tostring(err))
    end
end

-- Прикрепяме буфер към EFM сървър
M.attach_buffer = function(bufnr)
    -- Проверка за валидността на буфера
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    if not vim.api.nvim_buf_is_valid(bufnr) then
        log(2, "Invalid buffer: " .. tostring(bufnr))
        return false
    end

    -- Проверка за тип на буфера
    if vim.bo[bufnr].buftype ~= "" then
        log(3, "Skipping special buffer: " .. vim.bo[bufnr].buftype)
        return false
    end

    local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
    if filetype == "" then
        log(3, "Skipping buffer with empty filetype")
        return false
    end

    -- Проверяваме дали EFM поддържа този тип файл
    local supported = false
    if global.efm and global.efm.filetypes then
        for _, ft in ipairs(global.efm.filetypes) do
            if ft == filetype then
                supported = true
                break
            end
        end
    end

    if not supported then
        log(3, "Filetype " .. filetype .. " not supported by EFM")
        return false
    end

    -- Проверяваме дали EFM сървърът работи
    local efm_clients = vim.lsp.get_clients({ name = "efm" })
    if #efm_clients == 0 then
        log(2, "EFM server not running, cannot attach")
        return false
    end

    -- Проверяваме дали буферът вече е прикрепен
    local already_attached = false
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
        if client.name == "efm" then
            already_attached = true
            break
        end
    end

    if already_attached then
        log(3, "Buffer " .. bufnr .. " already attached to EFM")
        return true
    end

    -- Прикрепяме буфера към EFM клиента
    log(3, "Attaching buffer " .. bufnr .. " to EFM client")

    local client_id = efm_clients[1].id
    vim.lsp.buf_attach_client(bufnr, client_id)

    -- Проверяваме дали прикрепването е успешно
    vim.defer_fn(function()
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
            if client.name == "efm" then
                log(3, "Successfully attached buffer " .. bufnr .. " to EFM")

                -- Enable formatting capabilities explicitly
                client.server_capabilities.documentFormattingProvider = true
                client.server_capabilities.documentRangeFormattingProvider = true

                -- Set up Format command for this buffer
                vim.api.nvim_buf_create_user_command(bufnr, "Format", function()
                    M.format_buffer(bufnr)
                end, { desc = "Format current buffer with EFM" })

                -- Set up format on save
                if vim.fn.exists("#format_on_save#BufWritePre") == 0 then
                    vim.api.nvim_create_augroup("format_on_save", { clear = true })
                end

                vim.api.nvim_clear_autocmds({ buffer = bufnr, group = "format_on_save" })
                vim.api.nvim_create_autocmd("BufWritePre", {
                    group = "format_on_save",
                    buffer = bufnr,
                    callback = function()
                        if vim.g.format_on_save ~= false then
                            M.format_buffer(bufnr)
                        end
                    end,
                    desc = "Format on save with EFM",
                })

                return true
            end
        end

        log(1, "Failed to attach buffer " .. bufnr .. " to EFM")
        return false
    end, 100)

    return true
end

-- Стартираме EFM сървъра
local function start_efm_server(fresh_start)
    local cmd = find_efm_executable()
    if not cmd or #cmd == 0 then
        log(1, "Failed to find efm-langserver executable")
        return false
    end

    -- Проверяваме дали EFM вече не работи
    if not fresh_start then
        for _, client in ipairs(vim.lsp.get_clients()) do
            if client.name == "efm" then
                log(3, "EFM server is already running")
                return true
            end
        end
    end

    -- Подготвяме настройките
    if type(global.efm) ~= "table" then
        global.efm = {
            init_options = { documentFormatting = true, documentRangeFormatting = true },
            settings = { languages = {} },
            filetypes = {},
        }
    end

    -- Включваме възможността за форматиране
    if not global.efm.capabilities then
        global.efm.capabilities = vim.lsp.protocol.make_client_capabilities()
        global.efm.capabilities.textDocument.formatting = {
            dynamicRegistration = true,
        }
    end

    -- Задаваме функцията on_attach, ако не е дефинирана
    if not global.efm.on_attach then
        global.efm.on_attach = function(client, bufnr)
            log(3, "EFM attached to buffer " .. bufnr)

            -- Активираме възможностите за форматиране
            client.server_capabilities.documentFormattingProvider = true
            client.server_capabilities.documentRangeFormattingProvider = true

            -- Задаваме Format команда
            vim.api.nvim_buf_create_user_command(bufnr, "Format", function()
                M.format_buffer(bufnr)
            end, { desc = "Format current buffer with EFM" })

            -- Добавяме форматиране при запис
            if vim.fn.exists("#format_on_save#BufWritePre") == 0 then
                vim.api.nvim_create_augroup("format_on_save", { clear = true })
            end

            vim.api.nvim_clear_autocmds({ buffer = bufnr, group = "format_on_save" })
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = "format_on_save",
                buffer = bufnr,
                callback = function()
                    if vim.g.format_on_save ~= false then
                        M.format_buffer(bufnr)
                    end
                end,
                desc = "Format on save with EFM",
            })
        end
    end

    -- Задаваме root_dir, ако не е дефиниран
    if not global.efm.root_dir then
        global.efm.root_dir = function(fname)
            local git_dir = vim.fs.find(".git", { path = fname, upward = true })[1]
            return git_dir and vim.fs.dirname(git_dir) or vim.fs.dirname(fname)
        end
    end

    -- Пълна конфигурация за стартиране
    local config = {
        name = "efm",
        cmd = cmd,
        root_dir = global.efm.root_dir(vim.fn.getcwd()),
        capabilities = global.efm.capabilities,
        settings = global.efm.settings,
        init_options = global.efm.init_options,
        on_attach = global.efm.on_attach,
        flags = global.efm.flags or { debounce_text_changes = 150 },
        filetypes = global.efm.filetypes,
    }

    -- Стартираме сървъра
    log(3, "Starting EFM server with cmd: " .. vim.inspect(cmd))
    local ok, err = pcall(function()
        vim.lsp.start(config)
    end)

    if not ok then
        log(1, "Failed to start EFM: " .. tostring(err))
        return false
    else
        log(3, "EFM server started successfully")

        -- Прикрепяме текущия буфер
        vim.defer_fn(function()
            local clients = vim.lsp.get_clients({ name = "efm" })
            if #clients == 0 then
                log(1, "EFM server failed to start properly")
            else
                log(3, "EFM server is running with " .. #clients .. " clients")

                -- Прикрепяме всички отворени буфери с подходящи типове файлове
                for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
                    if vim.api.nvim_buf_is_loaded(bufnr) then
                        local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
                        local should_attach = false

                        for _, efm_ft in ipairs(global.efm.filetypes) do
                            if ft == efm_ft then
                                should_attach = true
                                break
                            end
                        end

                        if should_attach then
                            M.attach_buffer(bufnr)
                        end
                    end
                end
            end
        end, 500)

        return true
    end
end

-- Рестартираме EFM сървъра
M.restart_efm = function()
    log(3, "Restarting EFM server")

    -- Спираме всички EFM клиенти
    for _, client in ipairs(vim.lsp.get_clients()) do
        if client.name == "efm" then
            client.stop()
            log(3, "Stopped EFM client with ID " .. client.id)
        end
    end

    -- Стартираме сървъра отново след малко
    vim.defer_fn(function()
        start_efm_server(true)
    end, 500)
end

-- Обновяваме форматиращите инструменти
M.update_formatters = function(filetypes, formatters)
    log(3, "Updating formatters for filetypes: " .. table.concat(filetypes, ", "))

    -- Инициализираме глобалната конфигурация ако не съществува
    if type(global.efm) ~= "table" then
        global.efm = {
            init_options = { documentFormatting = true, documentRangeFormatting = true },
            settings = { languages = {} },
            filetypes = {},
        }
    end

    -- Обединяваме форматиращите инструменти
    local efm = funcs.merge(efm_base, efm_user)

    -- Добавяме нови типове файлове ако ги няма
    for _, ft in ipairs(filetypes) do
        local found = false
        for _, existing_ft in ipairs(global.efm.filetypes) do
            if existing_ft == ft then
                found = true
                break
            end
        end

        if not found then
            table.insert(global.efm.filetypes, ft)
            log(3, "Added new filetype: " .. ft)
        end

        -- Инициализираме масива за типа файл ако не съществува
        if not global.efm.settings.languages[ft] then
            global.efm.settings.languages[ft] = {}
        end
    end

    -- Добавяме нови форматиращи инструменти
    for _, formatter in ipairs(formatters) do
        for _, ft in ipairs(filetypes) do
            if efm[formatter] then
                -- Проверяваме дали тази форматираща инструмент не е вече добавена
                local already_added = false
                for _, existing_formatter in ipairs(global.efm.settings.languages[ft] or {}) do
                    -- Опростена проверка базирана на formatCommand
                    if
                        existing_formatter.formatCommand
                        and efm[formatter].formatCommand
                        and existing_formatter.formatCommand == efm[formatter].formatCommand
                    then
                        already_added = true
                        break
                    end
                end

                if not already_added then
                    if not global.efm.settings.languages[ft] then
                        global.efm.settings.languages[ft] = {}
                    end
                    table.insert(global.efm.settings.languages[ft], efm[formatter])
                    log(3, "Added formatter " .. formatter .. " for " .. ft)
                else
                    log(3, "Formatter " .. formatter .. " already exists for " .. ft)
                end
            else
                log(2, "Formatter '" .. formatter .. "' not found in EFM configuration")
            end
        end
    end

    -- Обновяваме сървъра с новите настройки
    if vim.tbl_count(vim.lsp.get_clients({ name = "efm" })) > 0 then
        M.restart_efm()
    else
        start_efm_server(false)
    end
end

-- Настройваме EFM
M.setup_efm = function()
    -- Проверяваме дали mason е инсталиран
    if not path_exists(vim.fn.stdpath("data") .. "/mason") then
        log(1, "Mason is not installed or initialized properly")
        -- Опитваме се да инициализираме mason
        pcall(function()
            require("mason").setup()
        end)
    end

    -- Проверяваме дали efm е инсталиран
    local mason_efm_paths = {
        vim.fn.stdpath("data") .. "/mason/packages/efm-langserver",
        vim.fn.stdpath("data") .. "/mason/packages/efm",
    }

    local installed = false
    for _, path in ipairs(mason_efm_paths) do
        if path_exists(path) then
            installed = true
            break
        end
    end

    if not installed then
        log(2, "EFM not installed through Mason, checking executable...")

        -- Проверяваме дали изпълнимият файл съществува в PATH
        if vim.fn.executable("efm-langserver") == 1 then
            installed = true
        else
            log(2, "EFM not found in PATH either, attempting to install...")

            -- Опитваме да инсталираме чрез Mason
            pcall(function()
                vim.cmd("MasonInstall efm-langserver")
            end)

            -- Опитваме се да намерим инсталирания пакет отново
            vim.defer_fn(function()
                for _, path in ipairs(mason_efm_paths) do
                    if path_exists(path) then
                        installed = true
                        start_efm_server(true)
                        break
                    end
                end

                if not installed then
                    log(1, "Failed to install EFM through Mason")
                end
            end, 3000)

            return
        end
    end

    -- Ако стигнем дотук, значи имаме инсталиран EFM
    start_efm_server(false)
end

-- Диагностични функции
M.diagnostics = function()
    log(3, "Running EFM diagnostics")

    -- Проверка на EFM инсталацията
    local mason_efm_paths = {
        vim.fn.stdpath("data") .. "/mason/packages/efm-langserver",
        vim.fn.stdpath("data") .. "/mason/packages/efm",
    }

    local installed = false
    for _, path in ipairs(mason_efm_paths) do
        if path_exists(path) then
            log(3, "Found EFM installation at: " .. path)
            installed = true
            break
        end
    end

    if not installed and vim.fn.executable("efm-langserver") == 1 then
        log(3, "EFM found in PATH")
        installed = true
    end

    if not installed then
        log(1, "EFM not installed")
    end

    -- Проверка на изпълнимия файл
    local cmd = find_efm_executable()
    log(3, "EFM executable: " .. vim.inspect(cmd))

    -- Проверка на конфигурацията
    if type(global.efm) ~= "table" then
        log(1, "EFM configuration missing")
        return
    end

    log(3, "EFM filetypes: " .. vim.inspect(global.efm.filetypes))

    -- Проверка на форматиращите инструменти
    local formatters_count = 0
    for ft, formatters in pairs(global.efm.settings.languages or {}) do
        formatters_count = formatters_count + #formatters
        log(3, "Filetype " .. ft .. " has " .. #formatters .. " formatters")
    end

    log(3, "Total formatters: " .. formatters_count)

    -- Проверка на текущия буфер
    local bufnr = vim.api.nvim_get_current_buf()
    local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")

    log(3, "Current buffer: " .. bufnr .. " with filetype: " .. ft)

    -- Проверка дали EFM е прикрепен към текущия буфер
    local attached = false
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
        if client.name == "efm" then
            attached = true
            break
        end
    end

    if attached then
        log(3, "EFM is attached to current buffer")
    else
        log(2, "EFM is NOT attached to current buffer")
    end

    -- Проверка на поддръжката на текущия тип файл
    local filetype_supported = false
    for _, efm_ft in ipairs(global.efm.filetypes or {}) do
        if ft == efm_ft then
            filetype_supported = true
            break
        end
    end

    if filetype_supported then
        log(3, "Current filetype is supported by EFM")
    else
        log(2, "Current filetype is NOT supported by EFM")
    end

    -- Проверка на форматиращите инструменти за текущия тип файл
    if global.efm.settings and global.efm.settings.languages and global.efm.settings.languages[ft] then
        local formatters = global.efm.settings.languages[ft]
        log(3, "Found " .. #formatters .. " formatters for current filetype")

        for i, formatter in ipairs(formatters) do
            if formatter.formatCommand then
                local cmd_parts = vim.split(formatter.formatCommand, " ")
                local cmd = cmd_parts[1]:gsub("%$", "")

                if vim.fn.executable(cmd) == 1 then
                    log(3, "Formatter " .. i .. ": " .. cmd .. " ✓")
                else
                    log(2, "Formatter " .. i .. ": " .. cmd .. " ✗ (not found)")
                end
            else
                log(2, "Formatter " .. i .. " has no formatCommand")
            end
        end
    else
        log(2, "No formatters found for current filetype")
    end

    -- Проверка на клиентите
    local efm_clients = vim.lsp.get_clients({ name = "efm" })
    log(3, "Found " .. #efm_clients .. " EFM clients")

    -- Опит за прикрепване на буфера
    if not attached and #efm_clients > 0 then
        log(3, "Attempting to attach buffer...")
        M.attach_buffer(bufnr)
    end
end

-- Създаваме глобалната команда Format
vim.api.nvim_create_user_command("Format", function()
    M.format_buffer()
end, {})

-- Създаваме команда за диагностика
vim.api.nvim_create_user_command("EfmDiagnostics", function()
    M.diagnostics()
end, {})

-- Създаваме команда за ръчно прикрепване на текущия буфер
vim.api.nvim_create_user_command("EfmAttach", function()
    M.attach_buffer()
end, {})

return M
