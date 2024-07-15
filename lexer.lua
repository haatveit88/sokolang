-- Sokolang lexer
require("token_types")

local function lex(code)
    local tokens = {}
    local index = 1
    local len = #code
    code = code .. " "  -- Adding a trailing space to capture the last token in the loop

    for i = 1, #code do
        local fragment = code:sub(i, i):match("%s")

        if fragment then
            if i > index then
                local lexeme = string.lower(code:sub(index, i - 1))

                local type
                local value

                if tonumber(lexeme) then
                    type = TokenType.NUMBER
                    value = tonumber(lexeme)
                elseif lexeme:match("[%+%-%*/%.]") then
                    type = TokenType.OPERATOR
                    value = lexeme
                elseif lexeme == "push" then
                    type = TokenType.KEYWORD
                    value = "push"
                elseif lexeme == "dup" then
                    type = TokenType.KEYWORD
                    value = "dup"
                elseif lexeme == "swap" then
                    type = TokenType.KEYWORD
                    value = "swap"
                elseif lexeme == "clear" then
                    type = TokenType.KEYWORD
                    value = "clear"
                elseif lexeme == "drop" then
                    type = TokenType.KEYWORD
                    value = "drop"
                elseif lexeme == "rotate" then
                    type = TokenType.KEYWORD
                    value = "rotate"
                elseif lexeme == "peek" then
                    type = TokenType.KEYWORD
                    value = "peek"
                else
                    type = TokenType.UNKNOWN
                    value = nil
                end

                if type ~= TokenType.UNKNOWN and value == nil then
                    error(string.format("Line [%i]: typed token created without a value: '%s'  (Source: %s)", index, type, fragment))
                end

                table.insert(tokens, {type = type, value = value, index = index})
            end
            index = i + 1
        end
    end

    return tokens
end


return {lex = lex}