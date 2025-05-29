--#region Definitions
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


--#endregion


local deepCopy = require("helperFunctions").deepCopy
local class = require("ccClass")

---# inventory
---Inventory system emulated
---@class Inventory
---@field inventorySize number
---@field defaultMaxSlotSize number
---@field protected init function
local inventory = class(function (a, inventorySize)
    a.inventorySize = inventorySize or 27
    a.defaultMaxSlotSize = 64
end)

---@protected
function inventory:slotNotEmpty(slot)
    return slot ~= nil
end

--- gets the space in the selected slot or the specified slot
---@param inventory Inventory the inventory to get the space from
---@param slot integer | nil the slot to get the space for
---@return integer space maxcount - currentcount
---@protected
function inventory:getItemSpace(slot)
    assert((slot >= 1 and slot <= 16) or slot == nil, "Slot number " .. slot .. " out of range")
    return (self:slotNotEmpty(self[slot]) and self[slot].maxcount - self[slot].count) or
    self.defaultMaxSlotSize
end

--- Finds the first slot containing the specified item or no Item, starting with the selected slot and looping around.
---@param inventory Inventory
---@param item item
---@param startingSlot number
---@protected
function inventory:findFittingSlot(item, startingSlot)
    for i = startingSlot, 16 do
        if self[i] == nil then
            return i
        end
        if self[i].name == item.name and self:getItemSpace(i) > 0 then
            return i
        end
    end
    for i = 1, startingSlot - 1 do
        if self[i] == nil then
            return i
        end
        if self[i].name == item.name and self:getItemSpace(i) > 0 then
            return i
        end
    end
end

--- gets the item count in the selected slot or the specified slot
---@param inventory Inventory the inventory to get the item-count from
---@param slot integer the slot to get the item-count from
---@return integer count the amount of items in the slot
---@protected
function inventory:getItemCount(slot)
    assert(slot ~= nil, "Slot must be specified")
    assert((slot >= 1 and slot <= 16) or slot == nil, "Slot number " .. slot .. " out of range")
    return self:slotNotEmpty(self[slot]) and self[slot].count or 0
end

--- Adds items to the selected slot or the specified slot.
---
--- <b>note</b>: This function will only work for tests and does not work on the CraftOS-Turtle
---@param inventory Inventory
---@param item item
---@param slot number | nil
---@protected
function inventory:pickUpItem(item, slot)
    assert(item.count > 0, "Count must be greater than 0")
    if slot == nil then
        while item.count > 0 do
            local fittingSlot = self:findFittingSlot(item, self.selectedSlot or 1) -- start with the selected slot on the turtle
            if fittingSlot == nil then
                return false, "No fitting slot found"
            end
            local space = self:getItemSpace(fittingSlot)
            local toTransfer = math.min(space, item.count)
            
            local currentCount = self:getItemCount(fittingSlot)
            self[fittingSlot] = deepCopy(item)
            if (self[fittingSlot] == nil) then
                self[fittingSlot].maxcount = item.maxcount or self.defaultMaxSlotSize
            end
            self[fittingSlot].count = currentCount + toTransfer
            item.count = item.count - toTransfer
        end
        return true
    else
        assert((slot >= 1 and slot <= 16), "Slot number " .. slot .. " out of range")
        if self:slotNotEmpty(self[slot] ) and self[slot].name ~= item.name then
            return false, "Can't pick up item, slot is not empty"
        end
        if self[slot] == nil then
            self[slot] = item
        else
            if self:getItemSpace(slot) < item.count then
                return false, "Not enough space in the slot"
            else
                self[slot].count = self[slot].count + item.count
            end
        end
    end
    return true
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
        count = item.count
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
    assert(slot ~= nil, "Slot must be specified")
    assert((slot >= 1 and slot <= self.inventorySize) or slot == nil, "Slot number " .. slot .. " out of range")
    ---@type item
    local iSlot = self[slot]
    return iSlot ~= nil and { name = iSlot.name, count = iSlot.count } or nil
end

--- ### Description:
--- for Testing purposes:
--- adds an item to the inventory
---@param item item
---@param slot number | nil
function inventory:addItemToInventory(item, slot)
    local succ, errorReason = self:pickUpItem(item, slot)
    assert(succ, errorReason)
    return succ, errorReason
end


return inventory