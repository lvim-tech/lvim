-- Table utility functions: merging, sorting, and searching Lua tables.
---@module "core.funcs.table"
local M = {}

-- Deep-merges tbl2 into tbl1 in-place. Nested tables are merged recursively;
-- scalar values and mixed-type keys are overwritten by tbl2.
---@param tbl1 table  Destination table (mutated)
---@param tbl2 table  Source table
---@return table      tbl1 after merging
M.merge = function(tbl1, tbl2)
    if type(tbl1) == "table" and type(tbl2) == "table" then
        for k, v in pairs(tbl2) do
            if type(v) == "table" and type(tbl1[k] or false) == "table" then
                M.merge(tbl1[k], v)
            else
                tbl1[k] = v
            end
        end
    end
    return tbl1
end

-- Converts a hash table into a mixed array/hash table so that ipairs() can
-- iterate the entries in a deterministic order. Used to execute config
-- functions in a predictable sequence.
---@param tbl table  Hash table to sort
---@return table     The same table with numeric indices added
M.sort = function(tbl)
    local arr = {}
    for key, value in pairs(tbl) do
        arr[#arr + 1] = { key, value }
    end
    for ix, value in ipairs(arr) do
        tbl[ix] = value
    end
    return tbl
end

-- Sorts bracket-key lines (e.g. `["foo"] = ...`) in the current buffer
-- alphabetically, placing all other lines after them. Useful for keeping
-- plugin module tables tidy.
M.sort_lua_table = function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local sorted_lines = {}
    local inner_lines = {}
    for _, line in ipairs(lines) do
        if line:match('%[".*"%]') then
            table.insert(sorted_lines, line)
        else
            table.insert(inner_lines, line)
        end
    end
    table.sort(sorted_lines)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, sorted_lines)
    vim.api.nvim_buf_set_lines(0, #sorted_lines, -1, false, inner_lines)
end

-- Linear search for a value in an array table.
---@param tbl   table  Array to search
---@param value any    Value to look for
---@return boolean     True if value is present
M.has_value = function(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

-- Concatenates two arrays, skipping any element already seen. O(n) via a hash
-- set — avoids the O(n²) cost of calling has_value() per element.
---@param table1 table  First array
---@param table2 table  Second array
---@return table        New array with unique values from both inputs
M.merge_unique = function(table1, table2)
    local seen = {}
    local merged = {}
    for _, v in ipairs(table1) do
        if not seen[v] then
            seen[v] = true
            merged[#merged + 1] = v
        end
    end
    for _, v in ipairs(table2) do
        if not seen[v] then
            seen[v] = true
            merged[#merged + 1] = v
        end
    end
    return merged
end

-- Returns a new array with duplicate values removed, preserving first-seen order.
---@param tbl table  Input array
---@return table     Deduplicated array
M.remove_duplicate = function(tbl)
    local hash = {}
    local res = {}
    for _, v in ipairs(tbl) do
        if not hash[v] then
            res[#res + 1] = v
            hash[v] = true
        end
    end
    return res
end

-- Returns a comparator function that sorts elements by their position in
-- a predefined `order` array. Elements not in the order array sort as 0.
---@param order table  Array defining the desired sort order
---@return function    Comparator for table.sort()
M.custom_sort = function(order)
    return function(a, b)
        local indexA = 0
        local indexB = 0
        for i, value in ipairs(order) do
            if value == a then
                indexA = i
            elseif value == b then
                indexB = i
            end
        end
        return indexA < indexB
    end
end

-- Searches a table whose values are arrays, returning the key whose array
-- contains search_value. Used to reverse-lookup a filetype from file_types map.
---@param tbl          table  Hash table with array values
---@param search_value any    Value to search for inside nested arrays
---@return any|nil            Key whose array contained search_value, or nil
M.find_key_by_value = function(tbl, search_value)
    for key, value in pairs(tbl) do
        if type(value) == "table" then
            for _, v in ipairs(value) do
                if v == search_value then
                    return key
                end
            end
        end
    end
    return nil
end

return M
