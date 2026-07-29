# Languages

Languages are owned by **lvim-lang**, not by a table in this repository. One provider declares
everything about a language in one place — its language server(s), how the project root is found, the
formatter and linter wiring, and, where such a thing genuinely exists, the debug adapter, the test
runner and the build recipe. `lvim-lsp` attaches the servers those providers declare, and `lvim-pkg`
installs the tools the first time they are needed.

## The model

```
lvim-lang provider          declares: filetypes, root markers, servers, tools, run/build/test/debug
      │
      ├──► lvim-lsp / lvim-ls   attach the server, own diagnostics / outline / peek / code actions
      ├──► lvim-pkg             install the server, the parser, the formatter, the linter, the adapter
      ├──► lvim-dap             the debug adapter and its configurations
      ├──► lvim-build           the build / run recipe
      └──► lvim-test            the test adapter
```

Providers come in two shapes, registered identically:

- **a directory per language** for the ones with real toolchain behaviour — run, test, debug, SDK
  management, dependency commands (Rust, Go, Dart, Python, TypeScript, the C family, Java, …);
- **a declarative data file** for the ones that are "a language server and its root markers".

## Asking the editor

The live set is the authority — a list in a file ages, the editor does not.

| Command | Answers |
|---|---|
| `:LvimLang providers` | every registered provider and the filetypes it claims |
| `:LvimLang status` | what is active for this buffer — provider, servers, tools, toolchain |
| `:LvimLang toolchain` | the SDK / toolchain the provider resolved for this project |
| `:checkhealth lvim-lang` | the same, plus which of its tools are actually installed |
| `:LvimLsp info` | the attached clients, their capabilities and this buffer's diagnostics |

## Installing what a language needs

Opening a file whose tools are missing offers to install them — **Space** toggles an entry, **Enter**
installs, `q` / `Esc` skips for five minutes. Nothing is installed behind your back, and nothing is
downloaded until a buffer of that type is opened.

`:LvimInstaller` is the same catalogue as a browser: LSP servers, debug adapters, linters, formatters,
runtimes, compilers and treesitter parsers, each showing what is installed and what is available.

## Per-project overrides

| File (at the project root) | What it overrides |
|---|---|
| `.lvim-lsp/config.lua` | LSP features for this project (`auto_format`, `inlay_hints`, `code_lens`, …) |
| `.lvim-ls/servers/<name>.lua` | one server's settings for this project |
| `.lvim/lang/run.lua` | the active run configuration a provider's `run` uses |
| `nvim-dap.lua` | project-local debug adapters and configurations |

`:LvimLsp reattach` applies an LSP override immediately, without restarting.

## Global LSP feature flags

Change them live from `:LvimControlCenter lsp`, or in code:

```lua
-- this session only
require("lvim-lsp.state").config.features.auto_format = false

-- persisted across restarts
require("lvim-lsp.core.globals").save({ auto_format = false })
```

## The providers

**92 providers**, covering **150 filetypes** and **94 distinct language servers**.
The last column is what the provider itself can *do* beyond editing — `run`, `build`, `test` and
`debug` appear only where a real implementation exists, never as a stub to pad the table.

