-- Heirline winbar configuration.
-- Builds the winbar component tree that appears at the top of each window.
-- Three mutually exclusive cases (via fallthrough = false):
--   1. Terminal buffers  → filetype label + terminal process name
--   2. Inactive windows  → file icon + unique filename only
--   3. Active windows    → file icon + unique filename + nvim-navic breadcrumb
-- Breadcrumb entries are clickable and jump the cursor to the symbol's
-- definition scope when clicked.

---@module "modules.base.configs.ui.heirline.winbar"

local icons = require("configs.base.ui.icons")
local hl    = require("configs.base.ui.highlight")

local M = {}

-- Builds and returns the heirline winbar component table.
-- Called once during heirline setup; all sub-components are defined inline.
---@return table  Heirline winbar component ready for heirline.setup()
M.get_winbar = function()
    local heirline_conditions = require("heirline.conditions")
    local tabby_filename      = require("tabby.filename")

    local space = { provider = " " }

    -- -------------------------------------------------------------------------
    -- file_types: uppercase filetype label (blue, bold)
    -- Used in the terminal branch of the winbar.
    -- -------------------------------------------------------------------------

    ---@type table  Heirline component for the filetype label
    local file_types = {
        ---@return string|nil  Uppercased filetype or nil for unnamed buffers
        provider = function()
            local file_type = vim.bo.filetype
            if file_type ~= "" then
                return "  " .. string.upper(file_type)
            end
        end,
        hl = { fg = _G.LVIM.colors.blue, bold = true },
    }

    -- -------------------------------------------------------------------------
    -- file_icon_name: devicon + unique filename rendered with inline highlights
    -- Uses tabby.filename.unique() to resolve a short unique path for the
    -- current window.  Applies two separate ad-hoc highlight groups so that
    -- the icon and the name can have different colours and backgrounds.
    -- -------------------------------------------------------------------------

    ---@type table  Heirline component for the file icon + unique filename
    local file_icon_name = {
        ---@return string|nil  Raw highlight-escaped string, or nil for unnamed buffers
        provider = function()
            -- Returns true when a value is nil or the empty string
            ---@param s any
            ---@return boolean
            local function isempty(s)
                return s == nil or s == ""
            end

            -- Highlight group for the filename text (red on bg_dark background)
            local hl_group_1 = "FileTextColor"
            vim.api.nvim_set_hl(0, hl_group_1, {
                fg   = _G.LVIM.colors.red,
                bg   = _G.LVIM.colors.bg_dark,
                bold = true,
            })

            local win_id   = vim.api.nvim_get_current_win()
            -- tabby provides a unique short name for this window (e.g. "foo.lua" or
            -- "src/foo.lua" when the basename alone would be ambiguous)
            local filename  = tabby_filename.unique(win_id)
            local extension = vim.fn.expand("%:e")

            if not isempty(filename) then
                local f_icon, f_icon_color =
                    require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })

                -- Per-extension highlight group for the icon (preserves devicon colour)
                local hl_group_2 = "FileIconColor" .. extension
                vim.api.nvim_set_hl(0, hl_group_2, { fg = f_icon_color, bg = _G.LVIM.colors.bg_dark })

                if isempty(f_icon) then
                    f_icon = ""
                end

                -- Build a raw statusline-style string that switches highlight groups
                -- around the icon and filename independently.
                -- Format: %#IconHl# <icon> %* <space> %#TextHl# filename %*  (two trailing spaces)
                return "%#"
                    .. hl_group_2
                    .. "# "
                    .. f_icon
                    .. "%*"
                    .. " "
                    .. "%#"
                    .. hl_group_1
                    .. "#"
                    .. filename
                    .. "%*"
                    .. "  "
            end
        end,
        hl = { fg = _G.LVIM.colors.red },
    }

    -- -------------------------------------------------------------------------
    -- navic: breadcrumb trail showing the code context at the cursor
    -- Renders the LSP symbol hierarchy from nvim-navic.  Each entry is
    -- clickable; clicking jumps the cursor to the symbol's scope start.
    -- The position is packed into the minwid integer with bit operations so it
    -- survives the heirline on_click callback round-trip without extra state.
    -- -------------------------------------------------------------------------

    ---@type table  Heirline component for the nvim-navic breadcrumb trail
    local navic = {
        -- Only render when navic has data for the current buffer / client
        condition = function()
            return require("nvim-navic").is_available()
        end,
        static = {
            -- Per-symbol-type highlight groups for breadcrumb icons
            ---@type table<string, string>  Maps navic symbol type name → hl group name
            type_hl = hl.winbar,

            -- Encodes (line, col, winnr) into a single integer for minwid storage.
            -- line occupies bits 31-16, col bits 15-6, winnr bits 5-0.
            ---@param line  integer  0-based line number from navic scope data
            ---@param col   integer  0-based column number
            ---@param winnr integer  Window number (fits in 6 bits, up to 63)
            ---@return integer       Packed integer suitable for on_click minwid
            enc = function(line, col, winnr)
                return bit.bor(bit.lshift(line, 16), bit.lshift(col, 6), winnr)
            end,

            -- Decodes a packed minwid integer back into (line, col, winnr).
            ---@param c integer  Packed value produced by enc()
            ---@return integer   line   0-based line number
            ---@return integer   col    0-based column number
            ---@return integer   winnr  Window number
            dec = function(c)
                local line  = bit.rshift(c, 16)
                local col   = bit.band(bit.rshift(c, 6), 1023)  -- 10-bit mask
                local winnr = bit.band(c, 63)                   -- 6-bit mask
                return line, col, winnr
            end,
        },
        ---@param self table  Rebuilds self.child from the current navic symbol data
        init = function(self)
            local data     = require("nvim-navic").get_data() or {}
            local children = {}
            for i, d in ipairs(data) do
                -- Pack the scope start position so the click callback can jump there
                local pos   = self.enc(d.scope.start.line, d.scope.start.character, self.winnr)
                local child = {
                    -- Symbol type icon, coloured by the type_hl mapping
                    {
                        provider = d.icon,
                        hl       = self.type_hl[d.type],
                    },
                    -- Symbol name: escape "%" to avoid statusline format codes,
                    -- and strip leading " -> " arrow prefixes from some LSP servers.
                    {
                        provider = d.name:gsub("%%", "%%%%"):gsub("%s*->%s*", ""),
                        on_click = {
                            minwid   = pos,
                            ---@param _      any     Unused self reference
                            ---@param minwid integer Packed (line, col, winnr) from enc()
                            callback = function(_, minwid)
                                local line, col, winnr = self.dec(minwid)
                                vim.api.nvim_win_set_cursor(vim.fn.win_getid(winnr), { line, col })
                            end,
                            name = "heirline_navic",
                        },
                    },
                }
                -- Insert a separator glyph between entries, but not after the last one
                if #data > 1 and i < #data then
                    table.insert(child, {
                        provider = " " .. icons.common.separator .. " ",
                        hl = { bg = _G.LVIM.colors.bg_dark, fg = _G.LVIM.colors.green },
                    })
                end
                table.insert(children, child)
            end
            -- Rebuild the full child component tree from the latest navic snapshot
            self.child = self:new(children, 1)
        end,
        ---@param self table  Component self (self.child built in init)
        ---@return string     Evaluated breadcrumb string for this render cycle
        provider = function(self)
            return self.child:eval()
        end,
        hl     = { bg = _G.LVIM.colors.bg_dark, fg = _G.LVIM.colors.blue, bold = true },
        -- Update the breadcrumb trail on every cursor movement
        update = "CursorMoved",
    }

    -- -------------------------------------------------------------------------
    -- terminal_name: process name for terminal buffers
    -- Strips the "term://<...>:" URI prefix, leaving only the shell/process name.
    -- -------------------------------------------------------------------------

    ---@type table  Heirline component for the terminal process label
    local terminal_name = {
        ---@return string  Terminal icon + process name extracted from the buffer name
        provider = function()
            -- gsub(".*:") strips everything up to and including the last ":" in the URI
            local tname, _ = vim.api.nvim_buf_get_name(0):gsub(".*:", "")
            return icons.common.terminal .. tname
        end,
        hl = { fg = _G.LVIM.colors.red, bold = true },
    }

    -- -------------------------------------------------------------------------
    -- winbar root component
    -- Three branches are tested in order; fallthrough = false stops at first match.
    --   Branch 1: terminal buffers → filetype label + process name
    --   Branch 2: inactive windows → file icon + filename (no breadcrumb)
    --   Branch 3: active windows   → file icon + filename + navic breadcrumb
    -- -------------------------------------------------------------------------

    ---@type table  Root heirline winbar component
    local winbar = {
        fallthrough = false,
        -- Branch 1: terminal buffers
        {
            condition = function()
                return heirline_conditions.buffer_matches({ buftype = { "terminal" } })
            end,
            {
                file_types,
                space,
                terminal_name,
            },
        },
        -- Branch 2: inactive windows (no navic to avoid expensive rendering)
        {
            condition = function()
                return not heirline_conditions.is_active()
            end,
            {
                file_icon_name,
            },
        },
        -- Branch 3: active windows with full breadcrumb
        {
            file_icon_name,
            navic,
        },
    }

    return winbar
end

return M
