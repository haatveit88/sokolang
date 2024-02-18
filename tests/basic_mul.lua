local cases = {
    {
        name = "multiply_simple",
        code = [[
            push 3
            push 4
            *
        ]],
        result = "12"
    },
    {
        name = "multiply_by_zero",
        code = [[
            push 5
            push 0
            *
        ]],
        result = "0"
    },
    {
        name = "multiply_by_one",
        code = [[
            push 5
            push 1
            *
        ]],
        result = "5"
    },
    {
        name = "multiply_negative",
        code = [[
            push -5
            push 3
            *
        ]],
        result = "-15"
    },
    {
        name = "multiply_two_negatives",
        code = [[
            push -5
            push -4
            *
        ]],
        result = "20"
    },
    {
        name = "multiply_decimals",
        code = [[
            push 2.5
            push 4.0
            *
        ]],
        result = "10"
    }
}

local test = {
    name = "Basic Operators: Multiply ( * )",
    cases = cases
}
return test