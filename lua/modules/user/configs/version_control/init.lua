local config = {}

config.nvim_fundo = function()
    local fundo_status_ok, fundo = pcall(require, "fundo")
    if not fundo_status_ok then
        return
    end
    fundo.setup({
        archives_dir = "/mnt/storage/biserstoilov/.fundo",
    })
end

return config
