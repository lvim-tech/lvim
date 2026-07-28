-- Plugin configuration for language tooling plugins.
-- Pure lvim-tech: lvim-lsp (LSP engine over lvim-ls), lvim-pkg / lvim-ts /
-- lvim-installer (packages + treesitter + install UI), lvim-dependencies,
-- lvim-dap + lvim-dap-view (debugging), lvim-db (database client), and
-- lvim-breadcrumbs (the symbol trail for the chrome winbar).

---@module "modules.base.configs.languages"

local icons = require("configs.base.ui.icons")
local lsp_config = require("modules.base.configs.languages.lsp")
-- NO CATALOG HERE. lvim-lang's providers own their languages and fan their own servers (from
-- `lvim-lang.servers`) out to lvim-lsp, so this setup ships an empty one. A language that has no
-- provider yet gets one written for it — a declarative file is usually enough. (The hand-written
-- catalog this config used to carry is gone; git history has it if a detail is ever needed.)

return {
    lvim_lsp = {
        opts = {
            diagnostics = {
                severity_sort = true,
                signs = {
                    error = icons.diagnostics.error,
                    warn = icons.diagnostics.warn,
                    hint = icons.diagnostics.hint,
                    info = icons.diagnostics.info,
                },
            },
            features = {
                -- Only the one that differs: auto_format and inlay_hints are on by default.
                document_highlight = true,
            },
            -- No `peek` block: lvim-lsp reads only `peek.native` and `peek.layout`, and its default
            -- layout is already "area" (the cmdheight/msgarea zone). A per-command table was
            -- accepted silently and consumed by nothing — the behaviour matched by coincidence.
            hover = {
                enabled = true,
            },
            dap_local_fn = require("modules.base.configs.languages.lsp.dap_utils").dap_local,

            -- LSP buffer keymaps are applied by the central manifest (modules/base/keys.lua →
            -- keys.lsp) via its own capability-guarded LspAttach autocmd — no on_attach needed here.
        },
    },

    -- -------------------------------------------------------------------------
    -- lvim-pkg: the single data + operations hub for installable things (LSP
    -- packages, treesitter parsers, vim.pack plugins). Domain plugins (lvim-lsp,
    -- lvim-ts) and the installer UI depend on it, so it is loaded early. setup()
    -- also bootstraps the tree-sitter CLI when missing.
    -- -------------------------------------------------------------------------
    lvim_pkg = {
        ---@return nil
        config = function()
            require("lvim-pkg").setup({
                -- Same snapshots directory the config's get_commit reads, so the installer
                -- and the loader share one active version set.
                snapshot_dir = _G.LVIM.global.lvim_path .. "/.snapshots",
            })
        end,
    },

    -- -------------------------------------------------------------------------
    -- lvim-ts: buffer-side treesitter runtime over the built-in vim.treesitter.
    -- Parsers + their queries are compiled/installed by lvim-pkg's self-contained
    -- parser backend; lvim-ts enables highlighting and a query-based indent on
    -- first open. Folds use the global treesitter foldexpr set in
    -- configs.base.options.
    -- -------------------------------------------------------------------------
    lvim_ts = {
        ---@return nil
        config = function()
            -- auto_install is off: lvim-installer offers parsers through the unified
            -- prompt instead of installing them silently.
            require("lvim-ts").setup({
                auto_install = false,
                -- Node-based incremental selection: gnn start, grn grow, grm shrink, grc scope.
                incremental_selection = { enable = true },
                -- Generic node-type text objects: af/if function, ac/ic class, aa/ia parameter.
                textobjects = { enable = true },
            })
        end,
    },

    -- -------------------------------------------------------------------------
    -- lvim-installer: the UI layer — unified on-open install prompt (LSP tools +
    -- treesitter parsers, sourced from lvim-pkg) and the control-center tab.
    -- -------------------------------------------------------------------------
    lvim_installer = {
        ---@return nil
        config = function()
            -- Manifest overrides for the browser's row-action keys (defaults stay in the plugin).
            require("lvim-installer").setup({ browser = { keys = require("modules.base.keys_apply").plugin("lvim-installer") } })
        end,
    },

    lvim_dependencies = {
        opts = {},
    },

    -- -------------------------------------------------------------------------
    -- lvim-dap: the DAP client (debug engine). Signs are engine-owned and
    -- self-theming; the per-language adapters/configurations come from the
    -- lvim-ls server configs (their declarative `dap` tables register through
    -- lvim-ls.core.dap into this engine). The historical <A-N> debug keys drive
    -- the engine's public API.
    -- -------------------------------------------------------------------------
    -- lvim-keyring: the credential wallet behind one master password. No options are set — the
    -- entry exists so the setup lives with the rest of its group's, not inline in the manifest.
    lvim_keyring = {
        config = function()
            require("lvim-keyring").setup({})
        end,
    },

    lvim_dap = {
        ---@return nil
        config = function()
            local dap = require("lvim-dap")
            dap.setup({})
            local map = vim.keymap.set
            map("n", "<A-1>", function()
                dap.toggle_breakpoint()
            end, { desc = "Dap Toggle Breakpoint" })
            map("n", "<A-2>", function()
                -- A session is LIVE but the UI was closed → just REOPEN it (don't relaunch or resume /
                -- terminate the session). Otherwise: no session → start (picks a config); panel open +
                -- stopped → continue (resume). So closing the panel and pressing this again brings the
                -- panel back instead of ending the run.
                local ok_view, view = pcall(require, "lvim-dap-view")
                if dap.session() and ok_view and not view.is_open() then
                    view.open()
                    vim.notify("lvim-dap: session active — reopened the debug view", vim.log.levels.INFO)
                else
                    dap.continue()
                end
            end, { desc = "Debug Start/Continue (reopen the view if a session is live but hidden)" })
            map("n", "<A-3>", function()
                dap.step_into()
            end, { desc = "Dap Step Into" })
            map("n", "<A-4>", function()
                dap.step_over()
            end, { desc = "Dap Step Over" })
            map("n", "<A-5>", function()
                dap.step_out()
            end, { desc = "Dap Step Out" })
            map("n", "<A-6>", function()
                dap.up()
            end, { desc = "Dap Up" })
            map("n", "<A-7>", function()
                dap.down()
            end, { desc = "Dap Down" })
            map("n", "<A-8>", function()
                dap.terminate()
                dap.close()
                pcall(function()
                    require("lvim-dap-view").close()
                end)
            end, { desc = "Dap Close" })
            map("n", "<A-9>", function()
                dap.restart()
            end, { desc = "Dap Restart" })
            map("n", "<A-0>", "<Cmd>LvimDapView repl<CR>", { desc = "Dap Repl" })
        end,
    },

    -- -------------------------------------------------------------------------
    -- lvim-dap-view: the debugger UI dock (watches / scopes / stack / breakpoints
    -- / exceptions / repl / console / sessions). auto_open/auto_close (defaults)
    -- follow the session lifecycle over the engine's listener bus — no manual
    -- event wiring needed.
    -- -------------------------------------------------------------------------
    lvim_dap_view = {
        ---@return nil
        config = function()
            require("lvim-dap-view").setup({})
            -- Dap-view toggle lives in the central keymap manifest: modules/base/keys.lua → <Leader>dv.
        end,
    },

    -- -------------------------------------------------------------------------
    -- lvim-db: the database client — connections drawer, result dock, per-
    -- connection notes, saved connections + query history in its own store.
    -- The daemon backend is built once with `sh native/build.sh` (see
    -- :checkhealth lvim-db).
    -- -------------------------------------------------------------------------
    lvim_db = {
        ---@return nil
        config = function()
            require("lvim-db").setup({})
            -- Db keys live in the central keymap manifest: modules/base/keys.lua → <Leader>od (Open / Tools).
        end,
    },

    -- -------------------------------------------------------------------------
    -- lvim-breadcrumbs: the symbol path from the document root to the cursor.
    -- setup() auto-attaches every documentSymbol-capable client (LspAttach);
    -- the trail renders as a SEGMENT inside the lvim-hud chrome winbar (see
    -- modules.base.configs.ui.chrome.winbar).
    -- -------------------------------------------------------------------------
    -- lvim-lang: the lvim-tech per-language dev-tooling base (replaces flutter-tools.nvim). Its Dart
    -- provider owns dartls (registered through lvim-lsp/lvim-ls, so features/keymaps/breadcrumbs follow
    -- from LspAttach like any other server), the run lifecycle (flutter run --machine, hot reload/
    -- restart), device/emulator selection, closing labels, the Flutter Outline, DAP, DevTools, the VM
    -- service, pub commands and run configs — all through the ecosystem, no third-party deps.
    lvim_lang = {
        ---@return nil
        config = function()
            require("lvim-lang").setup({})
        end,
    },

    -- -------------------------------------------------------------------------
    -- lvim-tex: LaTeX integration — which file IS the document, how it is built,
    -- what its log means, and where a position in the PDF maps back to in the
    -- source. Replaces vimtex; the keys are the same letters off <localleader>
    -- (`,ll` build, `,lv` view, `,lt` toc …), so nothing has to be relearned.
    --
    -- Everything else is already owned elsewhere and is NOT configured here:
    -- texlab and latexindent by lvim-lang, the grammars by lvim-ts, the snippet
    -- engine by lvim-snippets, the PDF page by lvim-preview.
    --
    -- The defaults are deliberate: `viewer.name = "auto"` takes lvim-preview's
    -- PDF page first (nothing to install, and the only viewer that can show the
    -- build state), and `quickfix = "on_error"` keeps warnings — near-constant in
    -- LaTeX — from stealing the screen on every save. Inverse search from that
    -- page additionally needs lvim-preview's own `artifact.allow_client_messages`.
    -- -------------------------------------------------------------------------
    lvim_tex = {
        ---@return nil
        config = function()
            require("lvim-tex").setup({
                -- Artefacts BESIDE the source, as vimtex built them and as the projects here are
                -- laid out (their .gitignore ignores *.aux/*.log/main.pdf at the project root, and
                -- every existing main.pdf sits next to its main.tex). The plugin's own default is a
                -- `build/` directory; this is the one place that choice belongs to the user.
                out_dir = false,
                -- vimtex had its maths abbreviations ON (backtick + a mnemonic, inside maths only),
                -- so they stay on here — the point of the swap is that nothing has to be relearned.
                imaps = { enabled = true },
                -- Rebuild on save from the moment a project opens, which is what `\ll` did in
                -- vimtex: there it started latexmk's own watch mode and every save recompiled. Here
                -- the loop is ours (one build in flight, one rerun queued), and `,la` still toggles
                -- it per project when a particular document should NOT rebuild.
                continuous = { auto_start = true },
                -- ── SyncTeX: every direction zathura can do ───────────────────────────────
                synctex = {
                    -- The viewer follows the CURSOR: after `follow_debounce` ms of stillness it is
                    -- moved to the paragraph the cursor sits in. vimtex has no such thing at all —
                    -- its only cursor-driven sync is for TeXpresso, its own live renderer.
                    follow_cursor = true,
                    -- …and the SCROLL, which is the half that matters for reading: a wheel, CTRL-E
                    -- or `zz` moves the view while the cursor stays put, and a viewer that only ever
                    -- answers the cursor sits still through all of it. A scroll is answered with the
                    -- window centre, since the cursor is no longer where you are looking.
                    follow_scroll = true,
                    follow_debounce = 400,
                    -- One more sync after every successful build, so the page lands on what you were
                    -- writing without waiting for the cursor to move again.
                    forward_on_build = true,
                    -- Ctrl-click in the PDF moves the cursor here. zathura runs the callback through
                    -- a shell; lvim-tex builds it from `v:servername`, so neovim-remote is not
                    -- involved (the `nvr` line in ~/.config/zathura/zathurarc is a leftover).
                    inverse = true,
                    -- THE OTHER WAY ROUND. zathura cannot report a POSITION — only which PAGE it is
                    -- showing, and it announces nothing when that changes (its entire D-Bus
                    -- interface carries one signal, and that one is for ctrl-click). So this is a
                    -- poll: a read costs ~3 ms, and the source moves a page's worth when you flip a
                    -- page, nothing in between. That is all the granularity zathura exposes.
                    --
                    -- `,lr` does the same thing on demand and does not need this switch — that one
                    -- is about whether the editor should follow BY ITSELF.
                    follow_back = {
                        enabled = true,
                        poll = { enabled = true, interval = 1000 },
                    },
                },
                viewer = {
                    name = "zathura",
                    zathura = {
                        -- WITHOUT THIS ZATHURA TAKES THE KEYBOARD ON EVERY SYNC. Each D-Bus command
                        -- it serves — `SynctexView`, which is what `--synctex-forward` becomes —
                        -- ends in `gtk_window_present`, guarded by one runtime option:
                        -- `dbus-raise-window` (zathurarc(5), default true). "quiet" makes lvim-tex
                        -- turn that option off in the window IT opened, over zathura's own
                        -- `ExecuteCommand` — the single method exempt from the raise — so your
                        -- zathurarc is never touched.
                        --
                        -- The trade is all-or-nothing: afterwards NO sync raises zathura, the
                        -- explicit `,lv` included. Drop this line and zathura stops following the
                        -- cursor altogether (the automatic follow only ever drives quiet viewers).
                        forward = "quiet",
                        -- How persistently that is asked for after a launch: zathura's bus name
                        -- appears a few hundred ms after the process and is not activatable, so the
                        -- request is retried rather than awaited.
                        raise_retries = 16,
                        raise_retry_ms = 250,
                    },
                },
            })
        end,
    },

    lvim_breadcrumbs = {
        ---@return nil
        config = function()
            require("lvim-breadcrumbs").setup({})
        end,
    },
}
