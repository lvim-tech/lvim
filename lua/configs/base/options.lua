-- Neovim global option configuration for LVIM IDE.
-- Sets all vim.g (global) and vim.opt (option) values that define the
-- baseline editor behaviour: indentation, search, folds, UI appearance,
-- backup/undo paths and diff settings.  Called once during startup from
-- configs.base.init via options.global().

---@module "configs.base.options"

local M = {}

--- Apply all global vim.g and vim.opt settings.
--- Reads _G.LVIM.global (LvimGlobal) for cache-path locations.
---@return nil
M.global = function()
    -- vim.g ---------------------------------------------------------------
    -- Disable git-blame virtual text by default; use CursorLine highlight group.
    -- A `.tex` file with no \documentclass — a chapter, an included preamble fragment — is detected as
    -- `plaintex`, which is a DIFFERENT language: texlab is wired for `tex`, so such a file would open
    -- with no LSP at all. Every .tex here is LaTeX; say so once, before filetype detection runs.
    vim.g.tex_flavor = "latex"

    -- netrw: hide the banner, single-level listing, 20-column side window.
    vim.g.netrw_banner = 0
    vim.g.netrw_hide = 1
    vim.g.netrw_browse_split = 0
    vim.g.netrw_altv = 1
    vim.g.netrw_liststyle = 1
    vim.g.netrw_winsize = 20
    vim.g.netrw_keepdir = 1
    vim.g.netrw_list_hide = [[\(^\|\s\s\)\zs\.\S\+]]
    vim.g.netrw_localcopydircmd = "cp -r"

    -- vim.opt -------------------------------------------------------------
    -- Allow per-project .nvim.lua / .exrc files; enforce secure mode for them.
    vim.opt.exrc = true
    vim.opt.secure = true
    -- Keep the viewport stable when splitting horizontally.
    vim.opt.splitkeep = "screen"
    -- Custom cursor shapes per mode (block in normal/visual, bar in insert).
    vim.opt.guicursor = "n-v-c:block-Cursor/lCursor,i-ci-ve:ver25-Cursor/lCursor,r-cr:hor20,o:hor50"
    -- Suppress common informational messages to reduce noise.
    vim.opt.shortmess = "ltToOCFI"
    -- NO `termguicolors` HERE — lvim-colorscheme owns it (theme.lua turns it on as part of applying
    -- the theme). Setting it this early puts the TUI into RGB mode ~70ms before any highlight group
    -- exists, and in that window the statusline (whose built-in default is `reverse`) has no `Normal`
    -- to reverse against, so nvim emits an explicit fg/bg of #000000: a black band across the bottom
    -- rows that flashes until the colorscheme lands. Leave it to the colorscheme.
    -- Enable mouse in normal and visual modes only.
    vim.opt.mouse = "nv"
    vim.opt.mousemodel = "extend"
    vim.opt.errorbells = true
    vim.opt.visualbell = true
    vim.opt.hidden = true
    vim.opt.fileformats = "unix,mac,dos"
    vim.opt.magic = true
    -- Allow blockwise virtual editing beyond line ends.
    vim.opt.virtualedit = "block"
    vim.opt.encoding = "utf-8"
    vim.opt.viewoptions = "folds,cursor,curdir,slash,unix"
    vim.opt.sessionoptions = "curdir,help,tabpages,winsize"
    -- Use the system clipboard for all yank/put operations.
    vim.opt.clipboard = "unnamedplus"
    vim.opt.wildignorecase = true
    vim.opt.wildmenu = true
    -- Complete the longest common prefix first, then cycle the full list, shown in a popup menu.
    vim.opt.wildmode = "longest:full,full"
    vim.opt.wildoptions = "pum,tagfile"
    -- Exclude generated files, binaries and dependency trees from wildmenu.
    vim.opt.wildignore =
        ".git,.hg,.svn,*.pyc,*.o,*.out,*.jpg,*.jpeg,*.png,*.gif,*.zip,**/tmp/**,*.DS_Store,**/node_modules/**,**/bower_modules/**"
    -- Disable all backup/swap files; rely on undofile instead.
    vim.opt.backup = false
    vim.opt.writebackup = false
    vim.opt.swapfile = false
    -- Store swap, undo, backup and view files under the unified cache path.
    vim.opt.directory = _G.LVIM.global.cache_path .. "/swag/"
    vim.opt.undodir = _G.LVIM.global.cache_path .. "/undo/"
    vim.opt.backupdir = _G.LVIM.global.cache_path .. "/backup/"
    vim.opt.viewdir = _G.LVIM.global.cache_path .. "/view/"
    vim.opt.history = 2000
    -- shada: include globals, 300 marks, 50 registers, 100 input history, 1 MB items.
    vim.opt.shada = "!,'300,<50,@100,s1000,h,c"
    vim.opt.backupskip = "/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*,*/shm/*,/private/var/*,.vault.vim"
    vim.opt.smarttab = true
    -- Round indents to multiples of shiftwidth.
    vim.opt.shiftround = true
    -- Fast CursorHold events and plugin refresh (100 ms).
    vim.opt.updatetime = 100
    vim.opt.redrawtime = 1500
    -- Search: live preview while typing, matches stay lit after <CR>, case-insensitive unless the
    -- pattern carries an uppercase letter, and wrapping at the end of the file.
    vim.opt.incsearch = true
    vim.opt.hlsearch = true
    vim.opt.ignorecase = true
    vim.opt.smartcase = true
    vim.opt.wrapscan = true
    vim.opt.infercase = true
    vim.opt.complete = ".,w,b,k"
    -- Show substitution results live without a split window.
    vim.opt.inccommand = "nosplit"
    vim.opt.grepformat = "%f:%l:%c:%m"
    -- Use ripgrep as the :grep backend.
    vim.opt.grepprg = "rg --hidden --vimgrep --smart-case --"
    vim.opt.breakat = [[\ \	;:,!?]]
    -- Do not jump to the first non-blank when moving between lines.
    vim.opt.startofline = false
    vim.opt.whichwrap = "h,l,<,>,[,],~"
    vim.opt.splitbelow = true
    vim.opt.splitright = true
    -- Reuse an already-open window when switching buffers.
    vim.opt.switchbuf = "useopen"
    vim.opt.backspace = "indent,eol,start"
    -- vim.opt.diffopt = "internal,filler,closeoff,indent-heuristic,linematch:60,algorithm:histogram"
    -- Use a stack-based jump list so <C-o>/<C-i> behave like a browser.
    vim.opt.jumpoptions = "stack"
    -- Hide the mode indicator (shown by the status line instead).
    vim.opt.showmode = false
    -- Keep at least 2 context lines above/below the cursor.
    vim.opt.scrolloff = 2
    vim.opt.sidescrolloff = 5
    -- Start with all folds open.
    vim.opt.foldlevelstart = 99
    vim.opt.ruler = false
    -- Whitespace hidden by default — matches the Control Center "Show whitespace characters"
    -- toggle (the 'list' option, which defaults to off). Enabling it reveals the glyphs below.
    vim.opt.list = false
    -- Show the tabline only when there are multiple tabs.
    vim.opt.showtabline = 1
    vim.opt.winwidth = 30
    vim.opt.winminwidth = 10
    vim.opt.pumheight = 15
    vim.opt.helpheight = 12
    vim.opt.previewheight = 12
    vim.opt.showcmd = false
    -- Hide the command line when not typing; reclaimed screen space.
    vim.opt.cmdheight = 0
    vim.opt.cmdwinheight = 5
    -- Do not equalize window sizes after split/close.
    vim.opt.equalalways = false
    -- Global status line (one bar for all windows).
    vim.opt.laststatus = 3
    vim.opt.display = "lastline"
    -- Soft-wrap indicator shown at the start of continuation lines.
    vim.opt.showbreak = "↳  "
    -- Visible glyphs for whitespace, so enabling 'list' ("Show whitespace characters")
    -- actually reveals tabs / trailing / nbsp / spaces instead of rendering them as blanks.
    vim.opt.listchars = "tab:» ,nbsp:␣,trail:·,space:·,extends:→,precedes:←"
    -- vim.opt.fillchars = "eob: ,fold:─"
    -- Disable popup-menu and window transparency.
    vim.opt.pumblend = 0
    vim.opt.winblend = 0
    -- Persist undo history across sessions.
    vim.opt.undofile = true
    -- Stop syntax highlighting for very long lines to keep performance.
    vim.opt.synmaxcol = 2500
    -- Format options: auto-wrap comments, continue comment leaders, allow join.
    vim.opt.formatoptions = "1jcroql"
    vim.opt.textwidth = 120
    vim.opt.expandtab = true
    vim.opt.autoindent = true
    vim.opt.tabstop = 4
    vim.opt.shiftwidth = 4
    -- softtabstop = -1 means follow shiftwidth.
    vim.opt.softtabstop = -1
    vim.opt.breakindentopt = "shift:2,min:20"
    vim.opt.wrap = true
    vim.opt.linebreak = true
    vim.opt.number = true
    vim.opt.relativenumber = true
    -- Minimum number-column width = 1. With a custom 'statuscolumn' (heirline) that draws and
    -- pads the numbers itself, the default numberwidth (4) would still reserve 4 cells whenever
    -- 'relativenumber' is on — and the column's `%=` align fills that reservation, leaving an
    -- empty gap before the git bar even when "Show line numbers" is off. numberwidth=1 removes
    -- the reservation so the gutter is identical regardless of 'relativenumber'.
    vim.opt.numberwidth = 1
    vim.opt.foldenable = true
    vim.opt.cursorline = true
    vim.opt.cursorcolumn = true
    -- Hide the sign column; diagnostics/git signs use extmarks instead.
    vim.opt.signcolumn = "no"
    -- Stays 80. lvim-indent's `column` block draws the ruler as a CHARACTER and blanks the
    -- window-local option itself (`own_option`), so this value keeps saying WHERE the ruler is
    -- while Neovim's background band never appears. Set `column.enabled = false` there to get the
    -- built-in band back — nothing here has to change for that.
    vim.opt.colorcolumn = "80"
    -- Conceal level 2: replace concealed text with cchar, hides markup in Markdown etc.
    vim.opt.conceallevel = 2
    vim.opt.fillchars = {
        diff = "╱", -- diagonal slash for removed diff regions
        eob = " ", -- hide the ~ end-of-buffer markers
        -- Window separators: a space instead of the box-drawing glyph, so each separator cell is a SOLID
        -- bar of the WinSeparator background with no thin line rendered inside it.
        vert = " ",
        horiz = " ",
        horizup = " ",
        horizdown = " ",
        vertleft = " ",
        vertright = " ",
        verthoriz = " ",
    }
    -- Diff options: histogram algorithm with aggressive line-matching.
    vim.opt.diffopt = {
        "internal",
        "filler",
        "closeoff",
        "vertical",
        "context:100",
        "algorithm:histogram",
        "linematch:100",
        "indent-heuristic",
    }
end

return M
