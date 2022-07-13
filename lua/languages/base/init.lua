local global = require("core.global")
local funcs = require("core.funcs")

local M = {}

M.file_types = {
    ["_diagnosticls"] = {
        "c",
        "cpp",
        "html",
        "json",
        "less",
        "lua",
        "markdown",
        "objc",
        "objcpp",
        "python",
        "sh",
        "vim",
    },
    ["_emmet"] = { "html", "css", "typescriptreact", "javascriptreact" },
    ["_stylelint"] = {
        "css",
        "less",
        "postcss",
        "sass",
        "scss",
        "sugarss",
    },
    ["_eslint"] = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
        "vue",
    },
    ["angular"] = { "typescript", "html", "typescriptreact", "typescript.tsx" },
    ["clojure"] = { "clojure", "edn" },
    ["cmake"] = { "cmake" },
    ["cpp"] = { "c", "cpp", "objc", "objcpp" },
    ["cs"] = { "cs", "vb" },
    ["css"] = { "css", "scss", "less" },
    ["d"] = { "d" },
    ["dart"] = { "dart" },
    ["elixir"] = { "elixir", "eelixir" },
    ["elm"] = { "elm" },
    ["ember"] = { "handlebars", "typescript", "javascript" },
    ["erlang"] = { "erlang" },
    ["fortran"] = { "fortran" },
    ["go"] = { "go", "gomod" },
    ["graphql"] = { "graphql" },
    ["groovy"] = { "groovy" },
    ["html"] = { "html" },
    ["java"] = { "java" },
    ["json"] = { "json" },
    ["jsts"] = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
    ["julia"] = { "julia" },
    ["kotlin"] = { "kotlin" },
    ["latex"] = { "bib", "tex" },
    ["lua"] = { "lua" },
    ["markdown"] = { "markdown" },
    ["perl"] = { "perl" },
    ["php"] = { "php" },
    ["python"] = { "python" },
    ["ruby"] = { "ruby" },
    ["r"] = { "r", "rmd" },
    ["rust"] = { "rust" },
    ["shell"] = { "sh" },
    ["sql"] = { "sql", "mysql" },
    ["vim"] = { "vim" },
    ["toml"] = { "toml" },
    ["vue"] = { "vue" },
    ["xml"] = { "xml", "xsd", "xsl", "xslt", "svg" },
    ["yaml"] = { "yaml" },
    ["zig"] = { "zig", "zir" },
}

M.setup = function()
    local filetype = vim.bo.filetype
    local project_root_path = vim.fn.getcwd()
    for language, v in pairs(M.file_types) do
        for _, v2 in pairs(v) do
            if v2 == filetype then
                M.start_language(language, project_root_path)
            end
        end
    end
end

M.start_language = function(language, project_root_path)
    if global["languages"][language] ~= nil then
        if global["languages"][language]["project_root_path"] == project_root_path then
            return
        else
            if funcs.file_exists(project_root_path .. "/.lvim/" .. language .. ".lua") then
                M.kill_server(language)
                M.pre_init_language(language, project_root_path, "custom")
                M.init_language(language, project_root_path)
            elseif global["languages"][language]["lsp_type"] == "global" then
                -- nothing
                return
            else
                M.kill_server(language)
                M.pre_init_language(language, project_root_path, "global")
                M.init_language(language, project_root_path)
            end
        end
    else
        M.pre_init_language(language, project_root_path, "global")
        M.init_language(language, project_root_path)
    end
end

M.pre_init_language = function(language, project_root_path, lsp_type)
    global.current_pwd = project_root_path
    global["languages"][language] = {}
    global["languages"][language]["project_root_path"] = project_root_path
    global["languages"][language]["pid"] = {}
    global["languages"][language]["lsp_type"] = lsp_type
end

M.kill_server = function(language)
    if next(global["languages"][language]["pid"]) ~= nil then
        for _, pid in pairs(global["languages"][language]["pid"]) do
            os.execute("kill -9 " .. pid .. " > /dev/null 2>&1")
        end
    end
end

M.init_language = function(language, project_root_path)
    local language_configs_global = dofile(global.lvim_path .. "/lua/languages/base/languages/" .. language .. ".lua")
    local language_configs
    if funcs.file_exists(project_root_path .. "/.lvim/" .. language .. ".lua") then
        local language_configs_custom = dofile(project_root_path .. "/.lvim/" .. language .. ".lua")
        language_configs = funcs.merge(language_configs_global, language_configs_custom)
    else
        language_configs = language_configs_global
    end
    for _, func in pairs(language_configs) do
        func()
    end
    vim.cmd("e")
end

return M
