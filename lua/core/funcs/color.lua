-- Color utilities: extracting highlight colors and alpha-blending hex values.
---@module "core.funcs.color"
local M = {}

-- Parses a "#rrggbb" hex string into an {r, g, b} integer triple.
---@param c string  Hex color string (e.g. "#1e2030")
---@return integer[]  Array of three integers in [0, 255]
local function rgb(c)
    c = string.lower(c)
    return { tonumber(c:sub(2, 3), 16), tonumber(c:sub(4, 5), 16), tonumber(c:sub(6, 7), 16) }
end

-- Retrieves the background and foreground hex colors of a highlight group.
-- Returns nil for each channel if the group has no color set.
---@param hl_group string   Highlight group name (e.g. "Normal", "Function")
---@return LvimHighlight    Table with bg and fg fields
M.get_highlight = function(hl_group)
    local hl_details = vim.api.nvim_get_hl(0, { name = hl_group })
    local bg_color = nil
    local fg_color = nil
    if hl_details.bg then
        bg_color = string.format("#%06x", hl_details.bg)
    end
    if hl_details.fg then
        fg_color = string.format("#%06x", hl_details.fg)
    end
    return { bg = bg_color, fg = fg_color }
end

-- Alpha-blends foreground over background and returns the resulting hex color.
-- alpha = 1.0 → pure foreground, alpha = 0.0 → pure background.
-- alpha may be a number in [0, 1] or a two-digit hex string (e.g. "80").
---@param foreground string         Foreground hex color (#rrggbb)
---@param alpha      number|string  Blend factor: number [0,1] or hex string
---@param background string         Background hex color (#rrggbb)
---@return string                   Blended hex color (#rrggbb)
M.blend = function(foreground, alpha, background)
    -- Allow callers to pass alpha as a hex byte string for convenience
    alpha = type(alpha) == "string" and (tonumber(alpha, 16) / 0xff) or alpha
    local bg = rgb(background)
    local fg = rgb(foreground)
    local blendChannel = function(i)
        local ret = (alpha * fg[i] + ((1 - alpha) * bg[i]))
        return math.floor(math.min(math.max(0, ret), 255) + 0.5)
    end
    return string.format("#%02x%02x%02x", blendChannel(1), blendChannel(2), blendChannel(3))
end

return M
