local config = {}

function config.nvim_cmp()
	local cmp_status_ok, cmp = pcall(require, "cmp")
	if not cmp_status_ok then
		return
	end
	local snip_status_ok, luasnip = pcall(require, "luasnip")
	if not snip_status_ok then
		return
	end
	require("luasnip.loaders.from_vscode").lazy_load()
	local check_backspace = function()
		local col = vim.fn.col(".") - 1
		return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
	end
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
		TypeParameter = "   (TypeParameter)",
	}
	cmp.setup({
		snippet = {
			expand = function(args)
				luasnip.lsp_expand(args.body)
			end,
		},
		mapping = {
			["<C-p>"] = cmp.mapping.select_prev_item(),
			["<C-n>"] = cmp.mapping.select_next_item(),
			["<C-d>"] = cmp.mapping.scroll_docs(-4),
			["<C-f>"] = cmp.mapping.scroll_docs(4),
			["<C-Space>"] = cmp.mapping.complete(),
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
				else
					fallback()
				end
			end, { "i", "s" }),
		},
		formatting = {
			format = function(entry, item)
				item.kind = lsp_symbols[item.kind]
				item.menu = ({
					luasnip = "[Snippet]",
					nvim_lsp = "[LSP]",
					buffer = "[Buffer]",
					path = "[Path]",
				})[entry.source.name]
				return item
			end,
		},
		sources = {
			{
				name = "luasnip",
			},
			{
				name = "nvim_lsp",
			},
			{
				name = "path",
			},
			{
				name = "buffer",
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
	cmp.setup.cmdline("/", {
		sources = {
			{ name = "buffer" },
		},
	})
	cmp.setup.cmdline(":", {
		sources = cmp.config.sources({
			{ name = "path" },
		}, {
			{ name = "cmdline" },
		}),
	})
end

function config.emmet_vim()
	vim.g.user_emmet_complete_tag = 0
	vim.g.user_emmet_install_global = 0
	vim.g.user_emmet_install_command = 0
	vim.g.user_emmet_mode = "a"
end

return config
