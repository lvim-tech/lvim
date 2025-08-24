local M = {}

local defaults = {
    highlight_match = true,
    system_open_cmd = nil,
    force_system_open_local = true,
    -- system_open_cmd = vim.fn.expand("/usr/bin/gedit"),
    -- force_system_open_local = true,
    allow_bare_domains = true,
    icon_guard = true,
    notify_level = vim.log.levels.INFO,
    dir_open_strategy = "system",
    search_forward_if_none = true,
    search_backward_if_none = true,
    search_max_lines = 60,
    pick_nearest_direction = true,
    pattern = "[%w%._~/#%-%+%%%?=&@:%d]+",
    debug = false,
    adapters = {
        neo_tree = true,
        nvim_tree = true,
        oil = true,
        mini_files = true,
        netrw = true,
    },
    extra_adapters = {},
    highlight_duration_ms = 300,
    ignore_headless_guard = false,
    max_sequential_candidates = 200,
}

local cfg = vim.deepcopy(defaults)
local uv = vim.uv or vim.loop
local adapters = {}
local adapters_initialized = false

local function dlog(msg)
    if cfg.debug then
        vim.notify("[GxPlus] " .. msg, vim.log.levels.DEBUG)
    end
end

local function log(msg, level)
    vim.notify("GxPlus: " .. msg, level or cfg.notify_level)
end

local function env_headless()
    if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
        return false
    end
    return (not os.getenv("DISPLAY") and not os.getenv("WAYLAND_DISPLAY") and not os.getenv("WSL_DISTRO_NAME"))
end

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

local function normalize_path(p)
    if not p then
        return p
    end
    p = p:gsub("\\", "/"):gsub("//+", "/")
    if #p > 1 and p:sub(-1) == "/" then
        p = p:sub(1, -2)
    end
    return p
end

local function is_url(s)
    return s:match("^https?://") or s:match("^file://")
end
local function strip_trailing_punct(s)
    return s:gsub("[)>.,;:]+$", "")
end
local function unquote(s)
    if s:match('^".*"$') or s:match("^'.*'$") then
        return s:sub(2, -2)
    end
    return s
end
local function expand_path(p)
    if p:sub(1, 1) == "~" then
        return vim.fn.expand(p)
    end
    return p
end
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
local function path_exists(p)
    return p and uv.fs_stat(p) ~= nil
end
local function is_dir(p)
    local st = uv.fs_stat(p)
    return st and st.type == "directory"
end
local function looks_like_domain_repo(s)
    if not cfg.allow_bare_domains then
        return false
    end
    return s:match("^[%w%.%-]+%.[%w%.%-]+/.+")
end
local function is_icon_like(token)
    if not cfg.icon_guard then
        return false
    end
    if not token or token == "" then
        return true
    end
    if token:match("[%w%./~]") then
        return false
    end
    local chars = vim.fn.strchars(token)
    return chars <= 6
end

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
        end_col = end_col,
        hl_group = "Visual",
        hl_mode = "combine",
        priority = 150,
    })

    if not ok then
        vim.notify("gxplus: failed to add extmark highlight: " .. tostring(mark_id_or_err), vim.log.levels.ERROR)
        return
    end

    -- schedule removal: prefer deleting the single extmark if we have an id, else clear namespace
    vim.defer_fn(function()
        if vim.api.nvim_buf_del_extmark and type(mark_id_or_err) == "number" then
            pcall(vim.api.nvim_buf_del_extmark, buf, ns, mark_id_or_err)
        else
            pcall(vim.api.nvim_buf_clear_namespace, buf, ns, 0, -1)
        end
    end, cfg.highlight_duration_ms or 250)
end

local function get_line(buf, lnum)
    return vim.api.nvim_buf_get_lines(buf, lnum - 1, lnum, false)[1]
end

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

local function token_under_cursor(line, col1, pattern)
    for _, t in ipairs(scan_line_tokens(line, pattern)) do
        if col1 >= t.s and col1 <= t.e and not is_icon_like(t.text) then
            return t
        end
    end
end

