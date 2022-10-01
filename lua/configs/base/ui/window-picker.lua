local api = vim.api
local fn = vim.fn
local M = {}
local escape = 27
local float_height = 3
local float_width = 6

local config = {
    chars = {
        "a",
        "b",
        "c",
        "d",
        "e",
        "f",
        "g",
        "h",
        "i",
        "j",
        "k",
        "l",
        "m",
        "n",
        "o",
        "p",
        "q",
        "r",
        "s",
        "t",
        "u",
        "v",
        "w",
        "x",
        "y",
        "z",
    },
    normal_hl = "NuiNormal",
    hint_hl = "Bold",
    border = "none",
}
local function window_keys(windows)
    local mapping = {}
    local chars = config.chars
    local nrs = {}
    local ids = {}
    local current = api.nvim_win_get_number(api.nvim_get_current_win())
    for _, win in ipairs(windows) do
        local nr = api.nvim_win_get_number(win)
        table.insert(nrs, nr)
        ids[nr] = win
    end
    table.sort(nrs)
    local index = 1
    for _, nr in ipairs(nrs) do
        if nr ~= current then
            local key = chars[index]
            if mapping[key] then
                key = key .. (index == #chars and chars[1] or chars[index + 1])
            end
            mapping[key] = ids[nr]
        end
        index = index == #chars and 1 or index + 1
    end
    return mapping
end

local function ask_second_char(keys, start)
    for key, _ in pairs(keys) do
        if key ~= start and key:sub(1, 1) == start then
            return true
        end
    end

    return false
end

local function open_floats(mapping)
    local floats = {}
    for key, window in pairs(mapping) do
        local bufnr = api.nvim_create_buf(false, true)
        if bufnr > 0 then
            local win_width = api.nvim_win_get_width(window)
            local win_height = api.nvim_win_get_height(window)
            local row = math.max(0, math.floor((win_height / 2) - 1))
            local col = math.max(0, math.floor((win_width / 2) - float_width))
            api.nvim_buf_set_lines(bufnr, 0, -1, true, { "", "  " .. string.upper(key) .. "  ", "" })
            api.nvim_buf_add_highlight(bufnr, 0, config.hint_hl, 1, 0, -1)
            local float_window = api.nvim_open_win(bufnr, false, {
                relative = "win",
                win = window,
                row = row,
                col = col,
                width = #key == 1 and float_width - 1 or float_width,
                height = float_height,
                focusable = false,
                style = "minimal",
                border = config.border,
                noautocmd = true,
            })
            api.nvim_win_set_option(float_window, "winhl", "Normal:" .. config.normal_hl)
            api.nvim_win_set_option(float_window, "diff", false)
            floats[float_window] = bufnr
        end
    end
    vim.cmd("redraw")
    return floats
end

local function close_floats(floats)
    for window, bufnr in pairs(floats) do
        api.nvim_win_close(window, true)
        api.nvim_buf_delete(bufnr, { force = true })
    end
end

local function get_char()
    local ok, char = pcall(fn.getchar)
    return ok and fn.nr2char(char) or nil
end

function M.setup(user_config)
    config = vim.tbl_extend("force", config, user_config)
end

function M.pick()
    local windows = vim.tbl_filter(function(id)
        return api.nvim_win_get_config(id).relative == ""
    end, api.nvim_tabpage_list_wins(0))
    local window_keys = window_keys(windows)
    local floats = open_floats(window_keys)
    local key = get_char()
    local window = nil
    if not key or key == escape then
        close_floats(floats)
        return
    end
    local window = window_keys[key]
    local extra = {}
    local choices = 0
    for hint, win in pairs(window_keys) do
        if vim.startswith(hint, key) then
            extra[hint] = win
            choices = choices + 1
        end
    end
    if choices > 1 then
        close_floats(floats)
        floats = open_floats(extra)
        local second = get_char()
        if second then
            local combined = key .. second
            window = window_keys[combined] or window_keys[key]
        else
            window = nil
        end
    end
    close_floats(floats)

    if window then
        api.nvim_set_current_win(window)
    end
end

return M
