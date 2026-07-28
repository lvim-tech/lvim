-- modules.base.configs.ui.chrome.statusline
-- The STATUSLINE DEFINITION for lvim-hud.chrome. The plugin ships only the engine + helpers (no predefined
-- segments — exactly like heirline); every segment lives HERE, in the config. The engine renders this list
-- with per-segment caching keyed by each segment's `events`. Reuses the chrome helpers (parts/utils) so no
-- data/format logic is duplicated; reorder / restyle / extend freely; any segment may carry a `click`.
--
-- Segment spec: { name, content = fn(ctx)->str, hl?, when?, events?, click?, buf?, align? } — see chrome.engine.
---@module "modules.base.configs.ui.chrome.statusline"

local parts = require("lvim-hud.chrome.parts")
local chrome_util = require("lvim-hud.chrome.utils")
local git_poll = require("lvim-hud.chrome.git")
local api = vim.api

-- presentation primitives (reused, never reimplemented)
local paint = parts.seg -- (group, text) -> "%#group#text%*"
local glyphs = parts.icons -- () -> the icon table
local human_size = chrome_util.size_str -- bytes -> "12.3 KB"
local device_icon = parts.devicon -- (buf, bg) -> icon, group
local bar_dark = chrome_util.bar_bg -- the bar background hex

-- the git User event the poller fires when branch/HEAD changes (so git/hunks rebuild)
local GIT_PULSE = "User:LvimUiChromeGit"

-- ── data helpers (live here, with the segments that use them — no plugin duplication) ────────────────────

