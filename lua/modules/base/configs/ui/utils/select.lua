local custom_select = require("nui.menu")
local event = require("nui.utils.autocmd").event
local popup_reference = nil

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

local function nui_select(entries, stuff, on_user_choice)
    assert(entries ~= nil and not vim.tbl_isempty(entries), "No entries available.")
    assert(popup_reference == nil, "Sorry")
    local userChoice = function(choiceIndex)
        on_user_choice(entries[choiceIndex["_index"] - 1])
    end
    local formatted_entries = format_entries(entries, stuff.format_item)
    local popup_options = {
        relative = "cursor",
        position = {
            row = 1,
            col = 0,
        },
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
    popup_reference = custom_select(popup_options, {
        lines = formatted_entries,
        on_close = function()
            popup_reference = nil
        end,
        on_submit = function(item)
            userChoice(item)
            popup_reference = nil
        end,
    })
    if popup_reference ~= nil then
        popup_reference:mount()
        popup_reference:on(event.BufLeave, popup_reference.menu_props.on_close, { once = true })
    end
end

return nui_select
