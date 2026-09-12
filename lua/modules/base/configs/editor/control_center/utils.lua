-- Shared helpers for the LVIM Control Center groups.
-- Exports:
--   merge_lists(t1, t2)              concatenate two array tables into a new one.
--   is_excluded(buf, extra_bt, extra_ft)
--                                    true when a buffer should be skipped by UI
--                                    features, matching its buftype/filetype
--                                    against the base exclusion lists plus any
--                                    extra buftypes/filetypes passed in.

---@module "modules.base.configs.editor.control_center.utils"

local M = {}

-- Filetypes that never take editor display options even though they ARE real file buffers.
-- (A non-file buffer is excluded by `is_excluded` outright — see there; this list is for the exceptions
-- among real files, and for naming the panels explicitly so the intent is readable.)
local base_bt = {}
local base_ft = { "", "lvim-ui-frame", "lvim-dashboard", "lvim-files", "lvim-control-center" }

M.merge_lists = function(t1, t2)
    local res = {}
    for _, v in ipairs(t1 or {}) do
        res[#res + 1] = v
    end
    for _, v in ipairs(t2 or {}) do
        res[#res + 1] = v
    end
    return res
end

--- Build a Control Center setting bound to a WINDOW-LOCAL vim option.
--- Both `get` and `set` use the GLOBAL value of the option, so the panel shows (and changes)
--- the same thing no matter which window it is opened from — a file window or a special
--- buffer such as the dashboard / the lvim-files panel, whose window-local values intentionally differ.
--- `set` also pushes the new value to the currently-open non-excluded windows for an
--- immediate effect, then persists.
-- The last-applied value of every window-local display option, keyed by option name. Populated
-- by win_option.set (startup restore AND panel edits), read by the enforcer below.
---@type table<string, { value:any, exclude_ft:string[] }>
local win_applied = {}
---@type integer? augroup id — created once, guards against re-registering the enforcer
local win_enforce_group = nil

--- Install (once) the autocmd that RE-APPLIES the persisted window-local display options to any
--- normal file buffer shown in a window AFTER startup. Neovim copies window-local options from
--- the window a new one is created in — NOT from the global default — so a window opened later
--- from an excluded window (the dashboard → lvim-space → a project file) would otherwise inherit
--- that window's stale value and ignore the persisted setting. Only normal buffers (buftype "")
--- are touched, so plugin panels / dashboards / trees keep their own display.
---@return nil
local function ensure_win_enforcer()
    if win_enforce_group then
        return
    end
    win_enforce_group = vim.api.nvim_create_augroup("LvimControlCenterWinOptions", { clear = true })
    vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType" }, {
        group = win_enforce_group,
        callback = function(args)
            if vim.bo[args.buf].buftype ~= "" then
                return -- only real file buffers; leave panels/trees/terminals/dashboards alone
            end
            local win = vim.api.nvim_get_current_win()
            for opt, spec in pairs(win_applied) do
                if not M.is_excluded(args.buf, {}, spec.exclude_ft or {}) then
                    pcall(function()
                        vim.wo[win][opt] = spec.value
                    end)
                end
            end
        end,
        desc = "Enforce Control Center window-local display options on newly shown file windows",
    })
end

