---@diagnostic disable: unused-local
local funcs = require("core.funcs")

local modules = {}
local plugins_snapshot = {}

local file_content = funcs.read_file(_G.global.lvim_path .. "/.snapshots/" .. _G.LVIM_SNAPSHOT)
if file_content ~= nil then
    plugins_snapshot = file_content
end

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- DEPENDENCIES -------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local dependencies_config = require("modules.user.configs.dependencies")

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- UI -----------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local ui_config = require("modules.user.configs.ui")

modules["lvim-tech/lvim-lsp"] = {
    config = function()
        require("lvim-lsp").setup()
    end,
}
modules["lvim-tech/lvim-dependencies"] = {
    config = function()
        require("lvim-dependencies").setup()
    end,
}
modules["lvim-tech/lvim-utils"] = {}

modules["nvzone/showkeys"] = {
    commit = funcs.get_commit("showkeys", plugins_snapshot),
    cmd = "ShowkeysToggle",
    config = ui_config.showkeys,
}

modules["nvzone/typr"] = {
    commit = funcs.get_commit("typr", plugins_snapshot),
    cmd = { "Typr", "TyprStats" },
    event = "VeryLazy",
    dependencies = "nvzone/volt",
    config = ui_config.typr,
}

-- modules["danilamihailov/beacon.nvim"] = {
--     opts = {
--         enabled = true, --- (boolean | fun():boolean) check if enabled
--         speed = 2, --- integer speed at wich animation goes
--         width = 40, --- integer width of the beacon window
--         winblend = 70, --- integer starting transparency of beacon window :h winblend
--         fps = 60, --- integer how smooth the animation going to be
--         min_jump = 3, --- integer what is considered a jump. Number of lines
--         cursor_events = { "CursorMoved" }, -- table<string> what events trigger check for cursor moves
--         window_events = { "WinEnter", "FocusGained" }, -- table<string> what events trigger cursor highlight
--         highlight = { bg = "white", ctermbg = 15 }, -- vim.api.keyset.highlight table passed to vim.api.nvim_set_hl
--     },
-- }

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- EDITOR -------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local editor_config = require("modules.user.configs.editor")

-- modules["jrop/tuis.nvim"] = {
--     config = function()
--         vim.keymap.set("n", "<leader>m", function()
--             require("tuis").choose()
--         end, { desc = "Choose Morph UI" })
--     end,
-- }

modules["wakatime/vim-wakatime"] = {
    event = "BufRead",
}

-- modules["yetone/avante.nvim"] = {
--     commit = funcs.get_commit("avante.nvim", plugins_snapshot),
--     build = "make",
--     event = "VeryLazy",
--     dependencies = {
--         "nvim-treesitter/nvim-treesitter",
--         "nvim-lua/plenary.nvim",
--         "MunifTanjim/nui.nvim",
--         "ibhagwan/fzf-lua",
--         "nvim-tree/nvim-web-devicons",
--         "zbirenbaum/copilot.lua",
--     },
--     config = editor_config.avante_nvim,
-- }
--
-- -- modules["nomad/nomad"] = {
-- --     commit = funcs.get_commit("nomad", plugins_snapshot),
-- --     -- priority = 10,
-- --     -- cmd = "Mad",
-- --     build = function()
-- --         local build = require("nomad.neovim.build")
-- --         build.builders.cargo():build(build.contexts.lazy())
-- --     end,
-- --     opts = {},
-- -- }
--
-- modules["obsidian-nvim/obsidian.nvim"] = {
--     commit = funcs.get_commit("obsidian.nvim", plugins_snapshot),
--     config = editor_config.obsidian_nvim,
-- }
--
-- -- modules["obsidian-nvim/calendar.nvim"] = {
-- --     commit = funcs.get_commit("cal.nvim", plugins_snapshot),
-- --     config = function()
-- --         -- require("calendar").setup()
-- --     end,
-- -- }

modules["mikesmithgh/kitty-scrollback.nvim"] = {
    commit = funcs.get_commit("kitty-scrollback.nvim", plugins_snapshot),
    lazy = true,
    cmd = {
        "KittyScrollbackGenerateKittens",
        "KittyScrollbackCheckHealth",
        "KittyScrollbackGenerateCommandLineEditing",
    },
    event = { "User KittyScrollbackLaunch" },
    config = editor_config.kitty_scrollback_nvim,
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- VERSION CONTROL ----------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local version_control_config = require("modules.user.configs.version_control")

-- modules["kevinhwang91/nvim-fundo"] = {
--     commit = funcs.get_commit("nvim-fundo", plugins_snapshot),
--     dependencies = {
--         "kevinhwang91/promise-async",
--     },
--     build = function()
--         require("fundo").install()
--     end,
--     config = function()
--         local fundo_status_ok, fundo = pcall(require, "fundo")
--         if not fundo_status_ok then
--             return
--         end
--         fundo.setup({
--             archives_dir = "/mnt/storage/biserstoilov/.fundo",
--         })
--     end,
-- }

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- LANGUAGES ----------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local languages_config = require("modules.user.configs.languages")

modules["RaafatTurki/hex.nvim"] = {
    config = function()
        require("hex").setup()
    end,
}

modules["aaronik/treewalker.nvim"] = {
    keys = {
        {
            "<C-j>j",
            function()
                vim.cmd("Treewalker Down")
            end,
            desc = "Treewalker Down",
        },
        {
            "<C-j>k",
            function()
                vim.cmd("Treewalker Up")
            end,
            desc = "Treewalker Up",
        },
        {
            "<C-j>h",
            function()
                vim.cmd("Treewalker Left")
            end,
            desc = "Treewalker Left",
        },
        {
            "<C-j>l",
            function()
                vim.cmd("Treewalker Right")
            end,
            desc = "Treewalker Right",
        },
        {
            "<C-j><C-j>",
            function()
                vim.notify("Treewalker SwapDown")
                vim.cmd("Treewalker SwapDown")
            end,
            desc = "Treewalker SwapDown",
        },
        {
            "<C-j><C-k>",
            function()
                vim.cmd("Treewalker SwapUp")
            end,
            desc = "Treewalker SwapUp",
        },
        {
            "<C-j><C-h>",
            function()
                vim.cmd("Treewalker SwapLeft")
            end,
            desc = "Treewalker SwapLeft",
        },
        {
            "<C-j><C-l>",
            function()
                vim.cmd("Treewalker SwapRight")
            end,
            desc = "Treewalker SwapRight",
        },
    },
    setup = function()
        require("treewalker").setup({})
    end,
}

-- modules["nvimdev/lspsaga.nvim"] = {
--     config = function()
--         require("lspsaga").setup({})
--     end,
-- }

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- COMPLETION ---------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local completion_config = require("modules.user.configs.completion")

modules["XXiaoA/atone.nvim"] = {
    config = function()
        require("atone").setup()
    end,
}

return modules
