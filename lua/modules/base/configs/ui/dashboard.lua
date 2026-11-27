-- lua/modules/base/configs/ui/dashboard.lua
-- The start-dashboard DEFINITION for lvim-dashboard (the engine ships no content, like the chrome
-- segments). Migrated from the old snacks.dashboard config: the same banner, the same menu, the same two
-- panes (menu + a meta line / recent files / projects), the same startup stat. Referenced by
-- lvim-utils.setup({ dashboard = require("modules.base.configs.ui.dashboard") }).

local logo = require("modules.base.configs.ui.logo")

return {
    enable = true,
    -- auto-open on a bare `nvim` (no file args, empty single window). Set false to open only via :LvimDashboard.
    auto_open = true,

    -- Suppress the greeter when lvim-space will load a project for the cwd (else it flashes before lvim-space
    -- takes over). Fully OPTIONAL + decoupled: the dashboard knows nothing about lvim-space — this is a plain
    -- predicate wired here, guarded by pcall, so if lvim-space is absent it just opens the dashboard as usual.
    should_open = function()
        local ok, pub = pcall(require, "lvim-space.pub")
        if ok and type(pub.has_project_for_cwd) == "function" and pub.has_project_for_cwd() then
            return false -- lvim-space will load the cwd project → don't show the greeter
        end
        return true
    end,

    -- the Projects folders: open folders, in the theme's yellow like the meta-line icons
    icons = { directory = "\u{f0770}" }, -- nf-md-folder_open
    hl = { dir_icon = "LvimIconYellow" },

    preset = {
        -- The banner: the ASCII logo + the version string.
        header = logo.logo_1 .. "v" .. (_G.LVIM.version or "v9.0.0"),
        -- The menu. `key` is both the shown shortcut and a buffer keymap; `action` is a :Cmd / function.
        keys = {
            { icon = "󰘮 ", key = "<Leader>uc", desc = "Lvim Control Center", action = ":LvimControlCenter" },
            { icon = "󰡃 ", key = "<Leader>pp", desc = "Lvim Space", action = ":LvimSpace" },
            { icon = "󰙅 ", key = "<Leader>of", desc = "File Explorer", action = ":LvimCommander area" },
            { icon = "󰱽 ", key = "<Leader>sf", desc = "Find File", action = ":LvimPicker files" },
            { icon = "󰻭 ", key = "<Leader>N", desc = "New File", action = ":ene | startinsert" },
            { icon = "󰺯 ", key = "<Leader>sg", desc = "Find Text", action = ":LvimPicker grep" },
            { icon = "󱋢 ", key = "<Leader>so", desc = "Recent Files", action = ":LvimPicker oldfiles" },
            {
                icon = "󰢻 ",
                key = "<Leader>vc",
                desc = "Config",
                action = ":LvimDashboard pick files " .. vim.fn.stdpath("config"),
            },
            { icon = "󰅢 ", key = "<Leader>ui", desc = "Installer", action = ":LvimInstaller" },
            { icon = "󰏗 ", key = "<Leader>ud", desc = "Dependencies", action = ":LvimDeps" },
            { icon = "󰐥 ", key = "<C-c>e", desc = "Quit", action = ":Quit" },
        },
    },

    sections = {
        { section = "header" },
        { section = "keys", padding = 1 },
        -- pane 2: a meta line, then Recent Files + Projects, then the startup stat below.
        { pane = 2 },
        function()
            local v = vim.version()
            -- Each icon is its own chunk, in the theme's yellow (lvim-icons' self-themed palette group): in
            -- lvim-icons' "material" mode a chunk that is one glyph is drawn as an image, the size of every other
            -- icon on the dashboard.
            ---@type string, string
            local os_icon, os_name
            if _G.LVIM.global.os == "linux" then
                os_icon, os_name = "\u{f033d}", "Linux" -- nf-md-linux
            elseif _G.LVIM.global.os == "mac" then
                os_icon, os_name = "\u{f0035}", "macOS" -- nf-md-apple
            else
                os_icon, os_name = "\u{f05b3}", "" -- nf-md-microsoft_windows
            end
            local build = ""
            if v.build ~= vim.NIL then
                build = " build " .. v.build
            end
            local version = ("%d.%d.%d%s"):format(v.major, v.minor, v.patch, build)
            return {
                pane = 2,
                text = {
                    { os_icon .. " ", hl = "LvimIconYellow" },
                    { os_name ~= "" and (os_name .. "  ") or " ", hl = "desc" },
                    { "\u{f0e18} ", hl = "LvimIconYellow" }, -- nf-md-calendar_month_outline
                    { os.date("%d-%m-%Y") .. "  ", hl = "desc" },
                    { "\u{e7c5} ", hl = "LvimIconYellow" }, -- nf-dev-vim
                    { version, hl = "desc" },
                },
                align = "center",
            }
        end,
        { pane = 2 },
        {
            pane = 2,
            icon = "󰋚 ",
            title = "Recent Files",
            section = "recent_files",
            indent = 2,
            title_indent = 0,
            padding = 1,
        },
        {
            pane = 2,
            icon = "󰉕 ",
            title = "Projects",
            section = "projects",
            indent = 2,
            title_indent = 0,
            padding = 1,
        },
        { indent = 3 },
        -- Startup stat from the lvim-pkg loader (plugins actually loaded vs registered).
        function()
            local ok, pkg = pcall(require, "lvim-pkg")
            local s = (ok and pkg.plugin_stats) and pkg.plugin_stats() or { loaded = 0, total = 0 }
            -- The loader owns the stat (frozen at UIEnter); the fallback keeps the panel honest
            -- when it paints before UIEnter or when lvim-pack is not the loader.
            local ok_pack, pack = pcall(require, "lvim-pack")
            local ms = (ok_pack and pack.stats().startup_ms)
                or (vim.uv.hrtime() - (_G.LVIM.start_time or vim.uv.hrtime())) / 1e6
            -- the icon is its own chunk (an image in "material", the size of the others), in the theme's yellow
            -- (lvim-icons' self-themed palette group, so it follows the colorscheme)
            return {
                text = {
                    { "\u{f14df} ", hl = "LvimIconYellow" }, -- nf-md-rocket_launch_outline
                    { string.format("Loaded %d/%d plugins in %.0f ms", s.loaded, s.total, ms), hl = "special" },
                },
                align = "center",
                padding = 1,
            }
        end,
    },
}

-- vim: foldmethod=indent foldlevel=1
