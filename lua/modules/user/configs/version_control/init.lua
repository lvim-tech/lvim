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

config.fugit2_nvim = function()
    local fugit2_status_ok, fugit2 = pcall(require, "fugit2")
    if not fugit2_status_ok then
        return
    end
    fugit2.setup({})
end

return config
