## Working functions

```lua
turtle.getFuelLevel()
turtle.turnLeft()
turtle.turnRight()
turtle.getSelectedSlot()
turtle.select(slotNum)
turtle.getItemCount(slotNum)
turtle.getItemSpace(slotNum)
turtle.getFuelLimit()
turtle.transferTo(slotNum, count)
turtle.equipLeft()
turtle.equipRight()
turtle.refuel(count)
turtle.dig()
turtle.digUp()
turtle.digDown()
turtle.forward()
turtle.back()
turtle.up()
turtle.down()
turtle.detect()
turtle.detectUp()
turtle.detectDown()
turtle.compare()
turtle.compareUp()
turtle.compareDown()
turtle.inspect()
turtle.inspectUp()
turtle.inspectDown()
turtle.compareTo(slotNum)
turtle.place(text)
turtle.placeUp(text)
turtle.placeDown(text)
```

## Implemented but not finished

### No check against fuel level or worldgen

```lua

```

## Implemented but not working

## Haven't started

```lua
turtle.drop(count)
turtle.dropUp(count)
turtle.dropDown(count)
turtle.suck(count)
turtle.suckUp(count)
turtle.suckDown(count)
turtle.attack()
turtle.attackUp()
turtle.attackDown()
turtle.craft(count)
peripheral.find("inventory, turtle, drive, ...")
```

Also: A way to manage the "state" of blocks (for turtle.inspect f.e.)
