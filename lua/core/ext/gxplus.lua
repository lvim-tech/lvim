-- Universal "open under cursor" extension for LVIM IDE (replaces the built-in gx).
-- Resolves URLs, local file paths (with optional :line:col suffix), bare
-- domain/repo references (e.g. "github.com/foo/bar") and paths inside
-- file-manager buffers (neo-tree, nvim-tree, oil, mini.files, netrw) by
-- querying a set of registered adapters before falling back to a line-scan
-- that searches nearby lines for any token matching the configured pattern.
--
-- Public API:
--   M.setup(opts?)         – initialise with optional config overrides
--   M.register_adapter(def) – add a custom file-manager adapter at runtime
--   M.map_default()        – bind gx → GxPlus in normal mode
--   M.open_current()       – programmatically trigger open on current cursor

---@module "core.ext.gxplus"

local M = {}

-- ---------------------------------------------------------------------------
-- Default configuration
-- ---------------------------------------------------------------------------

---@class GxPlusConfig
---@field highlight_match          boolean           Briefly highlight the matched token
---@field system_open_cmd          string|nil        Override the system opener command (nil = auto-detect)
---@field force_system_open_local  boolean           Use system opener for local files too (not only URLs)
---@field allow_bare_domains       boolean           Treat "domain.tld/path" strings as HTTPS URLs
---@field icon_guard               boolean           Skip tokens that look like Nerd Font icon glyphs
---@field notify_level             integer           vim.log.levels value for informational messages
---@field dir_open_strategy        "system"|"adapter_action"|"edit"  How to open directories
---@field search_forward_if_none   boolean           Scan lines below cursor when nothing is found on the current line
---@field search_backward_if_none  boolean           Scan lines above cursor when nothing is found on the current line
---@field search_max_lines         integer           Maximum number of lines to scan in each direction
---@field pick_nearest_direction   boolean           Prefer the closest token when multiple candidates exist
---@field pattern                  string            Lua pattern used to extract tokens from a line
---@field debug                    boolean           Enable verbose debug notifications
---@field adapters                 table<string, boolean>  Enable/disable built-in adapters by name
---@field extra_adapters           table             Additional adapter definitions to register
---@field highlight_duration_ms    integer           Milliseconds to keep the temporary token highlight
---@field ignore_headless_guard    boolean           Allow system_open even when no display is detected
---@field max_sequential_candidates integer          Stop collecting tokens after this many candidates

---@type GxPlusConfig
local defaults = {
    highlight_match          = true,
    system_open_cmd          = nil,
    force_system_open_local  = true,
    -- system_open_cmd = vim.fn.expand("/usr/bin/gedit"),
    -- force_system_open_local = true,
    allow_bare_domains       = true,
    icon_guard               = true,
    notify_level             = vim.log.levels.INFO,
    dir_open_strategy        = "system",
    search_forward_if_none   = true,
    search_backward_if_none  = true,
    search_max_lines         = 60,
    pick_nearest_direction   = true,
    pattern                  = "[%w%._~/#%-%+%%%?=&@:%d]+",
    debug                    = false,
    adapters = {
        neo_tree   = true,
        nvim_tree  = true,
        oil        = true,
        mini_files = true,
        netrw      = true,
    },
    extra_adapters           = {},
    highlight_duration_ms    = 300,
    ignore_headless_guard    = false,
    max_sequential_candidates = 200,
}

-- Active configuration (deep-copied from defaults, may be overridden by setup()).
---@type GxPlusConfig
local cfg = vim.deepcopy(defaults)

-- libuv handle (vim.uv preferred; falls back to deprecated vim.loop).
local uv = vim.uv or vim.loop

---@type table  List of registered adapter definitions.
local adapters = {}
---@type boolean  Guard so adapters are only initialised once per setup() call.
local adapters_initialized = false

-- ---------------------------------------------------------------------------
-- Logging helpers
-- ---------------------------------------------------------------------------

--- Emit a DEBUG-level notification only when cfg.debug is enabled.
---@param msg string
---@return nil
local function dlog(msg)
    if cfg.debug then
        vim.notify("[GxPlus] " .. msg, vim.log.levels.DEBUG)
    end
end

--- Emit a notification at the given level (defaults to cfg.notify_level).
---@param msg   string
---@param level integer|nil  vim.log.levels constant
---@return nil
local function log(msg, level)
    vim.notify("GxPlus: " .. msg, level or cfg.notify_level)
end

-- ---------------------------------------------------------------------------
-- Environment helpers
-- ---------------------------------------------------------------------------

