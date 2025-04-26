return {
    enable = true,
    properties = {
        data_types = {
            ["text"] = {
                text = " 󱔏 ",
                hl = "MarkviewIcon4",
            },
        },
        default = {
            use_types = true,
            border_top = " ┃ ",
            border_middle = " ┃ ",
            border_bottom = " ┗╸",
            border_hl = "MarkviewComment",
        },

        ["^tags$"] = {
            match_string = "^tags$",
            use_types = false,
            text = " 󰓹 ",
            hl = "MarkviewIcon4",
        },
        ["^aliases$"] = {
            match_string = "^aliases$",
            use_types = false,
            text = " 󰿨 ",
            hl = "MarkviewIcon4",
        },
    },
}
