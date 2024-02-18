local cases = {
    {
        name = "divide_simple",
        code = [[
            push 12
            push 4
            /
        ]],
        result = "3"
    },
    {
        name = "divide_by_one",
        code = [[
            push 5
            push 1
            /
        ]],
        result = "5"
    },
    {
        name = "divide_by_self",
        code = [[
            push 5
            push 5
            /
        ]],
        result = "1"
    },
    {
        name = "divide_negative",
        code = [[
            push -10
            push 2
            /
        ]],
        result = "-5"
    },
    {
        name = "divide_two_negatives",
        code = [[
            push -10
            push -5
            /
        ]],
        result = "2"
    },
    {
        name = "divide_into_decimal",
        code = [[
            push 1
            push 2
            /
        ]],
        result = "0.5"
    },
    {
        name = "divide_by_zero",
        code = [[
            push 10
            push 0
            /
        ]],
        result = "NAN"
    }
}


local test = {
    name = "Basic Operators: Divide ( / )",
    cases = cases
}
return test