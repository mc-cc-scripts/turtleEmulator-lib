# Using Peripherals

The Emulator will wraps peripherals, so they can be used within your script

There are some pre-existing peripherals in this emulator, but if your required peripheral has not been added (yet),
doing so yourself should not be too much work - as described further down.

## Important
The lifecycle of peripherals is not (yet) manged by the emulator.
Should that be relevant to your tests, please manage them yourself with the help of the __OnAction__ events currently provied in [Blocks](BLOCKS.md) and [Items](INVENTORY)

## Using existing peripherals

When attempting to use peripherals, it is important to get the **peripheral** **from** a **turtle**.
That is, because the "peripheral" is a global within ComputerCraft / CCTweaked - while also beeing unique to each turtle. (yes, the emulator can handle multiple (somewhat WIP))

Using **Chests** as an example for Block-Peripherals:

```lua
-- setup in your testing-env
local turtleEmulator = require("turtleEmulator")
local chestInventory = require("chestInventory") -- the peripheral-Class


_G.turtle = turtleEmulator:createTurtle() -- create the turtle and set it as global
_G.peripheral = turtle.getPeripheralModule() -- get the peripheral and set it as global 


--- create any block, make it a peripheral of type <Inventory>
local block = turtleEmulator:createBlock({ item = { name = "minecraft:chest" }, position = vector.new(1, 0, 0 ) })
local chest = turtleEmulator:addPeripheralToItem(block.item, chestInventory)

-- the following could be in the script you want to test
local chest = peripheral.find("inventory")
assert(1 = chest.getItemCount(1))
```

Using **GeoScanner** as an example for equipable-Peripherals:
```lua
-- setup in your testing-env
local turtleEmulator = require("turtleEmulator")
local chestInventory = require("chestInventory") -- the peripheral-Class


_G.turtle = turtleEmulator:createTurtle() -- create the turtle and set it as global
_G.peripheral = turtle.getPeripheralModule() -- get the peripheral and set it as global 

-- create the item, make it a peripheral of type <GeoScanner>
turtle.addItemToInventory({ name = "advancedperipherals:geoscanner", count = 1, maxcount = 1, equipable = true}, 1)
turtleEmulator:addPeripheralToItem(turtle.inventory[1], geoScanner, turtle)
-- mock the result
scanner.scanResult = { { name = "minecraft:stone", count = 64, tags = {} } }

-- in the script you want to test
turtle.equipLeft()
local scanner = peripheral.wrap("left")
local result = scanner.scan(8)
assert(result[1].name == "minecraft:stone")
```

## Creating your own Peripheral

When creating your peripheral, please make sure to use the *CCClass.lua" provided in the TestSuite-lib, or a similar Class & Instance creator.

As long as your peripheral is build like described below and correctly provied to the _addPeripheralToItem_ - function in the turtleEmulator, your peripheral should be good to go, including adding the self-reference missing in the CCScript

```lua
---@type ccClass
local class = require("ccClass")
---@class MyOwnPeripheral : PeripheralActions
local myOwnPeripheral = class(function (a, turtle, additionalParameter1, ...)
    -- this is the constructor
    a.turtle = turtle
    a.additionalField1 = additionalParameter1
    -- ...
end)

function myOwnPeripheral:doStuff()
end
-- ...

return myOwnPeripheral
```