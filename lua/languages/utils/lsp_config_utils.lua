local M = { path = {} }

local function escape_wildcards(path)
    return path:gsub("([%[%]%?%*])", "\\%1")
end

function M.root_pattern(...)
    local patterns = M.tbl_flatten({ ... })
    return function(startpath)
        startpath = M.strip_archive_subpath(startpath)
        for _, pattern in ipairs(patterns) do
            local match = M.search_ancestors(startpath, function(path)
                for _, p in ipairs(vim.fn.glob(table.concat({ escape_wildcards(path), pattern }, "/"), true, true)) do
                    if vim.uv.fs_stat(p) then
                        return path
                    end
                end
            end)
            if match ~= nil then
                return match
            end
        end
    end
end

function M.insert_package_json(config_files, field, fname)
    local path = vim.fn.fnamemodify(fname, ":h")
    local root_with_package = vim.fs.dirname(vim.fs.find("package.json", { path = path, upward = true })[1])

    if root_with_package then
        local path_sep = "/"
        for line in io.lines(root_with_package .. path_sep .. "package.json") do
            if line:find(field) then
                config_files[#config_files + 1] = "package.json"
                break
            end
        end
    end
    return config_files
end

function M.strip_archive_subpath(path)
    path = vim.fn.substitute(path, "zipfile://\\(.\\{-}\\)::[^\\\\].*$", "\\1", "")
    path = vim.fn.substitute(path, "tarfile:\\(.\\{-}\\)::.*$", "\\1", "")
    return path
end

function M.tbl_flatten(t)
    return vim.iter(t):flatten(math.huge):totable()
end

return M
