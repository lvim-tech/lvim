local uv, api = vim.loop, vim.api
local global = require("core.global")
local funcs = require("core.funcs")
local packer_compiled = global.packer_path .. "/lua/packer_compiled.lua"
local packer = nil

-- local a = require("async")
local display = {
    open_fn = function()
        return require("packer.util").float({ border = "single" })
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
    _G.LVIM_SNAPSHOT = vim.fn.input("Rollback from file: ", global.snapshot_path, "file")
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

function plugins.compile_notify()
    plugins.compile()
    vim.notify("Compile Done!", "info", { title = "Packer" })
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
end

return plugins
