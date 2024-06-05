-- This is the default checkActionValid function
---@type checkActionValidFunc
local defaultcheckActionValid = function(equipslots, action, block)
    -- example use cases:
    --
    -- if equipslots.left and equipslots.left.name == "" then end
    -- if action == "dig" then end
    -- if block.item.name == "" then end

    
    return true
end

return defaultcheckActionValid