--- Return true when running in a headless environment with no display server.
-- Checks DISPLAY (X11), WAYLAND_DISPLAY, and WSL_DISTRO_NAME.
-- Always returns false on Windows because Windows handles its own open commands.
---@return boolean
local function env_headless()
    if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
        return false
    end
    return (not os.getenv("DISPLAY") and not os.getenv("WAYLAND_DISPLAY") and not os.getenv("WSL_DISTRO_NAME"))
end

--- Return the appropriate system opener command for the current OS.
-- Respects cfg.system_open_cmd if set explicitly.
---@return string  "open" (macOS), "start" (Windows), or "xdg-open" (Linux)
local function detect_system_opener()
    if cfg.system_open_cmd then
        return cfg.system_open_cmd
    end
    if vim.fn.has("mac") == 1 then
        return "open"
    elseif vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
        return "start"
    else
        return "xdg-open"
    end
end

-- ---------------------------------------------------------------------------
-- Path / string utilities
-- ---------------------------------------------------------------------------

--- Normalise a file path: convert backslashes, collapse double slashes,
--- and strip a trailing slash (unless the path is the root "/").
---@param p string|nil
---@return string|nil  Normalised path, or nil if the input was nil
local function normalize_path(p)
    if not p then
        return p
    end
    p = p:gsub("\\", "/"):gsub("//+", "/")
    -- Remove trailing slash except for the root path.
    if #p > 1 and p:sub(-1) == "/" then
        p = p:sub(1, -2)
    end
    return p
end

--- Return true when the string starts with http://, https://, or file://.
---@param s string
---@return boolean
local function is_url(s)
    return s:match("^https?://") or s:match("^file://")
end

--- Strip common trailing punctuation that is unlikely to be part of a URL/path.
---@param s string
---@return string, integer
local function strip_trailing_punct(s)
    return s:gsub("[)>.,;:]+$", "")
end

--- Remove surrounding single or double quotes from a string.
---@param s string
---@return string
local function unquote(s)
    if s:match('^".*"$') or s:match("^'.*'$") then
        return s:sub(2, -2)
    end
    return s
end

--- Expand a leading "~" to the user's home directory.
---@param p string
---@return string
local function expand_path(p)
    if p:sub(1, 1) == "~" then
        return vim.fn.expand(p)
    end
    return p
end

--- Parse a "file:line:col" or "file:line" suffix from a string.
---@param s string  Raw token (may contain :line:col suffix)
---@return string   file part
---@return integer|nil  line number or nil
---@return integer|nil  column number or nil
local function split_file_line_col(s)
    local f, l, c = s:match("^(.+):(%d+):(%d+)$")
    if f then
        return f, tonumber(l), tonumber(c)
    end
    f, l = s:match("^(.+):(%d+)$")
    if f then
        return f, tonumber(l), nil
    end
    return s, nil, nil
end

--- Return true when the path exists on disk (uses libuv fs_stat).
---@param p string|nil
---@return boolean|nil
local function path_exists(p)
    return p and uv.fs_stat(p) ~= nil
end

--- Return true when the path is a directory.
---@param p string
---@return boolean|nil
local function is_dir(p)
    local st = uv.fs_stat(p)
    return st and st.type == "directory"
end

--- Return true when the string looks like a bare "domain.tld/owner/repo"
--- reference that should be opened as an HTTPS URL.
---@param s string
---@return boolean
local function looks_like_domain_repo(s)
    if not cfg.allow_bare_domains then
        return false
    end
    return s:match("^[%w%.%-]+%.[%w%.%-]+/.+")
end

--- Return true when the token consists entirely of non-alphanumeric glyphs
--- and is short enough to be a Nerd Font icon rather than a path/URL.
---@param token string|nil
---@return boolean
local function is_icon_like(token)
    if not cfg.icon_guard then
        return false
    end
    if not token or token == "" then
        return true
    end
    -- Any ASCII word character, dot, slash, or tilde means it is not just an icon.
    if token:match("[%w%./~]") then
        return false
    end
    -- Multi-codepoint glyphs can still be short in character count.
    local chars = vim.fn.strchars(token)
    return chars <= 6
end

-- ---------------------------------------------------------------------------
-- Highlight helper
-- ---------------------------------------------------------------------------

