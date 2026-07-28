-- modules.base.configs.ui.chrome.statuscolumn
-- The STATUSCOLUMN (per-line gutter) DEFINITION for lvim-hud.chrome. The plugin ships only the engine +
-- helpers (no predefined sections — like heirline); every section lives HERE. The engine renders this list
-- PER LINE (ctx = { buf, win, lnum, relnum, virtnum }); reuses chrome.gutter/parts (no duplication); clicks go
-- through each section's `click.run` (resolving the clicked line via chrome.gutter).
--
-- Layout: [other-sign][diagnostic-sign] %= [number] [git-gutter] — all cells use NATIVE gutter groups so the
-- whole gutter keeps one uniform dimmed background.
---@module "modules.base.configs.ui.chrome.statuscolumn"

local gutter = require("lvim-hud.chrome.gutter")
local parts = require("lvim-hud.chrome.parts")
local api = vim.api

-- toggles (edit freely)
local SHOW_MARKS = true -- a / b… mark letter in the number cell
local SHOW_GIT_GUTTER = true -- the git-sign-coloured vertical bar (dim when no provider decorates)

-- click action for a NON-diagnostic/-git sign, keyed by a Lua pattern on the sign name (edit / extend freely)
local OTHER_CLICK = {
    ["LvimDap.*"] = function()
        pcall(function()
            require("lvim-dap").continue()
        end)
    end,
}

--- The line-number cell (mark letter / absolute / relative, padded, CursorLineNr vs LineNr).
---@param ctx LvimChromeCtx
---@return string
local function line_number(ctx)
    local buf, win = ctx.buf, ctx.win
    local ft = vim.bo[buf].filetype
    if ft == "qf" or ft == "org" or ctx.virtnum ~= 0 then
        return ""
    end
    if not vim.wo[win].number then
        return ""
    end
    local max_len = #tostring(api.nvim_buf_line_count(buf))
    local mark = SHOW_MARKS and gutter.mark_letter(buf, ctx.lnum, ctx.win) or ""
    if mark ~= "" then
        local pad = (ctx.relnum == 0) and string.rep(" ", math.max(0, max_len - 1)) or ""
        return ("%%#LvimUiChromeMark#%s%s%%*"):format(pad, mark)
    end
    local n
    if ctx.relnum == 0 then
        n = ctx.lnum
    else
        n = vim.wo[win].relativenumber and ctx.relnum or ctx.lnum
    end
    local str = tostring(n)
    local pad = string.rep(" ", math.max(0, max_len - #str))
    local hl = (ctx.relnum == 0) and "CursorLineNr" or "LineNr"
    return ("%%#%s#%s%s%%*"):format(hl, pad, str)
end

---@type LvimChromeSegment[]
return {
    -- non-diagnostic, non-git signs (the highest-priority one with text) — click dispatches by sign name
    {
        name = "sc_other",
        click = {
            name = "sc_other",
            run = function()
                local s = gutter.sign_at_mouse(gutter.is_other)
                if s then
                    for pat, cb in pairs(OTHER_CLICK) do
                        if s.name:match(pat) then
                            return cb()
                        end
                    end
                end
            end,
        },
        content = function(ctx)
            -- A wrapped line is drawn as several screen rows and this function runs for each of
            -- them; without the guard the sign is repeated on every continuation row, which reads as
            -- two signs for one mark.
            if ctx.virtnum == 0 then
                for _, e in ipairs(gutter.signs(ctx.buf, ctx.lnum, gutter.is_other)) do
                    if e.text ~= "" then
                        return ("%%#%s#%s %%*"):format(e.sign_hl_group, vim.trim(e.text))
                    end
                end
            end
            -- A blank cell of the SAME width, exactly as the diagnostic section below does. Returning
            -- "" instead would make the gutter narrower on lines without a sign, so every line that
            -- gained or lost one — a search marker moving with the viewport, say — would shift the
            -- text sideways.
            return "  "
        end,
    },
    -- diagnostic sign (the sign's own colour + our icon), or a blank cell — click opens the diagnostics list
    {
        name = "sc_diag",
        click = {
            name = "sc_diag",
            run = function()
                if gutter.sign_at_mouse(gutter.is_diag) then
                    pcall(vim.cmd, "LvimLsp diagnostics")
                end
            end,
        },
        content = function(ctx)
            local s = gutter.signs(ctx.buf, ctx.lnum, gutter.is_diag)[1]
            if not s then
                return " "
            end
            return ("%%#%s#%s %%*"):format(s.sign_hl_group, gutter.diag_icon(s.sign_hl_group))
        end,
    },

    { align = true }, -- push the number + gutter to the right

    -- line number (+ mark) — click toggles a DAP breakpoint on that line
    {
        name = "sc_number",
        click = {
            name = "sc_number",
            run = function()
                gutter.at_mouse()
                pcall(function()
                    require("lvim-dap").toggle_breakpoint()
                end)
            end,
        },
        content = line_number,
    },
    { content = " " },
    -- git-gutter bar: ONE symbol (the vline), COLOURED by the line's git state via lvim-git's public
    -- `line_hl` (add/change/delete/… each a distinct hl) — no separate glyph; the colour tells the state.
    -- Dim `LineNr` bar when the line has no git change (or lvim-git is not loaded).
    {
        name = "sc_git",
        content = function(ctx)
            local bar = parts.icons().vline
            if SHOW_GIT_GUTTER then
                local ok, signs = pcall(require, "lvim-git.signs")
                local hl = ok and signs.line_hl(ctx.buf, ctx.lnum)
                if hl then
                    return ("%%#%s#%s%%*"):format(hl, bar)
                end
            end
            return ("%%#LineNr#%s%%*"):format(bar)
        end,
    },
    { content = " " },
}
