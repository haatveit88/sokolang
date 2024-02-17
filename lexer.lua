-- Sokolang lexer
require("token_types")

local function lex(code)
    local tokens = {}
    local tokenIndex = 1
    code = code .. " "  -- Adding a trailing space to capture the last token in the loop

    for i = 1, #code do
        if code:sub(i, i):match("%s") then
            if i > tokenIndex then
                local tokenStr = code:sub(tokenIndex, i - 1)
                local tokenType = TokenType.UNKNOWN
                local tokenValue = tokenStr

                if tonumber(tokenStr) then
                    tokenType = TokenType.NUMBER
                    tokenValue = tonumber(tokenStr)
                elseif tokenStr:match("[%+%-%*/]") then
                    tokenType = TokenType.OPERATOR
                elseif tokenStr == "push" then
                    tokenType = TokenType.KEYWORD
                end

                table.insert(tokens, {Type = tokenType, Value = tokenValue, Index = tokenIndex})
            end
            tokenIndex = i + 1
        end
    end

    return tokens
end


return {lex = lex}