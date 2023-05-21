local funcs = require("core.funcs")
local common = require("modules.base.configs.ui.heirline.common")

local file_name_block = {
    init = function(self)
        self.filename = vim.api.nvim_buf_get_name(0)
    end,
}
local work_dir = {
    provider = function()
        local icon = "    "
        local cwd = vim.fn.getcwd(0)
        cwd = vim.fn.fnamemodify(cwd, ":~")
        if not common.heirline_conditions.width_percent_below(#cwd, 0.25) then
            cwd = vim.fn.pathshorten(cwd)
        end
        local trail = cwd:sub(-1) == "/" and "" or "/"
        return icon .. cwd .. trail
    end,
    hl = { fg = common.theme_colors.blue_01, bold = true },
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
        if not common.heirline_conditions.width_percent_below(#filename, 0.25) then
            filename = vim.fn.pathshorten(filename)
        end
        return filename .. " "
    end,
    hl = function()
        return {
            fg = common.vi_mode.static.mode_colors[_G.LVIM_SETTINGS.mode],
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
    hl = { fg = common.theme_colors.blue_01 },
}
local file_flags = {
    {
        provider = function()
            if vim.bo.modified then
                return "   "
            end
        end,
        hl = { fg = common.theme_colors.red_01 },
    },
    {
        provider = function()
            if not vim.bo.modifiable or vim.bo.readonly then
                return "   "
            end
        end,
        hl = { fg = common.theme_colors.red_01 },
    },
}
file_name_block = common.heirline_utils.insert(
    file_name_block,
    file_name,
    common.file_icon,
    file_size,
    unpack(file_flags),
    { provider = "%<" }
)
local git = {
    condition = common.heirline_conditions.is_git_repo,
    init = function(self)
        ---@diagnostic disable-next-line: undefined-field
        self.status_dict = vim.b.gitsigns_status_dict
        self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
    end,
    hl = { fg = common.theme_colors.orange_02 },
    {
        provider = function(self)
            return "  " .. self.status_dict.head .. " "
        end,
        hl = { bold = true },
    },
    {
        provider = function(self)
            local count = self.status_dict.added or 0
            return count > 0 and ("  " .. count)
        end,
        hl = { fg = common.theme_colors.green_01 },
    },
    {
        provider = function(self)
            local count = self.status_dict.removed or 0
            return count > 0 and ("  " .. count)
        end,
        hl = { fg = common.theme_colors.red_02 },
    },
    {
        provider = function(self)
            local count = self.status_dict.changed or 0
            return count > 0 and ("  " .. count)
        end,
        hl = { fg = common.theme_colors.orange_02 },
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

local macro_rec = {
    condition = function()
        return require("NeoComposer.state")
    end,
    provider = require("NeoComposer.ui").status_recording,
}

local diagnostics = {
    condition = common.heirline_conditions.has_diagnostics,
    static = {
        error_icon = " ",
        warn_icon = " ",
        info_icon = " ",
        hint_icon = " ",
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
        hl = { fg = common.theme_colors.red_02 },
    },
    {
        provider = function(self)
            return self.warnings > 0 and (self.warn_icon .. self.warnings .. " ")
        end,
        hl = { fg = common.theme_colors.orange_02 },
    },
    {
        provider = function(self)
            return self.info > 0 and (self.info_icon .. self.info .. " ")
        end,
        hl = { fg = common.theme_colors.teal_01 },
    },
    {
        provider = function(self)
            return self.hints > 0 and (self.hint_icon .. self.hints .. " ")
        end,
        hl = { fg = common.theme_colors.teal_01 },
    },
    on_click = {
        callback = function()
            vim.cmd("Neotree diagnostics position=bottom")
        end,
        name = "heirline_diagnostics",
    },
}
local lsp_active = {
    condition = common.heirline_conditions.lsp_attached,
    update = { "LspAttach", "LspDetach", "BufWinEnter" },
    provider = function()
        local names = {}
        local null_ls = {}
        for _, server in pairs(vim.lsp.buf_get_clients(0)) do
            if server.name == "null-ls" then
                local sources = require("null-ls.sources")
                local ft = vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(0), "filetype")
                for _, source in ipairs(sources.get_available(ft)) do
                    table.insert(null_ls, source.name)
                end
                null_ls = funcs.remove_duplicate(null_ls)
            else
                table.insert(names, server.name)
            end
        end
        if next(null_ls) == nil then
            return "  LSP [" .. table.concat(names, ", ") .. "]"
        else
            return "  LSP [" .. table.concat(names, ", ") .. "] | NULL-LS [" .. table.concat(null_ls, ", ") .. "]"
        end
    end,
    hl = { fg = common.theme_colors.blue_01, bold = true },
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
    hl = { fg = common.theme_colors.orange_02, bold = true },
}
local file_format = {
    provider = function()
        local format = vim.bo.fileformat
        if format ~= "" then
            local symbols = {
                unix = "  ",
                dos = "  ",
                mac = "  ",
            }
            return symbols[format]
        end
    end,
    hl = { fg = common.theme_colors.orange_02, bold = true },
}
local spell = {
    condition = require("lvim-linguistics.status").spell_has,
    provider = function()
        local status = require("lvim-linguistics.status").spell_get()
        return " SPELL: " .. status
    end,
    hl = { fg = common.theme_colors.green_02, bold = true },
}
local statistic = {
    provider = function()
        if _G.LVIM_SETTINGS.mode == "v" or _G.LVIM_SETTINGS.mode == "V" then
            return " " .. vim.fn.wordcount().visual_words .. "/" .. vim.fn.wordcount().words
        else
            return " " .. vim.fn.wordcount().words
        end
    end,
    hl = { fg = common.theme_colors.teal_01, bold = true },
}
local ruler = {
    provider = " %7(%l/%3L%):%2c %P",
    hl = { fg = common.theme_colors.red_02, bold = true },
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
    hl = { fg = common.theme_colors.red_02 },
}

return {
    fallthrough = false,
    hl = function()
        if common.heirline_conditions.is_active() then
            return {
                bg = common.theme_colors.bg,
                fg = common.theme_colors.green_01,
            }
        else
            return {
                bg = common.theme_colors.bg,
                fg = common.theme_colors.green_01,
            }
        end
    end,
    static = {
        mode_color = function(self)
            local mode_color = common.heirline_conditions.is_active() and vim.fn.mode() or "n"
            return self.mode_colors[mode_color]
        end,
    },
    {
        common.vi_mode,
        work_dir,
        file_name_block,
        git,
        common.space,
        macro_rec,
        common.align,
        diagnostics,
        lsp_active,
        common.file_type,
        file_encoding,
        file_format,
        spell,
        statistic,
        ruler,
        scroll_bar,
    },
}