---@param o { name:string, label:string, opt?:string, type?:string, default:any, options?:any[], exclude_ft?:string[], desc?:string, disabled?:boolean|fun(value:any):boolean }
---@return table
M.win_option = function(o)
    local opt = o.opt or o.name
    return {
        name = o.name,
        label = o.label,
        desc = o.desc,
        type = o.type or "bool",
        default = o.default,
        options = o.options,
        -- Optional: render the row dimmed + struck through when the predicate returns true
        -- (the value is left untouched). Used to show an option as inert while a master
        -- toggle is off — e.g. relative line numbers while "Show line numbers" is disabled.
        disabled = o.disabled,
        get = function(ctx)
            -- Pure window-local options have no reliable global value, so the panel reads the
            -- persisted (intended) value from the owning instance's store — window-independent,
            -- the same from a file or the dashboard. Falls back to the default when nothing is
            -- stored yet (or when opened outside a panel, so ctx is absent).
            local v = ctx and ctx.data and ctx.data:load(o.name)
            if v == nil then
                v = o.default
            end
            if o.type == "string" then
                return type(v) == "table" and table.concat(v, ",") or tostring(v)
            end
            return v
        end,
        set = function(val, on_init, ctx)
            -- Global default first (so windows opened with no parent inherit it).
            vim.api.nvim_set_option_value(opt, val, { scope = "global" })
            -- Remember the intended value + install the enforcer, so windows opened LATER (a project
            -- file opened from the dashboard via lvim-space, well after this restore ran) get it too —
            -- new windows copy window-local options from their parent window, not the global default.
            win_applied[opt] = { value = val, exclude_ft = o.exclude_ft or {} }
            ensure_win_enforcer()
            -- Apply to every ALREADY-OPEN window too — on startup restore as well as on a panel
            -- edit. The global scope above only seeds parentless windows; a window that already
            -- exists keeps its own window-local value (set from the core defaults before this restore
            -- ran), so without this loop the buffer visible at startup would ignore a persisted
            -- "off". This is why toggling from the panel "worked" while the startup value did not —
            -- the edit path always ran this loop.
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                local buf = vim.api.nvim_win_get_buf(win)
                if not M.is_excluded(buf, {}, o.exclude_ft or {}) then
                    vim.wo[win][opt] = val
                end
            end
            -- Persist only genuine edits, never the startup restore (the value was just loaded).
            if not on_init and ctx and ctx.data then
                ctx.data:save(o.name, val)
            end
        end,
    }
end

--- Build a Control Center setting bound to a GLOBAL vim option (vim.o / vim.opt).
--- `set` applies it globally and persists (skipping persistence during startup restore).
---@param o { name:string, label:string, opt?:string, type?:string, default:any, options?:any[], desc?:string, disabled?:boolean|fun(value:any):boolean }
---@return table
M.global_option = function(o)
    local opt = o.opt or o.name
    return {
        name = o.name,
        label = o.label,
        desc = o.desc,
        type = o.type or "bool",
        default = o.default,
        options = o.options,
        -- Optional: render the row dimmed + struck through when the predicate returns true
        -- (value untouched) — e.g. 'smartcase' is inert while 'ignorecase' is off.
        disabled = o.disabled,
        get = function(ctx)
            -- Read the persisted (intended) value from the owning instance's store so buffer-local
            -- options (tabstop, …) are not read off a special buffer such as the dashboard; default
            -- until stored (or when opened outside a panel, so ctx is absent).
            local v = ctx and ctx.data and ctx.data:load(o.name)
            if v == nil then
                v = o.default
            end
            if o.type == "string" then
                return type(v) == "table" and table.concat(v, ",") or tostring(v)
            end
            return v
        end,
        set = function(val, on_init, ctx)
            vim.opt[opt] = val
            if not on_init and ctx and ctx.data then
                ctx.data:save(o.name, val)
            end
        end,
    }
end

--- Is `buf` off-limits for a window-local editor option?
---
--- THE GUARD: a buffer that is not a real FILE (`buftype ~= ""` — a panel, a tree, a terminal, the start
--- dashboard, quickfix, help) never takes editor display options. Line numbers on the control-center panel
--- itself, or on the dashboard the panel was opened over, are not a setting the user asked for — they are the
--- toggle leaking into the chrome. The enforcer autocmd already refused such buffers; the APPLY loops did
--- not, which is exactly where it leaked. The filetype lists remain for the exceptions among real files
--- (markdown, a tree that IS a file buffer, …).
M.is_excluded = function(buf, extra_bt, extra_ft)
    local exclude_bt = M.merge_lists(base_bt, extra_bt)
    local exclude_ft = M.merge_lists(base_ft, extra_ft)
    local ft = vim.bo[buf].filetype
    local bt = vim.bo[buf].buftype
    if bt ~= "" then
        return true -- not a file buffer: chrome, not content
    end
    for _, ebt in ipairs(exclude_bt or {}) do
        if bt == ebt then
            return true
        end
    end
    for _, eft in ipairs(exclude_ft or {}) do
        if ft == eft then
            return true
        end
    end
    return false
end

return M
