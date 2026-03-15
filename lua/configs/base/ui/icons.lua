-- Centralised Nerd-Font / Unicode icon table for LVIM IDE.
-- Every UI component (heirline, cmp, nvim-tree, outline, DAP, Mason, lazy.nvim,
-- diagnostics, git status, project picker, etc.) imports from this single
-- module so icon choices are maintained in one place.
--
-- The top-level keys group icons by consumer:
--   common        – generic editor / shell symbols
--   git_status    – git file-status icons
--   ctrlspace     – vim-ctrlspace status-bar glyphs
--   cmp           – nvim-cmp completion-kind icons (padded with spaces)
--   lsp           – LSP symbol-kind icons (tighter, for breadcrumbs / winbar)
--   outline       – symbol-outline icons with paired highlight groups
--   navbuddy      – navbuddy breadcrumb icons
--   diagnostics   – diagnostic severity icons
--   lazy          – lazy.nvim UI glyphs
--   mason         – Mason package status icons
--   dap_ui        – nvim-dap-ui tree and control icons
--   projects      – project-type / framework detection icons

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
    git_status = {
        added = "",
        deleted = "",
        modified = "",
        renamed = "",
        untracked = "",
        ignored = "",
        unstaged = "󰄗",
        staged = "󰄵",
        conflict = "",
        commit = "",
    },

    --- vim-ctrlspace status-bar indicators.
    ---@type table<string, string>
    ctrlspace = {
        CS = "",
        Sin = "",
        All = "",
        Vis = "",
        File = "󰈙",
        Tabs = "󰄮 ",
        CTab = "󰡖 ",
        NTM = "",
        WLoad = "󰜮",
        WSave = "󰜷",
        Zoom = "",
        SLeft = "",
        SRight = "",
        BM = "",
        Help = "",
        IV = "󰄗",
        IA = "󰄵",
        IM = " ",
        Dots = "",
    },

    --- nvim-cmp completion-kind icons.
    -- Each entry is padded with leading/trailing spaces for visual alignment.
    ---@type table<string, string>
    cmp = {
        Folder = " 󰝰 ",
        File = " 󰈙 ",
        Namespace = "  ",
        Package = "  ",
        Module = "  ",
        Interface = "  ",
        Constructor = "  ",
        Enum = " 󰕘 ",
        EnumMember = " 󰕚 ",
        Class = " 󰊾 ",
        Method = " 󰡱 ",
        Function = " 󰊕 ",
        Property = "  ",
        Field = " 󰢤 ",
        Constant = " 󰐃 ",
        Variable = " 󰯍 ",
        String = " 󰬶 ",
        Number = " 󰎠 ",
        Boolean = " ◩ ",
        Array = "  ",
        Object = " 󰅩 ",
        Key = " 󰌈 ",
        Null = " 󰟢 ",
        Struct = "  ",
        Event = "  ",
        Operator = " 󱓉 ",
        TypeParameter = "󰊄 ",
        Text = " 󰬶 ",
        Unit = "  ",
        Value = " 󱗽 ",
        Keyword = " 󰌈 ",
        Snippet = "  ",
        Color = " 󰌁 ",
        Reference = " 󰡌 ",
    },
    -- 󰕐 󰘯 󰖷   󰁁 󰃐 󰮄 󱗽 󰡱 󰋙󰌋 󰷖 󰧾 󰨑 󰒟 󱦜 󱄽 󰕘 󰕚    󰡌 󰢤 󰊾 󰯍 󰨝 󱒊 󰬶 󰎠 󱎆

    --- LSP symbol-kind icons used in breadcrumbs / winbar (tighter, no padding).
    ---@type table<string, string>
    lsp = {
        File = "󰈙 ",
        Module = " ",
        Namespace = " ",
        Package = " ",
        Class = "󰊾 ",
        Method = "󰡱 ",
        Property = " ",
        Field = "󰢤 ",
        Constructor = "  ",
        Enum = "󰕘 ",
        EnumMember = "󰕚 ",
        Interface = " ",
        Function = "󰊕 ",
        Variable = "󰯍 ",
        Constant = "󰐃 ",
        String = "󰬶 ",
        Number = "󰎠 ",
        Boolean = "◩ ",
        Array = " ",
        Object = "󰅩 ",
        Key = "󰌈 ",
        Null = "󰟢 ",
        Struct = " ",
        Event = " ",
        Operator = "󱓉 ",
        TypeParameter = "󰊄 ",
    },

    --- Symbol-outline icons with associated highlight groups.
    -- Each entry is an LvimIconOutlineEntry: { icon, hl }.
    ---@type table<string, LvimIconOutlineEntry>
    outline = {
        File = { icon = "󰈙", hl = "@directory" },
        Module = { icon = "", hl = "@include" },
        Namespace = { icon = "", hl = "@namespace" },
        Package = { icon = "", hl = "@include" },
        Class = { icon = "󰊾", hl = "@structure" },
        Method = { icon = "󰡱", hl = "@method" },
        Property = { icon = "", hl = "@property" },
        Field = { icon = "󰢤", hl = "@field" },
        Constructor = { icon = "", hl = "@constructor" },
        Enum = { icon = "󰕘", hl = "@field" },
        Interface = { icon = "", hl = "@type" },
        Function = { icon = "󰊕", hl = "@function" },
        Variable = { icon = "󰯍", hl = "@variable" },
        Constant = { icon = "󰐃", hl = "@constant" },
        String = { icon = "󰬶", hl = "@string" },
        Number = { icon = "󰎠", hl = "@number" },
        Boolean = { icon = "◩", hl = "@boolean" },
        Array = { icon = "", hl = "@field" },
        Object = { icon = "󰅩", hl = "@type" },
        Key = { icon = "󰌈", hl = "@keyword" },
        Null = { icon = "󰟢", hl = "@comment" },
        EnumMember = { icon = "󰕚", hl = "@field" },
        Struct = { icon = "", hl = "@structure" },
        Event = { icon = "", hl = "@keyword" },
        Operator = { icon = "󱓉", hl = "@operator" },
        TypeParameter = { icon = "󰊄", hl = "@type" },
        Component = { icon = "󰅴", hl = "Function" },
        Fragment = { icon = "󰅴", hl = "Constant" },
        -- ccls
        TypeAlias = { icon = " ", hl = "Type" },
        Parameter = { icon = " ", hl = "Identifier" },
        StaticMethod = { icon = " ", hl = "Function" },
        Macro = { icon = " ", hl = "Function" },
    },

    --- navbuddy breadcrumb icons (string only, no highlight table).
    ---@type table<string, string>
    navbuddy = {
        File = "󰈙 ",
        Namespace = " ",
        Package = " ",
        Module = " ",
        Interface = " ",
        Constructor = " ",
        Enum = "󰕘 ",
        EnumMember = "󰕚 ",
        Class = "󰊾 ",
        Method = "󰡱 ",
        Function = "󰊕 ",
        Property = " ",
        Field = "󰢤 ",
        Constant = "󰐃 ",
        Variable = "󰯍 ",
        String = "󰬶 ",
        Number = "󰎠 ",
        Boolean = "◩ ",
        Array = " ",
        Object = "󰅩 ",
        Key = "󰌈 ",
        Null = "󰟢 ",
        Struct = " ",
        Event = " ",
        Operator = "󱓉 ",
        TypeParameter = "󰊄 ",
    },

    --- Diagnostic severity icons (error, warn, hint, info).
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
    lazy = {
        cmd = " ",
        config = "",
        event = "",
        ft = " ",
        init = " ",
        import = " ",
        keys = " ",
        lazy = "󰒲 ",
        loaded = "●",
        not_loaded = "○",
        plugin = " ",
        runtime = " ",
        source = " ",
        start = "",
        task = "󰸞 ",
        list = {
            "●",
            "➜",
            "",
            "‒",
        },
    },

    --- Mason package manager status icons.
    ---@type table<string, string>
    mason = {
        package_installed = " ",
        package_pending = "󰆴 ",
        package_uninstalled = " ",
    },

    --- nvim-dap-ui icons split into tree navigation, debugger controls and
    --- gutter/sign indicators.
    ---@type LvimIconDapUi
    dap_ui = {
        base = { expanded = "", collapsed = "", current_frame = "" },
        controls = {
            pause = "",
            play = "",
            step_into = "",
            step_over = "",
            step_out = "",
            step_back = "",
            run_last = "",
            terminate = "",
            disconnect = "",
        },
        sign = {
            breakpoint = "",
            reject = "",
            condition = "",
            stopped = "󰏤",
            log_point = "",
        },
    },

    --- Project-type / framework detection icons used by the project picker.
    ---@type table<string, string>
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
