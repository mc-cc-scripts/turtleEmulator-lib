


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

---@alias item {name: string, durabilty: integer, equipable: boolean, fuelgain: integer, placeAble: boolean, maxcount: number, wildcardInfo: any, count: integer}
---@alias inventory { [integer]: item }

---@alias left string
---@alias right string
---@alias equipslots {left: item, right: item}


---@class TurtleMock
---@field position position
---@field facing facing
---@field canMoveToCheck fun(direction: direction): boolean
---@field canPrint boolean
---@field fuelLevel integer
---@field inventory inventory
---@field selectedSlot integer
---@field fuelLimit integer
---@field defaultMaxSlotSize integer
---@field equipslots equipslots
---@field emulator TurtleEmulator
--- this class should not be used directly, use the createMock of the turtleEmulator function instead, which will set the proxy
local turtleMock = {

}

local function deepCopy(original)
    local copy
    if type(original) == 'table' then
        copy = {}
        for original_key, original_value in next, original, nil do
            copy[deepCopy(original_key)] = deepCopy(original_value)
        end
        setmetatable(copy, deepCopy(getmetatable(original)))
    else -- number, string, boolean, etc
        copy = original
    end
    return copy
end

---@param self TurtleMock
---@param direction string the direction to move to
---@return boolean success if the turtle can move to the direction
---@return string | nil errorReason the reason why the turtle can't move to the direction
local function canMoveTo(self, direction)
    if self.canMoveToCheck ~= nil and type(self.canMoveToCheck) == "function" then
        if not self.canMoveToCheck(direction) then
            return false, "Can't move to " .. direction
        else
            return true
        end
    else
        --TODO implement a check for the world
        return false, "Move to  " .. direction .. " is not implemented yet."
    end
end

local function forward(self)
    if self.facing == 0 then
        self.position.x = self.position.x + 1
    elseif self.facing == 1 then
        self.position.z = self.position.z + 1
    elseif self.facing == 2 then
        self.position.x = self.position.x - 1
    elseif self.facing == 3 then
        self.position.z = self.position.z - 1
    end
    return true
end

local function back(self)
    if self.facing == 0 then
        self.position.x = self.position.x - 1
    elseif self.facing == 1 then
        self.position.z = self.position.z - 1
    elseif self.facing == 2 then
        self.position.x = self.position.x + 1
    elseif self.facing == 3 then
        self.position.z = self.position.z + 1
    end
    return true
end

local function up(self)
    self.position.y = self.position.y + 1
    return true
end

local function down(self)
    self.position.y = self.position.y - 1
    return true
end

local function slotNotEmpty(slot)
    return slot ~= nil
end

--- Finds the first slot containing the specified item or no Item, starting with the selected slot and looping around.
---@param turtle TurtleMock
---@param item item
---@param startingSlot number
local function findFittingSlot(turtle, item, startingSlot)
    for i = startingSlot, 16 do
        if turtle.inventory[i] == nil then
            return i
        end
        if turtle.inventory[i].name == item.name and turtle:getItemSpace(i) > 0 then
            return i
        end
    end
    for i = 1, startingSlot - 1 do
        if turtle.inventory[i] == nil then
            return i
        end
        if turtle.inventory[i].name == item.name and turtle:getItemSpace(i) > 0 then
            return i
        end
    end
end

--- Adds items to the selected slot or the specified slot.
---
--- <b>note</b>: This function will only work for tests and does not work on the CraftOS-Turtle
---@param turtle TurtleMock
---@param item item
---@param slot number | nil
local function pickUpItem(turtle, item, slot)
    assert(item.count > 0, "Count must be greater than 0")
    turtle:print("Item: ", item.count)
    if slot == nil then
        while item.count > 0 do
            local fittingSlot = findFittingSlot(turtle, item, turtle.selectedSlot)
            if fittingSlot == nil then
                return false, "No fitting slot found"
            end
            local space = turtle:getItemSpace(fittingSlot)
            local toTransfer = math.min(space, item.count)

            local currentCount = turtle:getItemCount(fittingSlot)
            turtle.inventory[fittingSlot] = deepCopy(item)
            if (turtle.inventory[fittingSlot] == nil) then
                turtle.inventory[fittingSlot].maxcount = item.maxcount or turtle.defaultMaxSlotSize
            end
            turtle.inventory[fittingSlot].count = currentCount + toTransfer
            item.count = item.count - toTransfer
        end
    else
        assert((slot >= 1 and slot <= 16), "Slot number " .. slot .. " out of range")
        if slotNotEmpty(turtle.inventory[slot] ) and turtle.inventory[slot].name ~= item.name then
            return false, "Can't pick up item, slot is not empty"
        end
        if turtle:getItemSpace(slot) < item.count then
            return false, "Not enough space in the slot"
        end
        if turtle.inventory[slot] == nil then
            turtle.inventory[slot] = item
        else
            turtle.inventory[slot].count = turtle.inventory[slot].count + item.count
        end
    end
    return true
