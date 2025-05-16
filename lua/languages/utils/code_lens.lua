local M = {}

local icons = {
    run = {
        icon = "",
        color = _G.LVIM_COLORS.green,
        hl_group = "CodeLensRun",
    },
    test = {
        icon = "",
        color = _G.LVIM_COLORS.orange,
        hl_group = "CodeLensTest",
    },
    benchmark = {
        icon = "",
        color = _G.LVIM_COLORS.red,
        hl_group = "CodeLensBench",
    },
    example = {
        icon = "",
        color = _G.LVIM_COLORS.blue,
        hl_group = "CodeLensExample",
    },
}

local function setup_highlights()
    for _, config in pairs(icons) do
        vim.api.nvim_set_hl(0, config.hl_group, {
            fg = config.color,
            bold = true,
            default = false,
        })
    end
end

local ns_id = vim.api.nvim_create_namespace("CodeLensIcons")

local function clear_virtual_texts(bufnr)
    vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
end

local function get_icon_for_title(title)
    local lower = title:lower()
    if lower:match("^run") then
        return icons.run.icon, icons.run.hl_group
    elseif lower:match("^test") then
        return icons.test.icon, icons.test.hl_group
    elseif lower:match("^bench") then
        return icons.benchmark.icon, icons.benchmark.hl_group
    elseif lower:match("^example") then
        return icons.example.icon, icons.example.hl_group
    else
        return icons.run.icon, icons.run.hl_group
    end
end

local function render_codelens(bufnr)
    clear_virtual_texts(bufnr)
    local lenses = vim.lsp.codelens.get(bufnr)
    if not lenses or #lenses == 0 then
        return
    end

    local lines = {}
    for _, lens in ipairs(lenses) do
        if lens and lens.command and lens.command.title and lens.range then
            local line = lens.range.start.line
            lines[line] = lines[line] or {}
            table.insert(lines[line], lens)
        end
    end

    for line, lenses_on_line in pairs(lines) do
        local virt = {}
        for i, lens in ipairs(lenses_on_line) do
            local icon, group = get_icon_for_title(lens.command.title)
            table.insert(virt, { icon, group })
            if i < #lenses_on_line then
                table.insert(virt, { "  " })
            end
        end
        if #virt > 0 then
            vim.api.nvim_buf_set_extmark(bufnr, ns_id, line, 0, {
                virt_text = virt,
                virt_text_pos = "eol",
                hl_mode = "combine",
            })
        end
    end
end

vim.api.nvim_create_autocmd("User", {
    pattern = "LspCodeLens",
    callback = function(args)
        setup_highlights()
        render_codelens(args.buf)
    end,
})

vim.api.nvim_create_user_command("RefreshCodeLens", function()
    local buf = vim.api.nvim_get_current_buf()
    clear_virtual_texts(buf)
    setup_highlights()
    vim.lsp.codelens.refresh()
    vim.notify("CodeLens refreshed with icons", vim.log.levels.INFO)
end, {})

vim.o.mouse = "a"
vim.keymap.set("n", "<2-LeftMouse>", function()
    local pos = vim.api.nvim_win_get_cursor(0)
    local line = pos[1] - 1
    local lenses = vim.lsp.codelens.get(0) or {}
    for _, lens in ipairs(lenses) do
        if lens.range.start.line == line then
            vim.lsp.codelens.run()
            return
        end
    end
    vim.api.nvim_input("<2-LeftMouse>")
end, { noremap = true, silent = true })

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "LspAttach", "ColorScheme" }, {
    group = vim.api.nvim_create_augroup("AutoCodeLensIcons", { clear = true }),
    callback = function()
        vim.defer_fn(function()
            if vim.lsp.codelens and vim.lsp.codelens.refresh then
                vim.lsp.codelens.refresh()
            end
        end, 100)
    end,
})

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        setup_highlights()
        vim.defer_fn(function()
            render_codelens(args.buf)
        end, 200)
    end,
})

vim.api.nvim_create_autocmd("User", {
    pattern = "LspCodeLensRefresh",
    callback = function(args)
        render_codelens(args.buf)
    end,
})

return M
