-- User editor-config overrides (entry point).
-- Populate and return a `configs` table to disable (= false), rewrite, or add
-- config functions relative to lua/configs/base/init.lua. Deep-merged over the
-- base configs at startup, with user entries winning on key conflicts.
-- Empty by default — see the HELP block below for the override patterns.

local configs = {}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- HELP ---------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- Disable of default Config function (from lua/configs/base/init.lua)

-- You can disable of any default Config function
-- configs["base_vim"] = = false

-- Rewrite of default Config function (from lua/configs/base/init.lua)

-- You can rewrite of settings of any of default Config function
-- configs["base_vim"] = {
--     -- your code
-- }

-- Add new Config function

-- You can add new Config function
-- configs["user_vim"] = {
--     your code
-- }

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- HELP ---------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

return configs
