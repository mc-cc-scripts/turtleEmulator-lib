# How to modify the inventory

Adding an item to the inventory (e.g. of a turtle) is very easy
At first You define the item.

Each item needs a **"name"**

```lua
local turtleEmulator = require("turtleEmulator")
_G.turtle = turtleEmulator:createTurtle()

local itemToAdd = {name = "minecraft:coal", count = 64, fuelgain = 16}
local addToSlotNo = 2

turtle.addItemToInventory(itemToAdd, addToSlotNo) -- adds the item(s) to the slot 
turtle.removeItem(addToSlotNo, 64) -- removes 64 item(s) from the slot
```

Additional modifiers:

1. **count** _Type: number_

    how many items are within the items-entity

1. **maxcount** _Type: number_
   
    Defines how many items each slot can hold. E.g. Ender Perals can only hold 16

2. **fuelgain** _Type: number_

    Allows the turtle to refuel by consuming the item, by the specified amount

3. **placeAble** _Type: boolean_

    Defines weither or not the item can be placed as a block within the world (default: false).
    
    Will be overshadowed if the following function is defined:

4. **placeAction** _Type: function_

    Is the **optional** action, which will be called when the item attempts to be placed as a block.
    
    Parameters: Turtle (selfReference), Item (currentItem), Vector (position)

    Return (Expected): Success _Type: boolean_

5. **equipable** _Type: boolean_

    Defines if weither or not the item is equipable (default: false).

6. **tags** _Type: table_

    Any tags you might require. E.g. in the **geoScanner**