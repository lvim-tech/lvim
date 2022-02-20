local global = require("core.global")
local funcs = require("core.funcs")
local M = {}

M.filetypes = {
    ["clojure"] = {
        "clojure",
        "edn"
    },
    ["cmake"] = {"cmake"},
    ["cpp"] = {
        "c",
        "cpp",
        "objc",
        "objcpp"
    },
    ["cs"] = {
        "cs",
        "vb"
    },
    ["css"] = {
        "css",
        "scss",
        "less"
    },
    ["d"] = {"d"},
    ["dart"] = {"dart"},
    ["elixir"] = {
        "elixir",
        "eelixir"
    },
    ["erlang"] = {"erlang"},
    ["fortran"] = {"fortran"},
    ["go"] = {"go", "gomod"},
    ["graphql"] = {"graphql"},
    ["groovy"] = {"groovy"},
    ["html"] = {"html"},
    ["java"] = {"java"},
    ["json"] = {"json"},
    ["jsts"] = {
        "javascript",
        "typescript",
        "javascriptreact",
        "typescriptreact"
    },
    ["kotlin"] = {"kotlin"},
    ["latex"] = {
        "bib",
        "tex"
    },
    ["lua"] = {"lua"},
    ["markdown"] = {"markdown"},
    ["php"] = {"php"},
    ["python"] = {"python"},
    ["ruby"] = {"ruby"},
    ["r"] = {"r", "rmd"},
    ["rust"] = {"rust"},
    ["shell"] = {"sh"},
    ["sql"] = {
        "sql",
        "mysql"
    },
    ["vim"] = {"vim"},
    ["toml"] = {"toml"},
    ["vue"] = {"vue"},
    ["xml"] = {
        "xml",
        "xsd",
        "xsl",
        "xslt",
        "svg"
    },
    ["yaml"] = {"yaml"}
}

M.setup = function()
    local filetype = vim.bo.filetype
    local project_root_path = vim.fn.getcwd()
    for language, v in pairs(M.filetypes) do
        for _, v2 in pairs(v) do
            if v2 == filetype then
                if language == "jsts" and funcs.file_exists(project_root_path .. "/angular.json") then
                    M.start_language("angular", project_root_path)
                    M.start_language("jsts", project_root_path)
                elseif language == "jsts" and funcs.file_exists(project_root_path .. "/ember-cli-build.js") then
                    M.start_language("ember", project_root_path)
                    M.start_language("jsts", project_root_path)
                else
                    M.start_language(language, project_root_path)
                end
            end
        end
    end
end

M.start_language = function(language, project_root_path)
    if global["languages"][language] ~= nil then
        if global["languages"][language]["project_root_path"] == project_root_path then
            -- nothing
            return
        else
            if funcs.file_exists(project_root_path .. "/lvim/" .. language .. ".lua") then
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
    local language_configs_global = dofile(global.languages_path .. language .. ".lua")
    local language_configs
    if funcs.file_exists(project_root_path .. "/lvim/" .. language .. ".lua") then
        local language_configs_custom = dofile(project_root_path .. "/lvim/" .. language .. ".lua")
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
