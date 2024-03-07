# turtleEmulator-lib

This Emulator is exclusively ment to enable testing CC code with a testingframework, outside MC and CraftOS.

### WIP

> Should increase in scope incrementally. For now it (will) only keep track of position and turtle-direction

### HOW TO USE

```lua
local turtleEmulator = require("<path>/turtleEmulator")

local turtleOne = turtleEmulator:createTurtle()
local turtleTwo = turtleEmulator:createTurtle()

-- override the default behavior, skipping fuelcheck etc.
turtleTwo.canMoveToCheck = function() return true end

turtleOne.forward()
assert(turtleOne.position.x == 1)

--...
```

### Restrictions

To allow the creation of multiple turtles within the same Emulator, the turtle returned by createTurtle is only a proxy, meaning that the metatable should not be modified.
However, should the need ever arise, you can modify it by getmetatable(turtle).\_\_metatable = nil. But please be aware that overriding the \_\_index and \_\_newIndex will break the functionality of the turtle.
