local ls = require("luasnip")

-- s = snippet, f = function_node, t = text_node, i = insert_node, c = choice_node, sn = snippet_node
local s = ls.s
local f = ls.f
local t = ls.t
local i = ls.i
-- local c = ls.c
-- local sn = ls.sn

return {
    s({
        trig = "([%w]+)%.par",
        regTrig = true,
        snippetType = "autosnippet",
        wordTrig = false,
    }, {
        f(function(_, parent)
            return "(" .. parent.captures[1] .. ")"
        end),
        i(0),
    }, {
        desc = "Parenthesis (postfix)",
    }),

    s({
        trig = "([^%s].*)%.r",
        regTrig = true,
        snippetType = "autosnippet",
        wordTrig = false,
    }, {
        f(function(_, parent)
            return "return " .. parent.captures[1]
        end),
        i(0),
    }, {
        desc = "Return (postfix)",
    }),

    s("lorem", {
        t({
            "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod",
            "tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At",
            "vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren,",
            "no sea takimata sanctus est Lorem ipsum dolor sit amet.",
        }),
        i(0),
    }, {
        desc = "Lorem Ipsum - 50 Words",
    }),
}
