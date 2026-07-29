-- keys/base/groups.lua — the LABEL for each <Leader> prefix, shown by lvim-keys-helper.
--
-- The taxonomy lives HERE and nowhere else: the panel is built from this table, so a prefix can
-- never be labelled as something the keymaps no longer do.
---@module "keys.base.groups"

return {
    ["<Leader>d"] = "Debug",
    ["<Leader>r"] = "Run / Test / Tasks",
    ["<Leader>g"] = "Git / Review",
    ["<Leader>f"] = "Files / Remote",
    ["<Leader>s"] = "Search / Navigate",
    ["<Leader>b"] = "Buffers",
    ["<Leader>w"] = "Windows",
    ["<Leader>wm"] = "Move window",
    ["<Leader>p"] = "Project / Space",
    ["<Leader>c"] = "Code / Edit",
    ["<Leader>o"] = "Open / Tools",
    ["<Leader>u"] = "UI / Toggles / Settings",
}

