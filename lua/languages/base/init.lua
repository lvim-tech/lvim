local global = require("core.global")

local M = {}

M.file_types = {
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
    ["haskell"] = { "haskell", "lhaskell" },
    ["html"] = { "html" },
    ["java"] = { "java" },
    ["json"] = { "json" },
    ["jsts"] = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
    ["julia"] = { "julia" },
    ["kotlin"] = { "kotlin" },
    ["latex"] = { "bib", "tex" },
    ["lua"] = { "lua" },
    ["markdown"] = { "markdown" },
    ["org"] = { "org" },
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
    for language, v in pairs(M.file_types) do
        for _, v2 in pairs(v) do
            if v2 == filetype then
                M.start_language(language)
            end
        end
    end
end

M.start_language = function(language)
    local project_root_path = vim.fn.getcwd()
    if global["languages"][language] ~= nil then
        if global["languages"][language]["project_root_path"] == project_root_path then
            return
        else
            M.pre_init_language(language, project_root_path, "global")
            M.init_language(language, project_root_path)
        end
    else
        M.pre_init_language(language, project_root_path, "global")
        M.init_language(language, project_root_path)
    end
end

M.pre_init_language = function(language, project_root_path, lsp_type)
    global["languages"][language] = {}
    global["languages"][language]["project_root_path"] = project_root_path
    global["languages"][language]["lsp_type"] = lsp_type
end

M.init_language = function(language)
    local lspconfig_util_ok, lspconfig_util = pcall(require, "lspconfig.util")
    if not lspconfig_util_ok then
        return
    end
    local neoconf_status_ok, neoconf = pcall(require, "neoconf")
    if not neoconf_status_ok then
        return
    end
    if #lspconfig_util.available_servers() == 0 then
        neoconf.setup()
    end
    local language_configs_global = dofile(global.lvim_path .. "/lua/languages/base/languages/" .. language .. ".lua")
    for _, func in pairs(language_configs_global) do
        if type(func) == "function" then
            func()
        end
    end
end

return M
