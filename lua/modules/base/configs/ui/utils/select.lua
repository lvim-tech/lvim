local popfix = require("popfix")

local popupReference = nil

local calculatePopupWidth = function(entries)
    local result = 0
    for _, entry in pairs(entries) do
        if #entry > result then
            result = #entry
        end
    end

    return result + 5
end

local formatEntries = function(entries, formatter)
    local formatItem = formatter or tostring
    local results = {}
    for _, entry in pairs(entries) do
        table.insert(results, string.format("%s", formatItem(entry)))
    end
    return results
end

local customUISelect = function(entries, stuff, onUserChoice)
    assert(entries ~= nil and not vim.tbl_isempty(entries), "No entries available.")
    assert(popupReference == nil, "Sorry")
    local commitChoice = function(choiceIndex)
        onUserChoice(entries[choiceIndex], choiceIndex)
    end
    local formattedEntries = formatEntries(entries, stuff.format_item)
    popupReference = popfix:new({
        width = calculatePopupWidth(formattedEntries),
        height = #formattedEntries,
        close_on_bufleave = true,
        keymaps = {
            i = {
                ["<Cr>"] = function(popup)
                    popup:close(function(sel)
                        commitChoice(sel)
                    end)
                    vim.schedule(function()
                        popupReference = nil
                    end)
                end,
            },
            n = {
                ["<Cr>"] = function(popup)
                    popup:close(function(sel)
                        commitChoice(sel)
                    end)
                    popupReference = nil
                end,
                ["<C-o>"] = function(popup)
                    popup:close()
                    popupReference = nil
                end,
                ["<C-c>"] = function(popup)
                    popup:close()
                    popupReference = nil
                end,
                ["<Esc>"] = function(popup)
                    popup:close()
                    popupReference = nil
                end,
            },
        },
        callbacks = {
            close = function()
                popupReference = nil
            end,
        },
        mode = "cursor",
        list = {
            numbering = true,
            border = true,
            border_chars = {
                TOP_LEFT = "",
                TOP_RIGHT = "",
                MID_HORIZONTAL = "",
                MID_VERTICAL = "",
                BOTTOM_LEFT = "",
                BOTTOM_RIGHT = "",
            },
            highlight = "UIPrompt",
            selection_highlight = "UIPromptSelect",
            matching_highlight = "UIPromptSelect",
        },
        data = formattedEntries,
    })
end

return customUISelect
