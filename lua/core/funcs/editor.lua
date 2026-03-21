-- Editor-aware utilities: Helm file detection and Treesitter-based comment removal.
---@module "core.funcs.editor"
local M = {}

-- Returns true when the current buffer is a Helm template file.
-- Detection is based on path patterns (templates/ directory, .gotmpl extension,
-- helmfile prefix) rather than file extension alone, since Helm files use .yaml.
---@return boolean  True if the buffer looks like a Helm template
M.is_helm = function()
    local filepath = vim.fn.expand("%:p")
    local filename = vim.fn.expand("%:t")
    -- Files inside a chart's templates/ directory are always Helm
    if
        string.match(filepath, ".+/templates/.+%.yaml$")
        or string.match(filepath, ".+/templates/.+%.yml$")
        or string.match(filepath, ".+/templates/.+%.tpl$")
        or string.match(filepath, ".+/templates/.+%.txt$")
    then
        return true
    end
    if string.match(filename, ".+%.gotmpl$") then
        return true
    end
    if string.match(filename, "helmfile.+%.yaml$") or string.match(filename, "helmfile.+%.yml$") then
        return true
    end
    return false
end

-- Removes all comments from the current buffer using Treesitter queries.
-- Whole-line comments are deleted entirely; inline comments are excised in-place.
-- Edits are applied bottom-up to preserve row indices during modification.
-- The buffer is reformatted via LSP after deletion.
M.remove_comments = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local ft = vim.bo[bufnr].filetype

    local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
    if not ok or not parser then
        vim.notify("Treesitter parser not available for " .. ft, vim.log.levels.WARN)
        return
    end

    local lang = parser:lang()

    -- Java uses distinct node names for line vs block comments
    local queries = {
        javascript = [[ (comment) @comment ]],
        typescript = [[ (comment) @comment ]],
        java = [[ (line_comment) @comment  (block_comment) @block_comment ]],
        lua = [[ (comment) @comment ]],
        python = [[ (comment) @comment ]],
        go = [[ (comment) @comment ]],
        c = [[ (comment) @comment ]],
        cpp = [[ (comment) @comment ]],
        rust = [[ (line_comment) @comment ]],
        html = [[ (comment) @comment ]],
        css = [[ (comment) @comment ]],
        yaml = [[ (comment) @comment ]],
        toml = [[ (comment) @comment ]],
        bash = [[ (comment) @comment ]],
        sh = [[ (comment) @comment ]],
    }

    local query_str = queries[lang] or [[ (comment) @comment ]]

    local ok_query, query = pcall(vim.treesitter.query.parse, lang, query_str)
    if not ok_query then
        vim.notify("Failed to parse treesitter query for " .. lang, vim.log.levels.WARN)
        return
    end

    local tree = parser:parse()[1]
    local root = tree:root()

    ---@type table<integer, boolean>  Rows to delete entirely
    local lines_to_delete = {}
    ---@type LvimCommentEdit[]        Inline comment ranges to excise
    local edits = {}
    local capture_names = query.captures or {}

    for id, node in query:iter_captures(root, bufnr, 0, -1) do
        local capture_name = capture_names[id] or "comment"
        local srow, scol, erow, ecol = node:range()

        if capture_name == "block_comment" then
            -- Mark every row spanned by the block for deletion
            for i = srow, erow do
                lines_to_delete[i] = true
            end
        elseif capture_name == "comment" then
            if srow == erow then
                local line = vim.api.nvim_buf_get_lines(bufnr, srow, srow + 1, false)[1]
                if scol == 0 and ecol == #line then
                    -- Comment occupies the full line — delete the row
                    lines_to_delete[srow] = true
                else
                    -- Inline comment — record the range to excise
                    table.insert(edits, { row = srow, start_col = scol, end_col = ecol, type = "partial" })
                end
            else
                for i = srow, erow do
                    lines_to_delete[i] = true
                end
            end
        end
    end

    -- Process inline edits bottom-up (reverse row, then reverse col) so that
    -- earlier edits don't shift the positions of later ones
    table.sort(edits, function(a, b)
        if a.row == b.row then
            return a.start_col > b.start_col
        end
        return a.row > b.row
    end)

    for _, edit in ipairs(edits) do
        -- Skip rows already queued for full deletion
        if not lines_to_delete[edit.row] then
            local line = vim.api.nvim_buf_get_lines(bufnr, edit.row, edit.row + 1, false)[1]
            local before = line:sub(1, edit.start_col)
            local after = line:sub(edit.end_col + 1)
            vim.api.nvim_buf_set_lines(bufnr, edit.row, edit.row + 1, false, { before .. after })
        end
    end

    -- Delete full rows bottom-up to avoid index shifting
    local rows_to_delete = {}
    for row in pairs(lines_to_delete) do
        table.insert(rows_to_delete, row)
    end
    table.sort(rows_to_delete, function(a, b)
        return a > b
    end)

    for _, row in ipairs(rows_to_delete) do
        vim.api.nvim_buf_set_lines(bufnr, row, row + 1, false, {})
    end

    -- Reformat after deletion so remaining code is properly indented
    vim.schedule(function()
        vim.lsp.buf.format({ async = true })
    end)
end

return M
