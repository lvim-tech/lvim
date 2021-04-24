local api = vim.api
local virtualtext = {}

local function get_size(tabl)
    local size = 0
    for _ in pairs(tabl) do size = size + 1 end
    return size
end

virtualtext.show = function()
    local buffer = vim.fn.bufnr()
    local clients = vim.lsp.get_active_clients()
    local size = get_size(clients)
    for i = 1, size, 1 do
        vim.lsp.diagnostic.display(vim.lsp.diagnostic.get(buffer, i), buffer, i,
                                   {virtual_text = true, underline = false})
    end
end

virtualtext.hide = function()
    local buffer = vim.fn.bufnr()
    local clients = vim.lsp.get_active_clients()
    local size = get_size(clients)
    for i = 1, size, 1 do
        vim.lsp.diagnostic.display(vim.lsp.diagnostic.get(buffer, i), buffer, i,
                                   {virtual_text = false, underline = false})
    end
end

return virtualtext
