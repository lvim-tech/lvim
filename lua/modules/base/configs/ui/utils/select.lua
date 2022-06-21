local CustomSelect = require("nui.menu")
local event = require("nui.utils.autocmd").event
local popupReference = nil

local formatEntries = function(entries, formatter)
    local formatItem = formatter or tostring
    local results = {}
    results[1] = CustomSelect.separator(" ")
    for _, entry in pairs(entries) do
        table.insert(results, CustomSelect.item(string.format("%s", formatItem(entry))))
    end
    return results
end

local function nui_select(entries, stuff, onUserChoice)
    assert(entries ~= nil and not vim.tbl_isempty(entries), "No entries available.")
    assert(popupReference == nil, "Sorry")
    local userChoice = function(choiceIndex)
        onUserChoice(entries[choiceIndex["_index"] - 1])
    end
    local formattedEntries = formatEntries(entries, stuff.format_item)

    local popup_options = {
        relative = "cursor",
        position = {
            row = 1,
            col = 0,
        },
        size = {
            height = #formattedEntries,
        },
        border = {
            highlight = "NuiBorder",
            style = "single",
            text = {
                top = stuff.prompt or "Choice:",
                top_align = "center",
            },
        },
        win_options = {
            winhighlight = "Normal:NuiBody",
        },
    }
    popupReference = CustomSelect(popup_options, {
        lines = formattedEntries,
        on_close = function()
            popupReference = nil
        end,
        on_submit = function(item)
            userChoice(item)
            popupReference = nil
        end,
    })
    if popupReference ~= nil then
        popupReference:mount()
        popupReference:on(event.BufLeave, popupReference.menu_props.on_close, { once = true })
    end
end

return nui_select
