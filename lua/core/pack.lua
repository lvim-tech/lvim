local uv, api = vim.loop, vim.api
local global = require("core.global")
local funcs = require("core.funcs")
local packer_compiled = global.packer_path .. "/lua/packer_compiled.lua"
local packer = nil

local display = {
    open_fn = function()
        return require("packer.util").float({
            border = { " ", " ", " ", " ", " ", " ", " ", " " },
        })
    end,
    working_sym = "ﰭ",
    error_sym = "",
    done_sym = "",
    removed_sym = "",
    moved_sym = "ﰳ",
}

local Packer = {}
Packer.__index = Packer

function Packer:load_plugins()
    self.repos = {}
    local base_modules = require("modules.base")
    local user_modules = require("modules.user")
    local modules = funcs.merge(base_modules, user_modules)
    for repo, conf in pairs(modules) do
        if conf ~= false then
            self.repos[#self.repos + 1] = vim.tbl_extend("force", { repo }, conf)
        end
    end
end

function Packer:load_packer()
    if not packer then
        api.nvim_command("packadd packer.nvim")
        packer = require("packer")
    end
    packer.init({
        compile_path = packer_compiled,
        snapshot_path = global.snapshot_path,
        git = { clone_timeout = 120 },
        preview_updates = true,
        disable_commands = true,
        log = { level = "error" },
        display = display,
        luarocks = {
            python_cmd = "python3",
        },
        max_jobs = 50,
    })
    packer.reset()
    local use = packer.use
    self:load_plugins()
    use({ "wbthomason/packer.nvim", opt = true })
    for _, repo in ipairs(self.repos) do
        use(repo)
    end
end

function Packer:init_ensure_plugins()
    local packer_dir = global.packer_path .. "/pack/packer/opt/packer.nvim"
    local state = uv.fs_stat(packer_dir)
    if not state then
        display = nil
        local cmd = "!git clone https://github.com/wbthomason/packer.nvim " .. packer_dir
        api.nvim_command(cmd)
        uv.fs_mkdir(global.packer_path .. "/lua", 511, function()
            assert("Make compile path dir faield")
        end)
        self:load_packer()
        packer.sync()
    end
end

local plugins = setmetatable({}, {
    __index = function(_, key)
        if key == "Packer" then
            return Packer
        end
        if not packer then
            Packer:load_packer()
        end
        return packer[key]
    end,
})

function plugins.ensure_plugins()
    Packer:init_ensure_plugins()
end

function plugins.package(repo)
    if not Packer.repos then
        Packer.repos = {}
    end
    table.insert(Packer.repos, repo)
end

function plugins.snapshot_current_show()
    local plugins_snapshot = {}
    local read_json_file = funcs.read_json_file(_G.LVIM_SNAPSHOT)
    if read_json_file ~= nil then
        plugins_snapshot = read_json_file
    end
    local notify = require("lvim-ui-config.notify")
    notify.info(vim.inspect(plugins_snapshot), {
        title = "LVIM IDE",
    })
end

function plugins.snapshot_file_choice()
    local snapshot_file = vim.fn.input("Rollback from file: ", global.snapshot_path .. "/", "file")
    local read_json_file = funcs.read_json_file(snapshot_file)
    local notify = require("lvim-ui-config.notify")
    if read_json_file ~= nil then
        _G.LVIM_SNAPSHOT = snapshot_file
        funcs.write_file(global.cache_path .. "/.lvim_snapshot", '{"snapshot": "' .. _G.LVIM_SNAPSHOT .. '"}')
        notify.warning("Restart LVIM IDE and run\n:PackerSync", {
            title = "LVIM IDE",
        })
    else
        notify.error("The file does not exist or is wrong", {
            title = "LVIM IDE",
        })
    end
end

function plugins.load_compile()
    if vim.fn.filereadable(packer_compiled) == 1 then
        require("packer_compiled")
    end
    local cmds = {
        "Compile",
        "Install",
        "Update",
        "Sync",
        "Clean",
        "Status",
        "Snapshot",
    }
    for _, cmd in ipairs(cmds) do
        api.nvim_create_user_command("Packer" .. cmd, function()
            require("core.pack")[string.lower(cmd)]()
        end, {})
    end
    vim.cmd("command! PackerShowCurrentSnapshot lua require('core.pack').snapshot_current_show()")
    vim.cmd("command! PackerChoiceSnapshotToRollback lua require('core.pack').snapshot_file_choice()")
    local PackerHooks = vim.api.nvim_create_augroup("PackerHooks", { clear = true })
    local notify = require("lvim-ui-config.notify")
    vim.api.nvim_create_autocmd("User", {
        group = PackerHooks,
        pattern = "PackerCompileDone",
        callback = function()
            notify.info("Compile Done!", {
                title = "LVIM IDE",
            })
            dofile(vim.env.MYVIMRC)
        end,
    })
end

return plugins