end

local function functionNotFoundError(key)
    return error("Function / Key: '" .. key .. "' not found")
end

--- ### Description:
---@param turtle TurtleMock
---@param slot number
---@param count number
---@return boolean
---@return string | nil
local function removeItem(turtle, slot, count)
    local item = turtle.inventory[slot]
    if item == nil then
        return false, "No item in the slot"
    end
    if item.count < count then
        return false, "Not enough items in the slot"
    end
    item.count = item.count - count
    if item.count == 0 then
        turtle.inventory[slot] = nil
    end
    return true
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
    removeItem(turtle, slot, 1)
    if equipedItem ~= nil then
        local newSlot = findFittingSlot(turtle, equipedItem, slot)
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
---@param turtle TurtleMock
---@param block block
---@param action string
---@return boolean
local function canDoAction(turtle, block, action)
    if block.checkActionValid == nil or block.checkActionValid[action] == nil then
        return false
    end
    if type(block.checkActionValid[action]) == "string" then
        if turtle.equipslots == nil then
            return false
        end
        if block.checkActionValid[action] == turtle.equipslots.left.name then
            return true
        end
        if block.checkActionValid[action] == turtle.equipslots.right.name then
            return true
        end
    end
    if type(block.checkActionValid[action]) == "table" then
        if #block.checkActionValid[action] == 0 then
            return true
        end
        if turtle.equipslots == nil then
            return false
        end
        if turtle.equipslots.left ~= nil and block.checkActionValid[action][turtle.equipslots.left.name] ~= nil then
            return true
        end
        if turtle.equipslots.right ~= nil and block.checkActionValid[action][turtle.equipslots.right.name] ~= nil then
            return true
        end
    end
    if type(block.checkActionValid[action]) == "function" then
        return block.checkActionValid(turtle.equipslots, action, block)
    end
    return false
end 

--- ### Description:
---
--- Digs in the specified direction
---@param turtle TurtleMock
---@param direction "forward" | "up" | "down"
---@return boolean
---@return string | nil
local function dig(turtle, direction)
    ---@type block
    local block = nil
    if not canDoAction(turtle, block, "dig") then
        return false, "TODO"
    end
    return false, "TODO"
end

---@param emulator TurtleEmulator
---@return TurtleProxy
function turtleMock.createMock(emulator)
    ---@type TurtleMock
    local turtle = {
        ---@type position
        position = { x = 0, y = 0, z = 0 },
        ---@type facing
        facing = 0,
        ---@type fun(direction: direction): boolean
        canMoveToCheck = nil,
        ---@type number
        fuelLevel = 0,
        ---@type boolean
        canPrint = false,
        ---@type inventory
        inventory = {},
        ---@type integer
        selectedSlot = 1,
        ---@type integer
        fuelLimit = 100000,
        ---@type integer
        defaultMaxSlotSize = 64,
        equipslots = {},
        emulator = emulator
    }
    setmetatable(turtle, { __index = turtleMock })

    ---@class TurtleProxy : TurtleMock
    local proxy = {}
    local mt = {}
    mt.__index = function(_, key)
        local value = turtle[key]
        if type(value) == "function" then
            return function(...)
                local mightBeSelf = select(1, ...)
                if mightBeSelf == turtle then
                    return value(...)
                elseif mightBeSelf == proxy then
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
    local c, e = canMoveTo(self, "forward")
    if not c then
        return c, e
    end
    return forward(self)
end

function turtleMock:back()
    local c, e = canMoveTo(self, "back")
    if not c then
        return c, e
    end
    return back(self)
end

function turtleMock:up()
    local c, e = canMoveTo(self, "up")
    if not c then
        return c, e
    end
    return up(self)
end

function turtleMock:down()
    local c, e = canMoveTo(self, "down")
    if not c then
        return c, e
    end
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
    return self.selectedSlot
end

--- selects the slot
---@param slot integer the slot to select
---@return boolean success true if the slot was selected
function turtleMock:select(slot)
    assert(slot >= 1 and slot <= 16, "bad argument #1 (expected number between 1 and 16)")
    self.selectedSlot = slot
    return true
end

--- gets the item count in the selected slot or the specified slot
---@param slot integer the slot to get the item-count from
---@return integer count the amount of items in the slot
function turtleMock:getItemCount(slot)
    slot = slot or self.selectedSlot
    assert((slot >= 1 and slot <= 16) or slot == nil, "Slot number " .. slot .. " out of range")
    return slotNotEmpty(self.inventory[slot]) and self.inventory[slot].count or 0
end

