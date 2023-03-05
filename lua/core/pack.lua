local global = require("core.global")
local funcs = require("core.funcs")

local lazy_pack = {}

function lazy_pack.snapshot_file_show()
    local plugins_snapshot = {}
    local file_content = funcs.read_file(_G.LVIM_SNAPSHOT)
    if file_content ~= nil then
        plugins_snapshot = file_content
    end
    local notify = require("lvim-ui-config.notify")
    notify.info(vim.inspect(plugins_snapshot), {
        title = "LVIM IDE",
    })
end

function lazy_pack.snapshot_file_choice()
    local snapshot_file = vim.fn.input("Rollback from file: ", global.snapshot_path .. "/", "file")
    local file_content = funcs.read_file(snapshot_file)
    local notify = require("lvim-ui-config.notify")
    if file_content ~= nil then
        _G.LVIM_SNAPSHOT = snapshot_file
        funcs.write_file(global.cache_path .. "/.lvim_snapshot", '{"snapshot": "' .. _G.LVIM_SNAPSHOT .. '"}')
        notify.warning("Run\n:Lazy sync", {
            title = "LVIM IDE",
        })
    else
        notify.error("The file does not exist or is wrong", {
            title = "LVIM IDE",
        })
    end
end

lazy_pack.is_lazy = function()
    local lazy_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazy_path) then
        vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            "https://github.com/folke/lazy.nvim.git",
            lazy_path,
        })
    end
    vim.opt.rtp:prepend(lazy_path)
    vim.cmd("command! SnapshotFileShow lua require('core.pack').snapshot_file_show()")
    vim.cmd("command! SnapshotFileChoice lua require('core.pack').snapshot_file_choice()")
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
            icons = {
                cmd = " ",
                config = " ",
                event = "",
                ft = " ",
                init = " ",
                keys = " ",
                plugin = " ",
                runtime = " ",
                source = " ",
                start = "",
                task = "✔ ",
            },
        },
    })
end

return lazy_pack
