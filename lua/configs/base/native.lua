-- lua/configs/base/native.lua
-- Native (no-plugin) SEARCH + COMPLETION setup. Used while the completion plugin (blink.cmp) is off, so the
-- editor falls back to Neovim's built-in machinery: native `incsearch`/`hlsearch` search, the native
-- command-line completion (wildmenu / pum), and native LSP completion (`vim.lsp.completion`, autotrigger).
-- Kept in its own file so it's easy to find / remove. Registered as the `base_native` setup phase.

local M = {}

function M.setup()
    -- ── Native search ──────────────────────────────────────────────────────────
    vim.opt.incsearch = true -- live highlight/scroll to the match as you type
    vim.opt.hlsearch = true -- keep all matches highlighted after <CR>
    vim.opt.ignorecase = true -- case-insensitive search …
    vim.opt.smartcase = true -- … unless the pattern has an uppercase letter
    vim.opt.wrapscan = true -- searches wrap around the end of the file

    -- ── Native command-line completion ─────────────────────────────────────────
    vim.opt.wildmenu = true
    vim.opt.wildmode = "longest:full,full" -- complete the longest common prefix, then cycle the full list
    vim.opt.wildoptions = "pum,tagfile" -- show the candidates in a popup menu

    -- ── Native LSP + insert completion ─────────────────────────────────────────
    -- DISABLED: the completion engine is now lvim-cmp (it replaced blink.cmp), so Neovim's built-in
    -- LSP completion must NOT also run — otherwise the native `pum` autotriggers ON TOP of the lvim-cmp
    -- menu (native `noselect`, drawn over the float) and hides its selection / clashes with it. Re-enable
    -- this block ONLY if you turn lvim-cmp off and want the plugin-free native popup back.
    --
    -- This file is the SOLE owner of `completeopt` (options.lua no longer sets it) — so while the block
    -- below is commented out the option keeps Neovim's default and no ins-completion path can raise a pum.
    -- vim.opt.completeopt = { "menu", "menuone", "noselect", "fuzzy", "popup" }
    -- vim.opt.pumheight = 15
    --
    -- local grp = vim.api.nvim_create_augroup("LvimNativeLspCompletion", { clear = true })
    -- vim.api.nvim_create_autocmd("LspAttach", {
    --     group = grp,
    --     callback = function(args)
    --         local client = vim.lsp.get_client_by_id(args.data.client_id)
    --         if not client then
    --             return
    --         end
    --         local ok_method = pcall(function()
    --             return client:supports_method("textDocument/completion")
    --         end)
    --         if ok_method and vim.lsp.completion and vim.lsp.completion.enable then
    --             pcall(vim.lsp.completion.enable, true, client.id, args.buf, { autotrigger = true })
    --         end
    --     end,
    -- })

    -- (The command-line completion-grid keymaps are owned by the lvim-utils `native` integration now, driven
    --  by `config.msgarea.completion_keys` — no longer hardcoded here.)
end

return M
