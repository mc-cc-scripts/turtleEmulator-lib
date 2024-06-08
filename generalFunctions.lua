local generalFunctions = {}
function generalFunctions.deepCopy(original)
    local copy
    if type(original) == 'table' then
        copy = {}
        for original_key, original_value in next, original, nil do
            copy[generalFunctions.deepCopy(original_key)] = generalFunctions.deepCopy(original_value)
        end
        setmetatable(copy, generalFunctions.deepCopy(getmetatable(original)))
    else -- number, string, boolean, etc
        copy = original
    end
    return copy
end

return generalFunctions