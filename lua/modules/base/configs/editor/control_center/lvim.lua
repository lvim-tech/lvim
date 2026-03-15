-- LVIM IDE meta-settings group for the LVIM Control Center.
-- Provides actions and selectors related to the LVIM plugin snapshot system:
--   • View the content of the currently active snapshot file in a floating window.
--   • Switch between the "default" and "latest" snapshot files.
-- Changes to the snapshot selection require a Neovim restart and a `Lazy sync`.

---@module "modules.base.configs.editor.control_center.lvim"

local funcs = require("core.funcs")
local data = require("lvim-control-center.persistence.data")
local icons = require("configs.base.ui.icons")

---@type table  Control Center settings group descriptor for LVIM IDE meta-options
return {
    name = "lvim",
    label = "LVIM",
    -- Append a trailing space so the Lua icon renders correctly next to the label.
    icon = icons.common.lua .. " ",
    settings = {
        -- -----------------------------------------------------------------
        -- Action: display current snapshot file
        -- -----------------------------------------------------------------
        {
            name = "snapshotfileshow",
            label = "Show current snapshot file",
            type = "action",
            ---Opens a read-only floating window containing the contents of
            ---the currently selected snapshot file (JSON rendered via vim.inspect).
            ---The window is dismissed with `q` or `<Esc>`.
            run = function()
                -- Guard: abort if no snapshot has been selected yet.
                if not _G.LVIM.snapshot then
                    vim.notify("No snapshot file selected", vim.log.levels.ERROR, { title = "LVIM IDE" })
                    return
                end
                ---@type table|nil  Raw file content returned by funcs.read_file
                local file_content = funcs.read_file(_G.LVIM.global.lvim_path .. "/.snapshots/" .. _G.LVIM.snapshot)
                if not file_content then
                    vim.notify("Failed to read snapshot file", vim.log.levels.ERROR, { title = "LVIM IDE" })
                    return
                end
                -- Create a scratch buffer (not listed, not backed by a file).
                local buf = vim.api.nvim_create_buf(false, true)
                -- Pretty-print the Lua table returned by read_file into lines.
                local content_lines = vim.split(vim.inspect(file_content), "\n")
                -- Insert an empty separator line between the header and content.
                table.insert(content_lines, 1, "")
                -- Cap the window width to leave a 2-column gutter on each side.
                local width = math.min(vim.o.columns - 4, 100)
                -- Prepend a title line and a horizontal rule.
                table.insert(content_lines, 1, "Snapshot: " .. _G.LVIM.snapshot)
                table.insert(content_lines, 2, string.rep("─", width))
                vim.api.nvim_buf_set_lines(buf, 0, -1, false, content_lines)
                -- Make the buffer read-only after content is set.
                vim.bo[buf].modifiable = false
                vim.bo[buf].filetype = "lua"
                -- Centre the float vertically and horizontally.
                local height = math.min(vim.o.lines - 4, 30)
                local col = math.floor((vim.o.columns - width) / 2)
                local row = math.floor((vim.o.lines - height) / 2)
                ---@type table  vim.api.nvim_open_win config for the snapshot float
                local opts = {
                    style = "minimal",
                    relative = "editor",
                    width = width,
                    height = height,
                    row = row,
                    col = col,
                    -- Use blank-space border for a clean, borderless look.
                    border = { " ", " ", " ", " ", " ", " ", " ", " " },
                    title = " Snapshot Content ",
                    title_pos = "center",
                }
                local win = vim.api.nvim_open_win(buf, true, opts)
                vim.wo[win].cursorline = true
                -- Bind `q` and `<Esc>` to close the floating window.
                vim.api.nvim_buf_set_keymap(
                    buf,
                    "n",
                    "q",
                    "<cmd>close<CR>",
                    { noremap = true, silent = true, nowait = true }
                )
                vim.api.nvim_buf_set_keymap(
                    buf,
                    "n",
                    "<Esc>",
                    "<cmd>close<CR>",
                    { noremap = true, silent = true, nowait = true }
                )
                vim.api.nvim_echo({ { "Press 'q' to close the window", "Normal" } }, false, {})
            end,
        },
        -- -----------------------------------------------------------------
        -- Selector: choose active snapshot file
        -- -----------------------------------------------------------------
        {
            name = "snapshotfilechoice",
            label = "Choice snapshot file",
            type = "select",
            -- "default" pins all plugins to the bundled snapshot; "latest" always
            -- resolves to the most recent snapshot file in the .snapshots directory.
            options = { "default", "latest" },
            default = "default",
            ---Reads the persisted snapshot choice from the cache directory.
            ---Falls back to "default" when the cache file is absent or malformed.
            ---@return string  Currently selected snapshot name
            get = function()
                ---@type table|nil  Decoded JSON object: { snapshot: string }
                local snapshot = funcs.read_file(_G.LVIM.global.cache_path .. "/.lvim_snapshot")
                if type(snapshot) == "table" then
                    _G.LVIM.snapshot = snapshot.snapshot
                else
                    _G.LVIM.snapshot = "default"
                end
                return _G.LVIM.snapshot
            end,
            ---@param val     string   New snapshot name ("default" or "latest")
            ---@param on_init boolean  True during startup; skip file write and notification
            set = function(val, on_init)
                _G.LVIM.snapshot = val
                if not on_init then
                    -- Persist the choice as a JSON object so it can be read back by get().
                    funcs.write_file(
                        _G.LVIM.global.cache_path .. "/.lvim_snapshot",
                        '{"snapshot": "' .. _G.LVIM.snapshot .. '"}'
                    )
                    -- Inform the user that the change requires a full restart + sync.
                    vim.notify("Restart NEOVIM and run: Lazy sync", vim.log.levels.INFO, {
                        title = "LVIM IDE",
                    })
                    data.save("snapshotfilechoice", val)
                end
            end,
        },
    },
}
