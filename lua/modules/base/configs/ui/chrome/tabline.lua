-- modules.base.configs.ui.chrome.tabline
-- The TABLINE DEFINITION for lvim-hud.chrome — tabby.nvim's functionality, on the chrome engine. The plugin
-- ships no predefined sections (like heirline); every section lives HERE. Reuses chrome.parts (no
-- duplication). Layout (= the tabby setup): vim logo · current-tab WINDOWS (clickable → focus, tabby's
-- `type = "win"`) · %= · lvim-space tabs · workspace · project.
---@module "modules.base.configs.ui.chrome.tabline"

local parts = require("lvim-hud.chrome.parts")
local engine = require("lvim-hud.chrome.engine")
local api = vim.api

---@type LvimChromeSegment[]
return {
    -- vim logo
    {
        name = "tl_logo",
        content = function()
            return parts.seg("TabLogo", " " .. parts.icons().vim .. " ")
        end,
    },
    -- current-tab windows (skip floats + excluded fts) — CLICKABLE: a click focuses the window (tabby win)
    {
        name = "tl_windows",
        content = function()
            local tab = api.nvim_get_current_tabpage()
            local active = api.nvim_tabpage_get_win(tab)
            local out = {}
            for _, w in ipairs(api.nvim_tabpage_list_wins(tab)) do
                if api.nvim_win_get_config(w).relative == "" then
                    local buf = api.nvim_win_get_buf(w)
                    -- `excluded` needs the COMPONENT name: without it there is no blacklist to check and the
                    -- guard silently passed everything, so panel windows claimed a cell. `listable` then keeps
                    -- unnamed buffers out unless they are a real unsaved draft (see chrome.parts).
                    if not parts.excluded(buf, "tabline") and parts.listable(buf) then
                        local grp = (w == active) and "TabActive" or "TabInactive"
                        local cell = parts.seg(grp, "  " .. parts.unique_name(w) .. "  ")
                        out[#out + 1] = engine.click_region(w, function()
                            pcall(api.nvim_set_current_win, w)
                        end, cell)
                    end
                end
            end
            return table.concat(out)
        end,
    },

    { align = true }, -- push the lvim-space side to the right

    -- lvim-space tabs · workspace · project. The TABS are CLICKABLE: a click switches
    -- to that lvim-space tab (via lvim-space.pub.switch_tab). Tab click-keys are offset
    -- by TAB_KEY_BASE so they can never collide with the window cells' keys (raw window
    -- handles) registered by tl_windows in the same render.
    {
        name = "tl_space",
        content = function()
            local ok, pub = pcall(require, "lvim-space.pub")
            if not (ok and pub.get_tab_info) then
                return ""
            end
            local TAB_KEY_BASE = 500000
            local info = pub.get_tab_info() or {}
            local out = {}
            for _, t in ipairs(info.tabs or {}) do
                local grp = t.active and "TabActive" or "TabInactive"
                local cell = parts.seg(grp, "  " .. tostring(t.name) .. "  ")
                if t.id and pub.switch_tab then
                    local tab_id = t.id
                    out[#out + 1] = engine.click_region(TAB_KEY_BASE + tab_id, function()
                        pub.switch_tab(tab_id)
                        vim.cmd("redrawtabline")
                    end, cell)
                else
                    out[#out + 1] = cell
                end
            end
            local ws = info.workspace_name
            if ws and ws ~= "Unknown" and ws ~= "" then
                out[#out + 1] = parts.seg("TabWorkspace", "  " .. ws .. "  ")
            end
            local proj = info.project_name
            if proj and proj ~= "Unknown" and proj ~= "" then
                out[#out + 1] = parts.seg("TabProject", "  " .. proj .. "  ")
            end
            return table.concat(out)
        end,
    },
}
