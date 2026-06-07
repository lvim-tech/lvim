-- Neovim global option configuration for LVIM IDE.
-- Sets all vim.g (global) and vim.opt (option) values that define the
-- baseline editor behaviour: indentation, search, folds, UI appearance,
-- backup/undo paths and diff settings.  Called once during startup from
-- configs.base.init via options.global().

---@module "configs.base.options"

require("configs.base.ui.fold")

local M = {}

--- Apply all global vim.g and vim.opt settings.
--- Reads _G.LVIM.global (LvimGlobal) for cache-path locations.
---@return nil
M.global = function()
    -- vim.g ---------------------------------------------------------------
    -- Disable git-blame virtual text by default; use CursorLine highlight group.
    vim.g.gitblame_enabled = 0
    vim.g.gitblame_highlight_group = "CursorLine"
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
    vim.opt.termguicolors = true
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
    -- Case-insensitive search unless the pattern contains uppercase letters.
    vim.opt.ignorecase = true
    vim.opt.smartcase = true
    vim.opt.infercase = true
    vim.opt.incsearch = true
    -- Wrap around file end when searching.
    vim.opt.wrapscan = true
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
    vim.opt.completeopt = "menu,menuone,noselect"
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
    -- Show invisible characters (defined below in listchars).
    vim.opt.list = true
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
    -- Render tabs and special whitespace as spaces (visually clean).
    vim.opt.listchars = "tab:  ,nbsp: ,trail: ,space: ,extends:→,precedes:←"
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
    vim.opt.foldenable = true
    vim.opt.cursorline = true
    vim.opt.cursorcolumn = true
    -- Hide the sign column; diagnostics/git signs use extmarks instead.
    vim.opt.signcolumn = "no"
    vim.opt.colorcolumn = "80"
    -- Conceal level 2: replace concealed text with cchar, hides markup in Markdown etc.
    vim.opt.conceallevel = 2
    -- Use Tree-sitter expressions for fold detection.
    vim.opt.foldmethod = "expr"
    vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    -- Custom fold text renderer defined in configs.base.ui.fold.
    vim.opt.foldtext = "v:lua.fold_text()"
    vim.opt.fillchars = {
        diff = "╱", -- diagonal slash for removed diff regions
        eob = " ", -- hide the ~ end-of-buffer markers
        fold = "─", -- horizontal bar for fold fill
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
