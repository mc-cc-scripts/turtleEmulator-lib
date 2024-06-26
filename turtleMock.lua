


---@alias direction "forward" | "back" | "up" | "down"
---@alias facing
---| 0 North
---| 1 East
---| 2 South
---| 3 West
---@alias north integer
---@alias east integer
---@alias height integer
---@alias position {x: north, y: east, z: height}



---@alias left string
---@alias right string
---@alias equipslots {left: item, right: item}

---@alias inspectResult {name: string, tags: table<string, any> | nil, state: table<string, any> | nil} | nil

local defaultInteraction = require("../defaultInteraction")
local deepCopy = require("../generalFunctions").deepCopy
local inventory = require("../inventory")
---@class TurtleMock
---@field position position | nil
---@field facing facing | nil
---@field canPrint boolean | nil
---@field fuelLevel integer | nil
---@field inventory inventory | nil
---@field fuelLimit integer | nil
---@field equipslots equipslots | nil
---@field emulator TurtleEmulator | nil
---@field id number | nil

---@class TurtleProxy : TurtleMock

--- this class should not be used directly, use the createMock of the turtleEmulator function instead, which will set the proxy
---@class TurtleMock
local turtleMock = {

}


---@param self TurtleProxy | TurtleMock
---@param act boolean | nil
---@return boolean
---@return string | nil
---@return position
local function forward(self, act)
    if act == nil then
        act = true
    end
    ---@type position
    local newPosition = deepCopy(self.position)
    if self.facing == 0 then
        newPosition.x = self.position.x + 1
    elseif self.facing == 1 then
        newPosition.z = self.position.z + 1
    elseif self.facing == 2 then
        newPosition.x = self.position.x - 1
    elseif self.facing == 3 then
        newPosition.z = self.position.z - 1
    end
    if self.emulator:getBlock(newPosition) ~= nil then
        return false, "Movement obstructed", newPosition
    end
    if self.fuelLevel < 1 then
        return false, "Out of fuel", newPosition
    end
    if act then
        self.position = newPosition
        self.fuelLevel = self.fuelLevel - 1
    end
    return true, nil, newPosition
end

---@param self TurtleProxy | TurtleMock
---@param act boolean | nil
---@return boolean
---@return string | nil
---@return position
local function back(self, act)
    if act == nil then
        act = true
    end
    local newPosition = deepCopy(self.position)
    if self.facing == 0 then
        newPosition.x = self.position.x - 1
    elseif self.facing == 1 then
        newPosition.z = self.position.z - 1
    elseif self.facing == 2 then
        newPosition.x = self.position.x + 1
    elseif self.facing == 3 then
        newPosition.z = self.position.z + 1
    end
    if self.emulator:getBlock(newPosition) ~= nil then
        return false, "Movement obstructed", newPosition
    end
    if self.fuelLevel < 1 then
        return false, "Out of fuel", newPosition
    end
    if act then
        self.position = newPosition
        self.fuelLevel = self.fuelLevel - 1
    end
    return true, nil, newPosition
end

---@param self TurtleProxy | TurtleMock
---@param act boolean | nil
---@return boolean
---@return string | nil
---@return position
local function up(self, act)
    if act == nil then
        act = true
    end
    local newPosition = deepCopy(self.position)
    newPosition.y = self.position.y + 1
    if self.emulator:getBlock(newPosition) ~= nil then
        return false, "Movement obstructed", newPosition
    end
    if self.fuelLevel < 1 then
        return false, "Out of fuel", newPosition
    end
    if act then
        self.position = newPosition
        self.fuelLevel = self.fuelLevel - 1
    end

    return true , nil, newPosition
end

---@param self TurtleProxy | TurtleMock
---@param act boolean | nil
---@return boolean
---@return string | nil
---@return position
local function down(self, act)
    if act == nil then
        act = true
    end
    local newPosition = deepCopy(self.position)
    newPosition.y = self.position.y - 1
    if self.emulator:getBlock(newPosition) ~= nil then
        return false, "Movement obstructed", newPosition
    end
    if self.fuelLevel < 1 then
        return false, "Out of fuel", newPosition
    end
    if act then
        self.position = newPosition
        self.fuelLevel = self.fuelLevel - 1
    end
    return true, nil, newPosition
end