--- Active LSP servers + EFM linters/formatters for `buf` (every dependency pcall-guarded). Expensive — the
--- engine gates it to the lsp segment's `events`, so it runs only on change.
---@param buf integer
---@return string
local function lsp_tools(buf)
    local clients = vim.lsp.get_clients({ bufnr = buf })
    if #clients == 0 then
        return ""
    end
    local servers = {}
    for _, c in ipairs(clients) do
        if c.name ~= "efm" then
            servers[#servers + 1] = c.name
        end
    end
    local linters, formatters = {}, {}
    local ok_mgr, mgr = pcall(require, "lvim-ls.core.manager")
    local ok_state, ls_state = pcall(require, "lvim-ls.state")
    local ok_pkg, pkg = pcall(require, "lvim-pkg")
    if ok_mgr and ok_state and ok_pkg then
        local efm_off = mgr.is_server_disabled_globally("efm") or mgr.is_server_disabled_for_buffer("efm", buf)
        if not efm_off then
            local ft = vim.bo[buf].filetype
            local function collect(field, out)
                for _, entry in pairs(ls_state.languages or {}) do
                    if vim.tbl_contains(entry.filetypes or {}, ft) then
                        for _, tool in ipairs(entry[field] or {}) do
                            local nm = type(tool) == "table" and tool[1] or tool
                            if pkg.is_installed("mason", nm) then
                                out[#out + 1] = nm
                            end
                        end
                    end
                end
            end
            collect("linters", linters)
            collect("formatters", formatters)
        end
    end
    local pieces = {}
    if #servers > 0 then
        pieces[#pieces + 1] = "LSP [" .. table.concat(parts.remove_duplicate(servers), ", ") .. "]"
    end
    if #linters > 0 then
        pieces[#pieces + 1] = "Li [" .. table.concat(parts.remove_duplicate(linters), ", ") .. "]"
    end
    if #formatters > 0 then
        pieces[#pieces + 1] = "Fo [" .. table.concat(parts.remove_duplicate(formatters), ", ") .. "]"
    end
    if #pieces == 0 then
        return ""
    end
    return paint("Blue", (" %s  %s"):format(glyphs().lsp, table.concat(pieces, " | ")))
end

--- Run a command later (so the picker/float closes first), used by several `click`s.
---@param cmd string
local function defer_cmd(cmd)
    vim.defer_fn(function()
        pcall(vim.cmd, cmd)
    end, 80)
end

-- ── the segments (left → right; `align` splits left / right) ─────────────────────────────────────────────
---@type LvimChromeSegment[]
return {
    -- vi-mode pill (mode-coloured)
    {
        name = "mode",
        events = { "ModeChanged", "CmdlineEnter", "CmdlineLeave" },
        content = function()
            local m = vim.fn.mode(1)
            parts.mode = m:sub(1, 1) -- shared with the file accent + word count
            local label = parts.MODE_LABEL[m] or m
            local group = parts.MODE_GROUP[parts.mode] or "ModeN"
            return paint(group, (" %s  %%(%s%%)  "):format(glyphs().vim, label))
        end,
    },
    -- lvim-table: table-mode chip. A persistent state belongs in a SEGMENT — the lvim-hud
    -- overlay is transient by contract, and a chip parked there replaces the whole statusline
    -- (measured; lvim-table's hud_chip now defaults off). Repaints on `User LvimTableMode`,
    -- which lvim-table fires on every enable/disable.
    {
        name = "tablemode",
        buf = true,
        events = { "User:LvimTableMode", "BufEnter" },
        content = function(ctx)
            local ok, tbl = pcall(require, "lvim-table")
            if not ok or not tbl.is_active(ctx.buf) then
                return ""
            end
            local icon = "󰓫"
            local okc, tconf = pcall(require, "lvim-table.config")
            if okc and tconf.icons ~= nil and tconf.icons.table ~= nil then
                icon = tconf.icons.table
            end
            return paint("Yellow", (" %s TABLE "):format(icon))
        end,
    },
    -- working directory (folder icon + ~-collapsed path) — click to open the file tree
    {
        name = "cwd",
        events = { "DirChanged" },
        click = {
            run = function()
                defer_cmd("LvimFiles panel")
            end,
            name = "cwd",
        },
        content = function()
            local cwd = vim.fn.fnamemodify(vim.fn.getcwd(0), ":~")
            if #cwd >= 0.25 * vim.o.columns then
                cwd = vim.fn.pathshorten(cwd)
            end
            local trail = cwd:sub(-1) == "/" and "" or "/"
            return paint("Blue", (" %s %s%s"):format(glyphs().folder, cwd, trail))
        end,
    },
    -- filename + devicon + size + readonly/modified flags (accent follows the mode)
    {
        name = "file",
        buf = true,
        events = { "TextChanged", "TextChangedI", "BufWritePost", "ModeChanged", "FileType" },
        content = function(ctx)
            local ic = glyphs()
            local name = api.nvim_buf_get_name(ctx.buf)
            local rel = vim.fn.fnamemodify(name, ":.")
            local out = {}
            if rel ~= "" then
                local fn = rel
                if #fn >= 0.25 * vim.o.columns then
                    fn = vim.fn.pathshorten(fn)
                end
                out[#out + 1] = paint(parts.MODE_ACCENT[parts.mode] or "Green", fn .. " ")
            end
            local icon, group = device_icon(ctx.buf, bar_dark())
            if icon then
                out[#out + 1] = ("%%#%s# %s %%*"):format(group, icon)
            end
            local fsize = vim.fn.getfsize(name)
            fsize = (fsize and fsize > 0) and fsize or 0
            if fsize > 0 then
                out[#out + 1] = paint("Blue", " " .. human_size(fsize) .. " ")
            end
            if not vim.bo[ctx.buf].modifiable or vim.bo[ctx.buf].readonly then
                out[#out + 1] = paint("Red", " " .. ic.lock .. " ")
            end
            if vim.bo[ctx.buf].modified then
                out[#out + 1] = paint("Red", " " .. ic.save .. " ")
            end
            out[#out + 1] = "%<"
            return table.concat(out)
        end,
    },
    -- git branch + (abbrev) — click to open LazyGit (through lvim-shell)
    {
        name = "git",
        buf = true,
        events = { GIT_PULSE },
        click = {
            run = function()
                defer_cmd("LvimShell lazygit")
            end,
            name = "git",
        },
        content = function()
            local g = git_poll.get()
            if not (g and g.head and g.head.branch) then
                return ""
            end
            local ic = glyphs()
            return paint("Orange", (" %s %s (%s) "):format(ic.git, g.head.branch, g.head.abbrev))
        end,
    },
    -- macro recording register ([q]) — only when the command line is hidden
    {
        name = "macro",
        events = { "RecordingEnter", "RecordingLeave", "CmdlineEnter", "CmdlineLeave" },
        content = function()
            if vim.fn.reg_recording() == "" or vim.o.cmdheight ~= 0 then
                return ""
            end
            return paint("Red", " [") .. paint("Green", vim.fn.reg_recording()) .. paint("Red", "]")
        end,
    },

    { align = true }, -- everything after floats to the far right

    -- diagnostics counts — click to open the lvim-lsp diagnostics peek
    {
        name = "diagnostics",
        buf = true,
        events = { "DiagnosticChanged" },
        click = {
            run = function()
                defer_cmd("LvimLsp diagnostics")
            end,
            name = "diagnostics",
        },
        content = function(ctx)
            local sev = vim.diagnostic.severity
            local c = vim.diagnostic.count(ctx.buf)
            local e, w, i, h = c[sev.ERROR] or 0, c[sev.WARN] or 0, c[sev.INFO] or 0, c[sev.HINT] or 0
            if e + w + i + h == 0 then
                return ""
            end
            local di = glyphs().diagnostics
            local out = {}
            if e > 0 then
                out[#out + 1] = paint("DiagError", ("%s %d "):format(di.error, e))
            end
            if w > 0 then
                out[#out + 1] = paint("DiagWarn", ("%s %d "):format(di.warn, w))
            end
            if i > 0 then
                out[#out + 1] = paint("DiagInfo", ("%s %d "):format(di.info, i))
            end
            if h > 0 then
                out[#out + 1] = paint("DiagHint", ("%s %d "):format(di.hint, h))
            end
            return table.concat(out)
        end,
    },
    -- attached LSP servers + EFM linters/formatters — click for :LvimLsp info
    {
        name = "lsp",
        buf = true,
        events = { "LspAttach", "LspDetach", "FileType" },
        click = {
            run = function()
                defer_cmd("LvimLsp info")
            end,
            name = "lsp",
        },
        content = function(ctx)
            return lsp_tools(ctx.buf)
        end,
    },
    -- lvim-lang: the active language provider's dev segment (run config / device / run state).
    -- Empty outside a provider buffer (Dart / Go / Rust). Click picks the run config. Refreshes on the
    -- `User LvimLangStatus` event lvim-lang fires when the selection changes.
    {
        name = "lvim-lang",
        buf = true,
        events = { "BufEnter", "LspAttach", "User" },
        click = {
            run = function()
                defer_cmd("LvimLang config")
            end,
            name = "lvim-lang",
        },
        content = function(ctx)
            local ok, seg = pcall(function()
                return require("lvim-lang").status(ctx.buf)
            end)
            return (ok and type(seg) == "string" and seg ~= "") and paint("Blue", " " .. seg) or ""
        end,
    },
    -- lvim-preview: the live-preview marker. Reads the plugin's framework-agnostic API, which
    -- returns "" unless THIS buffer is one of the previewed documents — so the marker follows the
    -- cursor and vanishes in unrelated files. Volatile (no `events`): the check is a small table
    -- lookup, and that way it appears/disappears the moment a preview starts or stops, without
    -- waiting for a buffer event. Clicking it re-opens the browser tab for this document.
    {
        name = "preview",
        buf = true,
        click = {
            run = function()
                defer_cmd("LvimPreview open")
            end,
            name = "preview",
        },
        content = function(ctx)
            local ok, seg = pcall(function()
                return require("lvim-preview").status_text(ctx.buf)
            end)
            return (ok and type(seg) == "string" and seg ~= "") and paint("Green", " " .. seg) or ""
        end,
    },
    -- uppercase filetype
    {
        name = "filetype",
        buf = true,
        events = { "FileType" },
        content = function(ctx)
            local ft = vim.bo[ctx.buf].filetype
            return ft ~= "" and paint("Green", "  " .. ft:upper()) or ""
        end,
    },
    -- file encoding
    {
        name = "encoding",
        buf = true,
        events = { "BufReadPost" },
        content = function(ctx)
            local enc = vim.bo[ctx.buf].fileencoding
            return enc ~= "" and paint("Orange", " " .. enc:upper()) or ""
        end,
    },
    -- line-ending format (unix/dos/mac)
    {
        name = "fileformat",
        buf = true,
        events = { "BufReadPost" },
        content = function(ctx)
            local f = vim.bo[ctx.buf].fileformat
            if f == "" then
                return ""
            end
            local ic = glyphs()
            local sym = { unix = ic.unix, dos = ic.dos, mac = ic.mac }
            return paint("Orange", " " .. (sym[f] or f) .. " ")
        end,
    },
    -- active spell language (via lvim-linguistics) — volatile (no events → rebuilt every render; it is cheap)
    {
        name = "spell",
        content = function()
            local ok, st = pcall(require, "lvim-linguistics.status")
            if not (ok and st.spell_has and st.spell_has()) then
                return ""
            end
            return paint("Green", " SPELL: " .. st.spell_get())
        end,
    },
    -- word count (visual/total in visual mode)
    {
        name = "wordcount",
        buf = true,
        events = { "CursorMoved", "CursorMovedI", "TextChanged", "TextChangedI", "ModeChanged" },
        content = function()
            local wc = vim.fn.wordcount()
            local txt
            if parts.mode == "v" or parts.mode == "V" then
                txt = (wc.visual_words or 0) .. "/" .. (wc.words or 0)
            else
                txt = tostring(wc.words or 0)
            end
            return paint("Cyan", " " .. txt)
        end,
    },
    -- ruler (line/total:col percentage) — a constant `%`-code string, Neovim evaluates it live (events = {})
    {
        name = "ruler",
        events = {},
        content = function()
            return paint("Red", " %7(%l/%3L%):%2c %P")
        end,
    },
    -- single block-char scroll position
    {
        name = "scrollbar",
        buf = true,
        events = { "CursorMoved", "CursorMovedI", "WinScrolled" },
        content = function()
            local cur, total = vim.fn.line("."), vim.fn.line("$")
            local chars = glyphs().scrollbar
            local idx = math.max(1, math.min(#chars, math.ceil((cur / math.max(total, 1)) * #chars)))
            return paint("Red", "  " .. chars[idx])
        end,
    },
}
