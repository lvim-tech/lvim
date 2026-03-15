-- Description: Custom floating diagnostic popup for LVIM IDE.
--
-- Renders diagnostics for the current cursor line in a styled floating window
-- with per-severity highlight ranges.  Also provides `goto_next` / `goto_prev`
-- helpers that jump to the neighbouring diagnostic and immediately show the
-- popup for the new location.
--
---@module "languages.utils.show_diagnostics"

local api            = vim.api
local util           = vim.lsp.util
local protocol       = vim.lsp.protocol
local DiagnosticSeverity = protocol.DiagnosticSeverity

local M = {}

-- ── Floating window padding constants ────────────────────────────────────────

--- Padding applied to all floating diagnostic windows (in cells / lines)
---@type { pad_top: integer, pad_bottom: integer, pad_right: integer, pad_left: integer }
local padding = {
    pad_top    = 1,
    pad_bottom = 1,
    pad_right  = 3,
    pad_left   = 3,
}

-- ── Private helpers ───────────────────────────────────────────────────────────

--- Applies padding to a list of text lines in-place and returns the modified list.
--- Left and right padding are added as spaces; top and bottom padding insert
--- empty strings at the respective ends.
---@param contents string[]  Lines to pad (modified in-place)
---@param opts     { pad_left?: integer, pad_right?: integer, pad_top?: integer, pad_bottom?: integer }
---@return string[]  The same `contents` table, now padded
local function trim_and_pad(contents, opts)
    opts = opts or {}
    local left_padding  = (" "):rep(opts.pad_left  or 1)
    local right_padding = (" "):rep(opts.pad_right or 1)
    for i, line in ipairs(contents) do
        -- Strip carriage returns and surround with the configured padding
        contents[i] = string.format("%s%s%s", left_padding, line:gsub("\r", ""), right_padding)
    end
    if opts.pad_top then
        for _ = 1, opts.pad_top do
            table.insert(contents, 1, "")
        end
    end
    if opts.pad_bottom then
        for _ = 1, opts.pad_bottom do
            table.insert(contents, "")
        end
    end
    return contents
end

--- Computes the optimal `(width, height)` for a floating window given `contents`.
--- Respects `max_width` and `max_height` constraints and accounts for line
--- wrapping when `wrap_at` is set.
---@param contents string[]  The lines that will be shown in the window
---@param opts     { width?: integer, height?: integer, wrap_at?: integer, max_width?: integer, max_height?: integer }
---@return integer width
---@return integer height
local function make_floating_popup_size(contents, opts)
    opts = opts or {}
    local width      = opts.width
    local height     = opts.height
    local wrap_at    = opts.wrap_at
    local max_width  = opts.max_width
    local max_height = opts.max_height

    ---@type integer[]  Display-width per line (populated lazily)
    local line_widths = {}

    if not width then
        width = 0
        for i, line in ipairs(contents) do
            line_widths[i] = vim.fn.strdisplaywidth(line)
            width = math.max(line_widths[i], width)
        end
    end

    if max_width then
        width   = math.min(width, max_width)
        wrap_at = math.min(wrap_at or max_width, max_width)
    end

    if not height then
        height = #contents
        -- Adjust height to account for wrapped lines when wrap_at is active
        if wrap_at and width >= wrap_at then
            height = 0
            if vim.tbl_isempty(line_widths) then
                -- line_widths not yet populated; compute on the fly
                for _, line in ipairs(contents) do
                    local line_width = vim.fn.strdisplaywidth(line)
                    height = height + math.ceil(line_width / wrap_at)
                end
            else
                for i = 1, #contents do
                    height = height + math.max(1, math.ceil(line_widths[i] / wrap_at))
                end
            end
        end
    end

    if max_height then
        height = math.min(height, max_height)
    end

    return width, height
end

--- Opens a floating preview window containing `contents`.
--- The window closes automatically when the cursor moves or the buffer is hidden.
---@param contents string[]     Lines to display (will be padded inside this function)
---@param syntax   string|nil   Optional filetype/syntax for the buffer (e.g. `"markdown"`)
---@return integer floating_bufnr  Buffer handle of the floating window
---@return integer floating_winnr  Window handle of the floating window
local function open_floating_preview(contents, syntax)
    contents = trim_and_pad(contents, padding)
    local width, height = make_floating_popup_size(contents, {
        max_width = 130,
    })
    local floating_bufnr = api.nvim_create_buf(false, true)
    if syntax then
        api.nvim_set_option_value("filetype", syntax, { buf = floating_bufnr })
    end
    local float_option   = util.make_floating_popup_options(width, height)
    -- Open focused so the user can scroll; a BufEnter autocommand will return focus
    local floating_winnr = api.nvim_open_win(floating_bufnr, true, float_option)
    -- Immediately return focus to the previous window without triggering autocmds
    api.nvim_command("noautocmd wincmd p")
    if syntax == "markdown" then
        -- Conceal markdown syntax characters for a cleaner display
        api.nvim_win_set_var(floating_winnr, "conceallevel", 2)
    end
    api.nvim_win_set_var(floating_winnr, "winblend", 0)
    api.nvim_buf_set_lines(floating_bufnr, 0, -1, true, contents)
    api.nvim_buf_set_var(floating_bufnr, "modifiable", false)
    api.nvim_buf_set_var(floating_bufnr, "bufhidden", "wipe")

    -- Register a one-shot autocommand to close the float on cursor movement.
    -- Deferred by 60 ms to avoid closing immediately due to the wincmd above.
    vim.defer_fn(function()
        api.nvim_command(
            "autocmd CursorMoved,CursorMovedI,BufHidden,InsertCharPre <buffer> lua pcall(vim.api.nvim_win_close, "
                .. floating_winnr
                .. ", true)"
        )
    end, 60)

    return floating_bufnr, floating_winnr
