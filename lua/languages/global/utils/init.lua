local lsp_installer_servers = require("nvim-lsp-installer.servers")
local global = require("core.global")
local group_lsp_format = vim.api.nvim_create_augroup("GroupLspFormat", {
	clear = true,
})
local group_highlight = vim.api.nvim_create_augroup("GroupHighlight", {
	clear = true,
})

local M = {}

M.setup_lsp = function(server_name, start_fn)
	local ok, server = lsp_installer_servers.get_server(server_name)
	if ok then
		server:on_ready(start_fn)
		if not server:is_installed() then
			server:install()
		end
	else
		print("Error starting lsp server " .. server_name)
	end
end

M.config_diagnostic = {
	virtual_text = false,
	update_in_insert = true,
	underline = true,
	severity_sort = true,
}

M.icons = {
	error = "",
	warn = "",
	hint = "",
	info = "",
}

M.setup_diagnostic = function(custom_config_diagnostic)
	local local_config_diagnostic
	if custom_config_diagnostic ~= nil then
		local_config_diagnostic = custom_config_diagnostic
	else
		local_config_diagnostic = M.config_diagnostic
	end
	vim.lsp.handlers["textDocument/publishDiagnostics"] = function(_, result, ctx)
		local uri = result.uri
		local bufnr = vim.uri_to_bufnr(uri)
		if not bufnr then
			return
		end
		local diagnostics = result.diagnostics
		local ok, vim_diag = pcall(require, "vim.diagnostic")
		if ok then
			for i, diagnostic in ipairs(diagnostics) do
				local rng = diagnostic.range
				diagnostics[i].lnum = rng["start"].line
				diagnostics[i].end_lnum = rng["end"].line
				diagnostics[i].col = rng["start"].character
				diagnostics[i].end_col = rng["end"].character
			end
			local namespace = vim.lsp.diagnostic.get_namespace(ctx.client_id)
			vim_diag.set(namespace, bufnr, diagnostics, local_config_diagnostic)
			if not vim.api.nvim_buf_is_loaded(bufnr) then
				return
			end
			vim.fn.sign_define("DiagnosticSignError", {
				texthl = "DiagnosticSignError",
				text = M.icons.error,
				numhl = "DiagnosticSignError",
			})
			vim.fn.sign_define("DiagnosticSignWarn", {
				texthl = "DiagnosticSignWarn",
				text = M.icons.warn,
				numhl = "DiagnosticSignWarn",
			})
			vim.fn.sign_define("DiagnosticSignHint", {
				texthl = "DiagnosticSignHint",
				text = M.icons.hint,
				numhl = "DiagnosticSignHint",
			})
			vim.fn.sign_define("DiagnosticSignInfo", {
				texthl = "DiagnosticSignInfo",
				text = M.icons.info,
				numhl = "DiagnosticSignInfo",
			})
			vim_diag.show(namespace, bufnr, diagnostics, local_config_diagnostic)
		end
	end
end

M.document_highlight = function(client)
	if client.resolved_capabilities.document_highlight then
		vim.api.nvim_create_autocmd("CursorHold", {
			callback = function()
				vim.lsp.buf.document_highlight()
			end,
			group = group_highlight,
		})
		vim.api.nvim_create_autocmd("CursorMoved", {
			callback = function()
				vim.lsp.buf.clear_references()
			end,
			group = group_highlight,
		})
	end
end

M.document_formatting = function(client)
	if client.resolved_capabilities.document_formatting then
		vim.api.nvim_create_autocmd("BufWritePre", {
			callback = function()
				vim.lsp.buf.formatting_seq_sync()
			end,
			group = group_lsp_format,
		})
	end
end

M.get_capabilities = function()
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities.textDocument.completion.completionItem.snippetSupport = true
	capabilities.textDocument.completion.completionItem.resolveSupport = {
		properties = {
			"documentation",
			"detail",
			"additionalTextEdits",
		},
	}
	local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
	if status_ok then
		capabilities = cmp_nvim_lsp.update_capabilities(capabilities)
	end
	return capabilities
end

M.toggle_virtual_text = function()
	if global.virtual_text == "no" then
		local config_diagnostic = {
			virtual_text = {
				prefix = "",
				spacing = 4,
			},
			update_in_insert = true,
			underline = true,
			severity_sort = true,
		}
		M.setup_diagnostic(config_diagnostic)
		if vim.api.nvim_buf_get_option(0, "modifiable") then
			vim.cmd("w")
		end
		global.virtual_text = "yes"
	else
		M.setup_diagnostic()
		if vim.api.nvim_buf_get_option(0, "modifiable") then
			vim.cmd("w")
		end
		global.virtual_text = "no"
	end
end

return M
