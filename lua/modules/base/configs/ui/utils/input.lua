local CustomInput = require("nui.input")
local event = require("nui.utils.autocmd").event
local popupReference = nil

local function nui_input(opts, onConfirm)
    -- vim.notify(vim.inspect(opts))
    assert(popupReference == nil, "Sorry")

    local popup_options = {
        relative = "cursor",
        position = {
            row = 1,
            col = 0,
        },
        size = 60,
        border = {
            highlight = "NuiBorder",
            style = "single",
            text = {
                top = opts.prompt,
                top_align = "center",
            },
        },
        win_options = {
            winhighlight = "Normal:NuiBody",
        },
    }
    popupReference = CustomInput(popup_options, {
        prompt = "➤ ",
        default_value = opts.default or "Enter:",
        on_close = function()
            popupReference = nil
        end,
        on_submit = function(value)
            onConfirm(value)
            popupReference = nil
        end,
    })
    if popupReference ~= nil then
        popupReference:mount()
        popupReference:map("n", "<esc>", popupReference.input_props.on_close, { noremap = true })
        popupReference:map("n", "q", popupReference.input_props.on_close, { noremap = true })
        popupReference:map("i", "<esc>", popupReference.input_props.on_close, { noremap = true })
        popupReference:on(event.BufLeave, popupReference.input_props.on_close, { once = true })
    end
end

return nui_input
