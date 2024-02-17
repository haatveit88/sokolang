local function printf(str, ...)
    if select("#", ...) > 0 then
        print(string.format(str, ...))
    else
        print(str)
    end
end

return printf