# Adding Blocks to the Environment

The TurtleEmulator keeps track of all the blocks within the emulated world.

To modify which blocks are present you can

1. Create each block as needed (containing Iteminformation, if needed)

```lua
local turtleEmulator = require("turtleEmulator")

local itemOfBlock = { name = "minecraft:stone", maxcount = 64 }
local block = { item = itemOfBlock, position = vector.new(1, 0, 0) }

turtleEmulator:createBlock(block)
turtleEmulator:removeBlock(block.position)
```
---
2. Remove all blocks
```lua
turtleEmulator:clearBlocks()
```
---
3. insert in bulk. The format should be the following (copied from the GeoScanner)

```lua
local blocksToEmulate = {
    {y = 0,x = 0,name = "minecraft:deepslate_iron_ore",z = -2,},
    {y = 0,x = 0,name = "computercraft:turtle_advanced",z = 0},
    {y = 2,x = 0,name = "enderchests:ender_chest",z = -2,}
}
turtleEmulator:readBlocks(blocksToEmulate)

-- or

-- with this funciton, you can define each block that gets created yourself
-- which is usefull, since scannedData does not contain any information the underlying item
-- or if you want to add inventories to each block containing "*chest*" etc.
-- this is the current default implementaion when no other function is given, just see it as an example
local mappingFunction = function(scannedBlock)
    return {
        item = {
            name = scanData.name,
            tags = scanData.tags
        },
        position = vector.new(scanData.x, scanData.y, scanData.z)
    }
end
turtleEmulator:readBlocks(blocksToEmulate, mappingFunction)
```
## Events

If you want the item to have specific interations when a turtle performs an action with the block, you will need to set the **checkActionValid** and **onInteraction** functions on the block, overwriting the default-behaviour

```lua
turtleEmulator:createBlock({
    item = { name = "minecraft:dirt" },
    position = vector.new(0, 1, 0),
    checkActionValid = { ["dig"] = function() return true end },
    onInteraction =
        function ()
            --- your code here
        end
})
```

---

**FULL EXAMPLE**

```lua
--- are the equiped tools valid?
local isToolValid = function(turtle, action, blockRef)
    if action ~= "dig" then return false end

    local tool1 = turtle.equipslots.left and turtle.equipslots.left.name or nil
    local tool2 = turtle.equipslots.right and turtle.equipslots.right.name or nil

    return (tool1 == "minecraft:hoe" or tool2 == "minecraft:hoe")
end;

-- On action: Change dirt to farmland, maybe change the durability etc....
local dirtInteraction = function(turtle, block, action)
    if block.item.name == "minecraft:dirt" and action == "dig" then
        block.item.name = "minecraft:farmland"
        return
    end
end



turtleEmulator:createBlock({
    item = { name = "minecraft:dirt" },
    position = vector.new(0, 1, 0),
    checkActionValid = { ["dig"] = isToolValid },
    onInteraction =
        dirtInteraction
})
_G.turtle = turtleEmulator:createTurtle()
turtle.addItemToInventory({ name = "minecraft:hoe", count = 1, maxcount = 1, equipable = true }, 3)

turtle.dig() -- false
turtle.select(3)
turtle.equipLeft()
turtle.dig() -- true

assert.are.equal("minecraft:farmland", turtleEmulator:getBlock({ x = 0, y = -1, z = 0 }).item.name) -- true
```