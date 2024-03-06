# turtleEmulator-lib

This Emulator is exclusively ment to enable testing CC code with a testingframework, outside MC and CraftOS.

### WIP

> This Libary is not finished at all at this point and <b><u> will not work yet.</b></u>
> Should increase in scope incrementally. For now it (will) only keep track of position and turtle-direction

### HOW TO USE

```lua
local turtleEmulator = require("<path>/turtleEmulator")

local turtleOne = turtleEmulator:createTurtle()
local turtleTwo = turtleEmulator:createTurtle()

--currently this will only work with a self reference, will work on removing this neccessity
-- one possibilty is a Proxy table in the turtleEmulator #todo

```
