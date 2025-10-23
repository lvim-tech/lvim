local function get_make_targets()
    local makefile = vim.fn.expand("%:p:h") .. "/Makefile"
    if vim.fn.filereadable(makefile) == 0 then
        return {}
    end
    local lines = vim.fn.systemlist("grep -E '^[a-zA-Z0-9_-]+:' " .. makefile .. " | cut -d: -f1")
    local targets = {}
    for _, line in ipairs(lines) do
        if line ~= "" and not line:match("^%.") then
            table.insert(targets, line)
        end
    end
    return targets
end

return {
    name = "RUN MAKE",
    builder = function(params)
        local cwd = vim.fn.expand("%:p:h")
        local targets = get_make_targets()
        local cmd = {}
        if params.target and params.target ~= "" then
            cmd = { "make", params.target }
        else
            cmd = { "bash", "-c", "for t in " .. table.concat(targets, " ") .. "; do make $t; done" }
        end
        return {
            cmd = cmd,
            components = { "default" },
            cwd = cwd,
        }
    end,
    parameters = {
        target = {
            type = "enum",
            choices = function()
                return get_make_targets()
            end,
            default = "",
            description = "Select a make target (leave empty to run all targets)",
        },
    },
    condition = {
        filetype = { "make", "makefile" },
    },
}
