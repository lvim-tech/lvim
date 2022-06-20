local popfix = require("popfix")

local popupReference = nil

local customUIInput = function(opts, onConfirm)
    assert(popupReference == nil, "Sorry")
    popupReference = popfix:new({
        close_on_bufleave = true,
        keymaps = {
            i = {
                ["<Cr>"] = function(popup)
                    popup:close(function(_, text)
                        onConfirm(text)
                    end)
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
        prompt = {
            numbering = true,
            border = false,
            highlight = "UIPrompt",
            prompt_highlight = "UIPromptSelect",
            init_text = opts.default,
        },
    })
end

return customUIInput
