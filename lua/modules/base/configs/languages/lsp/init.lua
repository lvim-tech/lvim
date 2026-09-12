-- LSP integration helpers for lvim-lsp.
-- Single entry-point used by:
--   • modules/user/init.lua      — on_attach keymaps + diagnostics/dap callbacks
--   • modules/base/configs/languages/init.lua  — lvim-lsp on_attach + get_capabilities
--   • modules/base/configs/editor/control_center/lsp.lua — progress toggle
--   • individual language server configs  — get_capabilities()
--
---@module "modules.base.configs.languages.lsp"

local M = {}

-- LSP buffer keymaps are defined in the central manifest (keys/base/lsp.lua)
-- and applied capability-guarded on LspAttach by core/keys.lua. No keymap
-- literals live in this module any more.

-- ── Capabilities ──────────────────────────────────────────────────────────────

--- Lazily-computed merged capabilities (built once and reused for all clients).
--- Merges lvim-cmp's completion capabilities fragment when that plugin is available.
---@return table
local _cached_capabilities = nil
M.get_capabilities = function()
    if _cached_capabilities then
        return _cached_capabilities
    end
    local caps = vim.lsp.protocol.make_client_capabilities()
    local ok, cmp = pcall(require, "lvim-cmp")
    if ok and cmp and type(cmp.capabilities) == "function" then
        caps = vim.tbl_deep_extend("force", caps, cmp.capabilities())
    end
    _cached_capabilities = caps
    return caps
end

return M
