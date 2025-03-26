local global = require("core.global")
local funcs = require("core.funcs")
local icons = require("configs.base.ui.icons")

local lazy_pack = {}

function lazy_pack.snapshot_file_show()
    local plugins_snapshot = {}
    local file_content = funcs.read_file(_G.LVIM_SNAPSHOT)
    if file_content ~= nil then
        plugins_snapshot = file_content
    end
    vim.notify(vim.inspect(plugins_snapshot), vim.log.levels.INFO, {
        title = "LVIM IDE",
    })
end

function lazy_pack.snapshot_file_choice()
    local snapshot_file = vim.fn.input("Rollback from file: ", global.snapshot_path .. "/", "file")
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