| Provider | Filetypes | Language server(s) | Also provides |
|---|---|---|---|
| **ada** | `ada` | `ada-language-server` | build, test |
| **ansible** | `yaml.ansible`, `ansible` | `ansible-language-server` | — |
| **assembly** | `asm`, `nasm` | `asm-lsp` | — |
| **astro** | `astro` | `astro-language-server` | build |
| **awk** | `awk` | `awk-language-server` | run |
| **bash** | `sh`, `bash` | `bash-language-server` | run |
| **cairo** | `cairo` | `cairo-language-server` | build, test |
| **clojure** | `clojure`, `edn` | `clojure-lsp` | run, test |
| **cmake** | `cmake` | `cmake-language-server` | build |
| **cobol** | `cobol` | `superbol` | build |
| **commonlisp** | `lisp` | `cl-lsp` | run, test |
| **coq** | `coq` | `coq-lsp` | — |
| **cpp** | `c`, `cpp`, `objc`, `objcpp` | `clangd` | run, build, test, debug |
| **crystal** | `crystal` | `crystalline` | run, build, test |
| **csharp** | `cs` | `omnisharp` | run, build, test, debug |
| **css** | `css`, `scss`, `less`, `sass` | `css-lsp` | — |
| **cue** | `cue` | `cuelsp` | — |
| **d** | `d` | `serve-d` | run, build, test |
| **dart** | `dart` | `dart` | run, build, test |
| **dockerfile** | `dockerfile` | `dockerfile-language-server` | build |
| **elixir** | `elixir`, `eelixir`, `heex` | `elixir-ls` | run, test, debug |
| **elm** | `elm` | `elm-language-server` | build, test |
| **erlang** | `erlang` | `erlang-ls` | test |
| **fish** | `fish` | `fish-lsp` | run |
| **fortran** | `fortran` | `fortls` | run, build, test |
| **fsharp** | `fsharp` | `fsautocomplete` | run, build, test, debug |
| **gdscript** | `gdscript` | `gdscript` | — |
| **gleam** | `gleam` | `gleam` | run, build, test |
| **glsl** | `glsl`, `vert`, `frag`, `geom`, `comp`, `tesc`, `tese` | `glsl_analyzer` | — |
| **go** | `go`, `gomod`, `gowork`, `gotmpl` | `gopls` | run, build, test, debug |
| **grain** | `grain` | `grain` | run, build |
| **graphql** | `graphql`, `gql` | `graphql` | — |
| **groovy** | `groovy` | `groovy-language-server` | run, build, test |
| **hare** | `hare` | `hare-lsp` | run, build, test |
| **haskell** | `haskell`, `lhaskell` | `haskell-language-server` | run, build, test, debug |
| **helm** | `helm` | `helm-ls` | — |
| **html** | `html` | `html-lsp` | — |
| **java** | `java` | `jdtls` | run, build, test, debug |
| **json** | `json`, `jsonc`, `json5` | `json-lsp` | — |
| **jsonnet** | `jsonnet`, `libsonnet` | `jsonnet-language-server` | run |
| **julia** | `julia` | `julia-lsp` | run, test |
| **kotlin** | `kotlin` | `kotlin-language-server` | run, build, test, debug |
| **latex** | `tex`, `plaintex`, `bib` | `texlab` | build |
| **lean** | `lean` | `leanls` | build |
| **lua** | `lua` | `lua-language-server` | run, test |
| **markdown** | `markdown`, `markdown.mdx`, `mdx` | `marksman` | — |
| **matlab** | `matlab`, `octave` | `matlab-language-server` | run |
| **move** | `move` | `move-analyzer` | build, test |
| **nextflow** | `nextflow` | `nextflow-language-server` | run |
| **nginx** | `nginx` | `nginx-language-server` | test |
| **nim** | `nim`, `nims`, `nimble` | `nimlangserver` | run, build, test |
| **nix** | `nix` | `nil` | build |
| **nushell** | `nu` | `nushell` | run |
| **ocaml** | `ocaml`, `ocaml.interface`, `ocamllex`, `menhir`, `dune` | `ocaml-lsp` | run, build, test, debug |
| **odin** | `odin` | `ols` | run, build, test |
| **pascal** | `pascal` | `pasls` | run, build |
| **perl** | `perl` | `perlnavigator` | run, test |
| **php** | `php` | `intelephense` | run, test, debug |
| **powershell** | `ps1` | `powershell-editor-services` | — |
| **prolog** | `prolog` | `swipl-lsp` | run |
| **proto** | `proto` | `protols` | build |
| **purescript** | `purescript` | `purescript-language-server` | build, test |
| **python** | `python` | `basedpyright`, `ruff` | run, test, debug |
| **r** | `r`, `rmd` | `r-languageserver` | run, test |
| **racket** | `racket`, `scheme` | `racket-langserver` | run, build, test |
| **rescript** | `rescript` | `rescript-language-server` | run, build |
| **roc** | `roc` | `roc_language_server` | run, build, test |
| **ruby** | `ruby`, `eruby` | `ruby-lsp` | run, test, debug |
| **rust** | `rust` | `rust-analyzer` | run, build, test, debug |
| **scala** | `scala`, `sbt` | `metals` | run, build, test, debug |
| **solidity** | `solidity` | `nomicfoundation-solidity-language-server` | build, test |
| **sql** | `sql`, `mysql`, `plsql` | `sqls` | — |
| **starlark** | `bzl`, `starlark` | `starpls` | build, test |
| **svelte** | `svelte` | `svelte-language-server` | build |
| **swift** | `swift` | `sourcekit-lsp` | run, build, test, debug |
| **systemverilog** | `verilog`, `systemverilog` | `verible-verilog-ls` | — |
| **tcl** | `tcl` | `tclsp` | run |
| **terraform** | `terraform`, `hcl`, `tf` | `terraform-ls` | — |
| **toml** | `toml` | `taplo` | — |
| **twig** | `twig` | `twiggy` | — |
| **typescript** | `typescript`, `typescriptreact`, `javascript`, `javascriptreact` | `eslint`, `vtsls` | run, build, test, debug |
| **typst** | `typst` | `tinymist` | build |
| **unison** | `unison` | `unison` | run |
| **v** | `vlang`, `v` | `v-analyzer` | run, build, test |
| **vala** | `vala` | `vala-language-server` | run, build |
| **vhdl** | `vhdl` | `rust_hdl` | — |
| **vim** | `vim` | `vim-language-server` | — |
| **vue** | `vue` | `vue-language-server` | build |
| **wgsl** | `wgsl` | `wgsl-analyzer` | — |
| **xml** | `xml`, `xsd`, `xsl`, `xslt`, `svg` | `lemminx` | — |
| **yaml** | `yaml`, `yaml.docker-compose`, `yaml.gitlab` | `yaml-language-server` | — |
| **zig** | `zig`, `zir` | `zls` | run, build, test, debug |

## Adding a language

A provider is the whole story — there is no second place to register it. Write a declarative data
file when the language is "a server and its roots", or a directory provider when it has a toolchain
worth driving. A language that also gets a build recipe and a test adapter needs the matching entries
in lvim-build and lvim-test: three independent systems, kept consistent on purpose.
