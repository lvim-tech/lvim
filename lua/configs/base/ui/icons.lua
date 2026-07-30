-- lua/configs/base/ui/icons.lua
-- The glyphs THIS configuration draws with — the icons on the tabs and rows it registers into
-- lvim-control-center, and the project kinds its scaffolding panel offers.
--
-- NOT an icon dictionary: lvim-icons resolves an icon from a file, an extension, a filetype or an
-- LSP kind, and every plugin carries the glyphs it draws itself (control-center its row markers,
-- lvim-ls its diagnostic signs). What is left here belongs to tabs and rows this config invents,
-- so no plugin could read it — it would only store it. One table, so a glyph is changed in one
-- place rather than hunted across the modules that render it.
--
---@module "configs.base.ui.icons"

return {
    -- Tab icons for the Control Center groups this config registers, plus the dashboard entry.
    common = {
        dot = "",
        eval = "",
        light_bulb = "",
        palette = "󱥚",
        project = " ",
        vim = "",
        vim2 = "",
    },

    -- The project kinds offered by the Control Center projects panel (its only reader).
    projects = {
        angular = "",
        astro = "󱌢",
        backend = "",
        django = "",
        express = "",
        flutter = "",
        frontend = "",
        go = "",
        laravel = "",
        mobile = "",
        nestjs = "󰟞",
        nextjs = "󰨞",
        python = "",
        react = "",
        react_native = "",
        svelte = "",
        vite = "󰁔",
    },
}
