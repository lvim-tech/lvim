return {
    black = {
        fPrefix = "black",
        formatCommand = "black -q -",
        formatStdin = true,
        -- rootMarkers = { "pyproject.toml" },
    },
    stylua = {
        fPrefix = "stylua",
        formatCommand = "stylua -",
        formatStdin = true,
        -- rootMarkers = { "stylua.toml", ".stylua.toml" },
    },
    yamlfmt = {
        fPrefix = "yamlfmt",
        formatCommand = "yamlfmt -",
        formatStdin = true,
        -- rootMarkers = { ".yamlfmt" },
    },
    shfmt = {
        fPrefix = "shfmt",
        formatCommand = "shfmt -",
        formatStdin = true,
        -- rootMarkers = { ".editorconfig" },
    },
    cbfmt = {
        fPrefix = "cbfmt",
        formatCommand = "cbfmt --stdin-filepath ${FILENAME} --best-effort",
        formatStdin = true,
        -- rootMarkers = { ".cbfmt.toml" },
    },
    prettierd = {
        fPrefix = "prettierd",
        formatCommand = "prettierd --tab-width=4 --stdin-filepath ${FILENAME}",
        formatStdin = true,
        -- rootMarkers = { ".prettierrc" },
    },
    ["golangci-lint"] = {
        lPrefix = "golangci-lint",
        lintCommand = "golangci-lint ${INPUT}",
        lintStdin = true,
        -- rootMarkers = { ".golangci.yml", ".golangci.yaml", ".golangci.toml", ".golangci.json" },
    },
    rubocop = {
        lPrefix = "rubocop",
        lintCommand = "rubocop -",
        lintStdin = true,
        -- rootMarkers = { ".rubocop.yml" },
    },
    flake8 = {
        lPrefix = "flake8",
        lintCommand = "flake8 -",
        lintStdin = true,
        -- rootMarkers = { ".flake8" },
    },
    cpplint = {
        lPrefix = "cpplint",
        lintCommand = "cpplint ${INPUT}",
        lintStdin = true,
        -- rootMarkers = { "cpplint.cfg" },
    },
    yamllint = {
        lPrefix = "yamllint",
        lintCommand = "yamllint -f parsable -",
        lintStdin = true,
        -- rootMarkers = {".yamllint", ".yamllint.yaml", ".yamllint.yml"}
    },
    vint = {
        lPrefix = "vint",
        lintCommand = "vint -",
        lintStdin = true,
        -- rootMarkers = { ".vintrc.yaml", ".vintrc.yml", ".vintrc" },
    },
}
