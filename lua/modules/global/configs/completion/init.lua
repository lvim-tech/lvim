local config = {}

function config.nvim_cmp()
    local cmp = require("cmp")
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
        Folder = "   (Folder)",
        EnumMember = "   (EnumMember)",
        Constant = "   (Constant)",
        Struct = "   (Struct)",
        Event = "   (Event)",
        Operator = "   (Operator)",
        TypeParameter = "   (TypeParameter)"
    }
    cmp.setup(
        {
            mapping = {
                ["<C-p>"] = cmp.mapping.select_prev_item(),
                ["<C-n>"] = cmp.mapping.select_next_item(),
                ["<C-d>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-e>"] = cmp.mapping.close(),
                ["<CR>"] = cmp.mapping.confirm(
                    {
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true
                    }
                ),
                ["<Tab>"] = cmp.mapping(
                    cmp.mapping.select_next_item(),
                    {
                        "i",
                        "s"
                    }
                ),
                ["<S-Tab>"] = cmp.mapping(
                    cmp.mapping.select_prev_item(),
                    {
                        "i",
                        "s"
                    }
                )
            },
            formatting = {
                format = function(entry, item)
                    item.kind = lsp_symbols[item.kind]
                    item.menu =
                        ({
                        nvim_lsp = "[LSP]",
                        buffer = "[Buffer]",
                        path = "[Path]",
                        vsnip = "[VSnip]"
                    })[entry.source.name]
                    return item
                end
            },
            sources = {
                {
                    name = "nvim_lsp"
                },
                {
                    name = "vsnip"
                },
                {
                    name = "path"
                },
                {
                    name = "buffer"
                }
            },
            snippet = {
                expand = function(args)
                    vim.fn["vsnip#anonymous"](args.body)
                end
            }
        }
    )
end

function config.lspkind_nvim()
    require("lspkind").init(
        {
            with_text = true,
            symbol_map = {
                Text = " ",
                Method = "",
                Function = "",
                Constructor = "",
                Variable = "[]",
                Class = " ",
                Interface = "ﰮ",
                Module = "",
                Property = "襁",
                Unit = "",
                Value = "",
                Enum = "練",
                Keyword = "",
                Snippet = "",
                Color = "",
                File = "",
                Folder = "",
                EnumMember = "",
                Constant = "",
                Struct = ""
            }
        }
    )
end

function config.emmet_vim()
    vim.g.user_emmet_complete_tag = 0
    vim.g.user_emmet_install_global = 0
    vim.g.user_emmet_install_command = 0
    vim.g.user_emmet_mode = "a"
end

return config