--- Briefly highlight a range in a buffer using an extmark, then remove it.
---@param buf      integer  Buffer handle
---@param lnum     integer  Zero-based line number
---@param start_col integer  Start column (0-based, byte offset)
---@param end_col  integer|nil  End column; if nil the whole line is highlighted
---@return nil
local function highlight_temp(buf, lnum, start_col, end_col)
    if not cfg or not cfg.highlight_match then
        return
    end

    if not vim.api.nvim_buf_set_extmark then
        vim.notify(
            "gxplus: nvim_buf_set_extmark not available — skipping highlight (no fallback configured)",
            vim.log.levels.WARN
        )
        return
    end

    local ns = vim.api.nvim_create_namespace("GxPlusTempHL")

    if not end_col then
        local line = vim.api.nvim_buf_get_lines(buf, lnum, lnum + 1, false)[1] or ""
        end_col = #line
    end

    local ok, mark_id_or_err = pcall(vim.api.nvim_buf_set_extmark, buf, ns, lnum, start_col, {
        end_col  = end_col,
        hl_group = "Visual",
        hl_mode  = "combine",
        priority = 150,
    })

    if not ok then
        vim.notify("gxplus: failed to add extmark highlight: " .. tostring(mark_id_or_err), vim.log.levels.ERROR)
        return
    end

    -- Schedule removal: delete the specific extmark by id when possible,
    -- otherwise clear the whole namespace as a safe fallback.
    vim.defer_fn(function()
        if vim.api.nvim_buf_del_extmark and type(mark_id_or_err) == "number" then
            pcall(vim.api.nvim_buf_del_extmark, buf, ns, mark_id_or_err)
        else
            pcall(vim.api.nvim_buf_clear_namespace, buf, ns, 0, -1)
        end
    end, cfg.highlight_duration_ms or 250)
end

-- ---------------------------------------------------------------------------
-- Buffer line access
-- ---------------------------------------------------------------------------

--- Return the text of a 1-based line from the given buffer.
---@param buf  integer  Buffer handle
---@param lnum integer  1-based line number
---@return string  Line text (empty string if out of range)
local function get_line(buf, lnum)
    return vim.api.nvim_buf_get_lines(buf, lnum - 1, lnum, false)[1]
end

-- ---------------------------------------------------------------------------
-- Token scanning
-- ---------------------------------------------------------------------------

---@class GxPlusToken
---@field s    integer  1-based start column of the match in the line string
---@field e    integer  1-based end column of the match in the line string
---@field text string   Cleaned token text (unquoted, trailing punct stripped)

