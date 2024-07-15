-- Sokolang lexer
require("token_types")

local keywords = {
    ["push"] = TokenType.KEYWORD,
    ["dup"] = TokenType.KEYWORD,
    ["swap"] = TokenType.KEYWORD,
    ["clear"] = TokenType.KEYWORD,
    ["drop"] = TokenType.KEYWORD,
    ["rotate"] = TokenType.KEYWORD,
    ["peek"] = TokenType.KEYWORD,
}

local delimiters = "[%s%+%*/%.!,]"

local tokens = {}
local index = 1

local function eat()
    index = index + 1
end

local function add_token(type, value)
    table.insert(tokens, { type = type, value = value, index = index })
end

local function lex(input)
    while index <= #input do
        local char = input:sub(index, index)

        if char:match("%s") then
            -- Any extra whitespace handling goes here
            eat()
        elseif char:match("[%+%*/]") then
            -- Handle operators
            add_token(TokenType.OPERATOR, char)
            eat()
        elseif char == "." then
            add_token(TokenType.PRINT, char)
            eat()
        elseif char == "," then
            --TODO: Handle commas inside arrays
            eat()
        elseif char == '!' then
            add_token(TokenType.REPEAT, char)
            eat()
        elseif char:match("%d") or (char == '-' and index < #input and input:sub(index + 1, index + 1):match("%d")) then
            -- Handle numbers, including negative ones
            local num = char
            eat()

            while index <= #input and input:sub(index, index):match("%d") do
                num = num .. input:sub(index, index)
                eat()
            end

            add_token(TokenType.NUMBER, tonumber(num))
        else
            -- Check for keywords and unknown tokens
            local start_index = index

            -- Iterate forward until a delimiter (whitespace, operator, etc.) is found
            while index <= #input and not input:sub(index, index):match(delimiters) do
                eat()
            end

            -- Extract the potential keyword or unknown token
            local lexeme = input:sub(start_index, index - 1)

            -- Check if the lexeme is a keyword
            for keyword in pairs(keywords) do
                if lexeme:sub(1, #keyword) == keyword then
                    add_token(keywords[keyword], keyword)
                    if #lexeme > #keyword then
                        -- Handle the rest of the lexeme if it's followed by a number
                        local remainder = lexeme:sub(#keyword + 1)
                        if remainder:match("^%-?%d+$") then
                            add_token(TokenType.NUMBER, tonumber(remainder))
                        else
                            -- If it's not a number, consider it unknown
                            for i = 1, #remainder do
                                add_token(TokenType.UNKNOWN, remainder:sub(i, i))
                            end
                        end
                    end
                    lexeme = nil
                    break
                end
            end

            -- If the lexeme was not a keyword, handle it as unknown
            if lexeme then
                for i = 1, #lexeme do
                    add_token(TokenType.UNKNOWN, lexeme:sub(i, i))
                end
            end
        end
    end

    return tokens
end

return { lex = lex }
