-- local fn = vim.fn
local global = require("core.global")
local data_path = global.data_path
local vim_path = global.vim_path
local packer_compiled = data_path .. "lua/packer_compiled.lua"
local funcs = require("core.funcs")
local packer = nil

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
        vim.api.nvim_command("packadd packer.nvim")
        packer = require("packer")
    end
    packer.init({
        compile_path = packer_compiled,
        git = { clone_timeout = 120 },
        disable_commands = true,
        display = {
            open_fn = function()
                return require("packer.util").float({ border = "single" })
            end,
        },
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
    local packer_dir = data_path .. "pack/packer/opt/packer.nvim"
    local state = vim.loop.uv.fs_stat(packer_dir)
    if not state then
        local cmd = "!git clone https://github.com/wbthomason/packer.nvim " .. packer_dir
        vim.api.nvim_command(cmd)
        vim.loop.uv.fs_mkdir(data_path .. "lua", 511, function()
            assert("make compile path dir faield")
        end)
        self:load_packer()
        packer.install()
    end
end

local plugins = setmetatable({}, {
    __index = function(_, key)
        if not packer then
            Packer:load_packer()
        end
        return packer[key]
    end,
})

function plugins.ensure_plugins()
    Packer:init_ensure_plugins()
end

function plugins.auto_compile()
    local file = vim.fn.expand("%:p")
    if not file:match(vim_path) then
        return
    end

    if file:match("plugins.lua") then
        plugins.clean()
    end
    plugins.compile_notify()
    require("packer_compiled")
end

function plugins.load_pack()
    if vim.fn.filereadable(packer_compiled) == 1 then
        require("packer_compiled")
    else
        vim.notify("Run PackerInstall", "info", { title = "Packer" })
    end
    vim.api.nvim_create_user_command("PackerInstall", "lua require('core.pack').install()", {})
    vim.api.nvim_create_user_command("PackerUpdate", "lua require('core.pack').update()", {})
    vim.api.nvim_create_user_command("PackerSync", "lua require('core.pack').sync()", {})
    vim.api.nvim_create_user_command("PackerClean", "lua require('core.pack').clean()", {})
    vim.api.nvim_create_user_command("PackerStatus", "lua require('core.pack').status()", {})
end

return plugins
