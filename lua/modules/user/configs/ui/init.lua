local config = {}

config.showkeys = function()
    local showkeys_status_ok, showkeys = pcall(require, "showkeys")
    if not showkeys_status_ok then
        return
    end
    showkeys.setup({
        timeout = 5,
        maxkeys = 6,
        show_count = true,
        position = "bottom-center",
    })
end

config.typr = function()
    local typr_status_ok, typr = pcall(require, "typr")
    if not typr_status_ok then
        return
    end
    typr.setup({
        kblayout = {
            { "q", "w", "e", "r", "t", "y", "u", "i", "o", "p" },
            { "a", "s", "d", "f", "g", "h", "j", "k", "l", ";" },
            { "z", "x", "c", "v", "b", "n", "m", ",", ".", "/" },
        },
    })
end

return config
