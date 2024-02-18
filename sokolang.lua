--  Sokolang prototype implementation
local lexer = require("lexer")
local printf = require("utils/printf")

local function interpret(tokens)
    local stack = {}

    local function push(value)
        table.insert(stack, value)
    end

    for _, token in ipairs(tokens) do
        if token.type == TokenType.NUMBER then
            push(token.value)

        elseif token.type == TokenType.OPERATOR then
            if #stack < 2 then
                error("Insufficient values in the stack for operation at index " .. token.index)
            end

            local b = table.remove(stack)
            local a = table.remove(stack)
            local result

            if token.value == "+" then
                result = a + b
            elseif token.value == "-" then
                result = a - b
            elseif token.value == "*" then
                result = a * b
            elseif token.value == "/" then
                if b == 0 then
                    result = "NAN"
                else
                    result = a / b
                end
            end

            push(result)
        elseif token.type == TokenType.KEYWORD and token.value == "push" then
            -- This simplification assumes handling of 'push' is direct; adjustments needed for actual sequence handling
        else
            error("Unknown or unsupported token at index " .. token.index)
        end
    end

    return stack
end

local function run(code)
    return (interpret(lexer.lex(code)))
end

local function run_file(filename)
    local file = assert(io.open(filename, "rb"))
    local code = file:read("*a")
    return run(code)
end

return {
    run = run,
    run_file = run_file,
    interpret = interpret,
}
