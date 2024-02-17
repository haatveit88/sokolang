-- test cases for basic mathematical operators [+ - * /]
local cases = {
    {
        name = "add_simple",
        code = [[
            push 1
            push 1
            +
        ]],
        result = "2"
    },
    {
        name = "add_zero",
        code = [[
            push 0
            push 5
            +
        ]],
        result = "5"
    },
    {
        name = "add_negative",
        code = [[
            push -5
            push 10
            +
        ]],
        result = "5"
    },
    {
        name = "add_two_negatives",
        code = [[
            push -10
            push -20
            +
        ]],
        result = "-30"
    },
    {
        name = "add_large_numbers",
        code = [[
            push 12345
            push 67890
            +
        ]],
        result = "80235"
    },
    {
        name = "add_decimals",
        code = [[
            push 1.5
            push 2.25
            +
        ]],
        result = "3.75"
    },
    {
        name = "add_negative_to_positive",
        code = [[
            push -15
            push 30
            +
        ]],
        result = "15"
    },
    {
        name = "add_multiple_numbers",
        code = [[
            push 5
            push 10
            +
            push 15
            +
        ]],
        result = "30"
    },
    {
        name = "add_many_in_a_row",
        code = [[
            push 10
            push 9
            push 8
            push 7
            push 6
            push 5
            push 4
            push 3
            push 2
            push 1
            +
            +
            +
            +
            +
            +
            +
            +
            +
        ]],
        result = "55"
    }
}

local test = {
    name = "Basic Operators: Add (+)",
    cases = cases
}
return test