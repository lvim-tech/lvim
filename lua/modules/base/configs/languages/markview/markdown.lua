return {
    enable = true,
    block_quotes = {
        enable = true,
        wrap = true,
        default = {
            border = "▋",
            hl = "MarkviewBlockQuoteDefault",
        },
        ["ABSTRACT"] = {
            preview = "󱉫 Abstract",
            hl = "MarkviewBlockQuoteNote",
            title = true,
            icon = "󱉫",
        },
        ["SUMMARY"] = {
            preview = "󱉫 Summary",
            hl = "MarkviewBlockQuoteNote",
            title = true,
            icon = "󱉫",
        },
        ["TLDR"] = {
            preview = "󱉫 Tldr",
            hl = "MarkviewBlockQuoteNote",
            title = true,
            icon = "󱉫",
        },
        ["TODO"] = {
            preview = " Todo",
            hl = "MarkviewBlockQuoteNote",
            title = true,
            icon = "",
        },
        ["INFO"] = {
            preview = " Info",
            hl = "MarkviewBlockQuoteNote",
            custom_title = true,
            icon = "",
        },
        ["SUCCESS"] = {
            preview = "󰗠 Success",
            hl = "MarkviewBlockQuoteOk",
            title = true,
            icon = "󰗠",
        },
        ["CHECK"] = {
            preview = "󰗠 Check",
            hl = "MarkviewBlockQuoteOk",
            title = true,
            icon = "󰗠",
        },
        ["DONE"] = {
            preview = "󰗠 Done",
            hl = "MarkviewBlockQuoteOk",
            title = true,
            icon = "󰗠",
        },
        ["QUESTION"] = {
            preview = "󰋗 Question",
            hl = "MarkviewBlockQuoteWarn",
            title = true,
            icon = "󰋗",
        },
        ["HELP"] = {
            preview = "󰋗 Help",
            hl = "MarkviewBlockQuoteWarn",
            title = true,
            icon = "󰋗",
        },
        ["FAQ"] = {
            preview = "󰋗 Faq",
            hl = "MarkviewBlockQuoteWarn",
            title = true,
            icon = "󰋗",
        },
        ["FAILURE"] = {
            preview = "󰅙 Failure",
            hl = "MarkviewBlockQuoteError",
            title = true,
            icon = "󰅙",
        },
        ["FAIL"] = {
            preview = "󰅙 Fail",
            hl = "MarkviewBlockQuoteError",
            title = true,
            icon = "󰅙",
        },
        ["MISSING"] = {
            preview = "󰅙 Missing",
            hl = "MarkviewBlockQuoteError",
            title = true,
            icon = "󰅙",
        },
        ["DANGER"] = {
            preview = " Danger",
            hl = "MarkviewBlockQuoteError",
            title = true,
            icon = "",
        },
        ["ERROR"] = {
            preview = " Error",
            hl = "MarkviewBlockQuoteError",
            title = true,
            icon = "",
        },
        ["BUG"] = {
            preview = " Bug",
            hl = "MarkviewBlockQuoteError",
            title = true,
            icon = "",
        },
        ["EXAMPLE"] = {
            preview = "󱖫 Example",
            hl = "MarkviewBlockQuoteSpecial",
            title = true,
            icon = "󱖫",
        },
        ["QUOTE"] = {
            preview = " Quote",
            hl = "MarkviewBlockQuoteDefault",
            title = true,
            icon = "",
        },
        ["CITE"] = {
            preview = " Cite",
            hl = "MarkviewBlockQuoteDefault",
            title = true,
            icon = "",
        },
        ["HINT"] = {
            preview = " Hint",
            hl = "MarkviewBlockQuoteOk",
            title = true,
            icon = "",
        },
        ["ATTENTION"] = {
            preview = " Attention",
            hl = "MarkviewBlockQuoteWarn",
            title = true,
            icon = "",
        },

        ["NOTE"] = {
            preview = "󰋽 Note",
            hl = "MarkviewBlockQuoteNote",
            title = true,
            icon = "󰋽",
        },
        ["TIP"] = {
            preview = " Tip",
            hl = "MarkviewBlockQuoteOk",
            title = true,
            icon = "",
        },
        ["IMPORTANT"] = {
            preview = " Important",
            hl = "MarkviewBlockQuoteSpecial",
            title = true,
            icon = "",
        },
        ["WARNING"] = {
            preview = " Warning",
            hl = "MarkviewBlockQuoteWarn",
            title = true,
            icon = "",
        },
        ["CAUTION"] = {
            preview = "󰳦 Caution",
            hl = "MarkviewBlockQuoteError",
            title = true,
            icon = "󰳦",
        },
    },
    code_blocks = {
        enable = true,
        style = "block",
        label_direction = "right",
        border_hl = "MarkviewCode",
        info_hl = "MarkviewCodeInfo",
        min_width = 60,
        pad_amount = 2,
        pad_char = " ",
        sign = true,
        default = {
            block_hl = "MarkviewCode",
            pad_hl = "MarkviewCode",
        },
        ["diff"] = {
            block_hl = function(_, line)
                if line:match("^%+") then
                    return "MarkviewPalette4"
                elseif line:match("^%-") then
                    return "MarkviewPalette1"
                else
                    return "MarkviewCode"
                end
            end,
            pad_hl = "MarkviewCode",
        },
    },
    headings = {
        enable = true,
        heading_1 = {
            style = "icon",
            sign = "󰌕 ",
            sign_hl = "MarkviewHeading1Sign",
            icon = "󰼏  ",
            hl = "MarkviewHeading1",
        },
        heading_2 = {
            style = "icon",
            sign = "󰌕 ",
            sign_hl = "MarkviewHeading2Sign",
            icon = "󰎨  ",
            hl = "MarkviewHeading2",
        },
        heading_3 = {
            style = "icon",
            sign = "󰌕 ",
            sign_hl = "MarkviewHeading3Sign",
            icon = "󰼑  ",
            hl = "MarkviewHeading3",
        },
        heading_4 = {
            style = "icon",
            sign = "󰌕 ",
            sign_hl = "MarkviewHeading4Sign",
            icon = "󰎲  ",
            hl = "MarkviewHeading4",
        },
        heading_5 = {
            style = "icon",
            sign = "󰌕 ",
            sign_hl = "MarkviewHeading5Sign",
            icon = "󰼓  ",
            hl = "MarkviewHeading5",
        },
        heading_6 = {
            style = "icon",
            sign = "󰌕 ",
            sign_hl = "MarkviewHeading6Sign",
            icon = "󰎴  ",
            hl = "MarkviewHeading6",
        },
        setext_1 = {
            style = "decorated",
            sign = "󰌕 ",
            sign_hl = "MarkviewHeading1Sign",
            icon = "  ",
            hl = "MarkviewHeading1",
            border = "▂",
        },
        setext_2 = {
            style = "decorated",
            sign = "󰌖 ",
            sign_hl = "MarkviewHeading2Sign",
            icon = "  ",
            hl = "MarkviewHeading2",
            border = "▁",
        },
        shift_width = 1,
        org_indent = false,
        org_indent_wrap = true,
        org_shift_char = " ",
        org_shift_width = 1,
    },
    horizontal_rules = {
        enable = true,
        parts = {
            {
                type = "repeating",
                direction = "left",
                repeat_amount = function(buffer)
                    local utils = require("markview.utils")
                    local window = utils.buf_getwin(buffer)
                    local width = vim.api.nvim_win_get_width(window)
                    local textoff = vim.fn.getwininfo(window)[1].textoff
                    return math.floor((width - textoff - 3) / 2)
                end,
                text = "─",
                hl = {
                    "MarkviewGradient1",
                    "MarkviewGradient1",
                    "MarkviewGradient2",
                    "MarkviewGradient2",
                    "MarkviewGradient3",
                    "MarkviewGradient3",
                    "MarkviewGradient4",
                    "MarkviewGradient4",
                    "MarkviewGradient5",
                    "MarkviewGradient5",
                    "MarkviewGradient6",
                    "MarkviewGradient6",
                    "MarkviewGradient7",
                    "MarkviewGradient7",
                    "MarkviewGradient8",
                    "MarkviewGradient8",
                    "MarkviewGradient9",
                    "MarkviewGradient9",
                },
            },
            {
                type = "text",
                text = "  ",
                hl = "MarkviewIcon3Fg",
            },
            {
                type = "repeating",
                direction = "right",
                repeat_amount = function(buffer) --[[@as function]]
                    local utils = require("markview.utils")
                    local window = utils.buf_getwin(buffer)
                    local width = vim.api.nvim_win_get_width(window)
                    local textoff = vim.fn.getwininfo(window)[1].textoff
                    return math.ceil((width - textoff - 3) / 2)
                end,
                text = "─",
                hl = {
                    "MarkviewGradient1",
                    "MarkviewGradient1",
                    "MarkviewGradient2",
                    "MarkviewGradient2",
                    "MarkviewGradient3",
                    "MarkviewGradient3",
                    "MarkviewGradient4",
                    "MarkviewGradient4",
                    "MarkviewGradient5",
                    "MarkviewGradient5",
                    "MarkviewGradient6",
                    "MarkviewGradient6",
                    "MarkviewGradient7",
                    "MarkviewGradient7",
                    "MarkviewGradient8",
                    "MarkviewGradient8",
                    "MarkviewGradient9",
                    "MarkviewGradient9",
                },
            },
        },
    },
    list_items = {
        enable = true,
        wrap = true,
        indent_size = function(buffer)
            if type(buffer) ~= "number" then
                return vim.bo.shiftwidth or 4
            end
            return vim.bo[buffer].shiftwidth or 4
        end,
        shift_width = 4,
        marker_minus = {
            add_padding = true,
            conceal_on_checkboxes = true,
            text = "●",
            hl = "MarkviewListItemMinus",
        },
        marker_plus = {
            add_padding = true,
            conceal_on_checkboxes = true,
            text = "◈",
            hl = "MarkviewListItemPlus",
        },
        marker_star = {
            add_padding = true,
            conceal_on_checkboxes = true,
            text = "◇",
            hl = "MarkviewListItemStar",
        },
        marker_dot = {
            add_padding = true,
            conceal_on_checkboxes = true,
        },
        marker_parenthesis = {
            add_padding = true,
            conceal_on_checkboxes = true,
        },
    },
    metadata_minus = {
        enable = true,
        hl = "MarkviewCode",
        border_hl = "MarkviewCodeFg",
        border_top = "▄",
        border_bottom = "▀",
    },
    metadata_plus = {
        enable = true,
        hl = "MarkviewCode",
        border_hl = "MarkviewCodeFg",
        border_top = "▄",
        border_bottom = "▀",
    },
    reference_definitions = {
        enable = true,
        default = {
            icon = " ",
            hl = "MarkviewPalette4Fg",
        },
        ["github%.com/[%a%d%-%_%.]+%/?$"] = {
            --- github.com/<user>
            icon = " ",
            hl = "MarkviewPalette0Fg",
        },
        ["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/?$"] = {
            --- github.com/<user>/<repo>
            icon = " ",
            hl = "MarkviewPalette0Fg",
        },
        ["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+/tree/[%a%d%-%_%.]+%/?$"] = {
            --- github.com/<user>/<repo>/tree/<branch>
            icon = " ",
            hl = "MarkviewPalette0Fg",
        },
        ["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+/commits/[%a%d%-%_%.]+%/?$"] = {
            --- github.com/<user>/<repo>/commits/<branch>
            icon = " ",
            hl = "MarkviewPalette0Fg",
        },

        ["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/releases$"] = {
            --- github.com/<user>/<repo>/releases
            icon = " ",
            hl = "MarkviewPalette0Fg",
        },
        ["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/tags$"] = {
            --- github.com/<user>/<repo>/tags
            icon = " ",
            hl = "MarkviewPalette0Fg",
        },
        ["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/issues$"] = {
            --- github.com/<user>/<repo>/issues
            icon = " ",
            hl = "MarkviewPalette0Fg",
        },
        ["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/pulls$"] = {
            --- github.com/<user>/<repo>/pulls
            icon = " ",
            hl = "MarkviewPalette0Fg",
        },
        ["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/wiki$"] = {
            --- github.com/<user>/<repo>/wiki
            icon = " ",
            hl = "MarkviewPalette0Fg",
        },
        ["developer%.mozilla%.org"] = {
            priority = -9999,
            icon = "󰖟 ",
            hl = "MarkviewPalette5Fg",
        },
        ["w3schools%.com"] = {
            priority = -9999,
            icon = " ",
            hl = "MarkviewPalette4Fg",
        },
        ["stackoverflow%.com"] = {
            priority = -9999,
            icon = "󰓌 ",
            hl = "MarkviewPalette2Fg",
        },
        ["reddit%.com"] = {
            priority = -9999,
            icon = " ",
            hl = "MarkviewPalette2Fg",
        },
        ["github%.com"] = {
            priority = -9999,
            icon = " ",
            hl = "MarkviewPalette6Fg",
        },
        ["gitlab%.com"] = {
            priority = -9999,
            icon = " ",
            hl = "MarkviewPalette2Fg",
        },
        ["dev%.to"] = {
            priority = -9999,
            icon = "󱁴 ",
            hl = "MarkviewPalette0Fg",
        },
        ["codepen%.io"] = {
            priority = -9999,
            icon = " ",
            hl = "MarkviewPalette6Fg",
        },
        ["replit%.com"] = {
            priority = -9999,
            icon = " ",
            hl = "MarkviewPalette2Fg",
        },
        ["jsfiddle%.net"] = {
            priority = -9999,
            icon = " ",
            hl = "MarkviewPalette5Fg",
        },
        ["npmjs%.com"] = {
            priority = -9999,
            icon = " ",
            hl = "MarkviewPalette0Fg",
        },
        ["pypi%.org"] = {
            priority = -9999,
            icon = "󰆦 ",
            hl = "MarkviewPalette0Fg",
        },
        ["mvnrepository%.com"] = {
            priority = -9999,
            icon = " ",
            hl = "MarkviewPalette1Fg",
        },
        ["medium%.com"] = {
            priority = -9999,
            icon = " ",
            hl = "MarkviewPalette6Fg",
        },
        ["linkedin%.com"] = {
            priority = -9999,
            icon = "󰌻 ",
            hl = "MarkviewPalette5Fg",
        },
        ["news%.ycombinator%.com"] = {
            priority = -9999,
            icon = " ",
            hl = "MarkviewPalette2Fg",
        },
    },
    tables = {
        enable = true,
        strict = false,
        col_min_width = 10,
        block_decorator = true,
        use_virt_lines = false,
        parts = {
            top = { "┌", "─", "┐", "┬" },
            header = { "│", "│", "│" },
            separator = { "├", "─", "┤", "┼" },
            row = { "│", "│", "│" },
            bottom = { "└", "─", "┘", "┴" },
            overlap = { "┝", "━", "┥", "┿" },
            align_left = "─",
            align_right = "─",
            align_center = { "╴", "╶" },
        },
        hl = {
            top = { "MarkviewTableHeader", "MarkviewTableHeader", "MarkviewTableHeader", "MarkviewTableHeader" },
            header = { "MarkviewTableHeader", "MarkviewTableHeader", "MarkviewTableHeader" },
            separator = { "MarkviewTableHeader", "MarkviewTableHeader", "MarkviewTableHeader", "MarkviewTableHeader" },
            row = { "MarkviewTableBorder", "MarkviewTableBorder", "MarkviewTableBorder" },
            bottom = { "MarkviewTableBorder", "MarkviewTableBorder", "MarkviewTableBorder", "MarkviewTableBorder" },
            overlap = { "MarkviewTableBorder", "MarkviewTableBorder", "MarkviewTableBorder", "MarkviewTableBorder" },
            align_left = "MarkviewTableAlignLeft",
            align_right = "MarkviewTableAlignRight",
            align_center = { "MarkviewTableAlignCenter", "MarkviewTableAlignCenter" },
        },
    },
}
