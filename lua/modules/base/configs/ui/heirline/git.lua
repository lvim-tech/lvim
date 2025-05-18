local M = {}
local uv = vim.loop

local function safe_systemlist(cmd)
    local result = vim.fn.system(cmd .. " 2>/dev/null")
    if type(result) == "string" and result ~= "" then
        result = result:gsub("\n$", "")
        if result:match("^(fatal:|error:)") then
            return nil
        end
        return result
    end
    return nil
end

local function head_path()
    local root = safe_systemlist("git rev-parse --show-toplevel")
    if root and root ~= "" then
        return root .. "/.git/HEAD", root
    end
    return nil
end

function M.update_git_status(root)
    local branch = safe_systemlist("git rev-parse --abbrev-ref HEAD") or "unknown"
    local detached = (branch == "HEAD")

    local abbrev = safe_systemlist("git rev-parse --short HEAD") or "unknown"
    local oid = safe_systemlist("git rev-parse HEAD") or "unknown"
    local commit_message = safe_systemlist("git log -1 --pretty=%s") or "no commit message"

    local tag_info = safe_systemlist("git describe --tags --long --always") or ""
    local tag_name, tag_distance, tag_oid = nil, nil, nil
    if tag_info ~= "" then
        tag_name, tag_distance, tag_oid = tag_info:match("^(.-)%-(%d+)%-g(%x+)$")
        if not tag_name then
            tag_name = tag_info
            tag_distance = 0
            tag_oid = abbrev
        end
    end

    _G.LVIM_GIT = {
        root = root,
        head = {
            abbrev = abbrev,
            branch = branch,
            commit_message = commit_message,
            detached = detached,
            oid = oid,
            tag = {
                distance = tonumber(tag_distance),
                name = tag_name,
                oid = tag_oid,
            },
        },
    }
end

function M.start()
    local path, root = head_path()
    if not path or not root then
        _G.LVIM_GIT = nil
        if M.poller then
            M.poller:stop()
            M.poller:close()
            M.poller = nil
        end
        return
    end

    M.update_git_status(root)

    if M.poller then
        M.poller:stop()
        M.poller:close()
        M.poller = nil
    end

    M.poller = uv.new_fs_poll()
    M.poller:start(path, 1000, function(err, prev, now)
        if err then
            return
        end
        if prev and now and prev.mtime.sec ~= now.mtime.sec then
            vim.schedule(function()
                M.update_git_status(root)
            end)
        end
    end)
end

vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
    callback = M.start,
})

return M
