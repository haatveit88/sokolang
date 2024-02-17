local cases = {
    {
        name = "subtract_simple",
        code = [[
            push 5
            push 3
            -
        ]],
        result = "2"
    },
    {
        name = "subtract_zero",
        code = [[
            push 5
            push 0
            -
        ]],
        result = "5"
    },
    {
        name = "subtract_from_zero",
        code = [[
            push 0
            push 5
            -
        ]],
        result = "-5"
    },
    {
        name = "subtract_negative",
        code = [[
            push -5
            push -10
            -
        ]],
        result = "5"
    },
    {
        name = "subtract_to_negative",
        code = [[
            push 5
            push 10
            -
        ]],
        result = "-5"
    },
    {
        name = "subtract_large_numbers",
        code = [[
            push 67890
            push 12345
            -
        ]],
        result = "55545"
    },
    {
        name = "subtract_decimals",
        code = [[
            push 10.5
            push 2.25
            -
        ]],
        result = "8.25"
    },
    {
        name = "subtract_to_zero",
        code = [[
            push 20
            push 20
            -
        ]],
        result = "0"
    },
    {
        name = "subtract_multiple_steps",
        code = [[
            push 50
            push 25
            -
            push 10
            -
        ]],
        result = "15"
    }
}


local test = {
    name = "Basic Operators: Subtract (-)",
    cases = cases
}

return test
