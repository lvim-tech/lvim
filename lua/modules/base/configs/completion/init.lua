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
    require("luasnip.loaders.from_lua").lazy_load({ paths = vim.fn.stdpath("config") .. "/snippets/lua" })
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
    local rule = require("nvim-autopairs.rule")
    local cond = require("nvim-autopairs.conds")
    local ts_conds = require("nvim-autopairs.ts-conds")
    local brackets = { { "(", ")" }, { "[", "]" }, { "{", "}" } }
    nvim_autopairs.add_rules({
        rule(" ", " ", "-markdown")
            :with_pair(function(opts)
                local pair = opts.line:sub(opts.col - 1, opts.col)
                return vim.tbl_contains({
                    brackets[1][1] .. brackets[1][2],
                    brackets[2][1] .. brackets[2][2],
                    brackets[3][1] .. brackets[3][2],
                }, pair)
            end)
            :with_move(cond.none())
            :with_cr(cond.none())
            :with_del(function(opts)
                local col = vim.api.nvim_win_get_cursor(0)[2]
                local context = opts.line:sub(col - 1, col + 2)
                return vim.tbl_contains({
                    brackets[1][1] .. "  " .. brackets[1][2],
                    brackets[2][1] .. "  " .. brackets[2][2],
                    brackets[3][1] .. "  " .. brackets[3][2],
                }, context)
            end),
    })
    for _, bracket in pairs(brackets) do
        nvim_autopairs.add_rules({
            rule(bracket[1] .. " ", " " .. bracket[2])
                :with_pair(function()
                    return false
                end)
                :with_del(function()
                    return false
                end)
                :with_move(function(opts)
                    return opts.prev_char:match(".%" .. bracket[2]) ~= nil
                end)
                :use_key(bracket[2]),
            rule(bracket[1], bracket[2]):with_pair(cond.after_text("$")),
            rule(bracket[1] .. bracket[2], ""):with_pair(function()
                return false
            end),
        })
    end
    nvim_autopairs.add_rule(rule("$", "$", "markdown")
        :with_move(function(opts)
            return opts.next_char == opts.char
                and ts_conds.is_ts_node({
                    "inline_formula",
                    "displayed_equation",
                    "math_environment",
                })(opts)
        end)
        :with_pair(ts_conds.is_not_ts_node({
            "inline_formula",
            "displayed_equation",
            "math_environment",
        }))
        :with_pair(cond.not_before_text("\\")))
    nvim_autopairs.add_rule(rule("/**", "  */"):with_pair(cond.not_after_regex(".-%*/", -1)):set_end_pair_length(3))
    nvim_autopairs.add_rule(rule("**", "**", "markdown"):with_move(function(opts)
        return cond.after_text("*")(opts) and cond.not_before_text("\\")(opts)
    end))
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
