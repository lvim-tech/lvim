-- Plugin configuration table for UI-related plugins in LVIM IDE.
-- Pure lvim-tech: window picking/moving (lvim-winpick / lvim-winmove), the key-hint
-- panel (lvim-keys-helper), the file manager (lvim-files), the TUI-app shell
-- integrations (lvim-shell), the terminal manager (lvim-term), and the indent guides
-- (lvim-indent). The editor chrome
-- (statusline / winbar / tabline / statuscolumn), cmdline/messages and the dashboard
-- are configured through the lvim-nvim forwarder (see configs.dependencies) with
-- their DEFINITIONS in the sibling chrome/ and dashboard.lua modules.

---@module "modules.base.configs.ui"

---@type table<string, table>  Map of plugin identifiers to their plugin specs
return {
    -- lvim-winpick: label each window so you can jump to it by key.
    -- Eager local checkout; also the swap-target API for lvim-winmove.
    lvim_winpick = {
        config = function()
            -- Defaults: include_current = false + autoselect_one = true, so with exactly two
            -- windows the current one is excluded → one candidate → it jumps with no keystroke.
            require("lvim-winpick").setup({})
            -- `gpp` window-picker key lives in the central manifest (keys/base.lua).
        end,
    },
    -- lvim-winmove: interactively move and swap windows within a tab.
    lvim_winmove = {
        config = function()
            require("lvim-winmove").setup({})
            -- `<C-c>w` win-move key lives in the central manifest (keys/base.lua).
        end,
    },
    -- lvim-keys-helper: the self-contained key-hint panel. The initial enabled / delay /
    -- style come from the persisted control-center settings; all three are then switched
    -- live from the control center (see control_center/general.lua).
    lvim_keys_helper = {
        -- `opts` as a FUNCTION: the values are read when the plugin loads (the persisted settings and
        -- the manifest are both live by then), and the loader calls its setup — the same shape every
        -- other plugin here uses. The old form required the module through a pcall and returned on
        -- failure, which is a guard inside a guard: the loader already runs a config under pcall,
        -- and by the time it does, the plugin is on the runtimepath.
        opts = function()
            return {
                enabled = _G.LVIM.keyshelper ~= false,
                delay = tonumber(_G.LVIM.settings.keyshelperdelay) or 200,
                style = _G.LVIM.settings.keyshelperstyle or "full",
                -- Labels for the leader groups, TAKEN FROM THE MANIFEST — the same table that
                -- defines the keys names their prefixes, so a group can never label a taxonomy the
                -- keymaps no longer use. (They were duplicated here, and this copy won: the panel
                -- showed "Calendar" / "Tools" / "Tasks & Build" for prefixes the manifest had long
                -- since re-assigned, because the applier's own registration ran before lvim-pack
                -- had put the helper on the rtp and was silently skipped.)
                groups = require("core.keys").resolve().groups,
            }
        end,
    },
    -- lvim-files: file manager with TWO views over one fs model — a persistent tree side
    -- panel and an editable-buffer directory view. Filesystem only: git status +
    -- diagnostics are decorations INSIDE the tree; the edit view is reached from the
    -- panel's `e` key or `:LvimFiles edit`.
    lvim_files = {
        -- Eager (like lvim-winpick/winmove/term): setup() registers the :LvimFiles command + highlight
        -- bind at startup, then the keymaps are set with vim.keymap.set (the framework's lazy `keys`/`cmd`
        -- fields do NOT reliably register standard keymaps here).
        config = function()
            -- `keys` forwards the manifest's `plugins["lvim-files"]` overrides into the plugin's own
            -- panel keys: the DEFAULTS stay in the plugin, the manifest is where a rebind is written.
            require("lvim-files").setup({
                panel = { auto_collapse = true },
                keys = require("core.keys").plugin("lvim-files"),
            })
            -- Its keys (<S-x>, <C-c><C-f>, <S-q>) live in the central manifest
            -- (keys/base.lua) with every other launcher.
        end,
    },
    -- lvim-shell: integrations for TUI apps launched inside a full-screen terminal
    -- buffer — Yazi, Vifm, Neomutt, LazyGit, and LazyDocker.
    lvim_shell = {
        config = function()
            -- ONE LAUNCHER: `:LvimShell <name> [dir]` over ~55 preset TUI programs (only those on
            -- PATH are offered in completion). The per-program `:Yazi` / `:Vifm` / `:LazyGit` /
            -- `:LazyDocker` / `:Neomutt` commands and the wrapper module behind them are gone —
            -- they duplicated the addon presets (yazi's chooser-file included), `:Vifm` called a
            -- function that did not exist, `:Yazi` was registered twice, and the LazyGit wrapper
            -- shelled out to `xrdb` to repaint a terminal colour. Shell/TUI launcher keys live in
            -- the central manifest: keys/base.lua → <Leader>o* (Open / Tools).
            -- Overrides go here (neomutt needs kitty's direct-colour TERM for real colours).
            local addons = require("lvim-shell.addons")
            addons.setup({
                neomutt = { config = { env = { TERM = "kitty-direct" } } },
            })
            addons.command()
        end,
    },
    -- lvim-term: persistent, named, toggleable terminals with a tab bar. The tab bar +
    -- <A-h>/<A-l>/<A-n> live in the plugin; here we keep the old numbered-terminal muscle
    -- memory (<C-c>N shows terminal N) and <Esc> to leave.
    lvim_term = {
        config = function()
            local term = require("lvim-term")
            -- No size: lvim-term keeps none of its own — the geometry comes from the shared
            -- lvim-utils dock geometry (a `size` key here was read by nothing).
            -- Manifest overrides for the terminal's own keys (defaults stay in the plugin).
            term.setup({ keys = require("core.keys").plugin("lvim-term") })
            local manager = require("lvim-term.manager")
            local ui = require("lvim-term.ui")
            -- <C-c>1..9: show terminal N (spawning up to N), mirroring the old numbered terminals.
            for i = 1, 9 do
                vim.keymap.set({ "n", "t" }, "<C-c>" .. i, function()
                    local ids = manager.ids()
                    while #ids < i do
                        manager.spawn()
                        ids = manager.ids()
                    end
                    ui.show(ids[i])
                end, { desc = "Terminal " .. i, silent = true })
            end
            -- Terminal-mode <Esc> lives in the central manifest (keys/base.lua → keys.global.terminal).
        end,
    },
    -- lvim-context: the sticky context header. The old settings (max_lines 3, trim_scope "outer",
    -- the per-language node lists) carry over 1:1; everything else is the plugin's default.
    lvim_context = {
        config = function()
            -- Every value here was the plugin's own default (max_lines 3, trim_scope "outer",
            -- min_window_height 0) — restating a default is drift waiting to happen.
            require("lvim-context").setup({})
        end,
    },
    -- lvim-winnav: <C-h/j/k/l> move, <C-Arrows> resize — the SAME keys as before, now backed by the
    -- plugin. At an edge: hand off to the tmux pane that way, except DOWN, which first descends into
    -- the docked message zone (that was a hand-written wrapper in dependencies/init.lua before).
    lvim_winnav = {
        opts = {
            -- Its OWN keys, bound by the plugin (config.keys): <C-h/j/k/l> move, <C-Arrows> resize.
            -- They were eight hand-written closures here, each re-implementing a call the plugin
            -- already exposes.
            at_edge = { left = "multiplexer", right = "multiplexer", up = "multiplexer", down = "dock" },
            default_amount = 2, -- the old resize step
        },
    },
    -- lvim-indent: indent guides (incl. through blank lines) + the enclosing-scope guide.
    -- Everything else — the `▏` glyph, the grey guide colour, the yellow scope with its
    -- start/end underlines — is already the plugin's default, so only the two settings that
    -- are genuinely ours are passed. Non-file buffers (panels, trees, terminals, the
    -- dashboard) are excluded by construction (buftype ~= ""), never by name.
    lvim_indent = {
        config = function()
            require("lvim-indent").setup({
                scope = { debounce = 5 },
                -- REPLACES the plugin's list (arrays replace, they don't concatenate), so this must
                -- be the whole set: the plugin's own defaults plus json. The old list was mostly
                -- third-party/panel filetypes — panels are excluded by CONSTRUCTION (buftype ~= ""),
                -- and dropping the real-file defaults meant guides came back in help/man/org.
                exclude = {
                    filetypes = {
                        "checkhealth",
                        "gitcommit",
                        "help",
                        "json",
                        "log",
                        "man",
                        "markdown",
                        "org",
                        "text",
                    },
                },
            })
        end,
    },
}

-- vim: foldmethod=indent foldlevel=1
