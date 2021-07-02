local M = {}

M.init = function()
    local filetypes = {
        ["cpp"] = {"cpp"},
        ["css"] = {"css", "less", "scss"},
        ["dart"] = {"dart"},
        ["html"] = {"html"},
        ["json"] = {"json"},
        ["ruby"] = {"ruby"},
        ["yaml"] = {"yaml"}
    }
    function search_extensions(filetype)
        for k, v in pairs(filetypes) do
            for _, v2 in pairs(v) do
                if v2 == filetype then
                    require("configs.global.filetypes.filetypes." .. k)
                end
            end
        end
        return false
    end

    search_extensions(vim.bo.filetype)
end

return M
