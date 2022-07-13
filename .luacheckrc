cache = true
ignore = {
    "011", -- A syntax error.
    "021", -- An invalid inline option.
    "022", -- An unpaired inline push directive.
    "023", -- An unpaired inline pop directive.
    "111", -- Setting an undefined global variable.
    "112", -- Mutating an undefined global variable.
    "113", -- Accessing an undefined global variable.
    "121", -- Setting a read-only global variable.
    "122", -- Setting a read-only field of a global variable.
    "131", -- Unused implicitly defined global variable.
    "142", -- Setting an undefined field of a global variable.
    "143", -- Accessing an undefined field of a global variable.
    "211", -- Unused local variable.
    "212", -- Unused argument.
    "213", -- Unused loop variable.
    "221", -- Local variable is accessed but never set.
    "231", -- Local variable is set but never accessed.
    "232", -- An argument is set but never accessed.
    "233", -- Loop variable is set but never accessed.
    "241", -- Local variable is mutated but never accessed.
    "311", -- Value assigned to a local variable is unused.
    "312", -- Value of an argument is unused.
    "313", -- Value of a loop variable is unused.
    "314", -- Value of a field in a table literal is unused.
    "321", -- Accessing uninitialized local variable.
    "331", -- Value assigned to a local variable is mutated but never accessed.
    "341", -- Mutating uninitialized local variable.
    "411", -- Redefining a local variable.
    "412", -- Redefining an argument.
    "413", -- Redefining a loop variable.
    "421", -- Shadowing a local variable.
    "422", -- Shadowing an argument.
    "423", -- Shadowing a loop variable.
    "431", -- Shadowing an upvalue.
    "432", -- Shadowing an upvalue argument.
    "433", -- Shadowing an upvalue loop variable.
    "511", -- Unreachable code.
    "512", -- Loop can be executed at most once.
    "521", -- Unused label.
    "531", -- Left-hand side of an assignment is too short.
    "532", -- Left-hand side of an assignment is too long.
    "541", -- An empty do end block.
    "542", -- An empty if branch.
    "551", -- An empty statement.
    "561", -- Cyclomatic complexity of a function is too high.
    "571", -- A numeric for loop goes from #(expr) down to 1 or less without negative step.
    "611", -- A line consists of nothing but whitespace.
    "612", -- A line contains trailing whitespace.
    "613", -- Trailing whitespace in a string.
    "614", -- Trailing whitespace in a comment.
    "621", -- Inconsistent indentation (SPACE followed by TAB).
    "631", -- Line is too long.
}
