# turtleEmulator-lib

This Libary is meant to Emulate the functions and behaviour of turtles in Minecraft.
This is exclusively useful for testing.

### HOW TO USE

1. Clone this Repository within yours as a submodule
2. require the ccPackage.lua of this repository

#### Setup

```lua
local turtleEmulator = require("turtleEmulator")
_G.turtle = turtleEmulator:createTurtle()
```


1. The TurtleEmulator needs to create a **turtle**, which will need to be used in globals.
    
    That will allow your normal scripts to run normally, - using the emulator-turtle
    The turtle will start at **position (0,0,0) facing the x direction**

2. That was it. Your minimalistic setup is done.

    The turtle will do all currently implemented operations as expected, such as
    ```lua
    turtle.forward()
    turtle.getFuelLevel()
    turtle.dig()
    ```


----
If you want further instructions about specific topics, follow these Docs:
1. [Add items to the inventory](INVENTORY.md)
2. [Create blocks within the world](BLOCKS.md)
3. [Peripherals](PERIPHERALS.md)