local function collect_tokens_in_line(line, pattern)
    local out = {}
    for _, t in ipairs(scan_line_tokens(line, pattern)) do
        if not is_icon_like(t.text) and t.text ~= "" then
            out[#out + 1] = t
        end
    end
    return out
end

local function adapter_neo_tree()
    return {
        name = "neo_tree",
        detect = function(ctx)
            return ctx.filetype == "neo-tree"
        end,
        get = function(ctx)
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
            local line = ctx.line or ""
            line = line:gsub("^%s+", "")
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

local function adapter_nvim_tree()
    return {
        name = "nvim_tree",
        detect = function(ctx)
            return ctx.filetype == "NvimTree"
        end,
        get = function()
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

local function adapter_oil()
    return {
        name = "oil",
        detect = function(ctx)
            return ctx.filetype == "oil"
        end,
        get = function()
            local ok, oil = pcall(require, "oil")
            if not ok then
                return nil
            end
            local okd, dir = pcall(oil.get_current_dir)
            local oke, entry = pcall(oil.get_cursor_entry)
            if okd and dir and oke and entry and entry.name then
                return { path = normalize_path(dir .. entry.name), type = entry.type == "directory" and "dir" or "file" }
            end
        end,
    }
end

local function adapter_mini_files()
    return {
        name = "mini_files",
        detect = function(ctx)
            local ft = ctx.filetype
            return ft == "minifiles" or ft == "mini.files" or ft == "MiniFiles"
        end,
        get = function()
            local ok_mf, mf = pcall(require, "mini.files")
            if not ok_mf then
                return nil
            end
            if mf.get_fs_entry then
                local ok_e, entry = pcall(mf.get_fs_entry)
                if ok_e and entry and entry.path then
                    return {
                        path = normalize_path(entry.path),
                        type = entry.fs_type == "directory" and "dir" or (entry.fs_type or "file"),
                    }
                end
            end
            if mf.get_cursor_entry then
                local ok_c, cent = pcall(mf.get_cursor_entry)
                if ok_c and cent and cent.path then
                    return {
                        path = normalize_path(cent.path),
                        type = cent.fs_type == "directory" and "dir" or (cent.fs_type or "file"),
                    }
                end
            end
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
                if raw:sub(1, 1) == "/" and not path_exists(raw) then
                    raw = raw:sub(2)
                end
                return { path = normalize_path(current_dir .. "/" .. raw), type = "unknown" }
            end
        end,
    }
end

local function adapter_netrw()
    return {
        name = "netrw",
        detect = function(ctx)
            return ctx.filetype == "netrw"
        end,
        get = function(ctx)
            local line = ctx.line or ""
            line = line:gsub("^%s*[%d%.]+%s*", "")
            local name = line:match("^(%S+)")
            if name and name ~= "" and not is_icon_like(name) then
                return { path = normalize_path(vim.fn.getcwd() .. "/" .. name), type = "unknown" }
            end
        end,
    }
end

local built_in_adapter_builders = {
    neo_tree = adapter_neo_tree,
    nvim_tree = adapter_nvim_tree,
    oil = adapter_oil,
    mini_files = adapter_mini_files,
    netrw = adapter_netrw,
}

function M.register_adapter(def)
    if not def or not def.name or not def.detect or not def.get then
        log("Adapter registration failed (missing fields)", vim.log.levels.ERROR)
        return
    end
    adapters[#adapters + 1] = def
end

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

local function build_context()
    local cur = vim.api.nvim_win_get_cursor(0)
    return {
        bufnr = vim.api.nvim_get_current_buf(),
        winid = vim.api.nvim_get_current_win(),
        filetype = vim.bo.filetype,
        cursor = { lnum = cur[1], col0 = cur[2], col1 = cur[2] + 1 },
        line = vim.api.nvim_get_current_line(),
        cwd = vim.loop.cwd(),
    }
end

local function first_matching_adapter(ctx)
    ensure_adapters()
    for _, ad in ipairs(adapters) do
        local ok, res = pcall(ad.detect, ctx)
        if ok and res then
            return ad
        end
    end
end

local function system_open(target, kind)
    local opener = detect_system_opener()
    if kind ~= "url" and not cfg.force_system_open_local then
        return false, "disabled"
    end
    if kind ~= "url" and env_headless() and not cfg.ignore_headless_guard then
        return false, "headless"
    end
    local cmd = (opener == "start") and { "cmd", "/c", "start", "", target } or { opener, target }
    dlog("system_open: " .. table.concat(cmd, " "))
    local ok, jid = pcall(vim.fn.jobstart, cmd, {
        detach = true,
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

local function jump_to_line_col(line, col)
    if line then
        pcall(vim.api.nvim_win_set_cursor, 0, { line, math.max(0, (col or 1) - 1) })
    end
end

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
    if not path_exists(filePart) and filePart:match("^/[^/]+$") then
        local candidate = normalize_path(vim.loop.cwd() .. filePart)
        if path_exists(candidate) then
            filePart = candidate
        end
    end
    if not path_exists(filePart) then
        local current_file = vim.api.nvim_buf_get_name(0)
        if current_file ~= "" then
            local base = vim.fn.fnamemodify(current_file, ":h")
            local alt = normalize_path(base .. "/" .. filePart)
            if path_exists(alt) then
                filePart = alt
            end
        end
    end
    if not path_exists(filePart) then
        local decoded = filePart:gsub("%%20", " ")
        if decoded ~= filePart and path_exists(decoded) then
            filePart = decoded
        else
            if looks_like_domain_repo(filePart) then
                local url = "https://" .. filePart
                local ok = system_open(url, "url")
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
        jump_to_line_col(line or (meta and meta.line), col or (meta and meta.col))
    end
    return true
end

local function collect_candidate_tokens(ctx)
    local buf = ctx.bufnr
    local pattern = cfg.pattern
    local lnum = ctx.cursor.lnum
    local col1 = ctx.cursor.col1
    local seen = {}
    local order = {}
    local function add(text, meta)
        if text and text ~= "" and not is_icon_like(text) and not seen[text] then
            seen[text] = true
            order[#order + 1] = { text = text, meta = meta }
        end
    end
    local line = get_line(buf, lnum) or ""
    local under = token_under_cursor(line, col1, pattern)
    if under then
        add(under.text, { lnum = lnum, start_col = under.s, end_col = under.e, origin = "under" })
    end
    local tokens_line = collect_tokens_in_line(line, pattern)
    for _, t in ipairs(tokens_line) do
        if not (under and t.text == under.text) then
            add(t.text, { lnum = lnum, start_col = t.s, end_col = t.e, origin = "same_line" })
        end
    end
    local max_lines = cfg.search_max_lines
    local total = vim.api.nvim_buf_line_count(buf)
    local up_count, down_count = 0, 0
    local radius = 1
    while
        (cfg.search_forward_if_none or cfg.search_backward_if_none)
        and (up_count < max_lines or down_count < max_lines)
        and #order < cfg.max_sequential_candidates
    do
        local did = false
        if cfg.search_backward_if_none and (lnum - radius) >= 1 and up_count < max_lines then
            local l = lnum - radius
            local ltext = get_line(buf, l) or ""
            for _, t in ipairs(collect_tokens_in_line(ltext, pattern)) do
                add(t.text, { lnum = l, start_col = t.s, end_col = t.e, origin = "up" })
            end
            up_count = up_count + 1
            did = true
        end
        if cfg.search_forward_if_none and (lnum + radius) <= total and down_count < max_lines then
            local l = lnum + radius
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

local function resolve_targets(args)
    local ctx = build_context()
    if args and args ~= "" then
        return { { text = args, meta = { source = "argument" } } }, ctx
    end
    local adapter = first_matching_adapter(ctx)
    local list = {}
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

local function execute_sequence(candidates)
    if #candidates == 0 then
        log("No target candidates.", vim.log.levels.WARN)
        return
    end
    for i, c in ipairs(candidates) do
        local success = open_path(c.text, c.meta)
        if success then
            if c.meta and c.meta.lnum and c.meta.start_col and c.meta.end_col then
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

local function create_user_command()
    if vim.g._gxplus_universal_cmd_created then
        return
    end
    vim.api.nvim_create_user_command("GxPlus", function(opts)
        local list = resolve_targets(opts.args)
        execute_sequence(list)
    end, { nargs = "?", complete = "file", desc = "Universal open (URL / file / dir)" })
    vim.api.nvim_create_user_command("GxPlusDiag", function()
        local ctx = build_context()
        local adapter = first_matching_adapter(ctx)
        local list = resolve_targets("")
        local lines = {
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
    vim.g._gxplus_universal_cmd_created = true
end

function M.setup(opts)
    if opts then
        cfg = vim.tbl_deep_extend("force", cfg, opts)
    end
    adapters = {}
    adapters_initialized = false
    for k, b in pairs({
        neo_tree = adapter_neo_tree,
        nvim_tree = adapter_nvim_tree,
        oil = adapter_oil,
        mini_files = adapter_mini_files,
        netrw = adapter_netrw,
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

function M.map_default()
    vim.keymap.set("n", "gx", "<cmd>GxPlus<CR>", { silent = true, desc = "GxPlus Universal" })
end

function M.open_current()
    local list = resolve_targets("")
    execute_sequence(list)
end

return M
