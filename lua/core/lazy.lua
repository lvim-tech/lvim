-- lazy.nvim bootstrap and plugin registration.
-- Handles first-run installation and merges base + user plugin specs.
local funcs = require("core.funcs")
local icons = require("configs.base.ui.icons")

local lazy_pack = {}

-- Clones lazy.nvim into the standard data path if it is not already present.
-- Aborts with an error message if the git clone fails.
lazy_pack.is_lazy = function()
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not (vim.uv or vim.loop).fs_stat(lazypath) then
        local lazyrepo = "https://github.com/folke/lazy.nvim.git"
        local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
        if vim.v.shell_error ~= 0 then
            vim.api.nvim_echo({
                { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
                { out,                            "WarningMsg" },
                { "\nPress any key to exit..." },
            }, true, {})
            vim.fn.getchar()
            os.exit(1)
        end
    end
    vim.opt.rtp:prepend(lazypath)
end

-- Merges base and user plugin specs, converts them to the list format expected
-- by lazy.setup(), and initialises the plugin manager.
-- Entries explicitly set to `false` in the user spec are excluded (disable pattern).
lazy_pack.load = function()
    ---@type table[]
    local repos = {}
    local base_modules = require("modules.base")
    local user_modules = require("modules.user")
    -- User spec wins on key conflicts — allows overriding or disabling base plugins
    local modules = funcs.merge(base_modules, user_modules)
    for repo, conf in pairs(modules) do
        if conf ~= false then
            repos[#repos + 1] = vim.tbl_extend("force", { repo }, conf)
        end
    end
    require("lazy").setup(repos, {
        install = {
            missing = true,
            -- Try the active theme first so startup doesn't flash the fallback color
            colorscheme = { _G.LVIM.theme, "habamax" },
        },
        ui = {
            size   = { width = 0.95, height = 0.95 },
            border = "none",
            icons  = icons.lazy,
        },
    })
end

return lazy_pack
