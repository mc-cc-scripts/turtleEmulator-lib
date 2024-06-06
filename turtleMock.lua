


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

---@alias item {name: string, durabilty: integer, equipable: boolean, fuelgain: integer, placeAble: boolean, maxcount: number, wildcardInfo: any, count: integer, tags: table<string, any> | nil}
---@alias inventory { [integer]: item }

---@alias left string
---@alias right string
---@alias equipslots {left: item, right: item}

---@alias inspectResult {name: string, tags: table<string, any> | nil, state: table<string, any> | nil} | nil

local defaultInteration = require("../defaultInteraction")

---@class TurtleMock
---@field position position
---@field facing facing
---@field canPrint boolean
---@field fuelLevel integer
---@field inventory inventory
---@field selectedSlot integer
---@field fuelLimit integer
---@field defaultMaxSlotSize integer
---@field equipslots equipslots
---@field emulator TurtleEmulator
---@field id number
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
---
--- note: Order is left to right on priority on equipment
---@param turtle TurtleMock
---@param block block
---@param action string
---@return boolean
local function canDoAction(turtle, block, action)
    local text = "Block cannot be interacted with whatsoever, missing Setup."..
        "If you want to prevent the turtle from interacting with the block, "..
        "set checkActionValid to {'<action>' = {}} or leave it empty to allow all actions"
    -- check typeof function
    assert(block.checkActionValid ~= nil, text)
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
---@param block block
---@return boolean
---@return string | nil
local function dig(turtle, block)
    
    if not canDoAction(turtle, block, "dig") then
        return false, "Cannot beak block with this tool"
    end
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
local function compare(block, compareItem)
    if block == nil and compareItem == nil then
        return true
    end
    if block == nil and compareItem ~= nil then
        return false
    end
    if compareItem == nil and block ~= nil then
        return false
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

---@param emulator TurtleEmulator
---@return TurtleProxy
function turtleMock.createMock(emulator, id)
    ---@type TurtleMock
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
        inventory = {},
        ---@type integer
        selectedSlot = 1,
        ---@type integer
        fuelLimit = 100000,
        ---@type integer
        defaultMaxSlotSize = 64,
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
        onInteration = defaultInteration
    }
    setmetatable(turtle, { __index = turtleMock })

    ---@class TurtleProxy : TurtleMock
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
    local _, _, blockPos = forward(self, false)
    ---@type block
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
    return compare(block, self.inventory[self.selectedSlot])
end

function turtleMock:compareUp()
    local block = self.emulator:getBlock({x = self.position.x, y = self.position.y + 1, z = self.position.z})
    return compare(block, self.inventory[self.selectedSlot])
end

function turtleMock:compareDown()
    local block = self.emulator:getBlock({x = self.position.x, y = self.position.y - 1, z = self.position.z})
    return compare(block, self.inventory[self.selectedSlot])
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

---will only print content if canPrint is set to true
---@param ... any
---@return nil
function turtleMock:print(...)
    if (self.canPrint == true) then
        print(...)
    end
end


setmetatable(turtleMock, mt)

return turtleMock