--- ### Description:
--- Switches slots if available.
---
--- If item is stackable, the old equip will be added to the inventory, if possible.
---
--- Otherwise the items are just switched
---
--- If no slot is available, the turtle will dispone the old item
---@param turtle TurtleMock
---@param slot number
---@param side left | right
---@return boolean
---@return string | nil
local function equip(turtle, slot, side)
    assert(side~= nil, "To Equip an Item, the side must be specified")
    local item = turtle.inventory[slot]
    if item == nil or not item.equipable then
        return false, "Not a valid upgrade"
    end
    local equipedItem
    local itemCopy = deepCopy(item)
    if turtle.equipslots == nil  then
            turtle.equipslots = {side = itemCopy}
    else
        equipedItem = turtle.equipslots[side]
        turtle.equipslots[side] = itemCopy
    end
    turtle.equipslots[side].count = 1
    turtle.inventory:removeItem(slot, 1)
    if equipedItem ~= nil then
        local newSlot = turtle.inventory:findFittingSlot(equipedItem, slot)
        if newSlot ~= nil then
            turtle.inventory[newSlot] = equipedItem
        end
    end
    return true
end

--- ### Description:
---
--- Checks if the turtle can do the action against the block
---
--- if nothing is setup, then all actions is not valid
---
--- if the action is setup, but the requirement(table) is empty, then the action is valid
---
--- note: Order is left to right on priority on equipment
---@param turtle TurtleMock
---@param block block | nil
---@param action string
---@return boolean
local function canDoAction(turtle, block, action)
    local text = "Block cannot be interacted with whatsoever, missing Setup."..
        "If you want to prevent the turtle from interacting with the block, "..
        "set checkActionValid to {'<action>' = {}} or leave it empty to allow all actions"
    -- check typeof function
    assert(block and block.checkActionValid, text)
    if type(block.checkActionValid) == "function" then
        return block.checkActionValid(turtle.equipslots, action, block)
    end
    assert(block.checkActionValid[action] ~= nil, text)
    if type(block.checkActionValid[action]) == "function" then
        return block.checkActionValid[action](turtle.equipslots, action, block)
    end
        
    if turtle.equipslots == nil then
        return false
    end
    -- check typeof string
    if type(block.checkActionValid[action]) == "string" then
        local requiredTool = block.checkActionValid[action]
        if turtle.equipslots.left and requiredTool == turtle.equipslots.left.name then
            return true
        end
        if turtle.equipslots.right and requiredTool == turtle.equipslots.right.name then
            return true
        end
        return false
    end

    -- check typeof table
    if type(block.checkActionValid[action]) == "table" then
        ---@diagnostic disable-next-line: param-type-mismatch
        for _, requiredTool in pairs(block.checkActionValid[action]) do
            if type(requiredTool) == "string" then
                if turtle.equipslots.left and requiredTool == turtle.equipslots.left.name then
                    return true
                end
                if turtle.equipslots.right and requiredTool == turtle.equipslots.right.name then
                    return true
                end
            end
            if type(requiredTool) == "function" then
                return requiredTool(turtle.equipslots, action, block)
            end
        end
        return false
    end
    return false
end 

--- ### Description:
---
--- Digs the specified block, if possible
---@param turtle TurtleProxy | TurtleMock
---@param block block | nil
---@return boolean
---@return string | nil
local function dig(turtle, block)
    
    if not canDoAction(turtle, block, "dig") then
        return false, "Cannot beak block with this tool"
    end
    assert(block, "Block is nil")
    ---@cast turtle TurtleProxy
    block.onInteration(turtle, block, "dig")
    return true, "Cannot beak block with this tool"
end

---@param block block | nil
---@return boolean
local function detect(block)
    return block and true or false
end

---@param block block | nil
---@param compareItem item | nil
---@return boolean
local function compareBlock(block, compareItem)
    if block == nil and compareItem == nil then
        return true
    end
    if block == nil and compareItem ~= nil then
        return false
    end
    if compareItem == nil and block ~= nil then
        return false
    end

    if not (block and block.item and block.item.name) then
        error("Block has no item")
    end
    if not (compareItem and compareItem.name) then
        error("CompareItem has no name")
    end
    return block.item.name == compareItem.name
end

---@param block block | nil
---@return boolean
---@return inspectResult
local function inspect(block)
    if block == nil or block.item == nil or block.item.name == nil then
        return false, nil
    end
    return true, { name = block.item.name, tags = block.item.tags, state = block.state }
end

