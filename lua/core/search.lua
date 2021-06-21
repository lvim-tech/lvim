local search = {}

search.visual_selection = function(cmdtype)
    local temp = vim.fn.getreg("s")
    vim.cmd('norm! gv"sy')
    local search_pattern = "\\V" .. vim.fn.substitute(vim.fn.escape(temp, cmdtype .. "\\"), [[\n]], [[\\n]], "g")
    vim.fn.setreg("/", search_pattern)
    vim.fn.setreg("s", temp)
end

search.vim = function(filetypes)
    vim.cmd("vim // **/" .. filetypes)
end

return search
