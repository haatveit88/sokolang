-- terminal output color code sequences (ECMA-48)
local prefix = "\27["
local postfix = "\27[0m"

local colors = {
    reset = 0,

    red = 31,
    green = 32,
    yellow = 33,
    blue = 34,
    magenta = 35,
    cyan = 36,
    white = 37,

    red_bright = 91,
    green_bright = 92,
    yellow_bright = 93,
    blue_bright = 94,
    magenta_bright = 95,
    cyan_bright = 96,
    white_bright = 97,
}

local function wrap(input, col)
    return string.format("%s%sm%s%s", prefix, tostring(col), input, postfix)
end

return {colors = colors, wrap = wrap}