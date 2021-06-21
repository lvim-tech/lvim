local M = {}

M.init = function()
    local filetypes = {
        ["cpp"] = {"c", "cpp"},
        ["omnisharp"] = {"cs", "vb"},
        ["java"] = {"java"},
        ["rust"] = {"rust"},
        ["go"] = {"go"},
        ["python"] = {"python"},
        ["ruby"] = {"ruby"},
        ["lua"] = {"lua"},
        ["php"] = {"php"},
        ["dart"] = {"dart"},
        ["elixir"] = {"elixir"},
        ["bash"] = {"sh"},
        ["vim"] = {"vim"},
        ["js-ts"] = {
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact"
        },
        ["graphql"] = {"graphql"},
        ["docker"] = {"dockerfile"},
        ["json"] = {"json"},
        ["latex"] = {"tex"},
        ["yaml"] = {"yaml"},
        ["svelte"] = {"svelte"},
        ["html"] = {"html"},
        ["css"] = {"css", "less", "scss"}
    }
    function search_extensions(filetype)
        for k, v in pairs(filetypes) do
            for _, v2 in pairs(v) do
                if v2 == filetype then
                    require("configs.global.filetypes.languages." .. k)
                end
            end
        end
        return false
    end

    search_extensions(vim.bo.filetype)
end

return M
