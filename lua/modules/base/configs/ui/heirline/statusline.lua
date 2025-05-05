local icons = require("configs.base.ui.icons")
local mason_registry = require("mason-registry")

local M = {}

M.get_statusline = function()
    local funcs = require("core.funcs")
    local heirline_conditions = require("heirline.conditions")
    local heirline_utils = require("heirline.utils")
    local space = { provider = " " }
    local align = { provider = "%=" }

    local file_types = {
        provider = function()
            local file_type = vim.bo.filetype
            if file_type ~= "" then
                return "  " .. string.upper(file_type)
            end
        end,
        hl = { fg = _G.LVIM_COLORS.green, bold = true },
    }
    local vi_mode = {
        init = function(self)
            self.mode = vim.fn.mode(1)
            if not self.once then
                vim.api.nvim_create_autocmd("ModeChanged", {
                    pattern = "*:*o",
                    command = "redrawstatus",
                })
                self.once = true
            end
        end,
        static = {
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
            mode_colors = {
                n = _G.LVIM_COLORS.green,
                i = _G.LVIM_COLORS.red,
                v = _G.LVIM_COLORS.orange,
                V = _G.LVIM_COLORS.orange,
                ["\22"] = _G.LVIM_COLORS.orange,
                c = _G.LVIM_COLORS.purple,
                s = _G.LVIM_COLORS.purple,
                S = _G.LVIM_COLORS.purple,
                ["\19"] = _G.LVIM_COLORS.purple,
                R = _G.LVIM_COLORS.cyan,
                r = _G.LVIM_COLORS.cyan,
                ["!"] = _G.LVIM_COLORS.cyan,
                t = _G.LVIM_COLORS.blue,
            },
        },
        provider = function(self)
            return " " .. icons.common.vim .. " " .. " %(" .. self.mode_names[self.mode] .. "%)  "
        end,
        hl = function(self)
            _G.LVIM_MODE = self.mode:sub(1, 1)
            return {
                bg = self.mode_colors[self.mode:sub(1, 1)],
                fg = vim.o.background == "dark" and _G.LVIM_COLORS.bg or _G.LVIM_COLORS.fg,
                bold = true,
            }
        end,
        update = {
            "ModeChanged",
            "MenuPopup",
            "CmdlineEnter",
            "CmdlineLeave",
        },
    }
    local file_name_block = {
        init = function(self)
            self.filename = vim.api.nvim_buf_get_name(0)
        end,
    }
    local work_dir = {
        provider = function()
            local icon = " " .. icons.common.folder_empty .. " "
            local cwd = vim.fn.getcwd(0)
            cwd = vim.fn.fnamemodify(cwd, ":~")
            if not heirline_conditions.width_percent_below(#cwd, 0.25) then
                cwd = vim.fn.pathshorten(cwd)
            end
            local trail = cwd:sub(-1) == "/" and "" or "/"
            return icon .. cwd .. trail
        end,
        hl = { fg = _G.LVIM_COLORS.blue, bold = true },
        on_click = {
            callback = function()
                vim.cmd("Neotree position=left")
            end,
            name = "heirline_browser",
        },
    }
    local file_name = {
        provider = function(self)
            local filename = vim.fn.fnamemodify(self.filename, ":.")
            if filename == "" then
                return
            end
            if not heirline_conditions.width_percent_below(#filename, 0.25) then
                filename = vim.fn.pathshorten(filename)
            end
            return filename .. " "
        end,
        hl = function()
            return {
                fg = vi_mode.static.mode_colors[_G.LVIM_MODE],
                bold = true,
            }
        end,
    }
    local file_icon = {
        init = function(self)
            local filename = self.filename
            local extension = vim.fn.fnamemodify(filename, ":e")
            self.icon, self.icon_color =
                require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
        end,
        provider = function(self)
            return self.icon and (" " .. self.icon .. " ")
        end,
        hl = function(self)
            return {
                fg = self.icon_color,
                bold = true,
            }
        end,
    }
    local file_size = {
        provider = function()
            local fsize = vim.fn.getfsize(vim.api.nvim_buf_get_name(0))
            fsize = (fsize < 0 and 0) or fsize
            if fsize <= 0 then
                return
            end
            local file_size = require("core.funcs").file_size(fsize)
            return " " .. file_size
        end,
        hl = { fg = _G.LVIM_COLORS.blue },
    }
    local file_readonly = {
        {
            provider = function()
                if not vim.bo.modifiable or vim.bo.readonly then
                    return " " .. icons.common.lock .. " "
                end
            end,
            hl = { fg = _G.LVIM_COLORS.red },
        },
    }
    local file_modified = {
        {
            provider = function()
                if vim.bo.modified then
                    return " " .. icons.common.save .. " "
                end
            end,
            hl = { fg = _G.LVIM_COLORS.red },
        },
    }
    file_name_block = heirline_utils.insert(
        file_name_block,
        file_name,
        file_icon,
        file_size,
        file_readonly,
        file_modified,
        { provider = "%<" }
    )
    local git = {
        condition = heirline_conditions.is_git_repo,
        init = function(self)
            ---@diagnostic disable-next-line: undefined-field
            self.status_dict = vim.b.gitsigns_status_dict
            self.has_changes = self.status_dict.added ~= 0
                or self.status_dict.removed ~= 0
                or self.status_dict.changed ~= 0
        end,
        hl = { fg = _G.LVIM_COLORS.orange },
        {
            provider = function(self)
                return " " .. icons.common.git .. " " .. self.status_dict.head .. " "
            end,
            hl = { bold = true },
        },
        {
            provider = function(self)
                local count = self.status_dict.added or 0
                return count > 0 and (" " .. icons.git_status.added .. " " .. count)
            end,
            hl = { fg = _G.LVIM_COLORS.green },
        },
        {
            provider = function(self)
                local count = self.status_dict.removed or 0
                return count > 0 and (" " .. icons.git_status.deleted .. " " .. count)
            end,
            hl = { fg = _G.LVIM_COLORS.red },
        },
        {
            provider = function(self)
                local count = self.status_dict.changed or 0
                return count > 0 and (" " .. icons.git_status.modified .. " " .. count)
            end,
            hl = { fg = _G.LVIM_COLORS.orange },
        },
        on_click = {
            callback = function()
                vim.defer_fn(function()
                    vim.cmd("Neogit")
                end, 100)
            end,
            name = "heirline_git",
        },
    }

    -- local macro_rec = {
    --     condition = function()
    --         return vim.fn.reg_recording() ~= "" and vim.o.cmdheight == 0
    --     end,
    --     provider = " ",
    --     hl = { fg = colors.red_01, bold = true },
    --     heirline_utils.surround({ "[", "]" }, nil, {
    --         provider = function()
    --             return vim.fn.reg_recording()
    --         end,
    --         hl = { fg = colors.green_01, bold = true },
    --     }),
    --     update = {
    --         "RecordingEnter",
    --         "RecordingLeave",
    --     },
    -- }
    local macro_rec = {
        condition = function()
            return require("NeoComposer.state")
        end,
        provider = require("NeoComposer.ui").status_recording,
    }
    local diagnostics = {
        condition = heirline_conditions.has_diagnostics,
        static = {
            error_icon = icons.diagnostics.error .. " ",
            warn_icon = icons.diagnostics.warn .. " ",
            hint_icon = icons.diagnostics.hint .. " ",
            info_icon = icons.diagnostics.info .. " ",
        },
        update = { "DiagnosticChanged", "BufEnter" },
        init = function(self)
            self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
            self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
            self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
            self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
        end,
        {
            provider = function(self)
                return self.errors > 0 and (self.error_icon .. self.errors .. " ")
            end,
            hl = { fg = _G.LVIM_COLORS.diag_error },
        },
        {
            provider = function(self)
                return self.warnings > 0 and (self.warn_icon .. self.warnings .. " ")
            end,
            hl = { fg = _G.LVIM_COLORS.diag_warn },
        },
        {
            provider = function(self)
                return self.info > 0 and (self.info_icon .. self.info .. " ")
            end,
            hl = { fg = _G.LVIM_COLORS.diag_hint },
        },
        {
            provider = function(self)
                return self.hints > 0 and (self.hint_icon .. self.hints .. " ")
            end,
            hl = { fg = _G.LVIM_COLORS.diag_info },
        },
        on_click = {
            callback = function()
                vim.cmd("Trouble diagnostics")
            end,
            name = "heirline_diagnostics",
        },
    }
    local lsp_active = {
        condition = heirline_conditions.lsp_attached,
        update = { "LspAttach", "LspDetach", "BufWinEnter" },
        provider = function()
            local lsp_manager = require("languages.lsp_manager")
            local lsp = {}
            local linters = {}
            local formatters = {}
            local p_lsp = ""
            local p_linters = ""
            local p_formatters = ""
            local current_buf = vim.api.nvim_get_current_buf()
            local efm_disabled = lsp_manager.is_server_disabled_globally("efm") or lsp_manager.is_server_disabled_for_buffer("efm", current_buf)
            for _, server in pairs(vim.lsp.get_clients({ bufnr = current_buf })) do
                if server.name ~= "efm" then
                    table.insert(lsp, server.name)
                end
            end
            if not efm_disabled then
                local filetype = vim.bo.filetype
                local sources = nil
                if
                    _G.global
                    and _G.global.efm
                    and _G.global.efm.settings
                    and _G.global.efm.settings.languages
                    and _G.global.efm.settings.languages[filetype]
                then
                    sources = _G.global.efm.settings.languages[filetype]
                end
                if not sources then
                    local efm_client = nil
                    for _, client in ipairs(vim.lsp.get_clients({ bufnr = current_buf })) do
                        if client.name == "efm" then
                            efm_client = client
                            break
                        end
                    end
                    if
                        efm_client
                        and efm_client.config
                        and efm_client.config.settings
                        and efm_client.config.settings.languages
                        and efm_client.config.settings.languages[filetype]
                    then
                        sources = efm_client.config.settings.languages[filetype]
                    end
                end
                if sources then
                    for i = 1, #sources do
                        if sources[i].lPrefix and mason_registry.is_installed(sources[i].server_name) then
                            table.insert(linters, sources[i].lPrefix)
                        end
                        if sources[i].fPrefix and mason_registry.is_installed(sources[i].server_name) then
                            table.insert(formatters, sources[i].fPrefix)
                        end
                    end
                end
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
                p_lsp = " LSP [" .. table.concat(lsp, ", ") .. "]"
            end
            local result = icons.common.lsp .. p_lsp .. p_linters .. p_formatters
            if result == icons.common.lsp then
                return ""
            end
            return result
        end,
        hl = { fg = _G.LVIM_COLORS.blue, bold = true },
        on_click = {
            callback = function()
                vim.defer_fn(function()
                    vim.cmd("LspInfo")
                end, 100)
            end,
            name = "heirline_LSP",
        },
    }
    local file_encoding = {
        provider = function()
            local enc = vim.opt.fileencoding:get()
            if enc ~= "" then
                return " " .. enc:upper()
            end
        end,
        hl = { fg = _G.LVIM_COLORS.orange, bold = true },
    }
    local file_format = {
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
        hl = { fg = _G.LVIM_COLORS.orange, bold = true },
    }
    local spell = {
        condition = require("lvim-linguistics.status").spell_has,
        provider = function()
            local status = require("lvim-linguistics.status").spell_get()
            return " SPELL: " .. status
        end,
        hl = { fg = _G.LVIM_COLORS.green, bold = true },
    }
    local statistic = {
        provider = function()
            local wc = vim.fn.wordcount()
            if _G.LVIM_MODE == "v" or _G.LVIM_MODE == "V" then
                return " " .. (wc.visual_words or 0) .. "/" .. (wc.words or 0)
            else
                return " " .. (wc.words or 0)
            end
        end,
        hl = { fg = _G.LVIM_COLORS.cyan, bold = true },
    }
    local ruler = {
        provider = " %7(%l/%3L%):%2c %P",
        hl = { fg = _G.LVIM_COLORS.red, bold = true },
    }
    local scroll_bar = {
        provider = function()
            local current_line = vim.fn.line(".")
            local total_lines = vim.fn.line("$")
            local chars = { "█", "▇", "▆", "▅", "▄", "▃", "▂", "▁" }
            local line_ratio = current_line / total_lines
            local index = math.ceil(line_ratio * #chars)
            return "  " .. chars[index]
        end,
        hl = { fg = _G.LVIM_COLORS.red },
    }

    local statusline = {
        fallthrough = false,
        hl = function()
            if heirline_conditions.is_active() then
                return {
                    bg = _G.LVIM_COLORS.bg_dark,
                    fg = _G.LVIM_COLORS.green,
                }
            else
                return {
                    bg = _G.LVIM_COLORS.bg_dark,
                    fg = _G.LVIM_COLORS.green,
                }
            end
        end,
        static = {
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
            space,
            macro_rec,
            align,
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
