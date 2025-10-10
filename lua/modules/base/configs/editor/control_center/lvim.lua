local funcs = require("core.funcs")
local data = require("lvim-control-center.persistence.data")
local icons = require("configs.base.ui.icons")

return {
    name = "lvim",
    label = "LVIM",
    icon = icons.common.lua .. " ",
    settings = {
        {
            name = "snapshotfileshow",
            label = "Show current snapshot file",
            type = "action",
            run = function()
                if not _G.LVIM_SNAPSHOT then
                    vim.notify("No snapshot file selected", vim.log.levels.ERROR, { title = "LVIM IDE" })
                    return
                end
                local file_content = funcs.read_file(_G.global.lvim_path .. "/.snapshots/" .. _G.LVIM_SNAPSHOT)
                if not file_content then
                    vim.notify("Failed to read snapshot file", vim.log.levels.ERROR, { title = "LVIM IDE" })
                    return
                end
                local buf = vim.api.nvim_create_buf(false, true)
                local content_lines = vim.split(vim.inspect(file_content), "\n")
                table.insert(content_lines, 1, "")
                local width = math.min(vim.o.columns - 4, 100)
                table.insert(content_lines, 1, "Snapshot: " .. _G.LVIM_SNAPSHOT)
                table.insert(content_lines, 2, string.rep("─", width))
                vim.api.nvim_buf_set_lines(buf, 0, -1, false, content_lines)
                vim.bo[buf].modifiable = false
                vim.bo[buf].filetype = "lua"
                local height = math.min(vim.o.lines - 4, 30)
                local col = math.floor((vim.o.columns - width) / 2)
                local row = math.floor((vim.o.lines - height) / 2)
                local opts = {
                    style = "minimal",
                    relative = "editor",
                    width = width,
                    height = height,
                    row = row,
                    col = col,
                    border = { " ", " ", " ", " ", " ", " ", " ", " " },
                    title = " Snapshot Content ",
                    title_pos = "center",
                }
                local win = vim.api.nvim_open_win(buf, true, opts)
                vim.wo[win].cursorline = true
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
        {
            name = "snapshotfilechoice",
            label = "Choice snapshot file",
            type = "select",
            options = { "default", "latest" },
            default = "default",
            get = function()
                local snapshot = funcs.read_file(_G.global.cache_path .. "/.lvim_snapshot")
                if type(snapshot) == "table" then
                    _G.LVIM_SNAPSHOT = snapshot.snapshot
                else
                    _G.LVIM_SNAPSHOT = "default"
                end
                return _G.LVIM_SNAPSHOT
            end,
            set = function(val, on_init)
                _G.LVIM_SNAPSHOT = val
                if not on_init then
                    funcs.write_file(
                        _G.global.cache_path .. "/.lvim_snapshot",
                        '{"snapshot": "' .. _G.LVIM_SNAPSHOT .. '"}'
                    )
                    vim.notify("Restart NEOVIM and run: Lazy sync", vim.log.levels.INFO, {
                        title = "LVIM IDE",
                    })
                    data.save("snapshotfilechoice", val)
                end
            end,
        },
    },
}
