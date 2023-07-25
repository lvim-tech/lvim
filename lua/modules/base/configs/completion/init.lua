local config = {}

config.nvim_cmp = function()
    local icons = require("configs.base.ui.icons")
    local cmp_status_ok, cmp = pcall(require, "cmp")
    if not cmp_status_ok then
        return
    end
    local snip_status_ok, luasnip = pcall(require, "luasnip")
    if not snip_status_ok then
        return
    end
    require("luasnip.loaders.from_lua").lazy_load()
    require("luasnip.loaders.from_vscode").lazy_load()
    require("luasnip.loaders.from_vscode").lazy_load({ paths = vim.fn.stdpath("config") .. "/snippets/vscode" })
    local check_backspace = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    end
    local lsp_symbols = icons.cmp
    cmp.setup({
        snippet = {
            expand = function(args)
                luasnip.lsp_expand(args.body)
            end,
        },
        mapping = {
            ["<C-j>"] = cmp.mapping.select_next_item(),
            ["<C-k>"] = cmp.mapping.select_prev_item(),
            ["<C-d>"] = cmp.mapping.scroll_docs(4),
            ["<C-u>"] = cmp.mapping.scroll_docs(-4),
            ["<C-Leader>"] = cmp.mapping.complete(),
            ["<C-e>"] = cmp.mapping.close(),
            ["<CR>"] = cmp.mapping.confirm({
                behavior = cmp.ConfirmBehavior.Replace,
                select = true,
            }),
            ["<Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_next_item()
                elseif luasnip.expandable() then
                    luasnip.expand()
                elseif luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump()
                elseif require("neogen").jumpable() then
                    require("neogen").jump_next()
                elseif check_backspace() then
                    fallback()
                else
                    fallback()
                end
            end, { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                elseif luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                elseif require("neogen").jumpable() then
                    require("neogen").jump_prev()
                else
                    fallback()
                end
            end, { "i", "s" }),
        },
        formatting = {
            format = function(entry, item)
                item.kind = lsp_symbols[item.kind]
                item.menu = ({
                    nvim_lsp = "[LSP]",
                    luasnip = "[Snippet]",
                    buffer = "[Buffer]",
                    path = "[Path]",
                    crates = "[Crates]",
                    latex_symbols = "[LaTex]",
                })[entry.source.name]
                return item
            end,
        },
        sources = {
            {
                name = "nvim_lsp",
            },
            {
                name = "luasnip",
            },
            {
                name = "buffer",
            },
            {
                name = "path",
            },
            {
                name = "crates",
            },
            {
                name = "latex_symbols",
            },
            {
                name = "orgmode",
            },
        },
    })
    cmp.setup.cmdline({ ":", "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
            {
                name = "cmdline",
            },
            {
                name = "buffer",
            },
            {
                name = "path",
            },
        },
    })
    cmp.setup.cmdline({ "@" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
            {
                name = "path",
            },
        },
    })
end

config.nvim_autopairs = function()
    local nvim_autopairs_status_ok, nvim_autopairs = pcall(require, "nvim-autopairs")
    if not nvim_autopairs_status_ok then
        return
    end
    nvim_autopairs.setup({
        check_ts = true,
        ts_config = {
            lua = {
                "string",
            },
            javascript = {
                "template_string",
            },
            java = false,
        },
    })
end

config.nvim_ts_autotag = function()
    local nvim_ts_autotag_status_ok, nvim_ts_autotag = pcall(require, "nvim-ts-autotag")
    if not nvim_ts_autotag_status_ok then
        return
    end
    nvim_ts_autotag.setup()
end

config.nvim_surround = function()
    local nvim_surround_status_ok, nvim_surround = pcall(require, "nvim-surround")
    if not nvim_surround_status_ok then
        return
    end
    nvim_surround.setup()
end

return config