end

-- ── Severity → highlight group mapping ───────────────────────────────────────

--- Maps LSP DiagnosticSeverity integer values to the corresponding Neovim
--- diagnostic highlight group names used for the message text.
---@type table<integer, string>
local floating_severity_highlight_name = {
    [DiagnosticSeverity.Error]       = "DiagnosticError",
    [DiagnosticSeverity.Warning]     = "DiagnosticWarn",
    [DiagnosticSeverity.Information] = "DiagnosticInfo",
    [DiagnosticSeverity.Hint]        = "DiagnosticHint",
}

-- ── Public API ────────────────────────────────────────────────────────────────

--- Collects all diagnostics on the current cursor line and displays them in a
--- floating window.  Each diagnostic is numbered and prefixed with its source.
--- The prefix is highlighted with `DiagnosticSourceInfo`; the message with the
--- severity-specific group.
---@return integer|nil floating_bufnr  Buffer handle, or nil when there are no diagnostics
---@return integer|nil floating_winnr  Window handle, or nil when there are no diagnostics
M.show_line_diagnostics = function()
    local bufnr    = 0  -- 0 = current buffer
    -- Convert 1-based cursor row to 0-based LSP line number
    local line_nr  = api.nvim_win_get_cursor(0)[1] - 1

    ---@type string[]   Display lines for the floating buffer
    local lines      = {}
    ---@type { [1]: integer, [2]: string }[]  Per-line { prefix_length, highlight_group } pairs
    local highlights = {}

    local line_diagnostics = vim.diagnostic.get(bufnr, { lnum = line_nr })
    if vim.tbl_isempty(line_diagnostics) then
        return
    end

    for i, diagnostic in ipairs(line_diagnostics) do
        -- Format: "1. (source) message first line"
        local prefix  = string.format("%d. (%s) ", i, diagnostic.source or "unknown")
        local hiname  = floating_severity_highlight_name[diagnostic.severity]
        assert(hiname, "unknown severity: " .. tostring(diagnostic.severity))
        local message_lines = vim.split(diagnostic.message, "\n", { trimempty = true })

        -- First line gets the numbered prefix
        table.insert(lines, prefix .. message_lines[1])
        table.insert(highlights, { #prefix, hiname })

        -- Continuation lines share the same highlight but have no prefix
        for j = 2, #message_lines do
            table.insert(lines, message_lines[j])
            table.insert(highlights, { 0, hiname })
        end
    end

    local popup_bufnr, winnr = open_floating_preview(lines, "plaintext")
    api.nvim_buf_set_var(popup_bufnr, "buftype", "prompt")

    local ns_id = vim.api.nvim_create_namespace("diagnostics_popup")

    for i, hi in ipairs(highlights) do
        local prefixlen, hiname = unpack(hi)
        -- Highlight the "N. (source) " prefix portion with a neutral info style
        vim.highlight.range(
            popup_bufnr,
            ns_id,
            "DiagnosticSourceInfo",
            { i - 1 + padding.pad_top, padding.pad_left },
            { i - 1 + padding.pad_top, padding.pad_left + prefixlen },
            {}
        )
        -- Highlight the message text with the severity colour
        vim.highlight.range(
            popup_bufnr,
            ns_id,
            hiname,
            { i - 1 + padding.pad_top, prefixlen + padding.pad_left },
            { i - 1 + padding.pad_top, -1 },
            {}
        )
    end

    return popup_bufnr, winnr
end

--- Jumps to the next diagnostic in the buffer and immediately shows the
--- floating diagnostic popup for the new cursor position.
---@return nil
M.goto_next = function()
    vim.diagnostic.jump({
        count = 1,
        float = false,  -- suppress the built-in float; we show our own
    })
    M.show_line_diagnostics()
end

--- Jumps to the previous diagnostic in the buffer and immediately shows the
--- floating diagnostic popup for the new cursor position.
---@return nil
M.goto_prev = function()
    vim.diagnostic.jump({
        count = -1,
        float = false,  -- suppress the built-in float; we show our own
    })
    M.show_line_diagnostics()
end

--- Opens `vim.diagnostic.open_float` with the given options (merged with a
--- default `pos` of -1000 to force the float above the cursor), then also
--- shows the custom popup.
---@param opts table|nil  Extra options forwarded to `vim.diagnostic.open_float`
---@return nil
M.line = function(opts)
    opts = vim.tbl_deep_extend("error", {
        pos = -1000,  -- position hint: render above the cursor line
    }, opts or {})
    vim.diagnostic.open_float(opts)
    M.show_line_diagnostics()
end

return M
