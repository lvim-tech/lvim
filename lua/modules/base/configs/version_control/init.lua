-- Plugin configuration for version-control plugins.
-- lvim-git — the in-house Magit/fugitive/neogit/vgit/diffview replica (+ jj + colocated sync) that runs the
-- whole git workflow inside the editor. setup() registers :LvimGit + binds highlights at startup, the gutter
-- signs auto-attach, and every component bootstraps lazily on its opener/subcommand. Keymaps are set here with
-- vim.keymap.set (the framework's lazy keys/cmd fields do not reliably register plain keymaps — same as
-- lvim-files). LazyGit (<Leader>sg) stays as a second, terminal-based option.

---@module "modules.base.configs.version_control"

---@type table<string, table>  Map of plugin identifiers to their plugin specs
return {
    lvim_git = {
        config = function()
            -- signs.gutter = false: no separate git glyph — the statuscolumn (chrome/statuscolumn.lua sc_git)
            -- colours its vline BAR from lvim-git's public `line_hl`, so one symbol + colour tells the state.
            require("lvim-git").setup({
                signs = { gutter = false },
                blame = { inline = { delay = 10 } }, -- near-instant inline blame (default 700ms)
            })
            -- Git keys live in the central keymap manifest: modules/base/keys.lua → <Leader>g*.
        end,
    },
    -- lvim-forge — the in-house Magit Forge (forge.el) replica: PR/issue/review across
    -- GitHub/GitLab/Gitea/Forgejo/Codeberg, cached offline in SQLite (lvim-utils.store). setup() registers
    -- :LvimForge, binds highlights, self-registers a "Forge" section into :LvimGit status, and wires the
    -- #topic/@user completion. CLI-first transport (gh/glab when authed, else curl+PAT). First use in a repo:
    -- `:LvimForge add` then `:LvimForge pull`; then the dispatch/topics/notifications render from the cache.
    lvim_forge = {
        config = function()
            require("lvim-forge").setup({})
            -- Forge keys live in the central keymap manifest: modules/base/keys.lua → <Leader>g*.
        end,
    },
}

-- vim: foldmethod=indent foldlevel=1
