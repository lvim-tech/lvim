-- Filetype-to-language mapping for LVIM IDE.
-- Each key is the language module name (matching a file in lua/languages/base/lsp/).
-- Each value is a list of Neovim filetype strings that the corresponding LSP
-- server should handle. These lists are merged into _G.LVIM.file_types at
-- startup so that LSP config files can reference them as _G.LVIM.file_types.<lang>.
--
-- See LvimNamespace.file_types in core/types.lua for the runtime type.
---@module "languages.base.file_types"

---@type table<string, string[]>
return {
    ["angular"] = {
        "typescript",
        "html",
        "typescriptreact",
        "typescript.tsx",
        "htmlangular",      -- Angular-specific HTML filetype registered by the Angular plugin
    },
    ["astro"] = {
        "astro",
    },
    ["cmake"] = {
        "cmake",
        "make",
    },
    ["cpp"] = {
        "c",
        "cpp",
        "objc",    -- Objective-C
        "objcpp",  -- Objective-C++
    },
    ["css"] = {
        "css",
        "scss",  -- SCSS (Sass with curly braces)
        "less",
    },
    ["d"] = {
        "d",
    },
    ["emmet"] = {
        -- HTML dialects
        "html",
        "css",
        "less",
        "postcss",
        "sass",
        "scss",
        "sugarss",
        -- JSX / TSX
        "typescriptreact",
        "javascriptreact",
        -- Astro components can also use Emmet
        "astro",
    },
    ["go"] = {
        "go",
        "gomod",  -- go.mod dependency file
    },
    ["helm"] = {
        "helm",
    },
    ["html"] = {
        "html",
    },
    ["json"] = {
        "json",
        "jsonc",  -- JSON with comments (used in tsconfig, VSCode settings, etc.)
    },
    ["jsts"] = {
        "javascript",
        "typescript",
        "javascriptreact",  -- .jsx files
        "typescriptreact",  -- .tsx files
    },
    ["kotlin"] = {
        "kotlin",
    },
    ["latex"] = {
        "bib",  -- BibTeX bibliography files
        "tex",
    },
    ["lua"] = {
        "lua",
    },
    ["markdown"] = {
        "markdown",
        "markdown.mdx",  -- MDX (Markdown with JSX)
    },
    ["nginx"] = {
        "nginx",
    },
    ["ocaml"] = {
        "ocaml",
        "menhir",          -- parser generator file
        "ocamlinterface",  -- .mli interface files
        "ocamllex",        -- ocamllex lexer definition
        "reason",          -- ReasonML (OCaml syntax variant)
        "dune",            -- dune build file
    },
    ["perl"] = {
        "perl",
    },
    ["php"] = {
        "php",
    },
    ["python"] = {
        "python",
    },
    ["r"] = {
        "r",
        "rmd",     -- R Markdown
        "quarto",  -- Quarto document (R/Python/Julia mixed)
    },
    ["rust"] = {
        "rust",
    },
    ["scala"] = {
        "scala",
        "sbt",  -- SBT build definition files
    },
    ["shell"] = {
        "sh",
        "bash",
        "zsh",
        "csh",
        "ksh",
    },
    ["sql"] = {
        "sql",
        "mysql",  -- MySQL-flavoured SQL dialect
    },
    ["stylelint"] = {
        "css",
        "less",
        "postcss",
        "sass",
        "scss",
        "sugarss",
    },
    ["tailwind"] = {
        -- html
        "aspnetcorerazor",
        "astro",
        "astro-markdown",
        "blade",
        "clojure",
        "django-html",
        "htmldjango",
        "edge",
        "eelixir", -- vim ft
        "elixir",
        "ejs",
        "erb",
        "eruby", -- vim ft
        "gohtml",
        "gohtmltmpl",
        "haml",
        "handlebars",
        "hbs",
        "html",
        "htmlangular",
        "html-eex",
        "heex",
        "jade",
        "leaf",
        "liquid",
        "markdown",
        "mdx",
        "mustache",
        "njk",
        "nunjucks",
        "php",
        "razor",
        "slim",
        "twig",
        -- css
        "css",
        "less",
        "postcss",
        "sass",
        "scss",
        "stylus",
        "sugarss",
        -- js
        "javascript",
        "javascriptreact",
        "reason",
        "rescript",
        "typescript",
        "typescriptreact",
        -- mixed
        "vue",
        "svelte",
        "templ",
    },
    ["toml"] = {
        "toml",
    },
    ["vim"] = {
        "vim",
    },
    ["vue"] = {
        "vue",
    },
    ["xml"] = {
        "xml",
        "xsd",   -- XML Schema Definition
        "xsl",   -- XSL Stylesheet
        "xslt",  -- XSLT Transformation
        "svg",   -- SVG is valid XML
    },
    ["yaml"] = {
        "yaml",
    },
    ["zig"] = {
        "zig",
        "zir",  -- Zig Intermediate Representation (for compiler development)
    },
}

-- vim: foldmethod=indent foldlevel=1
