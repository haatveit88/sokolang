--  Sokolang prototype implementation
local lexer = require("lexer")
local printf = require("utils/printf")

local function interpret(tokens)
    local stack = {}

    local function push(value)
        table.insert(stack, value)
    end

    for _, token in ipairs(tokens) do
        if token.Type == TokenType.NUMBER then
            push(token.Value)

        elseif token.Type == TokenType.OPERATOR then
            if #stack < 2 then
                error("Insufficient values in the stack for operation at index " .. token.Index)
            end

            local b = table.remove(stack)
            local a = table.remove(stack)
            local result

            if token.Value == "+" then
                result = a + b
            elseif token.Value == "-" then
                result = a - b
            elseif token.Value == "*" then
                result = a * b
            elseif token.Value == "/" then
                if b == 0 then
                    result = "NAN"
                else
                    result = a / b
                end
            end

            push(result)
        elseif token.Type == TokenType.KEYWORD and token.Value == "push" then
            -- This simplification assumes handling of 'push' is direct; adjustments needed for actual sequence handling
        else
            error("Unknown or unsupported token at index " .. token.Index)
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
