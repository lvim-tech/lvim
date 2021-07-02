local fn, uv, api = vim.fn, vim.loop, vim.api
local global = require "core.global"
local data_path = global.data_path
local packer_compiled = data_path .. "packer_compiled.vim"
local compile_to_lua = data_path .. "lua" .. global.path_sep .. "_compiled.lua"
local funcs = require "core.funcs"
local packer = nil

local Packer = {}
Packer.__index = Packer

function Packer:load_plugins()
    self.repos = {}
    local global_modules = require "modules.global"
    local custom_modules = require "modules.custom"
    local modules = funcs.merge(global_modules, custom_modules)
    for repo, conf in pairs(modules) do
        if conf ~= false then
            self.repos[#self.repos + 1] = vim.tbl_extend("force", {repo}, conf)
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
        git = {clone_timeout = 120},
        disable_commands = true
    })
    packer.reset()
    local use = packer.use
    self:load_plugins()
    use {"wbthomason/packer.nvim", opt = true}
    for _, repo in ipairs(self.repos) do use(repo) end
end

function Packer:init_ensure_plugins()
    local packer_dir = data_path .. "pack" .. global.path_sep .. "packer" ..
                           global.path_sep .. "opt" .. global.path_sep ..
                           "packer.nvim"
    local state = uv.fs_stat(packer_dir)
    if not state then
        local cmd = "!git clone https://github.com/wbthomason/packer.nvim " ..
                        packer_dir
        api.nvim_command(cmd)
        uv.fs_mkdir(data_path .. "lua", 511,
                    function() assert("make compile path dir failed") end)
        self:load_packer()
        packer.install()
    end
end

local plugins = setmetatable({}, {
    __index = function(_, key)
        if not packer then Packer:load_packer() end
        return packer[key]
    end
})

function plugins.ensure_plugins() Packer:init_ensure_plugins() end

function plugins.convert_compile_file()
    local lines = {}
    local lnum = 1
    lines[#lines + 1] = "vim.cmd [[packadd packer.nvim]]\n"
    for line in io.lines(packer_compiled) do
        lnum = lnum + 1
        if lnum > 15 then
            lines[#lines + 1] = line .. "\n"
            if line == "END" then break end
        end
    end
    table.remove(lines, #lines)
    if fn.isdirectory(data_path .. "lua") ~= 1 then
        os.execute("mkdir -p " .. data_path .. "lua")
    end
    if fn.filereadable(compile_to_lua) == 1 then os.remove(compile_to_lua) end
    local file = io.open(compile_to_lua, "w")
    for _, line in ipairs(lines) do file:write(line) end
    file:close()

    os.remove(packer_compiled)
end

function plugins.auto_compile()
    plugins.compile()
    plugins.convert_compile_file()
end

function plugins.load_compile()
    if fn.filereadable(compile_to_lua) == 1 then
        require("_compiled")
    else
        assert(
            "Missing packer compile file Run PackerCompile Or PackerInstall to fix")
    end
    vim.cmd [[command! PackerCompile lua require('core.pack').auto_compile()]]
    vim.cmd [[command! PackerInstall lua require('core.pack').install()]]
    vim.cmd [[command! PackerUpdate lua require('core.pack').update()]]
    vim.cmd [[command! PackerSync lua require('core.pack').sync()]]
    vim.cmd [[command! PackerClean lua require('core.pack').clean()]]
    vim.cmd [[autocmd User PackerComplete lua require('core.pack').auto_compile()]]
    vim.cmd [[command! PackerStatus  lua require('core.pack').status()]]
end

return plugins
