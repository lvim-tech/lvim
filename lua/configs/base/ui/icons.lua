return {
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
    -- 󰕐 󰘯 󰖷   󰁁 󰃐 󰮄 󱗽 󰡱 󰋙󰌋 󰷖 󰧾 󰨑 󰒟 󱦜 󱄽 󰕘 󰕚    󰡌 󰢤 󰊾 󰯍 󰨝 󱒊 󰬶 󰎠 󱎆
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
    diagnostics = {
        global = "",
        error = "",
        warn = "",
        hint = "󰌵",
        info = "",
        other = "",
    },
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
    mason = {
        package_installed = " ",
        package_pending = "󰆴 ",
        package_uninstalled = " ",
    },
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
    projects = {
        -- General project types
        frontend = "", -- HTML5 (nf-dev-html5)  fallback: ""
        backend = "", -- Database / backend (nf-fa-database) fallback: ""
        fullstack = "", -- Full stack / layers (fa-layer-group) fallback: ""
        mobile = "", -- Mobile phone (fa-mobile-alt) fallback: "📱"
        api = "", -- API / link (fa-link) fallback: "󰗚"
        cli = "", -- CLI tool (nf-dev-term) fallback: ""
        plugin = "󰒓", -- Plugin (nf-mdi-plugin) fallback: "🔌"
        library = "󰏗", -- Library (package) fallback: "📦"
        template = "󰗀", -- Template / starter fallback: ""
        portfolio = "󰀄", -- Portfolio / personal site fallback: ""

        -- Frontend frameworks / meta
        html = "", -- HTML5 (nf-dev-html5)
        tailwind = "󱏿", -- Tailwind CSS (custom nerdfont) fallback: ""
        bootstrap = "", -- Bootstrap (nf-dev-bootstrap) fallback: ""
        vite = "󰁔", -- Vite (nf-custom-vite)
        nextjs = "󰨞", -- Next.js (octicon) fallback: ""
        react = "", -- React (nf-dev-react)
        vue = "", -- Vue (nf-dev-vuejs)
        nuxt = "󰔶", -- Nuxt.js (nf-dev-nuxtjs)
        svelte = "", -- Svelte (nf-dev-svelte)
        angular = "", -- Angular (nf-dev-angular)
        astro = "󱌢", -- Astro (custom nerdfont) fallback: ""
        solid = "󰡱", -- SolidJS (custom) fallback: ""
        remix = "󰑷", -- Remix.run (custom) fallback: ""

        -- Backend frameworks & servers
        nodejs = "", -- Node.js (nf-dev-nodejs)
        deno = "", -- Deno (commonly used glyph; may overlap with Rust) fallback: "里"
        bun = "󰳲", -- Bun (custom)
        express = "", -- Express (node/express glyph) fallback: ""
        nestjs = "󰟞", -- NestJS (custom) fallback: ""
        fastapi = "󰚀", -- FastAPI (custom) fallback: ""
        django = "", -- Django (nf-dev-django)
        flask = "", -- Flask
        laravel = "", -- Laravel
        symfony = "", -- Symfony
        spring = "", -- Spring / Java
        rails = "", -- Ruby on Rails

        -- Mobile / hybrid
        ionic = "", -- Ionic fallback: ""
        capacitor = "", -- Capacitor (fallback: "🔌")
        react_native = "", -- React Native (reuse React icon)
        flutter = "", -- Flutter

        -- Desktop / game engines
        electron = "", -- Electron
        unity = "", -- Unity
        unreal = "", -- Unreal Engine

        -- Languages
        go = "", -- Go (nf-dev-go)
        rust = "", -- Rust
        python = "", -- Python
        php = "", -- PHP
        java = "", -- Java
        kotlin = "", -- Kotlin
        csharp = "󰌛", -- C#
        cpp = "", -- C++
        c = "", -- C

        -- CMS / Specific platforms
        wordpress = "󰇧", -- WordPress
        astro_blog = "󱌢", -- Astro blog starter
        vitepress = "󰁔", -- VitePress (reuse vite)
        docusaurus = "󰗚", -- Docusaurus
        docsify = "󰗚", -- Docsify (use same docs icon)
    },
}
