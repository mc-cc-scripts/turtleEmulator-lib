-- This is the default checkActionValid function
---@type checkActionValidFunc
local defaultcheckActionValid = function(turtle, action, block)
    -- example use cases:
    --
    -- if turtle.equipslots.left and turtle.equipslots.left.name == "" then end
    -- if action == "dig" then end
    -- if block.item.name == "" then end

    
    return true
end

return defaultcheckActionValid