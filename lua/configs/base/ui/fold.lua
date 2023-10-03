local function get_custom_foldtxt_suffix(foldstart)
    local fold_suffix_str = string.format(" %s [%s lines]", "➤", vim.v.foldend - foldstart + 1)

    return { fold_suffix_str, "Folded" }
end

local function get_custom_foldtext(foldtxt_suffix, foldstart)
    local line = vim.api.nvim_buf_get_lines(0, foldstart - 1, foldstart, false)[1]

    return {
        { line, "Normal" },
        foldtxt_suffix,
    }
end

_G.get_foldtext = function()
    local foldstart = vim.v.foldstart
    local ts_foldtxt = vim.treesitter.foldtext()
    local foldtxt_suffix = get_custom_foldtxt_suffix(foldstart)

    if type(ts_foldtxt) == "string" then
        return get_custom_foldtext(foldtxt_suffix, foldstart)
    end

    table.insert(ts_foldtxt, foldtxt_suffix)
    return ts_foldtxt
end

vim.opt.foldtext = "v:lua.get_foldtext()"
