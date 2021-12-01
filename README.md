# LVIM IDE

![LVIM IDE](https://github.com/lvim-tech/lvim/blob/production/media/lvim-ide-logo.png)

[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://github.com/lvim-tech/lvim/blob/production/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/lvim-tech/lvim.svg?style=social&label=Star)](https://github.com/lvim-tech/lvim/stargazers/)
[![Requires](https://img.shields.io/badge/requires-nvim%200.5%2B-9cf?logo=neovim)](https://neovim.io//)
[![GitHub contributors](https://img.shields.io/github/contributors/lvim-tech/lvim.svg)](https://github.com/lvim-tech/lvim/graphs/contributors/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)
[![GitHub issues](https://img.shields.io/github/issues/lvim-tech/lvim.svg)](https://github.com/lvim-tech/lvim/issues/)
[![GitHub issues-closed](https://img.shields.io/github/issues-closed/lvim-tech/lvim.svg)](https://github.com/lvim-tech/lvim/issues?q=is%3Aissue+is%3Aclosed)

## LVIM IDE is a modular Neovim configuration written in LUA with full customization

-   Now support Neovim 0.5.0, 0.5.1, 0.6.0+
-   Add or remove plugins, rewrite all plugins
-   Add or remove settings, rewrite all settings
-   Dynamic LSP activation
-   Dynamic debugging activation - Dap
-   Automaticaly install of the lsp servers and dap
-   Linters
-   Autoformat
-   Custom settings for projects
-   67 plugins
-   Loading time - ~065.000

---

![lvim-logo](https://github.com/lvim-tech/lvim/blob/production/media/lvim-ide-screenshot.png?v1.1.0)

---

For detail info see [wiki](https://github.com/lvim-tech/lvim/wiki) - `6500+` lines of instructions and code

## [YouTube](https://www.youtube.com/channel/UCSV5_UXKLl1JDZbQaYWuFKQ) channel

## Requirements

-   [neovim >=0.5.0](https://github.com/neovim/neovim/wiki/Installing-Neovim)
-   [pynvim](https://github.com/neovim/pynvim)
-   [neovim-remote](https://github.com/mhinz/neovim-remote)
-   [nodejs](https://nodejs.org/en/)
-   [ripgrep](https://github.com/BurntSushi/ripgrep)
-   [fzf](https://github.com/junegunn/fzf)
-   [rsync](https://github.com/WayneD/rsync)

## Current version - 1.2.0

Install:

```bash
git clone https://github.com/lvim-tech/lvim.git ~/.config/nvim
```

> Important: If you installed the LVIM IDE before version 1.0.0 - I recommend a clean installation

```bash
rm -rf ~/.config/nvim
rm -rf ~/.cache/nvim
rm -rf ~/.local/share/nvim
git clone https://github.com/lvim-tech/lvim.git ~/.config/nvim
```
