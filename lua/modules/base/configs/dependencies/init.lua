-- Plugin configuration for core dependency plugins of the pure lvim-tech set.
-- Covers: lvim-colorscheme (theme setup), lvim-icons (file icons), and the
-- lvim-nvim umbrella forwarder that configures the split base modules
-- (lvim-utils / common / hud / msgarea / picker / snippets / image / dashboard).

---@module "modules.base.configs.dependencies"
---@diagnostic disable: undefined-field

return {
    -- -------------------------------------------------------------------------
    -- Colorscheme: lvim-colorscheme
    -- The plugin self-manages the active theme (remember = true: restore + apply + persist);
    -- dim_inactive / dark_active focus cues off here (toggle from control-center), with
    -- invisible FloatBorder edges.
    -- -------------------------------------------------------------------------
    lvim_colorscheme = {
        ---@return table  Options table forwarded to lvim-colorscheme.setup()
        opts = function()
            -- The control-center DB backs lvim-colorscheme's settings.restore() (run inside setup, right after
            -- this opts table is consumed). The colorscheme loads early (priority 100), before control-center's
            -- own setup, so OPEN that DB here first — else restore() reads a closed DB and the saved panel
            -- settings (background/dim/cache/dark…) silently revert to defaults on startup. db.init is idempotent.
            pcall(function()
                require("lvim-control-center.persistence.db").init()
            end)
            return {
                cache = false,
                -- Two INDEPENDENT focus cues (on by default; toggle from control-center):
                --   dim_inactive — mute the foreground of non-focused windows (bg uniform)
                --   dark_active  — slightly darker bg for the focused window (bg_soft_dark)
                dim_inactive = true,
                dark_active = true,
                -- lvim-colorscheme self-manages the active theme: it restores + applies the last
                -- committed theme on setup and persists every change (store + mirror file), so
                -- there is no `_G.LVIM.theme` apply here. `style` is only the first-run default,
                -- used before any theme has been picked.
                remember = true,
                style = "everforest_soft",
                styles = {
                    floats = "dark",
                    sidebars = "dark",
                },
                -- Sidebar background (Normal:NormalSB) only for the panels we actually run. neo-tree and the
                -- LvimLsp outline theme themselves (they already wear bg_sidebar), so they stay OUT of this list;
                -- these are the helper/side windows that don't.
                sidebar_filetypes = {
                    "help",
                    "qf",
                    "man",
                    "checkhealth",
                },
                ---@param hl  table<string, table>  Highlight group overrides
                ---@param c   table                  The theme's active palette (lvim-colorscheme's own)
                on_highlights = function(hl, c)
                    -- Make float borders invisible by blending them into the float bg
                    hl.FloatBorder = {
                        bg = c.bg_float,
                        fg = c.bg_float,
                    }
                    -- (neo-tree no longer overridden — its background follows the theme's
                    -- "Sidebar style" / `styles.sidebars` like the other sidebars.)
                end,
            }
        end,
    },

    lvim_nvim = {
        config = function()
            require("lvim-common").gx.map_default()
            -- Window navigation + resizing (<C-h/j/k/l> and <C-Arrows>) now belong to LVIM-WINNAV — see
            -- configs/ui/init.lua. Same keys; it adds the tmux handoff at an edge, and `at_edge.down = "dock"`
            -- replaces the hand-written <C-j> wrapper that descended into the message zone.
            vim.api.nvim_create_user_command("Quit", function()
                require("lvim-common").quit.open()
            end, {})
            vim.api.nvim_create_user_command("Messages", function()
                require("lvim-hud").notify.history()
            end, { desc = "Browse captured notifications / messages" })
            -- Configure the whole lvim-tech set from one place through the umbrella. Each `["lvim-<plugin>"]`
            -- key is forwarded to that plugin's own setup() in a dependency-safe order (see lvim-nvim). The
            -- unified `:LvimPicker <finder> [area|float|bottom]` command is registered by lvim-picker; the
            -- finder functions stay public for keymaps: require("lvim-picker").files(...).
            require("lvim-nvim").setup({
                ["lvim-utils"] = {
                    cursor = { ft = { "lvim-utils-ui" } }, -- lvim-lsp / lvim-files self-register their panels
                },
                ["lvim-common"] = {
                    gx = {},
                    -- Drop 'colorcolumn' on windows narrower than the column while 'wrap' is on (it would
                    -- otherwise render as a stray cell on a wrapped continuation row). Reads the global value
                    -- control-center keeps in sync. Same exclusions as the control-center colorcolumn option.
                    colorcolumn = { enabled = true, exclude_ft = { "lvim-files" } },
                },
                ["lvim-hud"] = {
                    notify = {
                        -- print() is captured via msg_show (lua_print) + ext_kinds routing, so do not also wrap
                        -- print (that would double-handle it).
                        override_print = false,
                        -- :Messages + live messages both render IN the msgarea zone (one styled panel; the
                        -- coloured filter bar shows only when focused). Descend with <C-w>j, <C-w>k / q to leave.
                        history = { statusline = false },
                        ext_kinds = {
                            [""] = "zone",
                            ["echomsg"] = "zone",
                            ["echoerr"] = "zone",
                            ["lua_print"] = "zone",
                            ["return_prompt"] = "toast",
                        },
                    },
                    -- Self-rendered command-line (own float) with per-mode icon badges.
                    -- statusline = false: keep the mode badge IN the float, publish nothing to the statusline.
                    cmdline = { enable = true, statusline = false },
                    -- vim.ui.input dispatcher; default to the command-line, per-call via opts.ui or
                    -- require("lvim-hud.input").route_next("popup"|"cmdline").
                    input = { enable = true, default = "cmdline" },
                    -- Editor chrome: native statusline / winbar / tabline / statuscolumn. The statusline is the
                    -- GLOBAL line (laststatus=3) so it has no per-buffer exclude; winbar / tabline / statuscolumn
                    -- keep their own lvim-hud default blacklists (dashboard / panels / terminals / qf / ...).
                    -- Each `segments` is a LAZY function (resolved at render, after the plugin loads); the
                    -- DEFINITIONS live in our config (modules.base.configs.ui.chrome.*) — edit those to restyle.
                    -- No `enabled = true` per chrome part: that is the plugin's default. Only the
                    -- `segments` DEFINITIONS are ours (modules.base.configs.ui.chrome.*) — each is a LAZY
                    -- function resolved at render, after the plugin loads. Edit those to restyle.
                    chrome = {
                        statusline = {
                            segments = function()
                                return require("modules.base.configs.ui.chrome.statusline")
                            end,
                        },
                        winbar = {
                            segments = function()
                                return require("modules.base.configs.ui.chrome.winbar")
                            end,
                        },
                        tabline = {
                            segments = function()
                                return require("modules.base.configs.ui.chrome.tabline")
                            end,
                        },
                        statuscolumn = {
                            segments = function()
                                return require("modules.base.configs.ui.chrome.statuscolumn")
                            end,
                        },
                    },
                },
                ["lvim-picker"] = {
                    -- statusline = false: NO finder publishes its title/counter to the statusline.
                    statusline = false,
                    -- Every finder (files / grep / … included) uses the themed tint list matched by the native
                    -- lvim-fuzzy engine — no fzf terminal panel. Proven at 1.5M (viewport-virtualized render +
                    -- prepared-context match). Set true to fall back to the fzf-TUI for the heavy finders.
                    fzf_tui = false,
                    -- Finder prompt: a nerd search glyph + "Search" label.
                    prompt = { icon = "", label = "Search" },
                    -- Fuzzy result ordering (picker + native completion): dirs first, then by best match.
                    fuzzy = { sort = { "dirs_first", "score" } },
                },
                ["lvim-msgarea"] = {
                    -- Persistent message area (docked float) — routed kinds land here instead of toasts.
                    -- Toggle live with :LvimMsgArea. max_height is the hard cap; auto_resize fits content.
                    enable = true,
                    max_height = 12,
                    unified = true,
                    integrations = { native = true }, -- native cmdline completion -> msgarea
                    completion_columns = 3, -- grid: 3 columns (1 = list)
                },
                -- Snippet collections (VS Code / SnipMate / LuaSnip syntax, all read by the plugin
                -- itself — the LuaSnip PLUGIN is no longer a peer) + the :LvimSnippets picker; its
                -- setup() registers the "snippets" completion source into lvim-cmp (register_source)
                -- and installs the postfix watcher.
                ["lvim-snippets"] = {
                    -- `paths` is a clean array REPLACE, so listing your own folder is required, not
                    -- optional. ORDER IS PRIORITY: the first root wins an equal fuzzy score, which is
                    -- why `custom` comes first — a few hundred packaged snippets must not outrank the
                    -- handful written for this setup. `custom` and `vendor` are siblings so neither
                    -- contains the other; a vendored pack is then removable (or replaceable) without
                    -- touching anything hand-written.
                    paths = {
                        vim.fn.stdpath("config") .. "/snippets/custom",
                        vim.fn.stdpath("config") .. "/snippets/vendor/friendly",
                        vim.fn.stdpath("config") .. "/snippets/vendor/vim-snippets",
                    },
                },
                ["lvim-image"] = {
                    -- Terminal graphics: :LvimImage viewer, `nvim picture.png`, :LvimImageInline for inline
                    -- document images (markdown / html / latex). Non-PNG decoded in memory via libvips.
                    -- Anchor images to TEXT CELLS inside tmux (kitty's unicode-placeholder grid), which is
                    -- the mechanism kitty added for multiplexers: the cells are ordinary text, so tmux owns
                    -- and clears them like any other content. Without it the only path left is drawing at
                    -- the outer terminal's cursor — measured here to land in the window's top-left corner
                    -- regardless of where it belongs, AND to survive tmux window switches, because tmux
                    -- never learns the image is there.
                    tmux_placeholders = true,
                },
                -- Start dashboard (greeter). Engine-only like chrome — the banner/menu/layout DEFINITION lives
                -- in our config (modules.base.configs.ui.dashboard). Auto-opens on a bare `nvim`.
                ["lvim-dashboard"] = require("modules.base.configs.ui.dashboard"),
            })

            -- Finder keys (files/grep/buffers/oldfiles/marks) live in the central keymap
            -- manifest: modules/base/keys.lua → <Leader>s* (Search / Navigate).

            local ui = require("lvim-ui")
            local ui_auto = ui.new({ width = false })

            local function clean_title(prompt, default_prompt)
                local t = (prompt and prompt:gsub("\n", "")) or default_prompt
                if t:sub(-1) == ":" then
                    t = " " .. t:sub(1, -2) .. " "
                end
                return t
            end

            vim.ui.select = function(items, opts, on_choice)
                assert(type(on_choice) == "function", "missing on_choice function")
                local format_item = opts.format_item or tostring
                local display = {}
                for _, item in ipairs(items) do
                    table.insert(display, format_item(item))
                end
                local is_code_action = opts.prompt and opts.prompt:find("[Cc]ode [Aa]ction")
                local sel = is_code_action and ui_auto or ui
                local icon = is_code_action and require("lvim-ui.rows").icons().action or nil
                local display_items = {}
                for _, label in ipairs(display) do
                    table.insert(display_items, icon and { label = label, icon = icon } or label)
                end
                sel.select({
                    title = clean_title(opts.prompt, " Select "),
                    items = display_items,
                    position = "cursor",
                    max_width = vim.api.nvim_win_get_width(0) - 4,
                    max_items = vim.api.nvim_win_get_height(0),
                    callback = function(confirmed, index)
                        if confirmed and index then
                            on_choice(items[index], index)
                        else
                            on_choice(nil, nil)
                        end
                    end,
                })
            end
        end,
    },

    -- -------------------------------------------------------------------------
    -- lvim-icons: the icon provider for the whole UI (filetype / extension / kind →
    -- themed glyph). Font mode + palette colours by default; set color_mode = "brand"
    -- for the upstream brand hues, or mode = "svg" once the COLRv1 font is installed.
    -- -------------------------------------------------------------------------
    lvim_icons = {
        -- color_mode defaults to "brand" (real per-type brand colours, independent of the theme).
        -- Set opts.color_mode = "theme" to follow the colorscheme, or "theme_brand" for a blend.
        opts = {},
    },
}

-- vim: foldmethod=indent foldlevel=1
