local config = {}

function config.cmp()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    local lsp_symbols = {
        Text = "   (Text) ",
        Method = "   (Method)",
        Function = "   (Function)",
        Constructor = "   (Constructor)",
        Field = " ﴲ  (Field)",
        Variable = "[] (Variable)",
        Class = "   (Class)",
        Interface = " ﰮ  (Interface)",
        Module = "   (Module)",
        Property = " 襁 (Property)",
        Unit = "   (Unit)",
        Value = "   (Value)",
        Enum = " 練 (Enum)",
        Keyword = "   (Keyword)",
        Snippet = "   (Snippet)",
        Color = "   (Color)",
        File = "   (File)",
        Reference = "   (Reference)",
        Folder = "   (Folder)",
        EnumMember = "   (EnumMember)",
        Constant = " ﲀ  (Constant)",
        Struct = " ﳤ  (Struct)",
        Event = "   (Event)",
        Operator = "   (Operator)",
        TypeParameter = "   (TypeParameter)"
    }

    cmp.setup({
        sources = {
            {name = "buffer"},
            {name = "nvim_lsp"},
            {name = "path"},
            {name = "luasnip"}
        },
        mapping = {
            ["<cr>"] = cmp.mapping.confirm({select = true}),
            ["<s-tab>"] = cmp.mapping.select_prev_item(),
            ["<tab>"] = cmp.mapping.select_next_item()
        },
        formatting = {
            format = function(entry, item)
                item.kind = lsp_symbols[item.kind]
                item.menu = ({
                    buffer = "[Buffer]",
                    nvim_lsp = "[LSP]",
                    path = "[Path]",
                    luasnip = "[Snippet]"
                })[entry.source.name]

                return item
            end,
        },
        snippet = {
            expand = function(args)
                luasnip.lsp_expand(args.body)
            end,
        },
    })

end

function config.emmet()
    vim.g.user_emmet_complete_tag = 0
    vim.g.user_emmet_install_global = 0
    vim.g.user_emmet_install_command = 0
    vim.g.user_emmet_mode = "a"
end

function config.lspkind()
    require("lspkind").init({
        with_text = true,
        symbol_map = {
            -- Text = "",
            Method = "ƒ",
            Function = "",
            Constructor = "",
            Variable = "",
            Class = "",
            Interface = "ﰮ",
            Module = "",
            Property = "",
            Unit = "",
            Value = "",
            Enum = "了",
            Keyword = "",
            Snippet = "﬌",
            Color = "",
            File = "",
            Folder = "",
            EnumMember = "",
            Constant = "",
            Struct = ""
        }
    })
end

return config
