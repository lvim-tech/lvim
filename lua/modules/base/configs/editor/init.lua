-- Plugin configuration table for editor-related plugins in LVIM IDE.
-- Each key is a plugin identifier (snake_case of the plugin name) whose value
-- is a LvimModule-compatible spec consumed by the core.pack loader. Pure
-- lvim-tech: workspace management (lvim-space), the settings panel
-- (lvim-control-center), language/spell switching, marks/jumps/macros
-- (lvim-vault), quickfix, text manipulation, tasks/build/remote, and
-- miscellaneous editing utilities.
---@module "modules.base.configs.editor"
---@type table<string, table>  Map of plugin identifiers to their plugin specs
return {
    -- lvim-space: project / workspace / tab management sidebar
    lvim_space = {
        -- Nothing to override: the icon table here was byte-identical to lvim-space's own
        -- defaults, and `log` is not one of its config keys at all.
        opts = {},
    },
    -- lvim-control-center: floating settings panel grouping all control_center/* modules
    lvim_control_center = {
        opts = function()
            -- Control-center + installer keys live in the central keymap manifest:
            -- keys/base.lua → <Leader>u* (UI / Toggles / Settings).
            -- Load each settings group module and register them in order. (The snapshot
            -- selector moved to lvim-installer — :LvimInstaller snapshot.)
            local general = require("modules.base.configs.editor.control_center.general")
            local appearance = require("modules.base.configs.editor.control_center.appearance")
            -- The LSP group: auto-format on save, inlay hints, diagnostic display mode, progress
            -- backend, code lens, plus the one-click LSP actions. It was disabled while its switches
            -- still called the pre-split `lvim-lsp.*` API; they now read and write `lvim-ls.*`, which is
            -- where that state actually lives, so the group is back.
            local lsp = require("modules.base.configs.editor.control_center.lsp")
            local commands = require("modules.base.configs.editor.control_center.commands")
            local projects = require("modules.base.configs.editor.control_center.projects")
            -- Centralized dock surface geometry (float/area/bottom sizes) + per-layout backdrop, defined
            -- locally here (control-center itself ships no predefined settings); reads/writes
            -- lvim-utils.config.dock.geometry live (the single authority every dock consumer resolves through).
            local geometry = require("modules.base.configs.editor.control_center.geometry")
            return {
                -- Instance-based: `command` is REQUIRED and unique. The loader forwards this table to
                -- setup(), which builds one instance (own command + own database) via new().
                command = "LvimControlCenter",
                -- Keep the ORIGINAL database directory (pre-instance default) so previously persisted
                -- settings carry over — the derived per-command path would point elsewhere.
                save = vim.fn.stdpath("data") .. "/lvim-control-center",
                groups = {
                    general,
                    appearance,
                    lsp,
                    commands,
                    projects,
                    geometry,
                },
            }
        end,
    },
    -- lvim-linguistics: per-mode keyboard layout switching and spell checking
    lvim_linguistics = {
        opts = function()
            -- <C-c>l / <C-c>k linguistics toggles live in the central manifest (keys/base.lua).
            return {
                base_config = {
                    mode_language = {
                        active = false,
                        normal_mode_language = "us",
                        insert_mode_language = "bg",
                        insert_mode_languages = { "en", "fr", "de", "bg" },
                    },
                    spell = {
                        active = false,
                        language = "en",
                        languages = {
                            en = {
                                spelllang = "en",
                                spellfile = "en.add",
                            },
                            fr = {
                                spelllang = "fr",
                                spellfile = "fr.add",
                            },
                            de = {
                                spelllang = "de",
                                spellfile = "de.add",
                            },
                            bg = {
                                spelllang = "bg",
                                spellfile = "bg.add",
                            },
                        },
                    },
                },
            }
        end,
    },
    -- lvim-vault: marks + jumps + a persistent macro bank (sqlite via lvim-utils.store) in one lvim-ui.tabs
    -- panel. Eager (like the other lvim-tech local-dev plugins): setup() registers :LvimVault at startup;
    -- the keymaps open its three tabs (the filter L/G/A · P/G/A lives inside each tab).
    lvim_vault = {
        config = function()
            -- Manifest overrides for the panel's own keys (defaults stay in the plugin).
            require("lvim-vault").setup({ keys = require("core.keys").plugin("lvim-vault") })
            -- The whole `m` prefix (mv* panels + m<verb><scope> mark verbs) lives in the central
            -- manifest (keys/base.lua) — `marks.disable_native = true` is what frees `m`.
        end,
    },
    -- lvim-undo: the undo history as a navigable, branching TIMELINE — diff preview beside it,
    -- named checkpoints/tags that survive restarts (sqlite via lvim-utils.store), and undofile
    -- purging. It reads Neovim's own undo tree, so it needs `undofile` on (core options set it).
    -- lvim-replace: project-wide search and replace in a panel. No options are set — the entry
    -- exists so the setup lives with every other editor plugin's, and so options have an obvious
    -- home the day one is needed.
    lvim_replace = {
        config = function()
            require("lvim-replace").setup({})
        end,
    },
    lvim_undo = {
        config = function()
            require("lvim-undo").setup({
                -- delta side-by-side is the diff the user reads everywhere else; the args are the
                -- plugin's own defaults, so only the engine has to be named.
                diff = { engine = "delta" },
                -- Named checkpoints on the operations worth rewinding to ("the version before the rename"), through the plugin's public checkpoint() seam.
                checkpoints = { auto = { format = true, lsp_rename = true, build = true } },
            })
            -- The <Leader>u* keys live in the central manifest (keys/base.lua → the
            -- "UI / Toggles / Settings" group). They were set here as well, and because a plugin
            -- config runs AFTER the manifest, `<Leader>up` (control-center projects) was silently
            -- replaced by "purge this buffer".
        end,
    },
    -- lvim-qf-loc: LVIM wrappers for quickfix and location list management
    lvim_qf_loc = {
        -- "native" is the plugin's default view.
        opts = {},
    },
    -- lvim-cycle: smart increment/decrement for numbers, dates, booleans, and operators.
    -- Default keys: <C-a>/<C-x> (normal + visual) plus g<C-a>/g<C-x> (visual sequential renumbering).
    lvim_cycle = {
        config = function()
            require("lvim-cycle").setup({
                groups = {
                    -- "int" covers decimal AND hex; preserve_case (on by default) covers the
                    -- True/False variant.
                    default = {
                        "int",
                        { kind = "date", patterns = { "%Y/%m/%d" } },
                        { elements = { "true", "false" } },
                        { elements = { "and", "or" } },
                        { elements = { "&&", "||" }, word = false },
                    },
                },
            })
        end,
    },
    -- lvim-move: move lines and selections up/down/left/right
    lvim_move = {
        opts = {},
    },
    -- lvim-comment: smart line and block commenting — gc{motion}/gcc, gb{motion}/gbb,
    -- visual gc/gb, plus gco/gcO/gcA, with the commentstring resolved per position via
    -- treesitter (embedded languages, jsx).
    lvim_comment = {
        config = function()
            require("lvim-comment").setup({})
        end,
    },
    -- lvim-buf-history: navigate the per-window buffer history (like browser
    -- back/forward) — <C-n>/<C-p>.
    lvim_buf_history = {
        config = function()
            require("lvim-buf-history").setup({})
            -- <C-n> / <C-p> buffer-history keys live in the central manifest (keys/base.lua).
        end,
    },
    -- lvim-color-picker: slider picker + converter + inline highlighter, on <C-c>r.
    lvim_color_picker = {
        cmd = { "LvimColorPicker" },
        keys = {
            {
                "<C-c>r",
                "<cmd>LvimColorPicker<cr>",
                mode = "n",
                desc = "ColorPicker",
            },
        },
        config = function()
            require("lvim-color-picker").setup({
                -- Inline swatches on demand: toggle the highlighter with
                -- :LvimColorPicker highlight (auto list empty = off by default).
                highlighter = { auto = {} },
            })
        end,
    },
    -- lvim-jump: label-based motions — enhanced f/t/F/T char motions (multi-line,
    -- labeled, with the ;/, repeat loop), the live-search jump mode, treesitter node
    -- selection and the operator-pending remote jump.
    lvim_jump = {
        config = function()
            require("lvim-jump").setup({
                -- Keep the historical lhs (<C-c>. / <C-c>, instead of the default s / S);
                -- "r" in operator-pending matches the old remote key.
                mappings = {
                    jump = false,
                    ts = false,
                    -- (`remote = "r"` is the plugin's default — not restated here.)
                },
            })
            -- <C-c>. / <C-c>; / <C-c>, jump keys (n/x/o) live in the central manifest (keys/base.lua).
        end,
    },
    -- lvim-search: a counter beside every visible search match — [1/12] on the one the cursor is
    -- heading for, [2]/[3] on the rest, and the nearest match painted above 'hlsearch'. It takes
    -- NO mappings: it watches v:hlsearch from a decoration provider, so n/N/*/#// stay untouched.
    lvim_search = {
        config = function()
            require("lvim-search").setup({})
        end,
    },
    -- lvim-calendar: month/quarter/year/agenda calendar. The Org diary under ~/Org/diary/
    -- plugs in as a SOURCE: existing entries decorate their days and show in the agenda;
    -- `i` on a day opens (creates) that day's file.
    lvim_calendar = {
        opts = {
            -- Monday-first is the plugin's default; only the ISO week column is ours.
            week_numbers = true,
            -- The org diary is a SHIPPED source now (lvim-calendar.sources): the orgmode
            -- YEAR/MONTH/DAY layout it reads is not a preference, so only the directory is.
            org_diary = { enabled = true, dir = "~/Org/diary" },
        },
    },
    -- lvim-table: per-buffer table mode — realign as you edit, row/column operations,
    -- cell text objects/motions, tableize and formulas.
    lvim_table = {
        config = function()
            require("lvim-table").setup({
                -- Buffer-local <leader>t* operation keys while table mode is on
                -- (mode-scoped maps).
                map_default_keys = true,
            })
            -- Table toggle lives in the central keymap manifest: keys/base.lua → <Leader>ct.
        end,
    },
    -- lvim-tasks: the task runner (panel + preview + filters + history). The old task
    -- keys live on: <Leader>or run (template chooser), <Leader>ot toggle the panel,
    -- <Leader>os open the panel, <Leader>oa history.
    lvim_tasks = {
        config = function()
            require("lvim-tasks").setup({})
            -- Tasks keys live in the central keymap manifest: keys/base.lua → <Leader>r* (Run / Test / Tasks).
        end,
    },
    -- lvim-build: detected project/file actions (Build/Run/Test/Bench/Lint), running
    -- through lvim-tasks. The old compile keys live on: <Leader>oo chooser,
    -- <Leader>og show the redo target, <Leader>od redo.
    lvim_build = {
        config = function()
            require("lvim-build").setup({})
            -- Build keys live in the central keymap manifest: keys/base.lua → <Leader>r* (Run / Test / Tasks).
        end,
    },
    -- lvim-test: granular test runner — discovers tests via treesitter and runs
    -- the nearest/file/suite through lvim-tasks with streaming per-test results.
    lvim_test = {
        config = function()
            require("lvim-test").setup({})
            -- Test keys live in the central keymap manifest: keys/base.lua → <Leader>r* (Run / Test / Tasks).
        end,
    },
    -- lvim-remote: upload/download/diff/sync project files over ssh/rsync (targets in
    -- .lvim/remote.lua). The old transfer keys live on under <Leader>t*.
    lvim_remote = {
        config = function()
            require("lvim-remote").setup({})
            -- Remote keys live in the central keymap manifest: keys/base.lua → <Leader>f* (Files / Remote).
        end,
    },
    -- lvim-rest: the in-editor REST/HTTP client — `.http` / `.rest` documents, environments, the
    -- variable system (document / prompt / dynamic / `{{vault}}`) and request chaining, with the
    -- response in a dock (body / headers / stats / verbose) plus history. Requests run through the
    -- native `lvim-rest-core` daemon when it has been built (`sh core/build.sh` in the plugin), and
    -- fall back to curl otherwise — `:checkhealth lvim-rest` reports which engine is live.
    lvim_rest = {
        config = function()
            require("lvim-rest").setup({})
            -- Launcher keys live in the central keymap manifest: keys/base.lua → <Leader>o*.
        end,
    },
    -- lvim-preview: live browser preview of Markdown / org with hot reload as you type, served by the
    -- plugin's OWN pure-Lua libuv HTTP + WebSocket server. Both parsers are the plugin's own; KaTeX,
    -- Mermaid and highlight.js are vendored, so the page never makes an external request.
    lvim_preview = {
        config = function()
            -- How the preview should be reachable from OTHER devices:
            --   "off"    — loopback only (safest): only this machine's browser can open it.
            --   "lan"    — bind the whole LAN so a phone / tablet on the SAME Wi-Fi can open it.
            --   "tunnel" — stay loopback; the plugin runs a tunnel command, captures the PUBLIC URL it
            --              prints, and drops it straight into the QR — no copy-paste, works from anywhere.
            local expose = "tunnel"
            require("lvim-preview").setup({
                -- Loopback unless we deliberately open the LAN.
                address = expose == "lan" and "0.0.0.0" or "127.0.0.1",
                -- Whenever the preview is reachable from outside, lock the server to ONLY the files you
                -- actually preview plus the images they embed — NEVER the whole project tree (no source,
                -- no .env / .git). On loopback the full tree is fine, so keep the default there.
                serve = expose == "off" and "root" or "documents",
                serve_hidden = expose == "off", -- hide dotfiles once exposed
                -- The preview opens in qutebrowser rather than whatever `xdg-open` decides. Named
                -- explicitly because the system default is a moving target — it changes with a
                -- desktop-file update or a "make X your default browser" prompt — and a preview that
                -- silently lands in a different browser than the one you read in is confusing rather
                -- than wrong. An argv LIST, not a string: it reaches `vim.system` verbatim, so no
                -- shell splits a path.
                browser = { "qutebrowser" },
                -- Let a viewer PAGE talk back to its producer. Needed for both inbound directions of
                -- the PDF page: ctrl-click inverse search (jump the cursor to the source of what you
                -- clicked) and the scroll link (scrolling the PDF moves the source with it — see
                -- lvim-tex's `synctex.follow_back`). Without it the page is one-way and both do
                -- nothing at all.
                --
                -- IT IS A REAL RELAXATION, and worth knowing while `expose` is "tunnel": the gate is
                -- per-connection, not per-device, so ANY client holding the URL may send those
                -- frames. What they can do is bounded — a producer only acts on shapes it registered
                -- a handler for, and lvim-tex's handler only scrolls or moves the cursor inside TeX
                -- buffers that are already open — but a stranger with the tunnel URL could move your
                -- view. Set `expose = "off"` (loopback only) if that matters more than the link.
                artifact = { allow_client_messages = true },
                -- Auto-tunnel: on start the plugin spawns the command, scrapes the public URL it prints,
                -- and advertises it (QR / status). Default provider is localhost.run (zero-install,
                -- anonymous). To use ANOTHER provider, set cmd + url_pattern here — a few that print
                -- their URL to stdout/stderr and so work out of the box:
                --   serveo:      cmd = { "ssh", "-R", "80:localhost:{port}", "serveo.net" },
                --                url_pattern = "https://[%w.%-]+%.serveo%.net"
                --   cloudflared: cmd = { "cloudflared", "tunnel", "--url", "http://localhost:{port}" },
                --                url_pattern = "https://[%w.%-]+%.trycloudflare%.com"
                -- (`{port}` is replaced with the real bound port. ngrok prints its URL only to a TUI /
                --  its local API, not stdout, so it needs a different scrape — ask if you want that.)
                -- tunnel = { enabled = expose == "tunnel" },
                -- An exposed start announces itself (warning + reachable URL) and pops a scannable QR,
                -- so a phone opens the preview without typing an IP. :LvimPreview qr shows it any time.
                lan = { warn = true, qr = true },
            })
            -- Launcher keys live in the central keymap manifest: keys/base.lua → <Leader>o*.
        end,
    },
    -- lvim-render: in-buffer decorated rendering of markdown, typst, org and latex — heading
    -- bands, list glyphs, code-block bands with the block's own language highlighted, tables drawn
    -- as boxes, folding by heading.
    lvim_render = {
        opts = {
            -- Window chrome for a RENDERED document, window-local and owned by the plugin: it
            -- records what was there, asserts these while the buffer renders, and hands the
            -- originals back when it stops. The rulers and gutters that earn their place in code
            -- are noise across a heading band or a table box — a rendered document is a page, not
            -- a source file. `["*"]` covers every filetype lvim-render draws (markdown, typst,
            -- org, tex, latex, plaintex); add a filetype key to single one out.
            win_options = {
                ["*"] = {
                    colorcolumn = "",
                    cursorcolumn = false,
                },
            },
        },
    },
    -- lvim-ansi: what a terminal drew in colour, shown in colour — foreground and background,
    -- bold, italic, underline, reverse — while the buffer text stays PLAIN, so search matches what
    -- is on screen and `yank` puts text in the register instead of escape codes. The colour lives
    -- in extmarks beside the text, not in it.
    lvim_ansi = {
        config = function()
            require("lvim-ansi").setup({
                -- Defaults left alone: they are the ones a 100k-line scrollback needs.
                -- `eager_limit` switches to a decoration provider past 20k ranges, and
                -- `max_groups` keeps a truecolour dump under nvim's ~19,600 highlight-group
                -- ceiling by quantising past 8,192 rather than erroring out.
                --
                -- `auto.enabled` stays false on purpose: colorize() REWRITES the buffer text
                -- (the escapes come out), which is too much to do unasked to every buffer that
                -- happens to hold one. :LvimAnsi colorize asks for it explicitly.
            })
        end,
    },
}

-- vim: foldmethod=indent foldlevel=15
