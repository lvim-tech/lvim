local modules = {}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- DEV OVERRIDES (local plugin development) ----------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Point every lvim-tech plugin that has a local clone under ~/lvim-tech at that clone, so edits are picked up
-- directly and vim.pack cannot overwrite them (dir= plugins are added to the runtimepath directly, not managed
-- by vim.pack). `dir` is deep-merged into the base spec, so each plugin's config/opts are preserved. This also
-- covers the plugins the lvim-nvim umbrella pulls in via its pack.lua distribution manifest — they resolve to
-- the local dev checkout instead of being cloned from GitHub. Remove a plugin's ~/lvim-tech clone to switch it
-- back to its published git version.
-- local dev_root = vim.fn.expand("~/lvim-tech")
-- if vim.fn.isdirectory(dev_root) == 1 then
--     for _, name in ipairs(vim.fn.readdir(dev_root)) do
--         if name:match("^lvim%-") and vim.fn.isdirectory(dev_root .. "/" .. name) == 1 then
--             modules["lvim-tech/" .. name] = { dir = dev_root .. "/" .. name }
--         end
--     end
-- end

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- HELP ---------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- Disable of default Module (Plug-in) (from lua/modules/base/init.lua)

-- You can disable of any default Module (Plug-in)
-- modules["lvim-tech/lvim-calendar"] = false

-- Rewrite of settings of default Module (Plug-in) (from lua/modules/base/init.lua)

-- You can rewrite of settings of any of default Module (Plug-in)
-- modules["lvim-tech/lvim-calendar"] = {
--     -- your code
-- }

-- Add new Module (Plug-in)

-- You can add new Module (Plug-in)
-- modules["name_of_your/plugin"] = {
--     your code
-- }

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- HELP ---------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Dependencies -------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- local dependencies_config = require("modules.user.configs.dependencies")

-- modules["name_of_your/plugin"] = {
--     config = dependencies_config.name_of_your_function
-- }

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- UI -----------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- local ui_config = require("modules.user.configs.ui")

-- modules["name_of_your/plugin"] = {
--     config = ui_config.name_of_your_function
-- }

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Editor -------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- local editor_config = require("modules.user.configs.editor")

-- modules["name_of_your/plugin"] = {
--     config = editor_config.name_of_your_function
-- }

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Version control ----------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- local version_control_config = require("modules.user.configs.version_control")

-- modules["name_of_your/plugin"] = {
--     config = version_control_config.name_of_your_function
-- }

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Languages ----------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- local languages_config = require("modules.user.configs.languages")

-- modules["name_of_your/plugin"] = {
--     config = languages_config.name_of_your_function
-- }

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Completion ---------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- local completion_config = require("modules.user.configs.completion")

-- modules["name_of_your/module"] = {
--     config = completion_config.name_of_your_function
-- }

return modules
