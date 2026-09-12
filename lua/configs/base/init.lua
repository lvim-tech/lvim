-- Base configuration bootstrap for LVIM IDE.
-- Exports a table of named setup functions that are called in sequence by the
-- main init to wire together options, keymaps, autocommands, user commands,
-- language file-type merging and the colour-palette extraction pipeline.

---@module "configs.base.init"

local options = require("configs.base.options")
local keys = require("core.keys")

---@type integer  Shared autocommand group used by all LvimIDE autocmds.
local group = vim.api.nvim_create_augroup("LvimIDE", {
    clear = true,
})

local funcs = require("core.funcs")

---@type table<string, fun(): nil>  Map of setup-phase name → setup function.
local configs = {}

-- Apply global vim.g / vim.opt settings (delegates to configs.base.options).
configs["base_options"] = function()
    options.global()
end

-- Wire LVIM-specific global behaviour: the utility user commands this config owns
-- (EditorConfigCreate).
configs["base_lvim"] = function()
    -- (`vim.deprecate` used to be replaced with an empty function here, to silence warnings coming
    -- from third-party plugins. There are none left — every plugin in this config is first-party —
    -- so a blanket silencer can now only hide OUR OWN use of a deprecated API. It is gone: a
    -- deprecation warning is a bug report about a plugin in ~/lvim-tech.)

    vim.api.nvim_create_user_command(
        "EditorConfigCreate",
        "lua require'core.funcs'.copy_file(_G.LVIM.global.lvim_path .. '/.configs/templates/.editorconfig', vim.fn.getcwd() .. '/.editorconfig')",
        { desc = "Create .editorconfig file from template" }
    )
    -- :LvimComments (strip), :LvimLuaTable (sort) and :LvimEval come from lvim-common's own
    -- setup() — the three utilities behind them live there now, with the rest of that plugin's
    -- editor quality-of-life modules. The manifest's `gcd` and `<Leader>co` call those commands.
end

-- Register filetype-specific autocommands:
-- Markdown visual overrides, prose listchars, 2-space indent for selected
-- languages, stripped UI for side-panel filetypes, Helm detection, and
-- Helm comment-string override.
configs["base_events"] = function()
    -- netrw: hide the statuscolumn (folded here from the retired keymaps_ft.lua).
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "netrw" },
        callback = function()
            vim.opt_local.statuscolumn = ""
        end,
        group = group,
    })

    -- Languages that conventionally use 2-space indentation.
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "c", "cpp", "dart", "haskell", "objc", "objcpp", "ruby", "markdown", "org" },
        callback = function()
            vim.opt_local.tabstop = 2
            vim.opt_local.shiftwidth = 2
        end,
        group = group,
    })

    -- Helm charts are YAML by extension and Go templates by content, so Neovim detects them as
    -- `yaml` and the wrong grammar/server attaches. Told to `vim.filetype.add`, which is the
    -- mechanism Neovim provides for exactly this: it participates in DETECTION, so the buffer is
    -- born `helm`. (It used to be a `BufRead`/`BufNewFile` autocmd that reassigned `filetype` AFTER
    -- detection had already run and fired FileType for `yaml` — every ft-keyed consumer saw yaml
    -- first, and anything that had already attached stayed attached.)
    vim.filetype.add({
        extension = { gotmpl = "helm" },
        pattern = {
            [".*/templates/.*%.ya?ml"] = "helm",
            [".*/templates/.*%.tpl"] = "helm",
            [".*/templates/.*%.txt"] = "helm",
            ["helmfile.*%.ya?ml"] = "helm",
        },
    })

    -- Helm: use Go-template block comment syntax for commentstring.
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "helm",
        callback = function()
            vim.bo.commentstring = "{{/* %s */}}"
        end,
        group = group,
    })
end

-- Remove the default LSP keymaps injected by Neovim so LVIM can define its own.
configs["base_languages"] = function()
    -- Remove Neovim's built-in LSP default mappings before LVIM installs its own.
    vim.keymap.del("n", "grn")
    vim.keymap.del({ "n", "v" }, "gra")
    vim.keymap.del("n", "grr")
    vim.keymap.del("n", "gri")
    vim.keymap.del("n", "gO")
    vim.keymap.del("i", "<C-s>")
end

-- Create utility user commands for window/path management and register
-- the GxPlus URL/file opener.
configs["base_commands"] = function()
    -- Uniform function-callback registration (no `lua require(...)` string eval). Each is wrapped in a
    -- no-arg closure so the command-info table nvim passes is never forwarded as a function argument
    -- (sudo_write in particular takes typed params, not the command opts).
    local cmd = vim.api.nvim_create_user_command
    cmd("CloseFloatWindows", function()
        funcs.close_float_windows()
    end, { desc = "Close all floating windows" })
    cmd("FocusFloatWindow", function()
        funcs.focus_float_window()
    end, { desc = "Focus the next floating window" })
    cmd("SetGlobalPath", function()
        funcs.set_global_path()
    end, { desc = "Set the global working directory" })
    cmd("SetWindowPath", function()
        funcs.set_window_path()
    end, { desc = "Set the window-local working directory" })
    cmd("SudoWrite", function()
        funcs.sudo_write()
    end, { desc = "Write the current file with sudo" })
    -- Safe :w wrapped in pcall so write errors are non-fatal in macros/scripts.
    cmd("Save", function()
        vim.schedule(function()
            pcall(vim.cmd, "w")
        end)
    end, { desc = "Save the current buffer (safe :w)" })
end

-- The central keymap manifest (keys/base/): launcher/group keys applied at startup,
-- LSP verbs on LspAttach, filetype leaves on FileType, and lvim-keys-helper group labels.
-- Runs after base_keymaps (alphabetical order), so the manifest wins on any overlap.
configs["base_keys"] = function()
    keys.apply()
end

return configs
