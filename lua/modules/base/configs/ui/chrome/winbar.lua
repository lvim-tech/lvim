-- modules.base.configs.ui.chrome.winbar
-- The WINBAR (per-window top line) DEFINITION for lvim-hud.chrome. The plugin ships no predefined sections
-- (like heirline); every section lives HERE. The engine renders this list PER WINDOW (ctx = { buf, win,
-- active }); each section gates itself with `when`. Reuses chrome.parts/utils (no duplication).
--
-- Branches (mutually exclusive via `when`): terminal label · file (devicon + unique name) · the
-- lvim-breadcrumbs symbol trail (a ready-made hud segment; active windows only, clickable).
---@module "modules.base.configs.ui.chrome.winbar"

local parts = require("lvim-hud.chrome.parts")
local chrome_util = require("lvim-hud.chrome.utils")
local api = vim.api

---@param buf integer
---@return boolean
local function is_term(buf)
    return vim.bo[buf].buftype == "terminal"
end

---@type LvimChromeSegment[]
local segments = {
    -- terminal: filetype label + process name
    {
        name = "wb_term",
        when = function(ctx)
            return is_term(ctx.buf)
        end,
        content = function(ctx)
            local ic = parts.icons()
            local ft = vim.bo[ctx.buf].filetype
            local label = ft ~= "" and parts.seg("Blue", "  " .. ft:upper() .. " ") or ""
            local pname = api.nvim_buf_get_name(ctx.buf):gsub(".*:", "")
            return label .. parts.seg("Red", ic.terminal .. " " .. pname)
        end,
    },
    -- file: devicon + unique filename (every non-terminal window)
    {
        name = "wb_file",
        when = function(ctx)
            return not is_term(ctx.buf)
        end,
        content = function(ctx)
            local out = {}
            local icon, grp = parts.devicon(ctx.buf, chrome_util.bar_bg())
            if icon then
                out[#out + 1] = ("%%#%s# %s %%*"):format(grp, icon)
            end
            out[#out + 1] = parts.seg("Red", parts.unique_name(ctx.win) .. "  ")
            return table.concat(out)
        end,
    },
}

-- lvim-breadcrumbs: the symbol trail (module ➤ class ➤ method) as a ready-made hud winbar segment —
-- per-kind coloured (the lvim-lsp outline accent set), clickable (jumps to the symbol), rendered in
-- active windows only. No file_prefix — the wb_file section above already leads with the file.
--
-- GUARDED, because the plugin loads on LspAttach: this module is resolved the first time the winbar
-- renders, which can be before any language server has attached. A hard require would abort the
-- whole winbar then. The trail has nothing to show until a server attaches anyway, and the winbar
-- is rebuilt per render, so it appears with the first attach.
local ok_bc, breadcrumbs = pcall(require, "lvim-breadcrumbs")
if ok_bc then
    segments[#segments + 1] = breadcrumbs.hud_segment()
end

return segments
