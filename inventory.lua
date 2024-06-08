---@class placeAction
---@field funciton fun(turtle: TurtleProxy | TurtleMock, item: item, position: position): boolean , any[]

---@class item
---@field name string
---@field durability integer | nil
---@field equipable boolean | nil
---@field fuelgain integer | nil
---@field placeAble boolean | nil
---@field placeAction placeAction | nil
---@field maxcount number | nil
---@field wildcardInfo any | nil
---@field count integer | nil
---@field tags table<string, any> | nil

---@class inventory
---@field inventorySize integer
---@field [integer] item | nil
---@field defaultMaxSlotSize integer
---@field selectedSlot integer
---@field createInventory fun(self: inventory, inventorySize: integer): inventory
---@field removeItem fun(self: inventory, slot: integer, count: integer): boolean, string | nil
---@field getItemDetail fun(self: inventory, slot: integer | nil): item | nil
---@field getItemSpace fun(self: inventory, slot: integer | nil): integer
---@field compareTo fun(self: inventory, slot: integer): boolean
---@field transferTo fun(self: inventory, slot: integer, count: integer): boolean, string | nil
---@field addItemToInventory fun(self: inventory, item: item, slot: integer | nil): boolean, string | nil
---@field getItemCount fun(self: inventory, slot: integer | nil): integer
---@field findFittingSlot fun(self: inventory, item: item, slot: integer): number
---@field select fun(self: inventory, slot: integer): boolean
---@field list fun(): item[]
---@field __index any

local deepCopy = require("../generalFunctions").deepCopy

---# inventory
---Inventory system emulated
local inventory = {
    inventorySize = 27,
    selectedSlot = 1,
    defaultMaxSlotSize = 64,
}

--#region local functions
local function slotNotEmpty(slot)
    return slot ~= nil
end

--- gets the space in the selected slot or the specified slot
---@param inventory inventory the inventory to get the space from
---@param slot integer | nil the slot to get the space for
---@return integer space maxcount - currentcount
local function getItemSpace(inventory, slot)
    slot = slot or inventory.selectedSlot
    assert((slot >= 1 and slot <= 16) or slot == nil, "Slot number " .. slot .. " out of range")
    return slotNotEmpty(inventory[slot]) and inventory[slot].maxcount - inventory[slot].count or
    inventory.defaultMaxSlotSize
end

--- Finds the first slot containing the specified item or no Item, starting with the selected slot and looping around.
---@param inventory inventory
---@param item item
---@param startingSlot number
local function findFittingSlot(inventory, item, startingSlot)
    for i = startingSlot, 16 do
        if inventory[i] == nil then
            return i
        end
        if inventory[i].name == item.name and getItemSpace(inventory, i) > 0 then
            return i
        end
    end
    for i = 1, startingSlot - 1 do
        if inventory[i] == nil then
            return i
        end
        if inventory[i].name == item.name and getItemSpace(inventory, i) > 0 then
            return i
        end
    end
end

--- gets the item count in the selected slot or the specified slot
---@param inventory inventory the inventory to get the item-count from
---@param slot integer the slot to get the item-count from
---@return integer count the amount of items in the slot
local function getItemCount(inventory, slot)
    slot = slot or inventory.selectedSlot
    assert((slot >= 1 and slot <= 16) or slot == nil, "Slot number " .. slot .. " out of range")
    return slotNotEmpty(inventory[slot]) and inventory[slot].count or 0
end

--- Adds items to the selected slot or the specified slot.
---
--- <b>note</b>: This function will only work for tests and does not work on the CraftOS-Turtle
---@param inventory inventory
---@param item item
---@param slot number | nil
local function pickUpItem(inventory, item, slot)
    assert(item.count > 0, "Count must be greater than 0")
    if slot == nil then
        while item.count > 0 do
            local fittingSlot = findFittingSlot(inventory, item, inventory.selectedSlot)
            if fittingSlot == nil then
                return false, "No fitting slot found"
            end
            local space = getItemSpace(inventory, fittingSlot)
            local toTransfer = math.min(space, item.count)

            local currentCount = getItemCount(inventory, fittingSlot)
            inventory[fittingSlot] = deepCopy(item)
            if (inventory[fittingSlot] == nil) then
                inventory[fittingSlot].maxcount = item.maxcount or inventory.defaultMaxSlotSize
            end
            inventory[fittingSlot].count = currentCount + toTransfer
            item.count = item.count - toTransfer
        end
    else
        assert((slot >= 1 and slot <= 16), "Slot number " .. slot .. " out of range")
        if slotNotEmpty(inventory[slot] ) and inventory[slot].name ~= item.name then
            return false, "Can't pick up item, slot is not empty"
        end
        if getItemSpace(inventory, slot) < item.count then
            return false, "Not enough space in the slot"
        end
        if inventory[slot] == nil then
            inventory[slot] = item
        else
            inventory[slot].count = inventory[slot].count + item.count
        end
    end
    return true
