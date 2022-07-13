local custom_select = require("nui.menu")
local event = require("nui.utils.autocmd").event
local select_reference = nil

local calculate_popup_width = function(entries, prompt)
    local result = 0
    for _, entry in pairs(entries) do
        if #entry.text > result then
            result = #entry.text
        end
    end
    if #prompt > result then
        result = #prompt
    end
    if result < 60 then
        result = 60
    end
    return result + 6
end

local format_entries = function(entries, formatter)
    local formatItem = formatter or tostring
    local results = {}
    results[1] = custom_select.separator(" ")
    for _, entry in pairs(entries) do
        table.insert(results, custom_select.item(string.format("%s", formatItem(entry))))
    end
    return results
end

local function nui_select(entries, stuff, onUserChoice)
    assert(entries ~= nil and not vim.tbl_isempty(entries), "No entries available.")
    assert(select_reference == nil, "Sorry")
    local userChoice = function(choiceIndex)
        onUserChoice(entries[choiceIndex["_index"] - 1])
    end
    local formatted_entries = format_entries(entries, stuff.format_item)
    local select_options = {
        relative = "editor",
        position = "50%",
        size = {
            width = calculate_popup_width(formatted_entries, stuff.prompt or "Choice:"),
            height = #formatted_entries,
        },
        border = {
            highlight = "NuiBorder",
            style = { " ", " ", " ", " ", " ", " ", " ", " " },
            text = {
                top = stuff.prompt or "Choice:",
                top_align = "center",
            },
        },
        win_options = {
            winhighlight = "Normal:NuiBody",
        },
    }
    select_reference = custom_select(select_options, {
        lines = formatted_entries,
        on_close = function()
            select_reference = nil
        end,
        on_submit = function(item)
            userChoice(item)
            select_reference = nil
        end,
    })
    if select_reference ~= nil then
        if vim.bo.filetype == "ctrlspace" then
            vim.cmd("bdelete")
        end
        select_reference:mount()
        select_reference:on(event.BufLeave, select_reference.menu_props.on_close, { once = true })
    end
end

return nui_select
