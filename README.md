# turtleEmulator-lib

This Emulator is exclusively ment to enable testing CC turtle-code with a testingframework (namely busted), outside MC and CraftOS.

### WIP

 Should increase in scope incrementally.

> For now it only supports all functions listed in the Progress.md

### HOW TO USE

```lua
local turtleEmulator = require("<path>/turtleEmulator")

-- create turtles
local turtleOne = turtleEmulator:createTurtle()
local turtleTwo = turtleEmulator:createTurtle()

-- add items to turtles for testing
turtleOne.addItemToInventory({ 
    name = "minecraft:coal",
    count = 64,
    maxcount = 64,
    fuelgain = 8
})
turtleOne.refuel(64)

assert(true == turtleOne.forward(), "I have fuel and should work")
assert(false == turtleTwo.forward(), "I have no fuel and should not work")

-- add block to World
turtleEmulator:createBlock({
    item = {
        name = "minecraft:dirt"
    },
    position = { x = 0, y = -1, z = 0 }
})

```
---
### Restrictions

To allow the creation of multiple turtles within the same Emulator, the turtle returned by createTurtle is only a proxy, meaning that the metatable should not be modified!
However, should the need ever arise, you can modify it by getmetatable(turtle).\_\_metatable = nil. But please be aware that overriding the \_\_index and \_\_newIndex will break the functionality of the turtle.
