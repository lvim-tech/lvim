-- keys/base/filetype.lua — the per-filetype leaves, applied buffer-local on FileType.
--
-- What is left here is what a language does DIFFERENTLY. The actions every language shares now
-- live in keys/base/lang.lua, bound from each provider's own command list, so this table is no
-- longer where a run key is declared per filetype — only where a language's own shape needs one.
---@module "keys.base.filetype"

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- FILETYPE  (applied buffer-local on FileType — makes <Leader>r ADAPT per ft)
-- Same lhs, different action per language → the group menu is ft-accurate automatically.
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
return {
    dart = {
        -- FLUTTER ONLY. Everything a Flutter buffer shares with every other language — run, build,
        -- test, the run configuration — comes from the shared language layer (keys/base/lang.lua),
        -- on the same chords it uses everywhere. What is left here is the dev SESSION: hot reload
        -- and restart, the device and the inspector, pub, the SDK. Those exist nowhere else, so
        -- they cannot be shared.
        --
        -- FIVE CHORDS MOVED, and the reason is measured: the shared layer is applied a tick later
        -- than this table, so where the two met the shared one silently won —
        -- `<C-c><C-c>r` had stopped being hot reload and become plain "run", which is the single
        -- chord a Flutter session leans on hardest. Rather than let the collision decide, the
        -- Flutter action moves to a free letter: reload r→h, devtools t→v, brightness b→B,
        -- paint p→y, detach D→x. `f` (run) and `c` (run config) are simply gone — they were the
        -- shared layer's own actions under a second name.
        { "<C-c><C-c>h", "<Cmd>LvimLang reload<CR>", "Hot reload" },
        { "<C-c><C-c>R", "<Cmd>LvimLang restart<CR>", "Hot restart" },
        { "<C-c><C-c>A", "<Cmd>LvimLang attach<CR>", "Attach" },
        { "<C-c><C-c>x", "<Cmd>LvimLang detach<CR>", "Detach" },
        { "<C-c><C-c>q", "<Cmd>LvimLang quit<CR>", "Quit" },
        { "<C-c><C-c>m", "<Cmd>LvimLang emulators<CR>", "Emulators" },
        { "<C-c><C-c>g", "<Cmd>LvimLang log toggle<CR>", "Dev log" },
        { "<C-c><C-c>v", "<Cmd>LvimLang devtools<CR>", "DevTools" },
        { "<C-c><C-c>i", "<Cmd>LvimLang inspect<CR>", "Inspect widget" },
        { "<C-c><C-c>y", "<Cmd>LvimLang paint<CR>", "Debug paint" },
        { "<C-c><C-c>B", "<Cmd>LvimLang brightness<CR>", "Brightness" },
        { "<C-c><C-c>P", "<Cmd>LvimLang platform<CR>", "Target platform" },
        { "<C-c><C-c>L", "<Cmd>LvimLang labels<CR>", "Closing labels" },
        { "<C-c><C-c>u", "<Cmd>LvimLang pub get<CR>", "Pub get" },
        { "<C-c><C-c>U", "<Cmd>LvimLang pub upgrade<CR>", "Pub upgrade" },
        { "<C-c><C-c>s", "<Cmd>LvimLang super<CR>", "Go to super" },
        { "<C-c><C-c>a", "<Cmd>LvimLang reanalyze<CR>", "Reanalyze" },
        { "<C-c><C-c>l", "<Cmd>LvimLang lsp restart<CR>", "Restart dartls" },
        { "<C-c><C-c>I", "<Cmd>LvimLang install<CR>", "Install SDK" },
        { "<C-c><C-c>o", "<Cmd>LvimLsp outline<CR>", "Outline" },
        { "<C-c><C-c>e", "<Cmd>LvimLsp rename<CR>", "Rename" },
    },
    -- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    -- PER LANGUAGE — what the provider offers BEYOND the shared layer.
    --
    -- The nine shared chords (keys/base/lang.lua) cover what every language does: run, build,
    -- test, debug, dependencies, the run configuration. What follows is the rest of each
    -- provider's own command list — `cargo clippy`, `go vet`, `mix credo`, `venv`, `switch-header`
    -- — one chord each, so a language's own tools are a keystroke away instead of a `:LvimLang`
    -- away.
    --
    -- THE LETTER IS DERIVED, not invented: the command's first letter when the shared layer has
    -- not taken it, its uppercase next, then a consonant from the word. `r b t f F d D p c` are
    -- the shared nine and are never reused, so no chord here can shadow "run" or "test".
    -- Generated from the live registry — a provider that gains a command is a regeneration away.
    -- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    -- ansible
    ["yaml.ansible"] = {
        { "<C-c><C-c>l", "<Cmd>LvimLang lint<CR>", "ansible-lint" },
    },
    ["ansible"] = {
        { "<C-c><C-c>l", "<Cmd>LvimLang lint<CR>", "ansible-lint" },
    },
    -- astro
    ["astro"] = {
        { "<C-c><C-c>v", "<Cmd>LvimLang dev<CR>", "npm run dev" },
    },
    -- bash
    ["sh"] = {
        { "<C-c><C-c>C", "<Cmd>LvimLang check<CR>", "shellcheck <file>" },
    },
    ["bash"] = {
        { "<C-c><C-c>C", "<Cmd>LvimLang check<CR>", "shellcheck <file>" },
    },
    -- cmake
    ["cmake"] = {
        { "<C-c><C-c>C", "<Cmd>LvimLang configure<CR>", "cmake -B build" },
    },
    -- cpp
    ["c"] = {
        { "<C-c><C-c>C", "<Cmd>LvimLang compile-commands<CR>", "compile-commands" },
        { "<C-c><C-c>n", "<Cmd>LvimLang configure<CR>", "configure" },
        { "<C-c><C-c>s", "<Cmd>LvimLang switch-header<CR>", "switch-header" },
        { "<C-c><C-c>S", "<Cmd>LvimLang symbol-info<CR>", "symbol-info" },
    },
    ["cpp"] = {
        { "<C-c><C-c>C", "<Cmd>LvimLang compile-commands<CR>", "compile-commands" },
        { "<C-c><C-c>n", "<Cmd>LvimLang configure<CR>", "configure" },
        { "<C-c><C-c>s", "<Cmd>LvimLang switch-header<CR>", "switch-header" },
        { "<C-c><C-c>S", "<Cmd>LvimLang symbol-info<CR>", "symbol-info" },
    },
    ["objc"] = {
        { "<C-c><C-c>C", "<Cmd>LvimLang compile-commands<CR>", "compile-commands" },
        { "<C-c><C-c>n", "<Cmd>LvimLang configure<CR>", "configure" },
        { "<C-c><C-c>s", "<Cmd>LvimLang switch-header<CR>", "switch-header" },
        { "<C-c><C-c>S", "<Cmd>LvimLang symbol-info<CR>", "symbol-info" },
    },
    ["objcpp"] = {
        { "<C-c><C-c>C", "<Cmd>LvimLang compile-commands<CR>", "compile-commands" },
        { "<C-c><C-c>n", "<Cmd>LvimLang configure<CR>", "configure" },
        { "<C-c><C-c>s", "<Cmd>LvimLang switch-header<CR>", "switch-header" },
        { "<C-c><C-c>S", "<Cmd>LvimLang symbol-info<CR>", "symbol-info" },
    },
    -- csharp
    ["cs"] = {
        { "<C-c><C-c>a", "<Cmd>LvimLang add<CR>", "add" },
        { "<C-c><C-c>C", "<Cmd>LvimLang clean<CR>", "dotnet clean [args]" },
        { "<C-c><C-c>R", "<Cmd>LvimLang remove<CR>", "dotnet remove package <package>" },
        { "<C-c><C-c>s", "<Cmd>LvimLang restore<CR>", "dotnet restore [args]" },
    },
    -- cue
    ["cue"] = {
        { "<C-c><C-c>e", "<Cmd>LvimLang eval<CR>", "cue eval <file>" },
        { "<C-c><C-c>v", "<Cmd>LvimLang vet<CR>", "cue vet" },
    },
    -- elixir
    ["elixir"] = {
        { "<C-c><C-c>C", "<Cmd>LvimLang compile<CR>", "mix compile [args]" },
        { "<C-c><C-c>R", "<Cmd>LvimLang credo<CR>", "mix credo [args]" },
        { "<C-c><C-c>m", "<Cmd>LvimLang format<CR>", "mix format [args]" },
        { "<C-c><C-c>i", "<Cmd>LvimLang iex<CR>", "iex -S mix [args]" },
    },
    ["eelixir"] = {
        { "<C-c><C-c>C", "<Cmd>LvimLang compile<CR>", "mix compile [args]" },
        { "<C-c><C-c>R", "<Cmd>LvimLang credo<CR>", "mix credo [args]" },
        { "<C-c><C-c>m", "<Cmd>LvimLang format<CR>", "mix format [args]" },
        { "<C-c><C-c>i", "<Cmd>LvimLang iex<CR>", "iex -S mix [args]" },
    },
    ["heex"] = {
        { "<C-c><C-c>C", "<Cmd>LvimLang compile<CR>", "mix compile [args]" },
        { "<C-c><C-c>R", "<Cmd>LvimLang credo<CR>", "mix credo [args]" },
        { "<C-c><C-c>m", "<Cmd>LvimLang format<CR>", "mix format [args]" },
        { "<C-c><C-c>i", "<Cmd>LvimLang iex<CR>", "iex -S mix [args]" },
    },
    -- erlang
    ["erlang"] = {
        { "<C-c><C-c>C", "<Cmd>LvimLang compile<CR>", "rebar3 compile [args]" },
        { "<C-c><C-c>T", "<Cmd>LvimLang ct<CR>", "rebar3 ct [args]" },
        { "<C-c><C-c>S", "<Cmd>LvimLang ct-suite<CR>", "ct-suite" },
        { "<C-c><C-c>e", "<Cmd>LvimLang eunit<CR>", "rebar3 eunit [args]" },
        { "<C-c><C-c>m", "<Cmd>LvimLang fmt<CR>", "erlfmt --write <current file>" },
        { "<C-c><C-c>s", "<Cmd>LvimLang shell<CR>", "rebar3 shell [args] (+ active run config)" },
    },
    -- fsharp
    ["fsharp"] = {
        { "<C-c><C-c>a", "<Cmd>LvimLang add<CR>", "add" },
        { "<C-c><C-c>C", "<Cmd>LvimLang clean<CR>", "dotnet clean [args]" },
        { "<C-c><C-c>m", "<Cmd>LvimLang format<CR>", "fantomas [paths…]" },
        { "<C-c><C-c>R", "<Cmd>LvimLang remove<CR>", "dotnet remove package <package>" },
        { "<C-c><C-c>s", "<Cmd>LvimLang restore<CR>", "dotnet restore [args]" },
    },
    -- go
    ["go"] = {
        { "<C-c><C-c>C", "<Cmd>LvimLang coverage<CR>", "coverage [clear]" },
        { "<C-c><C-c>g", "<Cmd>LvimLang generate<CR>", "go generate ./... [args]" },
        { "<C-c><C-c>G", "<Cmd>LvimLang get<CR>", "go get <module[@version]> | -u ./..." },
        { "<C-c><C-c>s", "<Cmd>LvimLang gotests<CR>", "gotests" },
        { "<C-c><C-c>S", "<Cmd>LvimLang gotestsum<CR>", "gotestsum" },
        { "<C-c><C-c>i", "<Cmd>LvimLang impl<CR>", "impl <receiver…> <interface>" },
        { "<C-c><C-c>m", "<Cmd>LvimLang mod<CR>", "mod tidy|download|verify|graph|why" },
        { "<C-c><C-c>T", "<Cmd>LvimLang tags<CR>", "tags <add|remove> [json|xml|…]" },
        { "<C-c><C-c>v", "<Cmd>LvimLang vet<CR>", "go vet ./... [args]" },
    },
    ["gomod"] = {
        { "<C-c><C-c>C", "<Cmd>LvimLang coverage<CR>", "coverage [clear]" },
        { "<C-c><C-c>g", "<Cmd>LvimLang generate<CR>", "go generate ./... [args]" },
        { "<C-c><C-c>G", "<Cmd>LvimLang get<CR>", "go get <module[@version]> | -u ./..." },
        { "<C-c><C-c>s", "<Cmd>LvimLang gotests<CR>", "gotests" },
        { "<C-c><C-c>S", "<Cmd>LvimLang gotestsum<CR>", "gotestsum" },
        { "<C-c><C-c>i", "<Cmd>LvimLang impl<CR>", "impl <receiver…> <interface>" },
        { "<C-c><C-c>m", "<Cmd>LvimLang mod<CR>", "mod tidy|download|verify|graph|why" },
        { "<C-c><C-c>T", "<Cmd>LvimLang tags<CR>", "tags <add|remove> [json|xml|…]" },
        { "<C-c><C-c>v", "<Cmd>LvimLang vet<CR>", "go vet ./... [args]" },
    },
    ["gowork"] = {
        { "<C-c><C-c>C", "<Cmd>LvimLang coverage<CR>", "coverage [clear]" },
        { "<C-c><C-c>g", "<Cmd>LvimLang generate<CR>", "go generate ./... [args]" },
        { "<C-c><C-c>G", "<Cmd>LvimLang get<CR>", "go get <module[@version]> | -u ./..." },
        { "<C-c><C-c>s", "<Cmd>LvimLang gotests<CR>", "gotests" },
        { "<C-c><C-c>S", "<Cmd>LvimLang gotestsum<CR>", "gotestsum" },
        { "<C-c><C-c>i", "<Cmd>LvimLang impl<CR>", "impl <receiver…> <interface>" },
        { "<C-c><C-c>m", "<Cmd>LvimLang mod<CR>", "mod tidy|download|verify|graph|why" },
        { "<C-c><C-c>T", "<Cmd>LvimLang tags<CR>", "tags <add|remove> [json|xml|…]" },
        { "<C-c><C-c>v", "<Cmd>LvimLang vet<CR>", "go vet ./... [args]" },
    },
    ["gotmpl"] = {
        { "<C-c><C-c>C", "<Cmd>LvimLang coverage<CR>", "coverage [clear]" },
        { "<C-c><C-c>g", "<Cmd>LvimLang generate<CR>", "go generate ./... [args]" },
        { "<C-c><C-c>G", "<Cmd>LvimLang get<CR>", "go get <module[@version]> | -u ./..." },
        { "<C-c><C-c>s", "<Cmd>LvimLang gotests<CR>", "gotests" },
        { "<C-c><C-c>S", "<Cmd>LvimLang gotestsum<CR>", "gotestsum" },
        { "<C-c><C-c>i", "<Cmd>LvimLang impl<CR>", "impl <receiver…> <interface>" },
        { "<C-c><C-c>m", "<Cmd>LvimLang mod<CR>", "mod tidy|download|verify|graph|why" },
        { "<C-c><C-c>T", "<Cmd>LvimLang tags<CR>", "tags <add|remove> [json|xml|…]" },
        { "<C-c><C-c>v", "<Cmd>LvimLang vet<CR>", "go vet ./... [args]" },
    },
    -- haskell
    ["haskell"] = {
        { "<C-c><C-c>C", "<Cmd>LvimLang clean<CR>", "stack clean / cabal clean [args]" },
    },
    ["lhaskell"] = {
        { "<C-c><C-c>C", "<Cmd>LvimLang clean<CR>", "stack clean / cabal clean [args]" },
    },
    -- helm
    ["helm"] = {
        { "<C-c><C-c>l", "<Cmd>LvimLang lint<CR>", "helm lint ." },
        { "<C-c><C-c>T", "<Cmd>LvimLang template<CR>", "helm template ." },
    },
    -- java
    ["java"] = {
        { "<C-c><C-c>e", "<Cmd>LvimLang extract-constant<CR>", "extract-constant" },
        { "<C-c><C-c>E", "<Cmd>LvimLang extract-method<CR>", "extract-method" },
        { "<C-c><C-c>x", "<Cmd>LvimLang extract-variable<CR>", "extract-variable" },
        { "<C-c><C-c>o", "<Cmd>LvimLang organize-imports<CR>", "jdtls: remove unused + order imports" },
    },
    -- latex
    ["tex"] = {
        { "<C-c><C-c>C", "<Cmd>LvimLang clean<CR>", "latexmk -c" },
    },
    ["plaintex"] = {
        { "<C-c><C-c>C", "<Cmd>LvimLang clean<CR>", "latexmk -c" },
    },
    ["bib"] = {
        { "<C-c><C-c>C", "<Cmd>LvimLang clean<CR>", "latexmk -c" },
    },
    -- ocaml
    ["ocaml"] = {
        { "<C-c><C-c>e", "<Cmd>LvimLang exec<CR>", "exec" },
        { "<C-c><C-c>m", "<Cmd>LvimLang fmt<CR>", "dune build @fmt --auto-promote (ocamlformat)" },
        { "<C-c><C-c>u", "<Cmd>LvimLang utop<CR>", "dune utop [dir]" },
    },
    ["ocaml.interface"] = {
        { "<C-c><C-c>e", "<Cmd>LvimLang exec<CR>", "exec" },
        { "<C-c><C-c>m", "<Cmd>LvimLang fmt<CR>", "dune build @fmt --auto-promote (ocamlformat)" },
        { "<C-c><C-c>u", "<Cmd>LvimLang utop<CR>", "dune utop [dir]" },
    },
    ["ocamllex"] = {
        { "<C-c><C-c>e", "<Cmd>LvimLang exec<CR>", "exec" },
        { "<C-c><C-c>m", "<Cmd>LvimLang fmt<CR>", "dune build @fmt --auto-promote (ocamlformat)" },
        { "<C-c><C-c>u", "<Cmd>LvimLang utop<CR>", "dune utop [dir]" },
    },
    ["menhir"] = {
        { "<C-c><C-c>e", "<Cmd>LvimLang exec<CR>", "exec" },
        { "<C-c><C-c>m", "<Cmd>LvimLang fmt<CR>", "dune build @fmt --auto-promote (ocamlformat)" },
        { "<C-c><C-c>u", "<Cmd>LvimLang utop<CR>", "dune utop [dir]" },
    },
    ["dune"] = {
        { "<C-c><C-c>e", "<Cmd>LvimLang exec<CR>", "exec" },
        { "<C-c><C-c>m", "<Cmd>LvimLang fmt<CR>", "dune build @fmt --auto-promote (ocamlformat)" },
        { "<C-c><C-c>u", "<Cmd>LvimLang utop<CR>", "dune utop [dir]" },
    },
    -- php
    ["php"] = {
        { "<C-c><C-c>a", "<Cmd>LvimLang analyse<CR>", "phpstan analyse" },
        { "<C-c><C-c>C", "<Cmd>LvimLang cs-fix<CR>", "php-cs-fixer fix" },
        { "<C-c><C-c>R", "<Cmd>LvimLang remove<CR>", "composer remove <package>" },
        { "<C-c><C-c>q", "<Cmd>LvimLang require<CR>", "require" },
        { "<C-c><C-c>s", "<Cmd>LvimLang serve<CR>", "php -S host:port" },
    },
    -- proto
    ["proto"] = {
        { "<C-c><C-c>g", "<Cmd>LvimLang generate<CR>", "buf generate" },
        { "<C-c><C-c>l", "<Cmd>LvimLang lint<CR>", "buf lint" },
    },
    -- python
    ["python"] = {
        { "<C-c><C-c>a", "<Cmd>LvimLang add<CR>", "add <package…>" },
        { "<C-c><C-c>C", "<Cmd>LvimLang check<CR>", "python -m compileall" },
        { "<C-c><C-c>g", "<Cmd>LvimLang coverage<CR>", "coverage [clear]" },
        { "<C-c><C-c>R", "<Cmd>LvimLang remove<CR>", "remove <package…>" },
        { "<C-c><C-c>n", "<Cmd>LvimLang run-module<CR>", "python -m <module> [args]" },
        { "<C-c><C-c>s", "<Cmd>LvimLang stub<CR>", "stub <import>" },
        { "<C-c><C-c>u", "<Cmd>LvimLang unittest<CR>", "unittest" },
        { "<C-c><C-c>U", "<Cmd>LvimLang update<CR>", "update [package…]" },
        { "<C-c><C-c>v", "<Cmd>LvimLang venv<CR>", "venv [create [name]]" },
    },
    -- ruby
    ["ruby"] = {
        { "<C-c><C-c>a", "<Cmd>LvimLang add<CR>", "bundle add <gem> [--version …]" },
        { "<C-c><C-c>R", "<Cmd>LvimLang rake<CR>", "rake" },
        { "<C-c><C-c>m", "<Cmd>LvimLang remove<CR>", "bundle remove <gem…>" },
        { "<C-c><C-c>B", "<Cmd>LvimLang rubocop<CR>", "rubocop [args]" },
        { "<C-c><C-c>x", "<Cmd>LvimLang rubocop-fix<CR>", "rubocop -A [args]" },
        { "<C-c><C-c>u", "<Cmd>LvimLang update<CR>", "bundle update [gem…]" },
    },
    ["eruby"] = {
        { "<C-c><C-c>a", "<Cmd>LvimLang add<CR>", "bundle add <gem> [--version …]" },
        { "<C-c><C-c>R", "<Cmd>LvimLang rake<CR>", "rake" },
        { "<C-c><C-c>m", "<Cmd>LvimLang remove<CR>", "bundle remove <gem…>" },
        { "<C-c><C-c>B", "<Cmd>LvimLang rubocop<CR>", "rubocop [args]" },
        { "<C-c><C-c>x", "<Cmd>LvimLang rubocop-fix<CR>", "rubocop -A [args]" },
        { "<C-c><C-c>u", "<Cmd>LvimLang update<CR>", "bundle update [gem…]" },
    },
    -- rust
    ["rust"] = {
        { "<C-c><C-c>a", "<Cmd>LvimLang add<CR>", "cargo add <crate[@version]> [--features …]" },
        { "<C-c><C-c>C", "<Cmd>LvimLang check<CR>", "cargo check [args]" },
        { "<C-c><C-c>l", "<Cmd>LvimLang clippy<CR>", "cargo clippy [args]" },
        { "<C-c><C-c>e", "<Cmd>LvimLang expand<CR>", "expand [item]" },
        { "<C-c><C-c>m", "<Cmd>LvimLang fmt<CR>", "cargo fmt [args]" },
        { "<C-c><C-c>n", "<Cmd>LvimLang nextest<CR>", "cargo nextest run [args]" },
        { "<C-c><C-c>R", "<Cmd>LvimLang remove<CR>", "cargo remove <crate…>" },
        { "<C-c><C-c>u", "<Cmd>LvimLang update<CR>", "cargo update [crate]" },
    },
    -- sql
    ["sql"] = {
        { "<C-c><C-c>l", "<Cmd>LvimLang lint<CR>", "sqlfluff lint <file>" },
    },
    ["mysql"] = {
        { "<C-c><C-c>l", "<Cmd>LvimLang lint<CR>", "sqlfluff lint <file>" },
    },
    ["plsql"] = {
        { "<C-c><C-c>l", "<Cmd>LvimLang lint<CR>", "sqlfluff lint <file>" },
    },
    -- svelte
    ["svelte"] = {
        { "<C-c><C-c>v", "<Cmd>LvimLang dev<CR>", "npm run dev" },
    },
    -- swift
    ["swift"] = {
        { "<C-c><C-c>C", "<Cmd>LvimLang clean<CR>", "swift package clean [args]" },
        { "<C-c><C-c>m", "<Cmd>LvimLang fmt<CR>", "swiftformat [args]" },
        { "<C-c><C-c>u", "<Cmd>LvimLang update<CR>", "swift package update" },
    },
    -- terraform
    ["terraform"] = {
        { "<C-c><C-c>P", "<Cmd>LvimLang plan<CR>", "terraform plan" },
        { "<C-c><C-c>v", "<Cmd>LvimLang validate<CR>", "terraform validate" },
    },
    ["hcl"] = {
        { "<C-c><C-c>P", "<Cmd>LvimLang plan<CR>", "terraform plan" },
        { "<C-c><C-c>v", "<Cmd>LvimLang validate<CR>", "terraform validate" },
    },
    ["tf"] = {
        { "<C-c><C-c>P", "<Cmd>LvimLang plan<CR>", "terraform plan" },
        { "<C-c><C-c>v", "<Cmd>LvimLang validate<CR>", "terraform validate" },
    },
    -- twig
    ["twig"] = {
        { "<C-c><C-c>l", "<Cmd>LvimLang lint<CR>", "djlint <file>" },
    },
    -- typescript
    ["typescript"] = {
        { "<C-c><C-c>a", "<Cmd>LvimLang add<CR>", "add <package…>" },
        { "<C-c><C-c>C", "<Cmd>LvimLang coverage<CR>", "coverage [clear]" },
        { "<C-c><C-c>v", "<Cmd>LvimLang dev<CR>", "run the `dev` script" },
        { "<C-c><C-c>i", "<Cmd>LvimLang install<CR>", "install" },
        { "<C-c><C-c>R", "<Cmd>LvimLang remove<CR>", "remove <package…>" },
        { "<C-c><C-c>s", "<Cmd>LvimLang script<CR>", "script [name]" },
        { "<C-c><C-c>T", "<Cmd>LvimLang types<CR>", "emit .d.ts declarations (tsc --declaration)" },
        { "<C-c><C-c>u", "<Cmd>LvimLang update<CR>", "update [package…]" },
    },
    ["typescriptreact"] = {
        { "<C-c><C-c>a", "<Cmd>LvimLang add<CR>", "add <package…>" },
        { "<C-c><C-c>C", "<Cmd>LvimLang coverage<CR>", "coverage [clear]" },
        { "<C-c><C-c>v", "<Cmd>LvimLang dev<CR>", "run the `dev` script" },
        { "<C-c><C-c>i", "<Cmd>LvimLang install<CR>", "install" },
        { "<C-c><C-c>R", "<Cmd>LvimLang remove<CR>", "remove <package…>" },
        { "<C-c><C-c>s", "<Cmd>LvimLang script<CR>", "script [name]" },
        { "<C-c><C-c>T", "<Cmd>LvimLang types<CR>", "emit .d.ts declarations (tsc --declaration)" },
        { "<C-c><C-c>u", "<Cmd>LvimLang update<CR>", "update [package…]" },
    },
    ["javascript"] = {
        { "<C-c><C-c>a", "<Cmd>LvimLang add<CR>", "add <package…>" },
        { "<C-c><C-c>C", "<Cmd>LvimLang coverage<CR>", "coverage [clear]" },
        { "<C-c><C-c>v", "<Cmd>LvimLang dev<CR>", "run the `dev` script" },
        { "<C-c><C-c>i", "<Cmd>LvimLang install<CR>", "install" },
        { "<C-c><C-c>R", "<Cmd>LvimLang remove<CR>", "remove <package…>" },
        { "<C-c><C-c>s", "<Cmd>LvimLang script<CR>", "script [name]" },
        { "<C-c><C-c>T", "<Cmd>LvimLang types<CR>", "emit .d.ts declarations (tsc --declaration)" },
        { "<C-c><C-c>u", "<Cmd>LvimLang update<CR>", "update [package…]" },
    },
    ["javascriptreact"] = {
        { "<C-c><C-c>a", "<Cmd>LvimLang add<CR>", "add <package…>" },
        { "<C-c><C-c>C", "<Cmd>LvimLang coverage<CR>", "coverage [clear]" },
        { "<C-c><C-c>v", "<Cmd>LvimLang dev<CR>", "run the `dev` script" },
        { "<C-c><C-c>i", "<Cmd>LvimLang install<CR>", "install" },
        { "<C-c><C-c>R", "<Cmd>LvimLang remove<CR>", "remove <package…>" },
        { "<C-c><C-c>s", "<Cmd>LvimLang script<CR>", "script [name]" },
        { "<C-c><C-c>T", "<Cmd>LvimLang types<CR>", "emit .d.ts declarations (tsc --declaration)" },
        { "<C-c><C-c>u", "<Cmd>LvimLang update<CR>", "update [package…]" },
    },
    -- typst
    ["typst"] = {
        { "<C-c><C-c>w", "<Cmd>LvimLang watch<CR>", "typst watch ${file}" },
    },
    -- unison
    ["unison"] = {
        { "<C-c><C-c>R", "<Cmd>LvimLang run-file<CR>", "run-file [main]" },
        { "<C-c><C-c>T", "<Cmd>LvimLang transcript<CR>", "transcript [file.md]" },
    },
    -- vue
    ["vue"] = {
        { "<C-c><C-c>v", "<Cmd>LvimLang dev<CR>", "npm run dev" },
    },
    -- zig
    ["zig"] = {
        { "<C-c><C-c>h", "<Cmd>LvimLang fetch<CR>", "zig fetch --save <url|path>" },
        { "<C-c><C-c>m", "<Cmd>LvimLang fmt<CR>", "zig fmt [path]" },
    },
    ["zir"] = {
        { "<C-c><C-c>h", "<Cmd>LvimLang fetch<CR>", "zig fetch --save <url|path>" },
        { "<C-c><C-c>m", "<Cmd>LvimLang fmt<CR>", "zig fmt [path]" },
    },

    -- tex has NO section here on purpose: lvim-tex owns its own `,l*` localleader set, and a
    -- plugin's internal keys live in the plugin. (This used to hold 25 `<C-c><C-c>*` chords calling
    -- `Vimtex*` commands — vimtex was replaced by lvim-tex, so every one of them was an E492.)
}

