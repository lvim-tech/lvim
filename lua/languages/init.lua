-- Description: Entry point for the LVIM language / LSP subsystem.
-- Registers autocommands that trigger LSP attachment on buffer events and
-- wires up the :LspReattach user command.  Also handles cleanup of stale
-- LSP servers when the working directory changes.
--
---@module "languages.init"

local lsp_manager = require("languages.lsp_manager")

---@type integer  Autocommand group used for all LSP-enable autocmds in this module
local group = vim.api.nvim_create_augroup("LvimLSPEnable", { clear = true })

local M = {}

--- Inspects the filetype of `bufnr`, finds every server key in
--- `_G.LVIM.file_types` whose filetype list includes that filetype, and
--- calls `lsp_manager.ensure_lsp_for_buffer` for each non-disabled match.
--- Also attaches the EFM language server when the filetype has a registered
--- EFM configuration.
---@param bufnr integer  Buffer handle to attach LSP servers to
local function attach_lsp_to_buffer(bufnr)
    if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
        return
    end
    local ft = vim.bo[bufnr].filetype
    if not ft or ft == "" then
        return
    end

    -- Collect every server key that declares support for this filetype
    ---@type string[]
    local matches = {}
    for key, filetypes in pairs(_G.LVIM.file_types or {}) do
        if vim.tbl_contains(filetypes, ft) then
            table.insert(matches, key)
        end
    end

    for _, match in ipairs(matches) do
        if
            not lsp_manager.is_server_disabled_globally(match)
            and not lsp_manager.is_server_disabled_for_buffer(match, bufnr)
        then
            lsp_manager.ensure_lsp_for_buffer(match, bufnr)
        end
    end

    -- Attach EFM if the filetype has per-file EFM config OR is listed in the
    -- global EFM filetypes table
    if
        (_G.efm_configs and _G.efm_configs[ft])
        or (_G.LVIM.global and _G.LVIM.global.efm and _G.LVIM.global.efm.filetypes and vim.tbl_contains(_G.LVIM.global.efm.filetypes, ft))
    then
        if
            not lsp_manager.is_server_disabled_globally("efm")
            and not lsp_manager.is_server_disabled_for_buffer("efm", bufnr)
        then
            lsp_manager.ensure_lsp_for_buffer("efm", bufnr)
        end
    end
end

--- Bootstraps the autocommand listeners and performs an initial sweep of all
--- already-loaded buffers so that LSP servers are attached immediately on
--- startup without waiting for the next file-open event.
---@return nil
M.init = function()
    -- Defer setup by 100 ms to allow the rest of the config to finish loading
    vim.defer_fn(function()
        -- Attach LSP when Neovim sets the filetype on a buffer
        vim.api.nvim_create_autocmd("FileType", {
            group = group,
            callback = function(args)
                local bufnr = args.buf
                attach_lsp_to_buffer(bufnr)
            end,
        })

        -- Re-check on BufEnter / BufReadPost with a short delay so the
        -- filetype option is guaranteed to be set before we inspect it
        vim.api.nvim_create_autocmd({ "BufEnter", "BufReadPost" }, {
            group = group,
            callback = function(args)
                local bufnr = args.buf
                vim.defer_fn(function()
                    if vim.api.nvim_buf_is_valid(bufnr) then
                        attach_lsp_to_buffer(bufnr)
                    end
                end, 100)
            end,
        })

        -- Manual command for forcing re-attachment on the current buffer
        vim.api.nvim_create_user_command("LspReattach", function()
            local bufnr = vim.api.nvim_get_current_buf()
            attach_lsp_to_buffer(bufnr)
        end, {})

        -- Stop servers that belong to a different project root after a
        -- directory change; a 5-second delay avoids premature shutdown while
        -- the shell is still in transition
        vim.api.nvim_create_autocmd("DirChanged", {
            pattern = "*",
            callback = function()
                vim.defer_fn(function()
                    require("languages.lsp_manager").stop_servers_for_old_project()
                    vim.cmd("Fidget clear")
                end, 5000)
            end,
            desc = "Stops LSP servers from other projects when directory is changed",
        })

        -- Attach to any buffers that were already open before init() ran
        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].filetype ~= "" then
                attach_lsp_to_buffer(bufnr)
            end
        end
    end, 100)
end

--- Indicates that the LSP subsystem is active.
--- Kept for compatibility with callers that expect a boolean guard.
---@return boolean  Always `true`
M.lsp_enable = function()
    return true
end

--- Returns all server keys in `_G.LVIM.file_types` whose declared filetype
--- list contains `ft`.
---@param ft string  Filetype string (e.g. `"lua"`, `"python"`)
---@return string[]  List of matching server/language keys
M.find_matching_keys = function(ft)
    if not ft or ft == "" then
        return {}
    end

    ---@type string[]
    local matches = {}
    for key, filetypes in pairs(_G.LVIM.file_types or {}) do
        if vim.tbl_contains(filetypes, ft) then
            table.insert(matches, key)
        end
    end
    return matches
end

-- Alias so callers can use either M.init() or M.setup()
M.setup = M.init

return M
