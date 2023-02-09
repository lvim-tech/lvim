local M = {}
_G.Status = M

function M.get_signs()
    local buf = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
    return vim.tbl_map(function(sign)
        return vim.fn.sign_getdefined(sign.name)[1]
    end, vim.fn.sign_getplaced(buf, { group = "*", lnum = vim.v.lnum })[1].signs)
end

function M.statuscolumn()
    local diagnostic_sign, git_sign
    for _, s in ipairs(M.get_signs()) do
        if s.name:find("GitSign") then
            git_sign = s
        elseif s.name:find("Diagnostic") then
            diagnostic_sign = s
        end
    end
    local diagnostic_column = diagnostic_sign
            and ("%#" .. diagnostic_sign.texthl .. "#" .. diagnostic_sign.text:sub(1, -2) .. "%*")
        or " "
    local git_column = git_sign and ("%#" .. git_sign.texthl .. "#" .. git_sign.text:sub(1, -2) .. "%*") or " "
    local number_text = " "
    local number = vim.api.nvim_win_get_option(vim.g.statusline_winid, "number")
    if number and vim.wo.relativenumber and vim.v.virtnum == 0 then
        number_text = vim.v.relnum == 0 and vim.v.lnum or vim.v.relnum
    elseif number and vim.wo.relativenumber == false and vim.v.virtnum == 0 then
        number_text = vim.v.lnum == 0 and vim.v.lnum or vim.v.lnum
    else
        return ""
    end
    local number_column = "%=" .. " " .. number_text .. " "
    local columns = {
        diagnostic_column,
        number_column,
        git_column,
    }
    return table.concat(columns, "")
end

return M
