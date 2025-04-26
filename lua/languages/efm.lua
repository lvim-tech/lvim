local global = require("core.global")
local setup_diagnostics = require("languages.utils.setup_diagnostics")

global.efm = global.efm or {
    filetypes = {},
    settings = { languages = {} },
}

local efm_group = vim.api.nvim_create_augroup("EfmAttachment", { clear = true })
global._efm_client_id = nil

local function get_efm_config()
    return {
        name = "efm",
        cmd = { "efm-langserver" },
        filetypes = global.efm.filetypes,
        single_file_support = true,
        settings = global.efm.settings,
        init_options = {
            documentFormatting = true,
            documentRangeFormatting = true,
        },
        on_attach = function(client, bufnr)
            global._efm_client_id = client.id
            client.server_capabilities.documentFormattingProvider = true
            client.server_capabilities.documentRangeFormattingProvider = true
            setup_diagnostics.keymaps(client, bufnr)
            setup_diagnostics.document_highlight(client, bufnr)
            setup_diagnostics.document_auto_format(client, bufnr)
            setup_diagnostics.inlay_hint(client, bufnr)
        end,
    }
end

local function start_efm_server()
    for _, client in ipairs(vim.lsp.get_clients()) do
        if client.name == "efm" or client.name == "efm_ls" then
            client:stop(true)
            vim.wait(200)
        end
    end
    local config = get_efm_config()
    if #config.filetypes == 0 then
        vim.notify("No registered file types for EFM", vim.log.levels.WARN)
        return false
    end
    local client_id = vim.lsp.start(config)
    if not client_id then
        vim.notify("Failed to start EFM server", vim.log.levels.ERROR)
        return false
    end
    global._efm_client_id = client_id
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) then
            local ft = vim.bo[bufnr].filetype
            if vim.tbl_contains(config.filetypes, ft) then
                vim.lsp.buf_attach_client(bufnr, client_id)
            end
        end
    end
    return true
end

vim.api.nvim_create_autocmd("FileType", {
    group = efm_group,
    callback = function(args)
        local ft = args.match
        local bufnr = args.buf
        if not vim.tbl_contains(global.efm.filetypes, ft) then
            return
        end
        if global._efm_client_id and vim.lsp.get_client_by_id(global._efm_client_id) then
            vim.defer_fn(function()
                vim.lsp.buf_attach_client(bufnr, global._efm_client_id)
            end, 100)
        else
            vim.defer_fn(start_efm_server, 100)
        end
    end,
})

return {
    get_config = get_efm_config,
    start = start_efm_server,
}
