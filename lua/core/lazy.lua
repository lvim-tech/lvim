local global = require("core.global")
local funcs = require("core.funcs")
local icons = require("configs.base.ui.icons")

local lazy_pack = {}

function lazy_pack.snapshot_file_show()
    if not _G.LVIM_SNAPSHOT then
        vim.notify("No snapshot file selected", vim.log.levels.ERROR, { title = "LVIM IDE" })
        return
    end
    local file_content = funcs.read_file(_G.LVIM_SNAPSHOT)
    if not file_content then
        vim.notify("Failed to read snapshot file", vim.log.levels.ERROR, { title = "LVIM IDE" })
        return
    end
    local buf = vim.api.nvim_create_buf(false, true)
    local content_lines = vim.split(vim.inspect(file_content), "\n")
    table.insert(content_lines, 1, "")
    table.insert(content_lines, 1, "Snapshot: " .. _G.LVIM_SNAPSHOT)
    table.insert(content_lines, 2, string.rep("─", 50))
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, content_lines)
    vim.bo[buf].modifiable = false
    vim.bo[buf].filetype = "lua"
    local width = math.min(vim.o.columns - 4, 100)
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
        border = "rounded",
        title = " Snapshot Content ",
        title_pos = "center",
    }
    local win = vim.api.nvim_open_win(buf, true, opts)
    vim.wo[win].cursorline = true
    vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>close<CR>", {
        noremap = true,
        silent = true,
        nowait = true,
        desc = "Close window",
    })
    vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "<cmd>close<CR>", {
        noremap = true,
        silent = true,
        nowait = true,
        desc = "Close window",
    })
    vim.api.nvim_echo({ { "Press 'q' to close the window", "Normal" } }, false, {})
end

function lazy_pack.snapshot_file_choice()
    local snapshot_dir = global.snapshot_path
    local files = vim.fn.glob(snapshot_dir .. "/*", true, true)
    if #files == 0 then
        vim.notify("No snapshot files found in " .. snapshot_dir, vim.log.levels.WARN, {
            title = "LVIM IDE",
        })
        return
    end
    local display_files = {}
    for i, file in ipairs(files) do
        display_files[i] = file:gsub(snapshot_dir .. "/", "")
    end
    vim.ui.select(display_files, {
        prompt = "Choose snapshot to rollback:",
        format_item = function(item)
            return icons.common.symbol .. " " .. item
        end,
    }, function(selected)
        if not selected then
            return
        end
        local snapshot_file = snapshot_dir .. "/" .. selected
        local file_content = funcs.read_file(snapshot_file)
        if file_content ~= nil then
            _G.LVIM_SNAPSHOT = snapshot_file
            funcs.write_file(global.cache_path .. "/.lvim_snapshot", '{"snapshot": "' .. _G.LVIM_SNAPSHOT .. '"}')
            vim.notify("Run\n:Lazy sync", vim.log.levels.WARN, {
                title = "LVIM IDE",
            })
        else
            vim.notify("The file does not exist or is wrong", vim.log.levels.ERROR, {
                title = "LVIM IDE",
            })
        end
    end)
end

lazy_pack.is_lazy = function()
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not (vim.uv or vim.loop).fs_stat(lazypath) then
        local lazyrepo = "https://github.com/folke/lazy.nvim.git"
        local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
        if vim.v.shell_error ~= 0 then
            vim.api.nvim_echo({
                { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
                { out, "WarningMsg" },
                { "\nPress any key to exit..." },
            }, true, {})
            vim.fn.getchar()
            os.exit(1)
        end
    end
    vim.opt.rtp:prepend(lazypath)
    vim.cmd("command! SnapshotFileShow lua require('core.lazy').snapshot_file_show()")
    vim.cmd("command! SnapshotFileChoice lua require('core.lazy').snapshot_file_choice()")
end

lazy_pack.load = function()
    local repos = {}
    local base_modules = require("modules.base")
    local user_modules = require("modules.user")
    local modules = funcs.merge(base_modules, user_modules)
    for repo, conf in pairs(modules) do
        if conf ~= false then
            repos[#repos + 1] = vim.tbl_extend("force", { repo }, conf)
        end
    end
    require("lazy").setup(repos, {
        install = {
            missing = true,
            colorscheme = { "lvim", "habamax" },
        },
        ui = {
            size = {
                width = 0.95,
                height = 0.95,
            },
            border = "none",
            icons = icons.lazy,
        },
    })
end

return lazy_pack
