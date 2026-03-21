-- Git status poller for the heirline statusline.
-- Reads branch name, abbreviated commit SHA, full OID, last commit message,
-- and tag information from git CLI commands, then stores the result in
-- _G.LVIM.git so heirline components can render it without blocking the UI.
-- A libuv filesystem poll watches .git/HEAD for changes and refreshes the
-- cached data automatically whenever the branch or HEAD pointer changes.

---@module "modules.base.configs.ui.heirline.git"
---@diagnostic disable: undefined-field

local M = {}

---@type table  libuv handle exposed by Neovim (vim.uv)
local uv = vim.uv

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

-- Runs a shell command and returns its single-line trimmed output.
-- Returns nil when the command produces no output, exits with an error,
-- or prints a git "fatal:" / "error:" prefix.
---@param cmd string  Shell command to execute (stderr is suppressed via 2>/dev/null)
---@return string|nil  Trimmed output, or nil on empty / error output
local function safe_systemlist(cmd)
    local result = vim.fn.system(cmd .. " 2>/dev/null")
    if type(result) == "string" and result ~= "" then
        -- Strip the trailing newline that vim.fn.system always appends
        result = result:gsub("\n$", "")
        -- Treat git error messages as "no result"
        if result:match("^(fatal:|error:)") then
            return nil
        end
        return result
    end
    return nil
end

-- Returns the path to .git/HEAD and the repository root for the CWD.
-- Returns nil, nil when the CWD is not inside a git repository.
---@return string|nil  Absolute path to .git/HEAD
---@return string|nil  Absolute path to the repository root
local function head_path()
    local root = safe_systemlist("git rev-parse --show-toplevel")
    if root and root ~= "" then
        return root .. "/.git/HEAD", root
    end
    return nil
end

-- ---------------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------------

-- Queries git for the current branch, commit info, and tag, then writes the
-- result to _G.LVIM.git so heirline components can read it synchronously.
-- Called both on startup and from the libuv .git/HEAD watcher callback.
---@param root string  Absolute repository root path (used for context only)
---@return nil
function M.update_git_status(root)
    ---@type string
    local branch = safe_systemlist("git rev-parse --abbrev-ref HEAD") or "unknown"
    -- When HEAD is detached, git prints "HEAD" instead of a branch name
    local detached = (branch == "HEAD")

    ---@type string  Short (7-char) commit hash shown alongside the branch name
    local abbrev = safe_systemlist("git rev-parse --short HEAD") or "unknown"
    ---@type string  Full 40-char commit OID
    local oid = safe_systemlist("git rev-parse HEAD") or "unknown"
    ---@type string  Subject line of the most recent commit
    local commit_message = safe_systemlist("git log -1 --pretty=%s") or "no commit message"

    -- Parse tag information from "git describe --tags --long --always".
    -- Output format: <tag>-<distance>-g<short-oid>
    ---@type string
    local tag_info = safe_systemlist("git describe --tags --long --always") or ""
    ---@type string|nil
    local tag_name, tag_distance, tag_oid = nil, nil, nil
    if tag_info ~= "" then
        tag_name, tag_distance, tag_oid = tag_info:match("^(.-)%-(%d+)%-g(%x+)$")
        if not tag_name then
            -- No tag found; git returned only the short OID
            tag_name = tag_info
            tag_distance = 0
            tag_oid = abbrev
        end
    end

    -- Write the result into the global LVIM namespace for heirline to consume
    ---@type LvimGit
    _G.LVIM.git = {
        root = root,
        head = {
            abbrev = abbrev,
            branch = branch,
            commit_message = commit_message,
            detached = detached,
            oid = oid,
            tag = {
                -- tonumber converts the string match to an integer (or nil)
                distance = tonumber(tag_distance),
                name = tag_name,
                oid = tag_oid,
            },
        },
    }
end

-- Starts (or restarts) the git status subsystem for the current working directory.
-- If the CWD is not a git repository, clears _G.LVIM.git and stops the poller.
-- Otherwise, performs an immediate status update and then watches .git/HEAD for
-- changes using a libuv fs_poll timer.
---@return nil
function M.start()
    local path, root = head_path()
    if not path or not root then
        -- Not in a git repository — clear cached data and stop any active poller
        _G.LVIM.git = nil
        if M.poller then
            M.poller:stop()
            M.poller:close()
            M.poller = nil
        end
        return
    end

    -- Populate git status immediately so the statusline shows data right away
    M.update_git_status(root)

    -- Stop the previous poller before creating a new one (e.g. after DirChanged)
    if M.poller then
        M.poller:stop()
        M.poller:close()
        M.poller = nil
    end

    -- Poll .git/HEAD every 1 second; refresh only when the mtime actually changes.
    -- The callback runs on the libuv thread, so updates are scheduled back to the
    -- main Neovim event loop via vim.schedule.
    M.poller = uv.new_fs_poll()
    M.poller:start(path, 1000, function(err, prev, now)
        if err then
            return
        end
        -- Compare modification timestamps to avoid redundant git calls
        if prev and now and prev.mtime.sec ~= now.mtime.sec then
            vim.schedule(function()
                M.update_git_status(root)
            end)
        end
    end)
end

-- Trigger M.start when Neovim loads and whenever the working directory changes
-- (e.g. after :cd, oil.nvim directory navigation, etc.)
vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
    callback = M.start,
})

return M