end

--#endregion

--#region public functions

--- ### Description:
---creates an Instance of of the Inventory class
---@param inventorySize any
function inventory:createInventory(inventorySize) 
    local i = {
        inventorySize = inventorySize or 27,
        selectedSlot = 1,
        defaultMaxSlotSize = 64,
    }
    setmetatable(i, self)
    self.__index = self
    return i
end

--- ### Description:
---@param slot number
---@param count number
---@return boolean
---@return string | nil
function inventory:removeItem( slot, count)
    local item = self[slot]
    if item == nil then
        return false, "No item in the slot"
    end
    if item.count < count then
        return false, "Not enough items in the slot"
    end
    item.count = item.count - count
    if item.count == 0 then
        self[slot] = nil
    end
    return true
end

--- ### Description:
--- gets the item in the selected slot or the specified slot
---@param slot integer | nil the slot to get the item-details from
---@return item | nil item the item in the slot
function inventory:getItemDetail(slot)
    slot = slot or self.selectedSlot
    assert((slot >= 1 and slot <= self.inventorySize) or slot == nil, "Slot number " .. slot .. " out of range")
    ---@type item
    local iSlot = self[slot]
    return iSlot ~= nil and { name = iSlot.name, count = iSlot.count } or nil
end

--- gets the space in the selected slot or the specified slot
---@param slot integer | nil the slot to get the space for
---@return integer space maxcount - currentcount
function inventory:getItemSpace(slot)
    return getItemSpace(self, slot)
end

--- ### Description:
--- Compare the item in the selected slot to the item in the specified slot.
---@param slot integer
---@return boolean equal true if the items are equal
function inventory:compareTo(slot)
    assert((slot >= 1 and slot <= 16), "Slot number " .. slot .. " out of range")
    local iSlot = self[self.selectedSlot]
    local compareSlot = self[slot]
    if iSlot == nil and compareSlot == nil then
        return true
    elseif iSlot == nil or compareSlot == nil then
        return false
    end
    return iSlot.name == compareSlot.name
end

--- ### Description:
--- Transfers items between the selected slot and the specified slot.
---
--- <b>note</b>: this function will transfer items when there is not enough room, but will return false non the less...
---@param slot integer the slot to transfer to
---@param count integer the amount of items to transfer
---@return boolean success true if the transfer was successful
---@return string | nil errorReason the reason why the transfer failed
function inventory:transferTo(slot, count)
    assert(slot ~= nil, "Slot must be specified")
    assert(count ~= nil, "Count must be specified")
    assert((slot >= 1 and slot <= 16), "Slot number " .. slot .. " out of range")
    assert(count > 0, "Count must be greater than 0")
    local currentSlot = self[self.selectedSlot]
    local targetSlot = self[slot]
    if (currentSlot == nil) or (targetSlot == nil) then
        if currentSlot == nil then
            return true
        end
        self[slot] = deepCopy(self[self.selectedSlot])
        self[slot].count =  math.min(self[slot] and self[slot].maxcount or 0 , count)
        local transferTo = math.min(currentSlot.count, count)
        currentSlot.count = currentSlot.count - transferTo
        if currentSlot.count < 1 then
            self[self.selectedSlot] = nil
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
            self[self.selectedSlot] = nil
        end
        ---@diagnostic disable-next-line: deprecated
        local unpack = table.unpack or unpack
        return worked and true or unpack({ false, "Not enough space in the target slot" })
    end
    return false, "Not enough space in the target slot"
end

--- ### Description:
--- for Testing purposes:
--- adds an item to the inventory
---@param item item
---@param slot number | nil
function inventory:addItemToInventory(item, slot)
    local succ, errorReason = pickUpItem(self, item, slot)
    assert(succ, errorReason)
    return succ, errorReason
end

--- ### Description:
--- selects the slot
---@param slot integer the slot to select
---@return boolean success true if the slot was selected
function inventory:select(slot)
    assert(slot >= 1 and slot <= 16, "bad argument #1 (expected number between 1 and 16)")
    self.selectedSlot = slot
    return true
end

--- ### Description:
---@param item item
---@param slot number
---@return number
function inventory:findFittingSlot(item, slot)
    return findFittingSlot(self, item, slot)
end

--- gets the item count in the selected slot or the specified slot
---@param slot integer the slot to get the item-count from
---@return integer count the amount of items in the slot
function inventory:getItemCount(slot)
    return getItemCount(self, slot)
end

--- ### Description:
--- List all items in this inventory.
--- This returns a table, with an entry for each slot.
function inventory:list()
    ---todo: implement
    local items = {}
    for i = 1, inventory.inventorySize do
        table.insert(items, inventory:getItemDetail(i))
    end
    return items
end

--#endregion

return inventory