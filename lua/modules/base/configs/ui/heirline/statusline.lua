-- Heirline statusline configuration.
-- Builds the full statusline component tree rendered at the bottom of every
-- regular window.  Left-to-right layout:
--   vi-mode pill | cwd | filename + icon + size + readonly/modified indicators
--   | git branch + diff stats | git hunk position | macro recording indicator
--   (align) | diagnostics | LSP/linter/formatter names | filetype | encoding
--   | line format | spell | word count | ruler | scrollbar
-- All components read colours from _G.LVIM.colors (LvimColors).

---@module "modules.base.configs.ui.heirline.statusline"

local icons = require("configs.base.ui.icons")
local mason_registry = require("mason-registry")

local M = {}

-- Builds and returns the heirline statusline component table.
-- Called once during heirline setup; all sub-components are defined inline.
---@return table  Heirline statusline component ready for heirline.setup()
M.get_statusline = function()
    local funcs = require("core.funcs")
    local heirline_conditions = require("heirline.conditions")
    local heirline_utils = require("heirline.utils")

    -- Horizontal padding primitive
    local space = { provider = " " }
    -- Right-align separator; everything after this floats to the far right
    local align = { provider = "%=" }

    -- Shows the buffer's filetype in uppercase (green, bold)
    ---@type table  Heirline component
    local file_types = {
        ---@return string|nil  Uppercased filetype, or nil for unnamed buffers
        provider = function()
            local file_type = vim.bo.filetype
            if file_type ~= "" then
                return "  " .. string.upper(file_type)
            end
        end,
        hl = { fg = _G.LVIM.colors.green, bold = true },
    }

    -- -------------------------------------------------------------------------
    -- vi_mode: mode pill with mode-specific background colour
    -- -------------------------------------------------------------------------

    ---@type table  Heirline component for the vi-mode indicator
    local vi_mode = {
        ---@param self table  Sets self.mode to the full mode string
        init = function(self)
            self.mode = vim.fn.mode(1)
            if not self.once then
                -- Ensure statusline redraws when entering operator-pending sub-modes
                vim.api.nvim_create_autocmd("ModeChanged", {
                    pattern = "*:*o",
                    command = "redrawstatus",
                })
                self.once = true
            end
        end,
        static = {
            -- Short display labels for every Vim mode code
            ---@type table<string, string>
            mode_names = {
                n = "N",
                no = "N?",
                nov = "N?",
                noV = "N?",
                ["no\22"] = "N?",
                niI = "Ni",
                niR = "Nr",
                niV = "Nv",
                nt = "Nt",
                v = "V",
                vs = "Vs",
                V = "V_",
                Vs = "Vs",
                ["\22"] = "^V",
                ["\22s"] = "^V",
                s = "S",
                S = "S_",
                ["\19"] = "^S",
                i = "I",
                ic = "Ic",
                ix = "Ix",
                R = "R",
                Rc = "Rc",
                Rx = "Rx",
                Rv = "Rv",
                Rvc = "Rv",
                Rvx = "Rv",
                c = "C",
                cv = "Ex",
                r = "...",
                rm = "M",
                ["r?"] = "?",
                ["!"] = "!",
                t = "T",
            },
            -- Background colour for the mode pill, keyed by the first mode character
            ---@type table<string, string>
            mode_colors = {
                n = _G.LVIM.colors.green,
                i = _G.LVIM.colors.red,
                v = _G.LVIM.colors.orange,
                V = _G.LVIM.colors.orange,
                ["\22"] = _G.LVIM.colors.orange,
                c = _G.LVIM.colors.purple,
                s = _G.LVIM.colors.purple,
                S = _G.LVIM.colors.purple,
                ["\19"] = _G.LVIM.colors.purple,
                R = _G.LVIM.colors.cyan,
                r = _G.LVIM.colors.cyan,
                ["!"] = _G.LVIM.colors.cyan,
                t = _G.LVIM.colors.blue,
            },
        },
        ---@param self table  Component self (has self.mode, self.mode_names)
        ---@return string     Rendered mode label with surrounding spaces
        provider = function(self)
            return " " .. icons.common.vim .. " " .. " %(" .. self.mode_names[self.mode] .. "%)  "
        end,
        ---@param self table  Component self
        ---@return table      Highlight spec { bg, fg, bold }
        hl = function(self)
            -- Sync the global mode so other components can read it without re-querying
            _G.LVIM.mode = self.mode:sub(1, 1)
            return {
                bg = self.mode_colors[self.mode:sub(1, 1)],
                -- On dark backgrounds use bg colour for text; on light use fg
                fg = vim.o.background == "dark" and _G.LVIM.colors.bg or _G.LVIM.colors.fg,
                bold = true,
            }
        end,
        update = { "ModeChanged", "MenuPopup", "CmdlineEnter", "CmdlineLeave" },
    }

    -- -------------------------------------------------------------------------
    -- file_name_block: container for filename + icon + size + flags
    -- -------------------------------------------------------------------------

    ---@type table  Parent block; sub-components are inserted via heirline_utils.insert
    local file_name_block = {
        ---@param self table  Sets self.filename for child components
        init = function(self)
            self.filename = vim.api.nvim_buf_get_name(0)
        end,
    }

    -- -------------------------------------------------------------------------
    -- work_dir: current working directory with folder icon
    -- -------------------------------------------------------------------------

    ---@type table  Heirline component that shows the CWD
    local work_dir = {
        ---@return string  Folder icon + shortened CWD path ending in "/"
        provider = function()
            local icon = " " .. icons.common.folder_empty .. " "
            local cwd = vim.fn.getcwd(0)
            -- Collapse $HOME to ~
            cwd = vim.fn.fnamemodify(cwd, ":~")
            -- Shorten path components when CWD takes more than 25% of the line
            if not heirline_conditions.width_percent_below(#cwd, 0.25) then
                cwd = vim.fn.pathshorten(cwd)
            end
            -- Always append a trailing slash for visual clarity
            local trail = cwd:sub(-1) == "/" and "" or "/"
            return icon .. cwd .. trail
        end,
        hl = { fg = _G.LVIM.colors.blue, bold = true },
        on_click = {
            -- Clicking the CWD opens Neo-tree on the left
            callback = function()
                vim.cmd("Neotree position=left")
            end,
            name = "heirline_browser",
        },
    }

    -- -------------------------------------------------------------------------
    -- file_name: relative path of the current file
    -- -------------------------------------------------------------------------

    ---@type table  Heirline component that renders the filename
    local file_name = {
        ---@param self table   Component self (has self.filename from file_name_block)
        ---@return string|nil  Relative path, optionally shortened, or nil for scratch buffers
        provider = function(self)
            local filename = vim.fn.fnamemodify(self.filename, ":.")
            if filename == "" then
                return
            end
            -- Shorten path components when the filename exceeds 25% of the line width
            if not heirline_conditions.width_percent_below(#filename, 0.25) then
                filename = vim.fn.pathshorten(filename)
            end
            return filename .. " "
        end,
        ---@return table  Highlight spec using the current vi-mode colour
        hl = function()
            return {
                fg = vi_mode.static.mode_colors[_G.LVIM.mode],
                bold = true,
            }
        end,
    }

    -- -------------------------------------------------------------------------
    -- file_icon: devicon glyph for the current file
    -- -------------------------------------------------------------------------

    ---@type table  Heirline component for the file devicon
    local file_icon = {
        ---@param self table  Sets self.icon and self.icon_color from nvim-web-devicons
        init = function(self)
            local filename = self.filename
            local extension = vim.fn.fnamemodify(filename, ":e")
            self.icon, self.icon_color =
                require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
        end,
        ---@param self table   Component self
        ---@return string|nil  Icon glyph surrounded by spaces, or nil when not available
        provider = function(self)
            return self.icon and (" " .. self.icon .. " ")
        end,
        ---@param self table  Component self
        ---@return table      Highlight spec using the devicon's own colour
        hl = function(self)
            return { fg = self.icon_color, bold = true }
        end,
    }

    -- -------------------------------------------------------------------------
    -- file_size: human-readable buffer size
    -- -------------------------------------------------------------------------

    ---@type table  Heirline component that shows the file size
    local file_size = {
        ---@return string|nil  Formatted file size string, or nil for empty buffers
        provider = function()
            local fsize = vim.fn.getfsize(vim.api.nvim_buf_get_name(0))
            -- getfsize returns -1 for very large files; clamp to 0
            fsize = (fsize < 0 and 0) or fsize
            if fsize <= 0 then
                return
            end
            ---@type string  Human-readable size (e.g. "12.3 KB") from core.funcs
            local file_size = require("core.funcs").file_size(fsize)
            return " " .. file_size .. " "
        end,
        hl = { fg = _G.LVIM.colors.blue },
    }

    -- -------------------------------------------------------------------------
    -- file_readonly / file_modified: buffer state indicators
    -- -------------------------------------------------------------------------

    ---@type table  Heirline component for the lock icon on read-only buffers
    local file_readonly = {
        {
            ---@return string|nil  Lock icon when buffer is not modifiable or is read-only
            provider = function()
                if not vim.bo.modifiable or vim.bo.readonly then
                    return " " .. icons.common.lock .. " "
                end
            end,
            hl = { fg = _G.LVIM.colors.red },
        },
    }

    ---@type table  Heirline component for the save icon on modified buffers
    local file_modified = {
        {
            ---@return string|nil  Save icon when the buffer has unsaved changes
            provider = function()
                if vim.bo.modified then
                    return " " .. icons.common.save .. " "
                end
            end,
            hl = { fg = _G.LVIM.colors.red },
        },
    }

    -- Combine all file name sub-components into the parent block
    file_name_block = heirline_utils.insert(
        file_name_block,
        file_name,
        file_icon,
        file_size,
        file_readonly,
        file_modified,
        { provider = "%<" } -- truncation point marker
    )

    -- -------------------------------------------------------------------------
    -- git: branch name + abbreviated SHA + line-diff stats
    -- -------------------------------------------------------------------------

    ---@type table  Heirline component that shows git branch and diff counts
    local git = {
        -- Only render when git data is available in the global namespace
        condition = function()
            return type(_G.LVIM.git) == "table" and _G.LVIM.git.head ~= nil
        end,
        ---@param self table  Sets self.status_dict with vgit diff counts
        init = function(self)
            -- Use vgit's per-buffer status if available; fall back to all-zero
            self.status_dict = vim.b.vgit_status or { added = 0, removed = 0, changed = 0 }
        end,
        hl = { fg = _G.LVIM.colors.orange },
        -- Branch name + short commit hash
        {
            ---@return string  Git icon + branch + "(abbrev)" or empty string
            provider = function()
                local head = _G.LVIM.git and _G.LVIM.git.head
                return head
                        and head.branch
                        and head.abbrev
                        and (" " .. icons.common.git .. " " .. head.branch .. " (" .. head.abbrev .. ") ")
                    or ""
            end,
            hl = { bold = true },
        },
        -- Added lines count
        {
            ---@param self table   Component self (has self.status_dict.added)
            ---@return string|false  Added indicator or false when count is zero
            provider = function(self)
                local count = self.status_dict.added or 0
                return count > 0 and (" " .. icons.git_status.added .. " " .. count)
            end,
            hl = { fg = _G.LVIM.colors.git_add },
        },
        -- Removed lines count
        {
            ---@param self table   Component self
            ---@return string|false  Removed indicator or false when count is zero
            provider = function(self)
                local count = self.status_dict.removed or 0
                return count > 0 and (" " .. icons.git_status.deleted .. " " .. count)
            end,
            hl = { fg = _G.LVIM.colors.git_delete },
        },
        -- Changed lines count
        {
            ---@param self table   Component self
            ---@return string|false  Changed indicator or false when count is zero
            provider = function(self)
                local count = self.status_dict.changed or 0
                return count > 0 and (" " .. icons.git_status.modified .. " " .. count)
            end,
            hl = { fg = _G.LVIM.colors.git_change },
        },
        on_click = {
            -- Clicking the git segment opens Neogit
            callback = function()
                vim.defer_fn(function()
                    vim.cmd("Neogit")
                end, 100)
            end,
            name = "heirline_git",
        },
    }

    -- -------------------------------------------------------------------------
    -- get_hunk_fields: normalises a hunk table from mini.diff
    -- Different versions of mini.diff use different field names; this helper
    -- abstracts the differences so the hunk display code stays clean.
    -- -------------------------------------------------------------------------

    ---@param h table  Raw hunk object from mini.diff
    ---@return table   Normalised hunk with .buf_start, .buf_count, .old_start,
    ---                .old_count, .type, .raw
    local function get_hunk_fields(h)
        return {
            -- New-side (buffer) range — try several field name variants
            buf_start = h.buf_start or (h.new and h.new.start) or h.new_start or nil,
            buf_count = h.buf_count or (h.new and h.new.count) or h.new_count or nil,
            -- Old-side (reference) range
            old_start = h.old_start
                or (h.old and h.old.start)
                or h.orig_start
                or h.ref_start
                or (h.ref and h.ref.start)
                or nil,
            old_count = h.old_count
                or (h.old and h.old.count)
                or h.orig_count
                or h.ref_count
                or (h.ref and h.ref.count)
                or nil,
            type = h.type or h.kind or nil,
            raw = h,
        }
    end

    -- -------------------------------------------------------------------------
    -- git_hunks: current hunk position indicator
    -- Shows "<current>/<total>" coloured by hunk type.
    -- Handles "change+delete" compound hunks (two adjacent mini.diff entries).
    -- -------------------------------------------------------------------------

    ---@type table  Heirline component for the hunk position display
    local git_hunks = {
        condition = function()
            if type(_G.LVIM.git) ~= "table" or _G.LVIM.git.head == nil then
                return false
            end
            local ok, minidiff = pcall(require, "mini.diff")
            if not ok then
                return false
            end
            local buf_data = minidiff.get_buf_data(0)
            local hunks = buf_data and buf_data.hunks or {}
            -- Only show when there is at least one hunk in the current buffer
            return type(hunks) == "table" and #hunks > 0
        end,
        ---@param self table  Sets hunk navigation state on self
        init = function(self)
            local minidiff = require("mini.diff")
            local buf_data = minidiff.get_buf_data(0)
            ---@type table[]
            local hunks = buf_data and buf_data.hunks or {}
            self.hunks_count = #hunks

            local lnum = vim.fn.line(".")
            self.current_hunk_index = nil
            self.current_hunk_type = nil
            self.current_hunk = nil
            -- True when the current hunk is a compound change+delete pair
            self.current_hunk_is_changedel = false
            -- Index of the paired delete hunk in a compound change+delete
            self.current_hunk_second_index = nil

            -- Find which hunk the cursor is currently inside
            for i, h in ipairs(hunks) do
                local f = get_hunk_fields(h)
                if f.buf_start and f.buf_count then
                    local first = f.buf_start
                    local last = f.buf_start + math.max(f.buf_count - 1, 0)
                    if f.type == "delete" then
                        -- Delete hunks occupy a single line boundary (no new lines)
                        if lnum == first or (first == 0 and lnum == 1) then
                            self.current_hunk_index = i
                            self.current_hunk_type = f.type
                            self.current_hunk = f
                            break
                        end
                    elseif lnum >= first and lnum <= last then
                        self.current_hunk_index = i
                        self.current_hunk_type = f.type
                        self.current_hunk = f
                        break
                    end
                end
            end

            -- Detect compound change+delete: a "change" hunk with both old and new
            -- line counts present indicates an inline replacement with deletions.
            if
                self.current_hunk
                and type(self.current_hunk_type) == "string"
                and string.match(self.current_hunk_type, "change")
            then
                local h = self.current_hunk
                if (h.old_count and h.old_count > 0) and (h.buf_count and h.buf_count > 0) then
                    self.current_hunk_is_changedel = true
                end
            end

            -- Check whether the next hunk is a delete that starts immediately
            -- after the current change hunk ends (making it a compound pair).
            if self.current_hunk_is_changedel and self.current_hunk_index then
                local next_h = hunks[self.current_hunk_index + 1]
                if next_h then
                    local nf = get_hunk_fields(next_h)
                    local cur_buf_start = self.current_hunk.buf_start or 0
                    local cur_buf_count = self.current_hunk.buf_count or 0
                    local expected_next_start = cur_buf_start + cur_buf_count
                    local is_adjacent = false
                    if nf.buf_start ~= nil and expected_next_start ~= nil then
                        if nf.buf_start == expected_next_start then
                            is_adjacent = true
                        end
                        -- Edge case: change ends at line 0, delete starts at line 1
                        if nf.buf_start == 0 and expected_next_start == 1 then
                            is_adjacent = true
                        end
                    end
                    if nf.type == "delete" and is_adjacent then
                        self.current_hunk_second_index = self.current_hunk_index + 1
                    else
                        self.current_hunk_second_index = nil
                    end
                else
                    self.current_hunk_second_index = nil
                end
            end
        end,
        -- Commit icon prefix for the hunk counter
        {
            provider = function()
                return "  " .. icons.git_status.commit .. " "
            end,
            hl = function()
                return { fg = _G.LVIM.colors.blue, bold = true }
            end,
        },
        -- Current hunk index, coloured by hunk type (add=green / change=orange / delete=red)
        {
            ---@param self table   Component self
            ---@return string      Current index or "-" when cursor is outside all hunks
            provider = function(self)
                if not self.current_hunk then
                    return "-"
                end
                return tostring(self.current_hunk_index or "-")
            end,
            ---@param self table  Component self
            ---@return table      Highlight spec keyed by hunk type colour
            hl = function(self)
                if not self.current_hunk_index then
                    return { fg = _G.LVIM.colors.blue, bold = true }
                end
                if self.current_hunk_type == "add" then
                    return { fg = _G.LVIM.colors.git_add, bold = true }
                elseif self.current_hunk_type == "change" then
                    return { fg = _G.LVIM.colors.git_change, bold = true }
                elseif self.current_hunk_type == "delete" or self.current_hunk_type == "remove" then
                    return { fg = _G.LVIM.colors.git_delete, bold = true }
                end
                return { fg = _G.LVIM.colors.blue, bold = true }
            end,
        },
        -- Comma separator between the primary and secondary hunk index
        {
            ---@param self table   Component self
            ---@return string      "," when a compound second index exists, else ""
            provider = function(self)
                if self.current_hunk_is_changedel and self.current_hunk_second_index then
                    return ","
                end
                return ""
            end,
            hl = function()
                return { fg = _G.LVIM.colors.blue, bold = true }
            end,
        },
        -- Second (delete) hunk index for a compound change+delete pair
        {
            ---@param self table   Component self
            ---@return string      Index of the paired delete hunk, or empty string
            provider = function(self)
                if not self.current_hunk_is_changedel then
                    return ""
                end
                if not self.current_hunk_second_index then
                    return ""
                end
                return tostring(self.current_hunk_second_index)
            end,
            hl = function()
                -- The delete portion of the pair is always shown in delete colour
                return { fg = _G.LVIM.colors.git_delete, bold = true }
            end,
        },
        -- Total hunk count denominator ("/N ")
        {
            ---@param self table   Component self
            ---@return string      "/N " where N is the total hunk count
            provider = function(self)
                return ("/%d "):format(self.hunks_count or 0)
            end,
            hl = function()
                return { fg = _G.LVIM.colors.blue, bold = true }
            end,
        },
        on_click = {
            -- Clicking the hunk counter opens VGit diff preview
            callback = function()
                vim.defer_fn(function()
                    vim.cmd("VGit buffer_diff_preview")
                end, 100)
            end,
            name = "heirline_git_hunks",
        },
    }

    -- -------------------------------------------------------------------------
    -- macro_rec: active macro recording indicator
    -- Visible only when a macro is being recorded and cmdheight == 0.
    -- Uses red_01 / green_01 from LvimColors for the recording indicator.
    -- -------------------------------------------------------------------------

    ---@type table  Heirline component that shows the active macro register
    local macro_rec = {
        condition = function()
            -- Only visible when recording a macro with the command line area hidden
            return vim.fn.reg_recording() ~= "" and vim.o.cmdheight == 0
        end,
        provider = " ",
        hl = { fg = _G.LVIM.colors.red_01, bold = true },
        -- Wrap the register letter in square brackets
        heirline_utils.surround({ "[", "]" }, nil, {
            ---@return string  Current recording register name (e.g. "q")
            provider = function()
                return vim.fn.reg_recording()
            end,
            hl = { fg = _G.LVIM.colors.green_01, bold = true },
        }),
        update = { "RecordingEnter", "RecordingLeave" },
    }
    -- Alternative macro_rec using NeoComposer (kept as reference, currently inactive):
    -- local macro_rec = {
    --     condition = function()
    --         return require("NeoComposer.state")
    --     end,
    --     provider = require("NeoComposer.ui").status_recording,
    -- }

    -- -------------------------------------------------------------------------
    -- diagnostics: error / warning / hint / info counts
    -- -------------------------------------------------------------------------

    ---@type table  Heirline component that shows diagnostic counts per severity
    local diagnostics = {
        condition = heirline_conditions.has_diagnostics,
        static = {
            error_icon = icons.diagnostics.error .. " ",
            warn_icon = icons.diagnostics.warn .. " ",
            hint_icon = icons.diagnostics.hint .. " ",
            info_icon = icons.diagnostics.info .. " ",
        },
        -- Refresh on diagnostic changes and when switching buffers
        update = { "DiagnosticChanged", "BufEnter" },
        ---@param self table  Sets self.errors/warnings/hints/info severity counts
        init = function(self)
            self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
            self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
            self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
            self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
        end,
        {
            ---@param self table   Component self
            ---@return string|false  Error icon + count, or false when zero
            provider = function(self)
                return self.errors > 0 and (self.error_icon .. self.errors .. " ")
            end,
            hl = { fg = _G.LVIM.colors.diag_error },
        },
        {
            ---@param self table   Component self
            ---@return string|false  Warning icon + count, or false when zero
            provider = function(self)
                return self.warnings > 0 and (self.warn_icon .. self.warnings .. " ")
            end,
            hl = { fg = _G.LVIM.colors.diag_warn },
        },
        {
            ---@param self table   Component self
            ---@return string|false  Info icon + count, or false when zero
            provider = function(self)
                return self.info > 0 and (self.info_icon .. self.info .. " ")
            end,
            hl = { fg = _G.LVIM.colors.diag_info },
        },
        {
            ---@param self table   Component self
            ---@return string|false  Hint icon + count, or false when zero
            provider = function(self)
                return self.hints > 0 and (self.hint_icon .. self.hints .. " ")
            end,
            hl = { fg = _G.LVIM.colors.diag_hint },
        },
        on_click = {
            callback = function()
                vim.cmd("Trouble diagnostics")
            end,
            name = "heirline_diagnostics",
        },
    }

    -- -------------------------------------------------------------------------
    -- lsp_active: names of attached LSP servers, linters, and formatters
    -- Queries EFM config (from _G.LVIM.global.efm or the live client) to list
    -- which linters and formatters are active for the current filetype.
    -- -------------------------------------------------------------------------

    ---@type table  Heirline component that shows active LSP/lint/format tool names
    local lsp_active = {
        condition = heirline_conditions.lsp_attached,
        update = { "LspAttach", "LspDetach", "BufWinEnter" },
        ---@return string  Formatted "LSP [servers] | Li [linters] | Fo [formatters]"
        provider = function()
            local lsp_manager = require("lvim-lsp.core.manager")
            ---@type string[]  Non-EFM LSP server names
            local lsp = {}
            ---@type string[]  Linter prefixes from EFM sources
            local linters = {}
            ---@type string[]  Formatter prefixes from EFM sources
            local formatters = {}
            local p_lsp = ""
            local p_linters = ""
            local p_formatters = ""

            local current_buf = vim.api.nvim_get_current_buf()
            -- Determine whether EFM is disabled globally or for this buffer
            local efm_disabled = lsp_manager.is_server_disabled_globally("efm")
                or lsp_manager.is_server_disabled_for_buffer("efm", current_buf)

            -- Collect names of all non-EFM clients
            for _, server in pairs(vim.lsp.get_clients({ bufnr = current_buf })) do
                if server.name ~= "efm" then
                    table.insert(lsp, server.name)
                end
            end

            if not efm_disabled then
                local filetype = vim.bo.filetype
                local ft_map = require("lvim-lsp.state").file_types

                -- Read formatters and linters for the current filetype directly from
                -- file_types — no EFM runtime query needed.
                local function collect(field, out)
                    for _, entry in pairs(ft_map) do
                        if vim.tbl_contains(entry.filetypes or {}, filetype) then
                            for _, tool in ipairs(entry[field] or {}) do
                                local pkg = type(tool) == "table" and tool[1] or tool
                                if mason_registry.is_installed(pkg) then
                                    table.insert(out, pkg)
                                end
                            end
                        end
                    end
                end
                collect("formatters", formatters)
                collect("linters", linters)

                -- Deduplicate before rendering (multiple filetypes may share a tool)
                if next(linters) ~= nil then
                    linters = funcs.remove_duplicate(linters)
                    p_linters = " | Li [" .. table.concat(linters, ", ") .. "]"
                end
                if next(formatters) ~= nil then
                    formatters = funcs.remove_duplicate(formatters)
                    p_formatters = " | Fo [" .. table.concat(formatters, ", ") .. "]"
                end
            end

            if next(lsp) ~= nil then
                p_lsp = "LSP [" .. table.concat(lsp, ", ") .. "]"
            end

            local result = icons.common.lsp .. "  " .. p_lsp .. p_linters .. p_formatters
            -- Return empty string when nothing is attached (avoids a lone LSP icon)
            if result == icons.common.lsp then
                return ""
            end
            return result
        end,
        hl = { fg = _G.LVIM.colors.blue, bold = true },
        on_click = {
            callback = function()
                vim.defer_fn(function()
                    vim.cmd("LspInfo")
                end, 100)
            end,
            name = "heirline_LSP",
        },
    }

    -- -------------------------------------------------------------------------
    -- file_encoding: buffer file encoding (e.g. "UTF-8")
    -- -------------------------------------------------------------------------

    ---@type table  Heirline component for the file encoding label
    local file_encoding = {
        ---@return string|nil  Uppercased encoding string or nil when empty
        provider = function()
            local enc = vim.opt.fileencoding:get()
            if enc ~= "" then
                return " " .. enc:upper()
            end
        end,
        hl = { fg = _G.LVIM.colors.orange, bold = true },
    }

    -- -------------------------------------------------------------------------
    -- file_format: line-ending format icon (unix / dos / mac)
    -- -------------------------------------------------------------------------

    ---@type table  Heirline component for the line-ending format indicator
    local file_format = {
        ---@return string|nil  Format icon or nil when fileformat is empty
        provider = function()
            local format = vim.bo.fileformat
            if format ~= "" then
                local symbols = {
                    unix = icons.common.unix .. " ",
                    dos = icons.common.dos .. " ",
                    mac = icons.common.mac .. " ",
                }
                return " " .. symbols[format]
            end
        end,
        hl = { fg = _G.LVIM.colors.orange, bold = true },
    }

    -- -------------------------------------------------------------------------
    -- spell: active spell-check language indicator
    -- -------------------------------------------------------------------------

    ---@type table  Heirline component that shows the active spell language
    local spell = {
        -- Only visible when spell checking is enabled (via lvim-linguistics)
        condition = require("lvim-linguistics.status").spell_has,
        ---@return string  "SPELL: <lang>" label
        provider = function()
            local status = require("lvim-linguistics.status").spell_get()
            return " SPELL: " .. status
        end,
        hl = { fg = _G.LVIM.colors.green, bold = true },
    }

    -- -------------------------------------------------------------------------
    -- statistic: word count (total or visual selection)
    -- -------------------------------------------------------------------------

    ---@type table  Heirline component for the word / visual-word count
    local statistic = {
        ---@return string  "visual/total" in visual mode, or "total" otherwise
        provider = function()
            local wc = vim.fn.wordcount()
            if _G.LVIM.mode == "v" or _G.LVIM.mode == "V" then
                -- Show selected word count vs total in visual mode
                return " " .. (wc.visual_words or 0) .. "/" .. (wc.words or 0)
            else
                return " " .. (wc.words or 0)
            end
        end,
        hl = { fg = _G.LVIM.colors.cyan, bold = true },
    }

    -- -------------------------------------------------------------------------
    -- ruler: line / column / percentage position indicator
    -- -------------------------------------------------------------------------

    ---@type table  Heirline component for the cursor position ruler
    local ruler = {
        -- %7(%l/%3L%) = right-aligned "line/totalLines", :%2c = column, %P = percentage
        provider = " %7(%l/%3L%):%2c %P",
        hl = { fg = _G.LVIM.colors.red, bold = true },
    }

    -- -------------------------------------------------------------------------
    -- scroll_bar: block-element scrollbar in the rightmost cell
    -- -------------------------------------------------------------------------

    ---@type table  Heirline component that renders a single-char scroll position bar
    local scroll_bar = {
        ---@return string  Two spaces + a block character indicating vertical scroll position
        provider = function()
            local current_line = vim.fn.line(".")
            local total_lines = vim.fn.line("$")
            -- Eight block chars from tallest (top of file) to shortest (bottom)
            local chars = { "█", "▇", "▆", "▅", "▄", "▃", "▂", "▁" }
            local line_ratio = current_line / total_lines
            local index = math.ceil(line_ratio * #chars)
            return "  " .. chars[index]
        end,
        hl = { fg = _G.LVIM.colors.red },
    }

    -- -------------------------------------------------------------------------
    -- statusline root component
    -- -------------------------------------------------------------------------

    ---@type table  Root heirline statusline with fallthrough disabled
    local statusline = {
        -- Do not try alternative patterns; always use this component
        fallthrough = false,
        ---@return table  Background/foreground highlight for the statusline bar
        hl = function()
            if heirline_conditions.is_active() then
                return {
                    bg = _G.LVIM.colors.bg_dark,
                    fg = _G.LVIM.colors.green,
                }
            else
                return {
                    bg = _G.LVIM.colors.bg_dark,
                    fg = _G.LVIM.colors.green,
                }
            end
        end,
        static = {
            -- Helper used by child components to get the active mode colour
            ---@param self table  Component self
            ---@return string     Hex colour for the current mode
            mode_color = function(self)
                local mode_color = heirline_conditions.is_active() and vim.fn.mode() or "n"
                return self.mode_colors[mode_color]
            end,
        },
        {
            vi_mode,
            work_dir,
            file_name_block,
            git,
            git_hunks,
            space,
            macro_rec,
            align, -- everything after align is right-justified
            diagnostics,
            lsp_active,
            file_types,
            file_encoding,
            file_format,
            spell,
            statistic,
            ruler,
            scroll_bar,
        },
    }

    return statusline
end

return M
