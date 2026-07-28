-- Centralised Nerd-Font icon table for the parts of this config that draw their own glyphs.
-- Every consumer imports from this single module so icon choices are maintained in one place.
--
-- The top-level keys group icons by consumer:
--   common        – generic editor / shell symbols
--   diagnostics   – diagnostic severity icons (forwarded into lvim-lsp)
--   projects      – project-type / framework detection icons (control-center's project scaffolder)
--
-- (The git_status / ctrlspace / cmp / lsp / outline / navbuddy / lazy / mason / dap_ui groups were
-- data for third-party UIs that no longer exist here — every lvim-tech plugin owns and configures
-- its own icons.)

---@module "configs.base.ui.icons"

---@class LvimIconOutlineEntry
---@field icon string   The Nerd Font / Unicode glyph
---@field hl   string   The highlight group applied to this icon

---@class LvimIconDapBase
---@field expanded      string
---@field collapsed     string
---@field current_frame string

---@class LvimIconDapControls
---@field pause      string
---@field play       string
---@field step_into  string
---@field step_over  string
---@field step_out   string
---@field step_back  string
---@field run_last   string
---@field terminate  string
---@field disconnect string

---@class LvimIconDapSign
---@field breakpoint string
---@field reject     string
---@field condition  string
---@field stopped    string
---@field log_point  string

---@class LvimIconDapUi
---@field base     LvimIconDapBase
---@field controls LvimIconDapControls
---@field sign     LvimIconDapSign

return {
    --- General-purpose editor / shell symbols used across multiple components.
    ---@type table<string, string>
    common = {
        default = "󰏗",
        unix = "",
        dos = "",
        mac = "",
        vim = "",
        vim2 = "",
        lua = "",
        set = "",
        vline = "▌",
        -- vline = "│",
        -- vline = "❘"
        terminal = "",
        terminal2 = "",
        plugins = "",
        palette = "󱥚",
        record = " ",
        time = "󱑍",
        project = " ",
        explorer = "",
        folder = "󰉋",
        folder_close = "󰉋",
        folder_open = "󰝰",
        folder_empty = "󰉖",
        file = "󰈙",
        search_in_files = "󱔗",
        search = "",
        help = "󰞋",
        quit = "󰅗",
        buffer = "󱔗",
        git = "",
        lsp = "",
        separator = "➤",
        dot = "",
        fix = "",
        todo = "",
        hack = "",
        warning = "",
        performance = "󰔠",
        note = "󰠮",
        test = "",
        trace = "",
        down = "",
        up = "",
        down2 = "󰄼",
        up2 = "󰄿",
        save = " ",
        unsave = "󱙃 ",
        lock = "",
        light_bulb = "",
        hourglass = "",
        prompt = "",
        question = "󱜸",
        symbol = "",
        symbol2 = "",
        eval = "",
        substitute1 = "",
        substitute2 = "",
        is_true = "",
        is_false = "",
    },

    --- Git file-status icons (used in nvim-tree, neo-tree, heirline git component).
    ---@type table<string, string>
    diagnostics = {
        global = "",
        error = "",
        warn = "",
        hint = "󰌵",
        info = "",
        other = "",
    },

    --- lazy.nvim UI glyphs.
    ---@type table<string, string|string[]>
    projects = {
        -- General project types
        frontend = "",
        backend = "",
        fullstack = "󰒠",
        mobile = "",
        api = "",
        cli = "",
        plugin = "󰒓",
        library = "󰏗",
        template = "󰗀",
        portfolio = "󰟠",

        -- Frontend frameworks / meta
        html = "",
        tailwind = "󱏿",
        bootstrap = "",
        vite = "󰁔",
        nextjs = "󰨞",
        react = "",
        vue = "",
        nuxt = "󰔶",
        svelte = "",
        angular = "",
        astro = "󱌢",
        solid = "󰡱",
        remix = "󰑷",

        -- Backend frameworks & servers
        nodejs = "",
        deno = "󰏦",
        bun = "󰳲",
        express = "",
        nestjs = "󰟞",
        fastapi = "󰚀",
        django = "",
        flask = "󰂺",
        laravel = "",
        symfony = "",
        spring = "",
        rails = "",

        -- Mobile / hybrid
        ionic = "",
        capacitor = "",
        react_native = "",
        flutter = "",

        -- Desktop / game engines
        electron = "",
        unity = "",
        unreal = "",

        -- Languages
        go = "",
        rust = "",
        python = "",
        php = "",
        java = "",
        kotlin = "",
        csharp = "󰌛",
        cpp = "",
        c = "",

        -- CMS / Specific platforms
        wordpress = "󰇧",
        astro_blog = "󱌢",
        vitepress = "󰁔",
        docusaurus = "󰗚",
        docsify = "󰗚",
    },
}
