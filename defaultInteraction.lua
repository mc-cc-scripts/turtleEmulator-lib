---@type Item
local turtleItem = {name = "computercraft:turtle_normal", count = 1, maxcount = 64}

---@type onInteration
local function defaultInteration(turtle, block, action)
    assert(turtle, "Turtle is nil")
    assert(turtle.emulator, "Turtle has no reference to the emulator")
    if block.emulator == nil then -- Block
        assert(block.item, "Block has no item")
        assert(block.item.name, "Block has no item name")
        if action == "dig" then
            block.item.count = block.item.count or 1
            block.item.maxcount = block.item.maxcount or 64
            turtle:addItemToInventory(block.item)
            turtle.emulator:removeBlock(block.position)
        end
    else -- Turtle. On a turtle, the "self" always gets inserted, therefore every parameter moves to the right
        if action == "dig" then
            assert(block.emulator, "Turtle has no reference to the emulator")
            block.emulator:removeTurtle(block)
            turtle:addItemToInventory(turtleItem)
        end
    end
end

return defaultInteration
