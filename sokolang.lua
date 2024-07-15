--  Sokolang prototype implementation
local lexer = require("lexer")
local printf = require("utils/printf")

local function preprocess(tokens)
    local expanded_tokens = {}
    local index = 1

    while index <= #tokens do
        local token = tokens[index]

        if token.type == TokenType.REPEAT and token.value == "!" then
            -- handle REPEATs, replace with previous non-repeat instruction
            local repetitions = 1
            while index + repetitions <= #tokens and tokens[index + repetitions].type == TokenType.REPEAT do
                repetitions = repetitions + 1
            end

            local previous = expanded_tokens[#expanded_tokens]
            for i = 1, repetitions do
                table.insert(expanded_tokens, previous)
            end

            index = index + repetitions
        else
            -- pass token through unchanged
            table.insert(expanded_tokens, token)
            index = index + 1
        end
    end

    return expanded_tokens
end


local function interpret(tokens)
    tokens = preprocess(tokens)
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

    for index, token in ipairs(tokens) do
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
            end

            if result then
                push(result)
            end
        elseif token.type == TokenType.PRINT and token.value == "." then
            log(peek())
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
            log(peek(n))
        else
            local remaining_tokens = ""
            local pointer
            for i = index, #tokens do
                pointer = i == index and " <<< that's this one" or ""
                remaining_tokens = remaining_tokens ..
                string.format("\n%i:{%s, %s}%s", i, tokens[i].type, tokens[i].value, pointer)
            end
            local err = string.format("\nUnknown or unsupported token at source index %i\n%s\n", index, remaining_tokens)
            error(err)
        end
    end

    return stack, printouts
end

local function run(code, dump)
    local tokens = lexer.lex(code)

    if dump then
        for k, v in ipairs(tokens) do
            print(string.format("%i:{%s, %s}", k, v.type, v.value))
        end
    end

    return interpret(tokens)
end


return {
    run = run,
    interpret = interpret,
}
