--  Sokolang prototype implementation
local lexer = require("lexer")
local printf = require("utils/printf")

local function interpret(tokens)
    local stack = {}
    local printouts = {}

    local function log(msg)
        printouts[#printouts + 1] = tostring(msg)
    end

    local function size()
        return #stack
    end

    local function empty()
        return size() == 0
    end

    local function push(...)
        local args = { ... }
        for i, v in ipairs(args) do
            table.insert(stack, v)
        end
    end

    local function pop(n)
        n = n or 1
        local results = {}

        for i = 1, n do
            table.insert(results, 1, table.remove(stack))
        end

        return unpack(results)
    end

    local function peek(index)
        return stack[index or size()]
    end

    for _, token in ipairs(tokens) do
        if token.type == TokenType.NUMBER then
            push(token.value)
        elseif token.type == TokenType.OPERATOR then
            --REVIEW: Should tokens contain a min. required number of arguments, to be checked here? Or just label as unary, binary, etc.
            -- if #stack < 2 then
            -- error("Insufficient values in the stack for operation at index " .. token.index)
            -- end

            local result

            if token.value == "+" then
                local a, b = pop(2)
                result = a + b
            elseif token.value == "-" then
                local a, b = pop(2)
                result = a - b
            elseif token.value == "*" then
                local a, b = pop(2)
                result = a * b
            elseif token.value == "/" then
                local a, b = pop(2)
                if b == 0 then
                    result = "NAN"
                else
                    result = a / b
                end
            elseif token.value == "." then
                log(peek())
            end

            if result then
                push(result)
            end
        elseif token.type == TokenType.KEYWORD and token.value == "push" then
            -- This simplification assumes handling of 'push' is direct; adjustments needed for actual sequence handling
        elseif token.type == TokenType.KEYWORD and token.value == "dup" then
            -- duplicate the top stack value, adding a copy of it to the stack
            push(peek())
        elseif token.type == TokenType.KEYWORD and token.value == "swap" then
            -- swap the position of the top two stack values
            local a, b = pop(2)
            push(b, a)
        elseif token.type == TokenType.KEYWORD and token.value == "clear" then
            -- delete all stack items (clear the stack)
            local l = #stack
            for i = 0, l do stack[i] = nil end
        elseif token.type == TokenType.KEYWORD and token.value == "drop" then
            pop()
        elseif token.type == TokenType.KEYWORD and token.value == "rotate" then
            local n = #stack
            if n == 2 then
                -- Swap the top two elements
                local a, b = pop(2)
                push(b, a)
            elseif n >= 3 then
                local a, b, c = pop(3)
                push(c, a, b)
            end
        elseif token.type == TokenType.KEYWORD and token.value == "peek" then
            local n = pop()
            log(peek())
        else
            error("Unknown or unsupported token at index " .. token.index)
        end
    end

    return stack, printouts
end

local function run(code)
    return interpret(lexer.lex(code))
end


return {
    run = run,
    interpret = interpret,
}