--- gets the space in the selected slot or the specified slot
---@param slot integer the slot to get the space for
---@return integer space maxcount - currentcount
function turtleMock:getItemSpace(slot)
    slot = slot or self.selectedSlot
    assert((slot >= 1 and slot <= 16) or slot == nil, "Slot number " .. slot .. " out of range")
    return slotNotEmpty(self.inventory[slot]) and self.inventory[slot].maxcount - self.inventory[slot].count or
        self.defaultMaxSlotSize
end

function turtleMock:getSocket(socket)

end

--- gets the item in the selected slot or the specified slot
---@param slot integer | nil the slot to get the item-details from
---@return item | nil item the item in the slot
function turtleMock:getItemDetail(slot)
    slot = slot or self.selectedSlot
    assert((slot >= 1 and slot <= 16) or slot == nil, "Slot number " .. slot .. " out of range")
    ---@type item
    local iSlot = self.inventory[slot]
    return iSlot ~= nil and { name = iSlot.name, count = iSlot.count } or nil
end

--- Compare the item in the selected slot to the item in the specified slot.
---@param slot integer
---@return boolean equal true if the items are equal
function turtleMock:compareTo(slot)
    assert((slot >= 1 and slot <= 16), "Slot number " .. slot .. " out of range")
    local iSlot = self.inventory[self.selectedSlot]
    local compareSlot = self.inventory[slot]
    if iSlot == nil and compareSlot == nil then
        return true
    elseif iSlot == nil or compareSlot == nil then
        return false
    end
    return iSlot.name == compareSlot.name
end

--- Transfers items between the selected slot and the specified slot.
---
--- <b>note</b>: this function will transfer items when there is not enough room, but will return false non the less...
---@param slot integer the slot to transfer to
---@param count integer the amount of items to transfer
---@return boolean success true if the transfer was successful
---@return string | nil errorReason the reason why the transfer failed
function turtleMock:transferTo(slot, count)
    assert(slot ~= nil, "Slot must be specified")
    assert(count ~= nil, "Count must be specified")
    assert((slot >= 1 and slot <= 16), "Slot number " .. slot .. " out of range")
    assert(count > 0, "Count must be greater than 0")
    local currentSlot = self.inventory[self.selectedSlot]
    local targetSlot = self.inventory[slot]
    if (currentSlot == nil) or (targetSlot == nil) then
        if currentSlot == nil then
            return true
        end
        self.inventory[slot] = deepCopy(self.inventory[self.selectedSlot])
        self.inventory[slot].count =  math.min(self.inventory[slot] and self.inventory[slot].maxcount or 0 , count)
        local transferTo = math.min(currentSlot.count, count)
        currentSlot.count = currentSlot.count - transferTo
        if currentSlot.count < 1 then
            self.inventory[self.selectedSlot] = nil
        end
        return true
    elseif currentSlot.name == targetSlot.name then
        local space = targetSlot.maxcount - targetSlot.count
        local worked = false
        local toTransfer = math.min(space, count)
        if space >= count then
            worked = true
        end
        targetSlot.count = targetSlot.count + toTransfer
        currentSlot.count = currentSlot.count - toTransfer
        if currentSlot.count < 1 then
            self.inventory[self.selectedSlot] = nil
        end
        local unpack = table.unpack or unpack
        return worked and true or unpack({ false, "Not enough space in the target slot" })
    end
    return false, "Not enough space in the target slot"
end

--- for Testing purposes:
--- adds an item to the inventory
---@param item item
---@param slot number | nil
function turtleMock:addItemToInventory(item, slot)
    local succ, errorReason = pickUpItem(self, item, slot)
    assert(succ, errorReason)
    return succ, errorReason
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
    local item = self.inventory[self.selectedSlot]
    if item == nil or count > item.count then
        return false, "TODO"
    end
    if item == nil then
        return false, "TODO"
    end
    if item.fuelgain == nil or item.fuelgain == 0 then
        return false, "TODO"
    end
    if removeItem(self, self.selectedSlot, count) == false then
        return false, "TODO"
    end
    self.fuelLevel = self.fuelLevel + item.fuelgain * count
    return true
end

--- Equips the item in the selected slot to the left side
---@return boolean
---@return string | nil
function turtleMock:equipLeft()
    return equip(self, self.selectedSlot, "left")
end

--- Equips the item in the selected slot to the right side
function turtleMock:equipRight()
    return equip(self, self.selectedSlot, "right")
end

function turtleMock:dig()

end

function turtleMock:digUp()
    
end

function turtleMock:digDown()
    
end

---will only print content if canPrint is set to true
---@param ... any
---@return nil
function turtleMock:print(...)
    if (self.canPrint == true) then
        print(...)
    end
end

local mt = {
    __index = function(table, key)
        return rawget(table, key) or functionNotFoundError(key)
    end
}

setmetatable(turtleMock, mt)

return turtleMock