---@param turtle TurtleProxy | TurtleMock
---@param position position
---@return boolean
---@return string | any | nil
local function place(turtle, position)
    local item = turtle.inventory[turtle.inventory.selectedSlot]
    if item == nil then
        return false, "No item to place"
    end
    if item.placeAction ~= nil then 
        return item.placeAction(turtle, item, position)
    end
    if item.placeAble == nil or item.placeAble == false then
        return false, "Cannot place item here"
    end
    local block = turtle.emulator:getBlock(position)
    if block ~= nil then
        return false, "Cannot place block here"
    end
    turtle.emulator:createBlock({item = item, position = position})
    return turtle.inventory:removeItem(turtle.inventory.selectedSlot, 1)
end

---@param emulator TurtleEmulator
---@return TurtleProxy
function turtleMock.createMock(emulator, id)
    local turtle = {
        ---@type position
        position = { x = 0, y = 0, z = 0 },
        ---@type facing
        facing = 0,
        ---@type number
        fuelLevel = 0,
        ---@type boolean
        canPrint = false,
        ---@type inventory
        inventory = inventory:createInventory(16),
        ---@type integer
        selectedSlot = 1,
        ---@type integer
        fuelLimit = 100000,
        equipslots = {},
        emulator = emulator,
        id = id,
        item = { name = "computercraft:turtle_normal" },
        checkActionValid = {["dig"] = function (equipslots, action, block)
            if equipslots.left and equipslots.left.name == "minecraft:pickaxe" then
                return true
            end
            if equipslots.right and equipslots.right.name == "minecraft:pickaxe" then
                return true
            end
            return false
        end},
        onInteration = defaultInteraction
    }
    setmetatable(turtle, { __index = turtleMock })

    local proxy = {}
    local mt = {}
    mt.__index = function(_, key)
        local value = turtle[key]
        if type(value) == "function" then
            return function(...)
                if value == turtle.onInteration then
                    return value(...)
                end
                local mightBeSelf = select(1, ...)
                if mightBeSelf == turtle then
                    return value(...)
                elseif mightBeSelf == proxy then
                ---@diagnostic disable-next-line: missing-parameter
                    return value(turtle, select(2, ...))
                end
                return value(turtle, ...)
            end
        end
        return value
    end
    mt.__newindex = function(_, key, value)
        turtle[key] = value
    end
    mt.__metatable = mt

    setmetatable(proxy, mt)
    return proxy
end

function turtleMock:forward()
    return forward(self)
end

function turtleMock:back()
    return back(self)
end

function turtleMock:up()
    return up(self)
end

function turtleMock:down()
    return down(self)
end

function turtleMock:turnLeft()
    self.facing = (self.facing - 1) % 4
    return true
end

function turtleMock:turnRight()
    self.facing = (self.facing + 1) % 4
    return true
end

function turtleMock:getSelectedSlot()
    return self.inventory.selectedSlot
end

--- gets the item count in the selected slot or the specified slot
---@param slot integer the slot to get the item-count from
---@return integer count the amount of items in the slot
function turtleMock:getItemCount(slot)
    return self.inventory:getItemCount(slot)
end

--- gets the space in the selected slot or the specified slot
---@param slot integer the slot to get the space for
---@return integer space maxcount - currentcount
function turtleMock:getItemSpace(slot)
    return self.inventory:getItemSpace(slot)
end

function turtleMock:getSocket(socket)

end

--- gets the item in the selected slot or the specified slot
---@param slot integer | nil the slot to get the item-details from
---@return item | nil item the item in the slot
function turtleMock:getItemDetail(slot)
    return self.inventory:getItemDetail(slot)
end

--- Compare the item in the selected slot to the item in the specified slot.
---@param slot integer
---@return boolean equal true if the items are equal
function turtleMock:compareTo(slot)
    return self.inventory:compareTo(slot)
end

function turtleMock:removeItem(slot, count)
    return self.inventory:removeItem(slot, count)
end

--- Transfers items between the selected slot and the specified slot.
---
--- <b>note</b>: this function will transfer items when there is not enough room, but will return false non the less...
---@param slot integer the slot to transfer to
---@param count integer the amount of items to transfer
---@return boolean success true if the transfer was successful
---@return string | nil errorReason the reason why the transfer failed
function turtleMock:transferTo(slot, count)
    return self.inventory:transferTo(slot, count)
end

