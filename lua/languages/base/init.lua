local global = require("core.global")
local funcs = require("core.funcs")

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
                M.init_language(language)
            end
        end
    end
end

M.init_language = function(language, project_root_path)
    local language_config = dofile(global.lvim_path .. "/lua/languages/base/languages/" .. language .. ".lua")
    for _, func in pairs(language_config) do
        func()
    end
    -- vim.cmd("e")
end

return M
