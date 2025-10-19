# LVIM IDE

![LVIM IDE](/assets/lvim-ide-logo.png)

## DESCRIPTION

> LVIM IDE is a modular Neovim configuration written in LUA with full customization

- LSP support for 20+ languages
- Debug support for c, cpp, dart, go, javascript/typescript, lua, php, python, rust, scala
- Linters with efm ("cpplint", "golangci-lint", "black", "yamllint", "vint")
- Formatters with efm ("stylua", "yamlfmt", "shfmt", "cbfmt", "prettierd")
- Automatically install dependencies (lsp servers, linters, formatters, debbugers) by filetype

> Current version - 7.6.1 (2025-10-19)

## INTRODUCTION

- Neovim 0.11.4+ (for NEOVIM < 0.11.4 use branch NEOVIM-0.11)
- Add or remove settings, rewrite all settings
- Add or remove plugins, rewrite all plugins
- Dynamic LSP activation
- Dynamic debugging activation - DAP
- Autoinstall the LSP servers, DAP servers, linters, and formatters
- Custom settings for projects

## REQUIREMENTS

- [neovim >= 0.11.4](https://github.com/neovim/neovim)
- [pynvim](https://github.com/neovim/pynvim)
- [neovim-remote](https://github.com/mhinz/neovim-remote)
- [node](https://github.com/nodejs/node)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [sed](https://github.com/mirror/sed)
- [fzf](https://github.com/junegunn/fzf)
- [git](https://github.com/git/git)
- [curl](https://github.com/curl/curl)
- [wget](https://www.gnu.org/software/wget/)
- [tar](https://www.gnu.org/software/tar/)
- [gzip](https://www.gnu.org/software/gzip/)
- [nerd](https://github.com/ryanoasis/nerd-fonts)

## INSTALL

```sh
git clone https://github.com/lvim-tech/lvim.git ~/.config/nvim
```

## LVIM CONTROL CENTER

```lua
:LvimControlCenter
```

## USER CONFIGS

### EDITOR

- Disable base config function

```lua
-- lua/configs/user/init.lua
configs["base_vim"] = false -- disable function "base_vim" from "lua/configs/base/init.lua"
```

- Rewrite base config function

```lua
-- lua/configs/user/init.lua
configs["base_vim"] = { -- rewrite function "base_vim" from "lua/configs/base/init.lua"
    -- your code
}
```

- Add user config function

```lua
-- lua/configs/user/init.lua
configs["user_vim"] = { -- add user function
    -- your code
}
```

### MODULES/PLUGINS

- Disable base plugin

```lua
-- lua/modules/user/init.lua
modules["name_of_your/plugin"] = false -- disable plugin
```

- Rewrite settings of base plugin

```lua
-- lua/modules/user/init.lua
modules["name_of_your/plugin"] = { -- rewrite settings of plugin
    -- your code
}
```

- Add new plugin

```lua
-- lua/modules/user/init.lua
modules["name_of_your/plugin"] = { -- add new plugin
    -- your code
}
```

### LSP (Languages)

> Extend/Rewrite/Remove LSP support for filetypes

1. First step - set filetypes:

- Disable filetypes

```lua
-- lua/languages/user/filetypes.lua
["shell"] = {} -- disable shell support
```

- Rewrite filetypes

```lua
-- lua/languages/user/filetypes.lua
["shell"] = { -- add support for shell
    "sh",
    "bash",
    "zsh"
}
```

- Add filetypes

```lua
-- lua/languages/user/filetypes.lua
["shell"] = { -- add support for shell (if shell not defined in "lua/languages/base/ft.lua")
    "sh",
    "bash",
    "zsh",
    "csh",
    "ksh"
}
```

2. Second step:

- Base settings - in folder `lua/languages/base/languages` (file name == language :: `shell` -> `shell.lua`)

- Rewrite settings - put file with same name in folder `lua/languages/user/languages`

- Add settings for new language - put file with same name in folder `lua/languages/user/languages`
