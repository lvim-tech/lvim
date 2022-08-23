local uv, api = vim.loop, vim.api
local data_dir = string.format("%s/site/", vim.fn.stdpath("data"))
local packer_compiled = data_dir .. "lua/packer_compiled.lua"
local funcs = require("core.funcs")
local packer = nil
local display = {
    open_fn = function()
        return require("packer.util").float({ border = "single" })
    end,
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
        git = { clone_timeout = 120 },
        disable_commands = true,
        display = display,
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
    local packer_dir = data_dir .. "pack/packer/opt/packer.nvim"
    local state = uv.fs_stat(packer_dir)
    if not state then
        display = nil
        local cmd = "!git clone https://github.com/wbthomason/packer.nvim " .. packer_dir
        api.nvim_command(cmd)
        uv.fs_mkdir(data_dir .. "lua", 511, function()
            assert("Make compile path dir faield")
        end)
        self:load_packer()
        packer.sync()
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

function plugins.package(repo)
    table.insert(Packer.repos, repo)
end

function plugins.compile_notify()
    plugins.compile()
    vim.notify("Compile Done!", "info", { title = "Packer" })
end

function plugins.load_compile()
    if vim.fn.filereadable(packer_compiled) == 1 then
        require("packer_compiled")
    else
        vim.notify("Run PackerInstall", "info", { title = "Packer" })
    end
    vim.cmd([[command! PackerCompile lua require('core.pack').compile_notify()]])
    vim.cmd([[command! PackerInstall lua require('core.pack').install()]])
    vim.cmd([[command! PackerUpdate lua require('core.pack').update()]])
    vim.cmd([[command! PackerSync lua require('core.pack').sync()]])
    vim.cmd([[command! PackerClean lua require('core.pack').clean()]])
    vim.cmd([[command! PackerStatus  lua require('core.pack').status()]])
end

return plugins