--- Scan a line and return all tokens that match the given Lua pattern.
---@param line    string  Full line text
---@param pattern string  Lua pattern to search for
---@return GxPlusToken[]
local function scan_line_tokens(line, pattern)
    local tokens = {}
    local idx = 1
    while true do
        local s, e = line:find(pattern, idx)
        if not s then
            break
        end
        local tk = strip_trailing_punct(unquote(line:sub(s, e)))
        tokens[#tokens + 1] = { s = s, e = e, text = tk }
        idx = e + 1
    end
    return tokens
end

--- Return the token whose column range covers the cursor, skipping icon-like tokens.
---@param line    string     Full line text
---@param col1    integer    1-based cursor column
---@param pattern string     Lua pattern for token extraction
---@return GxPlusToken|nil
local function token_under_cursor(line, col1, pattern)
    for _, t in ipairs(scan_line_tokens(line, pattern)) do
        if col1 >= t.s and col1 <= t.e and not is_icon_like(t.text) then
            return t
        end
    end
end

--- Return all non-icon, non-empty tokens found in a line.
---@param line    string
---@param pattern string
---@return GxPlusToken[]
local function collect_tokens_in_line(line, pattern)
    local out = {}
    for _, t in ipairs(scan_line_tokens(line, pattern)) do
        if not is_icon_like(t.text) and t.text ~= "" then
            out[#out + 1] = t
        end
    end
    return out
end

-- ---------------------------------------------------------------------------
-- Built-in file-manager adapters
-- ---------------------------------------------------------------------------

--- Adapter for neo-tree.nvim buffers.
-- Tries the renderer API first, then the source manager, then falls back to
-- line-parsing to extract the node path.
---@return table  Adapter definition with name/detect/get fields
local function adapter_neo_tree()
    return {
        name   = "neo_tree",
        ---@param ctx table  Cursor context built by build_context()
        ---@return boolean
        detect = function(ctx)
            return ctx.filetype == "neo-tree"
        end,
        ---@param ctx table
        ---@return { path: string, type: "file"|"dir"|"unknown" }|nil
        get    = function(ctx)
            local ok_r, renderer = pcall(require, "neo-tree.ui.renderer")
            if ok_r then
                local ok_n, node = pcall(renderer.get_node)
                if ok_n and node and node.path then
                    return { path = node.path, type = node.type == "directory" and "dir" or "file" }
                end
                if renderer.get_node_at_position then
                    local ok2, n2 = pcall(renderer.get_node_at_position, ctx.cursor.lnum)
                    if ok2 and n2 and n2.path then
                        return { path = n2.path, type = n2.type == "directory" and "dir" or "file" }
                    end
                end
            end
            -- Fallback: iterate known source states to find the current node.
            local ok_m, manager = pcall(require, "neo-tree.sources.manager")
            if ok_m and manager.get_state then
                for _, s in ipairs({ "filesystem", "buffers", "git_status", "document_symbols" }) do
                    local state = manager.get_state(s)
                    if state and state.bufnr == ctx.bufnr and state.tree and state.tree.get_node then
                        local node = state.tree:get_node()
                        if node and node.path then
                            return { path = node.path, type = node.type == "directory" and "dir" or "file" }
                        end
                    end
                end
            end
            -- Last resort: parse the visible line, skipping any leading icon glyph.
            local line = ctx.line or ""
            line = line:gsub("^%s+", "")
            -- Split off the first UTF-8 character (potential icon) from the rest.
            local first, rest = line:match("^([%z\1-%127\194-\244][\128-\191]*)(.*)$")
            rest = (rest or ""):gsub("^%s+", "")
            local name
            if first and is_icon_like(first) then
                name = rest:match("^(%S+)")
            else
                name = line:match("^(%S+)")
            end
            if not name or name == "" or is_icon_like(name) then
                return nil
            end
            local ok_m2, manager2 = pcall(require, "neo-tree.sources.manager")
            if ok_m2 then
                local state = manager2.get_state("filesystem")
                if state and state.bufnr == ctx.bufnr and state.path then
                    return { path = state.path .. "/" .. name, type = "unknown" }
                end
            end
            return { path = name, type = "unknown" }
        end,
    }
end

--- Adapter for nvim-tree.lua buffers.
---@return table
local function adapter_nvim_tree()
    return {
        name   = "nvim_tree",
        ---@param ctx table
        ---@return boolean
        detect = function(ctx)
            return ctx.filetype == "NvimTree"
        end,
        ---@return { path: string, type: "file"|"dir" }|nil
        get    = function()
            local ok_api, api = pcall(require, "nvim-tree.api")
            if not ok_api then
                return nil
            end
            local ok_n, node = pcall(api.tree.get_node_under_cursor)
            if ok_n and node and node.absolute_path then
                return { path = node.absolute_path, type = node.type == "directory" and "dir" or "file" }
            end
        end,
    }
end

--- Adapter for oil.nvim directory buffers.
---@return table
local function adapter_oil()
    return {
        name   = "oil",
        ---@param ctx table
        ---@return boolean
        detect = function(ctx)
            return ctx.filetype == "oil"
        end,
        ---@return { path: string, type: "file"|"dir" }|nil
        get    = function()
            local ok, oil = pcall(require, "oil")
            if not ok then
                return nil
            end
            local okd, dir   = pcall(oil.get_current_dir)
            local oke, entry = pcall(oil.get_cursor_entry)
            if okd and dir and oke and entry and entry.name then
                return {
                    path = normalize_path(dir .. entry.name),
                    type = entry.type == "directory" and "dir" or "file",
                }
            end
        end,
    }
end

--- Adapter for mini.files buffers (multiple API versions supported).
---@return table
local function adapter_mini_files()
    return {
        name   = "mini_files",
        ---@param ctx table
        ---@return boolean
        detect = function(ctx)
            local ft = ctx.filetype
            return ft == "minifiles" or ft == "mini.files" or ft == "MiniFiles"
        end,
        ---@return { path: string, type: string }|nil
        get    = function()
            local ok_mf, mf = pcall(require, "mini.files")
            if not ok_mf then
                return nil
            end
            -- Prefer get_fs_entry (newer API).
            if mf.get_fs_entry then
                local ok_e, entry = pcall(mf.get_fs_entry)
                if ok_e and entry and entry.path then
                    return {
                        path = normalize_path(entry.path),
                        type = entry.fs_type == "directory" and "dir" or (entry.fs_type or "file"),
                    }
                end
            end
            -- Older API: get_cursor_entry.
            if mf.get_cursor_entry then
                local ok_c, cent = pcall(mf.get_cursor_entry)
                if ok_c and cent and cent.path then
                    return {
                        path = normalize_path(cent.path),
                        type = cent.fs_type == "directory" and "dir" or (cent.fs_type or "file"),
                    }
                end
            end
            -- Fallback: resolve the name on the current line against the cwd.
            local current_dir
            if mf.get_fs_state then
                local ok_s, st = pcall(mf.get_fs_state)
                if ok_s and st and st.cwd then
                    current_dir = st.cwd
                end
            end
            if not current_dir and mf.get_current_dir then
                local ok_cd, cd = pcall(mf.get_current_dir)
                if ok_cd then
                    current_dir = cd
                end
            end
            current_dir = current_dir or vim.loop.cwd()
            local line = vim.api.nvim_get_current_line()
            line = line:gsub("^%s+", "")
            local raw = line:match("^(%S+)")
            if raw and raw ~= "" and not is_icon_like(raw) then
                -- mini.files sometimes prefixes entries with a leading slash; strip it.
                if raw:sub(1, 1) == "/" and not path_exists(raw) then
                    raw = raw:sub(2)
                end
                return { path = normalize_path(current_dir .. "/" .. raw), type = "unknown" }
            end
        end,
    }
end

--- Adapter for the built-in netrw file browser.
---@return table
local function adapter_netrw()
    return {
        name   = "netrw",
        ---@param ctx table
        ---@return boolean
        detect = function(ctx)
            return ctx.filetype == "netrw"
        end,
        ---@param ctx table
        ---@return { path: string, type: "unknown" }|nil
        get    = function(ctx)
            local line = ctx.line or ""
            -- Strip the leading "N." line-number prefix that netrw inserts.
            line = line:gsub("^%s*[%d%.]+%s*", "")
            local name = line:match("^(%S+)")
            if name and name ~= "" and not is_icon_like(name) then
                return { path = normalize_path(vim.fn.getcwd() .. "/" .. name), type = "unknown" }
            end
        end,
    }
end

--- Map of adapter name → constructor function, used during initialisation.
---@type table<string, fun(): table>
local built_in_adapter_builders = {
    neo_tree   = adapter_neo_tree,
    nvim_tree  = adapter_nvim_tree,
    oil        = adapter_oil,
    mini_files = adapter_mini_files,
    netrw      = adapter_netrw,
}

-- ---------------------------------------------------------------------------
-- Adapter registry
-- ---------------------------------------------------------------------------

--- Register a custom file-manager adapter.
-- The definition must have: name (string), detect (function), get (function).
---@param def table  Adapter definition table
---@return nil
function M.register_adapter(def)
    if not def or not def.name or not def.detect or not def.get then
        log("Adapter registration failed (missing fields)", vim.log.levels.ERROR)
        return
    end
    adapters[#adapters + 1] = def
end

--- Lazily build and register all enabled built-in adapters (runs once).
---@return nil
local function ensure_adapters()
    if adapters_initialized then
        return
    end
    for k, b in pairs(built_in_adapter_builders) do
        if cfg.adapters[k] then
            local ok, d = pcall(b)
            if ok and d then
                M.register_adapter(d)
            end
        end
    end
    for _, d in ipairs(cfg.extra_adapters or {}) do
        M.register_adapter(d)
    end
    adapters_initialized = true
end

-- ---------------------------------------------------------------------------
-- Context & adapter dispatch
-- ---------------------------------------------------------------------------

---@class GxPlusContext
---@field bufnr    integer  Current buffer handle
---@field winid    integer  Current window handle
---@field filetype string   Buffer filetype
---@field cursor   { lnum: integer, col0: integer, col1: integer }  Cursor position
---@field line     string   Full text of the line under the cursor
---@field cwd      string   Current working directory

--- Build a context snapshot for the current cursor position.
---@return GxPlusContext
local function build_context()
    local cur = vim.api.nvim_win_get_cursor(0)
    return {
        bufnr    = vim.api.nvim_get_current_buf(),
        winid    = vim.api.nvim_get_current_win(),
        filetype = vim.bo.filetype,
        -- col0 is 0-based (API native); col1 is 1-based (used for token matching).
        cursor   = { lnum = cur[1], col0 = cur[2], col1 = cur[2] + 1 },
        line     = vim.api.nvim_get_current_line(),
        cwd      = vim.loop.cwd(),
    }
end

--- Return the first adapter whose detect() returns true for the given context.
---@param ctx GxPlusContext
---@return table|nil  Matching adapter or nil
local function first_matching_adapter(ctx)
    ensure_adapters()
    for _, ad in ipairs(adapters) do
        local ok, res = pcall(ad.detect, ctx)
        if ok and res then
            return ad
        end
    end
end

-- ---------------------------------------------------------------------------
-- Open dispatcher
-- ---------------------------------------------------------------------------

--- Invoke the OS system opener (xdg-open / open / start) for a target.
-- For non-URL targets the force_system_open_local flag must be set.
-- Headless environments are rejected unless ignore_headless_guard is true.
---@param target string  URL or file path to open
---@param kind   "url"|"file"|string  Target kind
---@return boolean  true on success
---@return string|nil  Error reason on failure
local function system_open(target, kind)
    local opener = detect_system_opener()
    if kind ~= "url" and not cfg.force_system_open_local then
        return false, "disabled"
    end
    if kind ~= "url" and env_headless() and not cfg.ignore_headless_guard then
        return false, "headless"
    end
    -- Windows "start" requires a blank title argument between "start" and the target.
    local cmd = (opener == "start") and { "cmd", "/c", "start", "", target } or { opener, target }
    dlog("system_open: " .. table.concat(cmd, " "))
    local ok, jid = pcall(vim.fn.jobstart, cmd, {
        detach    = true,
        on_stderr = function(_, data, _)
            local err = table.concat(
                vim.tbl_filter(function(x)
                    return x and #x > 0
                end, data),
                "\n"
            )
            if #err > 0 then
                dlog("stderr: " .. err)
            end
        end,
    })
    if not ok or jid <= 0 then
        return false, "jobstart_failed"
    end
    return true
end

--- Jump the cursor to a 1-based line / column in the current window.
---@param line integer|nil
---@param col  integer|nil  1-based column; converted to 0-based internally
---@return nil
local function jump_to_line_col(line, col)
    if line then
        pcall(vim.api.nvim_win_set_cursor, 0, { line, math.max(0, (col or 1) - 1) })
    end
end

--- Open a resolved target: URLs go to the system browser, local paths are
--- opened with :edit (or the system opener when force_system_open_local is set).
---@param target string  Resolved path or URL
---@param meta   table|nil  Optional metadata (line, col, adapter)
---@return boolean  true when the target was successfully opened
---@return string|nil  Error code on failure ("empty", "url_fail", "unknown", …)
local function open_path(target, meta)
    if not target or target == "" then
        return false, "empty"
    end
    dlog("open_path: " .. target)

    if is_url(target) then
        local ok = system_open(target, "url")
        if not ok then
            log("URL open failed: " .. target, vim.log.levels.ERROR)
            return false, "url_fail"
        end
        return true
    end

    local original = target
    local filePart, line, col = split_file_line_col(target)
    filePart = expand_path(filePart)
    filePart = normalize_path(filePart)

    -- If the path looks like "/name" (single component) and does not exist,
    -- try resolving it relative to the cwd.
    if not path_exists(filePart) and filePart:match("^/[^/]+$") then
        local candidate = normalize_path(vim.loop.cwd() .. filePart)
        if path_exists(candidate) then
            filePart = candidate
        end
    end

    -- Try resolving relative to the current buffer's directory.
    if not path_exists(filePart) then
        local current_file = vim.api.nvim_buf_get_name(0)
        if current_file ~= "" then
            local base = vim.fn.fnamemodify(current_file, ":h")
            local alt  = normalize_path(base .. "/" .. filePart)
            if path_exists(alt) then
                filePart = alt
            end
        end
    end

    -- Decode percent-encoded spaces (%20) as a last-ditch attempt.
    if not path_exists(filePart) then
        local decoded = filePart:gsub("%%20", " ")
        if decoded ~= filePart and path_exists(decoded) then
            filePart = decoded
        else
            -- If the string looks like a bare domain/repo, open as an HTTPS URL.
            if looks_like_domain_repo(filePart) then
                local url = "https://" .. filePart
                local ok  = system_open(url, "url")
                if not ok then
                    log("Failed to open: " .. url, vim.log.levels.ERROR)
                    return false, "domain_fail"
                end
                return true
            end
            dlog("Unknown target: " .. original)
            return false, "unknown"
        end
    end

    -- Debug: Show filetype, mime, and default handler always if debug is enabled
    if cfg.debug and path_exists(filePart) then
        local mime
        local ok1, out1 = pcall(vim.fn.systemlist, { "file", "--mime-type", "-b", filePart })
        if ok1 and out1 and #out1 > 0 then
            mime = out1[1]
        end
        if mime then
            local handler
            local ok2, out2 = pcall(vim.fn.systemlist, { "xdg-mime", "query", "default", mime })
            if ok2 and out2 and #out2 > 0 then
                handler = out2[1]
            end
            vim.notify(
                string.format(
                    "[GxPlus debug] filetype: %s | mime: %s | default handler: %s",
                    vim.bo.filetype,
                    mime,
                    handler or "N/A"
                ),
                vim.log.levels.INFO
            )
        else
            vim.notify(
                string.format("[GxPlus debug] filetype: %s | mime: UNKNOWN", vim.bo.filetype),
                vim.log.levels.INFO
            )
        end
    end

    if is_dir(filePart) then
        if cfg.dir_open_strategy == "system" then
            local ok = system_open(filePart, "file")
            if not ok then
                log("System dir open failed, using :edit " .. filePart, vim.log.levels.WARN)
                vim.cmd.edit(vim.fn.fnameescape(filePart))
            end
        elseif cfg.dir_open_strategy == "adapter_action" and meta and meta.adapter and meta.adapter.open_dir then
            local ok, err = pcall(meta.adapter.open_dir, filePart, meta)
            if not ok then
                log("Adapter dir open error: " .. tostring(err), vim.log.levels.ERROR)
                vim.cmd.edit(vim.fn.fnameescape(filePart))
            end
        else
            vim.cmd.edit(vim.fn.fnameescape(filePart))
        end
        return true
    end

    if cfg.force_system_open_local then
        local ok = system_open(filePart, "file")
        if not ok then
            log("System open failed, editing: " .. filePart, vim.log.levels.WARN)
            vim.cmd.edit(vim.fn.fnameescape(filePart))
            jump_to_line_col(line, col)
        end
    else
        vim.cmd.edit(vim.fn.fnameescape(filePart))
        -- Prefer explicit line/col from the token; fall back to meta-provided values.
        jump_to_line_col(line or (meta and meta.line), col or (meta and meta.col))
    end
    return true
end

-- ---------------------------------------------------------------------------
-- Candidate collection
-- ---------------------------------------------------------------------------

---@class GxPlusCandidate
---@field text string  Token text
---@field meta table   Source metadata (lnum, start_col, end_col, origin, …)

--- Collect all unique candidate tokens ordered by proximity to the cursor.
-- Priority: token under cursor → other tokens on the same line → tokens on
-- nearby lines (alternating up/down, bounded by search_max_lines).
---@param ctx GxPlusContext
---@return GxPlusCandidate[]
local function collect_candidate_tokens(ctx)
    local buf     = ctx.bufnr
    local pattern = cfg.pattern
    local lnum    = ctx.cursor.lnum
    local col1    = ctx.cursor.col1
    ---@type table<string, boolean>  Deduplication set
    local seen  = {}
    ---@type GxPlusCandidate[]
    local order = {}

    local function add(text, meta)
        if text and text ~= "" and not is_icon_like(text) and not seen[text] then
            seen[text] = true
            order[#order + 1] = { text = text, meta = meta }
        end
    end

    -- 1. Token directly under the cursor (highest priority).
    local line  = get_line(buf, lnum) or ""
    local under = token_under_cursor(line, col1, pattern)
    if under then
        add(under.text, { lnum = lnum, start_col = under.s, end_col = under.e, origin = "under" })
    end

    -- 2. Remaining tokens on the cursor line.
    local tokens_line = collect_tokens_in_line(line, pattern)
    for _, t in ipairs(tokens_line) do
        if not (under and t.text == under.text) then
            add(t.text, { lnum = lnum, start_col = t.s, end_col = t.e, origin = "same_line" })
        end
    end

    -- 3. Expand outward from the cursor line, alternating up and down.
    local max_lines = cfg.search_max_lines
    local total     = vim.api.nvim_buf_line_count(buf)
    local up_count, down_count = 0, 0
    local radius = 1
    while
        (cfg.search_forward_if_none or cfg.search_backward_if_none)
        and (up_count < max_lines or down_count < max_lines)
        and #order < cfg.max_sequential_candidates
    do
        local did = false
        if cfg.search_backward_if_none and (lnum - radius) >= 1 and up_count < max_lines then
            local l     = lnum - radius
            local ltext = get_line(buf, l) or ""
            for _, t in ipairs(collect_tokens_in_line(ltext, pattern)) do
                add(t.text, { lnum = l, start_col = t.s, end_col = t.e, origin = "up" })
            end
            up_count = up_count + 1
            did = true
        end
        if cfg.search_forward_if_none and (lnum + radius) <= total and down_count < max_lines then
            local l     = lnum + radius
            local ltext = get_line(buf, l) or ""
            for _, t in ipairs(collect_tokens_in_line(ltext, pattern)) do
                add(t.text, { lnum = l, start_col = t.s, end_col = t.e, origin = "down" })
            end
            down_count = down_count + 1
            did = true
        end
        if not did then
            break
        end
        radius = radius + 1
    end
    return order
end

-- ---------------------------------------------------------------------------
-- Target resolution
-- ---------------------------------------------------------------------------

--- Resolve an ordered list of open candidates from either a command argument,
--- an adapter result, or the line-scan heuristic.
---@param args string|nil  Optional explicit target passed from the user command
---@return GxPlusCandidate[]  Ordered candidate list
---@return GxPlusContext       Context snapshot at the time of resolution
local function resolve_targets(args)
    local ctx = build_context()
    -- When called with an explicit argument, skip all heuristics.
    if args and args ~= "" then
        return { { text = args, meta = { source = "argument" } } }, ctx
    end
    local adapter = first_matching_adapter(ctx)
    local list    = {}
    if adapter then
        dlog("Adapter detected: " .. adapter.name)
        local ok_get, data = pcall(adapter.get, ctx)
        if ok_get and data and data.path and data.path ~= "" and not is_icon_like(data.path) then
            list[#list + 1] = { text = data.path, meta = { source = "adapter", adapter = adapter, type = data.type } }
        end
    end
    for _, cand in ipairs(collect_candidate_tokens(ctx)) do
        list[#list + 1] = { text = cand.text, meta = cand.meta }
    end
    return list, ctx
end

-- ---------------------------------------------------------------------------
-- Execution
-- ---------------------------------------------------------------------------

--- Try each candidate in order until one opens successfully.
-- Highlights the matched token and positions the cursor on it.
---@param candidates GxPlusCandidate[]
---@return nil
local function execute_sequence(candidates)
    if #candidates == 0 then
        log("No target candidates.", vim.log.levels.WARN)
        return
    end
    for i, c in ipairs(candidates) do
        local success = open_path(c.text, c.meta)
        if success then
            if c.meta and c.meta.lnum and c.meta.start_col and c.meta.end_col then
                -- Convert 1-based token columns to 0-based extmark coordinates.
                highlight_temp(0, c.meta.lnum - 1, c.meta.start_col - 1, c.meta.end_col)
                pcall(vim.api.nvim_win_set_cursor, 0, { c.meta.lnum, c.meta.start_col - 1 })
            end
            if i > 1 then
                dlog("Opened candidate #" .. i .. " (" .. c.text .. ")")
            end
            return
        else
            dlog("Skipped candidate '" .. c.text .. "'")
        end
    end
    log("No valid target found after scanning.", vim.log.levels.WARN)
end

-- ---------------------------------------------------------------------------
-- User commands
-- ---------------------------------------------------------------------------

--- Create the GxPlus and GxPlusDiag user commands (idempotent via guard flag).
---@return nil
local function create_user_command()
    if vim.g._gxplus_universal_cmd_created then
        return
    end
    vim.api.nvim_create_user_command("GxPlus", function(opts)
        local list = resolve_targets(opts.args)
        execute_sequence(list)
    end, { nargs = "?", complete = "file", desc = "Universal open (URL / file / dir)" })

    -- Diagnostic command: prints context, detected adapter, and first 10 candidates.
    vim.api.nvim_create_user_command("GxPlusDiag", function()
        local ctx     = build_context()
        local adapter = first_matching_adapter(ctx)
        local list    = resolve_targets("")
        local lines   = {
            "=== GxPlusDiag ===",
            "filetype: " .. ctx.filetype,
            "cursor: lnum=" .. ctx.cursor.lnum .. " col0=" .. ctx.cursor.col0,
            "line: " .. ctx.line,
            "adapter: " .. (adapter and adapter.name or "none"),
            "candidates: " .. tostring(#list),
        }
        for i, c in ipairs(list) do
            if i > 10 then
                lines[#lines + 1] = "..."
                break
            end
            lines[#lines + 1] = i .. ": " .. c.text
        end
        vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
    end, { desc = "GxPlus diagnostics" })

    -- Set the guard so this block is never executed more than once.
    vim.g._gxplus_universal_cmd_created = true
end

-- ---------------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------------

--- Initialise GxPlus with optional configuration overrides.
-- Resets the adapter list and re-registers all enabled built-in adapters.
---@param opts GxPlusConfig|nil  Partial config table merged over defaults
---@return nil
function M.setup(opts)
    if opts then
        cfg = vim.tbl_deep_extend("force", cfg, opts)
    end
    -- Reset adapter state so the new config takes effect cleanly.
    adapters             = {}
    adapters_initialized = false
    for k, b in pairs({
        neo_tree   = adapter_neo_tree,
        nvim_tree  = adapter_nvim_tree,
        oil        = adapter_oil,
        mini_files = adapter_mini_files,
        netrw      = adapter_netrw,
    }) do
        if cfg.adapters[k] then
            local ok, d = pcall(b)
            if ok and d then
                M.register_adapter(d)
            end
        end
    end
    for _, d in ipairs(cfg.extra_adapters or {}) do
        M.register_adapter(d)
    end
    create_user_command()
end

--- Bind the default gx keymap to GxPlus in normal mode.
---@return nil
function M.map_default()
    vim.keymap.set("n", "gx", "<cmd>GxPlus<CR>", { silent = true, desc = "GxPlus Universal" })
end

--- Programmatically trigger GxPlus on the current cursor position.
---@return nil
function M.open_current()
    local list = resolve_targets("")
    execute_sequence(list)
end

return M