--- Transfers items between the selected slot and the specified slot.
---@param slot number the slot to transfer to
---@return boolean
function turtleMock:select(slot)
    return self.inventory:select(slot)
end

--- for Testing purposes:
--- adds an item to the inventory
---@param item item
---@param slot number | nil
function turtleMock:addItemToInventory(item, slot)
    return self.inventory:addItemToInventory(item, slot)
end

--- gets the current fuel level
---@return integer fuelLevel
function turtleMock:getFuelLevel()
    return self.fuelLevel
end

function turtleMock:getFuelLimit()
    return self.fuelLimit
end

--- refuels the turtle
---@param count number
---@return boolean
---@return string | nil
function turtleMock:refuel(count)
    count = count or 1
    assert(count > 0, "Count must be greater than 0")
    local item = self.inventory[self.inventory.selectedSlot]
    if item == nil or count > item.count then
        return false, "TODO"
    end
    if item == nil then
        return false, "TODO"
    end
    if item.fuelgain == nil or item.fuelgain == 0 then
        return false, "TODO"
    end
    if self.inventory:removeItem(self.inventory.selectedSlot, count) == false then
        return false, "TODO"
    end
    self.fuelLevel = self.fuelLevel + item.fuelgain * count
    return true
end

--- Equips the item in the selected slot to the left side
---@return boolean
---@return string | nil
function turtleMock:equipLeft()
    return equip(self, self.inventory.selectedSlot, "left")
end

--- Equips the item in the selected slot to the right side
function turtleMock:equipRight()
    return equip(self, self.inventory.selectedSlot, "right")
end

function turtleMock:dig()
    local _, _, blockPos = forward(self, false)
    ---@type block | nil
    local block = self.emulator:getBlock(blockPos)
    
    return dig(self, block)
end

function turtleMock:digUp()
    local blockPos = self.emulator:getBlock({x = self.position.x, y = self.position.y + 1, z = self.position.z})
    return dig(self, blockPos)
end

function turtleMock:digDown()
    local blockPos = self.emulator:getBlock({x = self.position.x, y = self.position.y - 1, z = self.position.z})
    return dig(self, blockPos)
end

function turtleMock:detect()
    local _, _, blockPos = forward(self, false)
    local block = self.emulator:getBlock(blockPos)
    return detect(block)
end

function turtleMock:detectUp()
    local block = self.emulator:getBlock({x = self.position.x, y = self.position.y + 1, z = self.position.z})
    return detect(block)
end

function turtleMock:detectDown()
    local block = self.emulator:getBlock({x = self.position.x, y = self.position.y - 1, z = self.position.z})
    return detect(block)
end

function turtleMock:compare()
    local _, _, blockPos = forward(self, false)
    local block = self.emulator:getBlock(blockPos)
    return compareBlock(block, self.inventory[self.inventory.selectedSlot])
end

function turtleMock:compareUp()
    local block = self.emulator:getBlock({x = self.position.x, y = self.position.y + 1, z = self.position.z})
    return compareBlock(block, self.inventory[self.inventory.selectedSlot])
end

function turtleMock:compareDown()
    local block = self.emulator:getBlock({x = self.position.x, y = self.position.y - 1, z = self.position.z})
    return compareBlock(block, self.inventory[self.inventory.selectedSlot])
end

function turtleMock:inspect()
    local _, _, blockPos = forward(self, false)
    local block = self.emulator:getBlock(blockPos)
    return inspect(block)
end

function turtleMock:inspectUp()
    local block = self.emulator:getBlock({x = self.position.x, y = self.position.y + 1, z = self.position.z})
    return inspect(block)
end

function turtleMock:inspectDown()
    local block = self.emulator:getBlock({x = self.position.x, y = self.position.y - 1, z = self.position.z})
    return inspect(block)
end

function turtleMock:place()
    local _, _, blockPos = forward(self, false)
    return place(self, blockPos)
end

function turtleMock:placeUp()
    local blockPos = {x = self.position.x, y = self.position.y + 1, z = self.position.z}
    return place(self, blockPos)
end

function turtleMock:placeDown()
    local blockPos = {x = self.position.x, y = self.position.y - 1, z = self.position.z}
    return place(self, blockPos)
end

---will only print content if canPrint is set to true
---@param ... any
---@return nil
function turtleMock:print(...)
    if (self.canPrint == true) then
        print(...)
    end
end

return turtleMock
