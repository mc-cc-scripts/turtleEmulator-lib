local class = require("./TestSuite-lib/ccClass/ccClass")
local inventory = require("../inventory/inventory")
local deepCopy = require("../TestSuite-lib/helperFunctions/helperFunctions").deepCopy
---@class TurtleInventory : Inventory
---@field protected _base Inventory the base inventory class
local turtleInventory = class(inventory, function (selfRef)
    inventory.init(selfRef)
    selfRef.selectedSlot = 1
end)



--- ### Description:
--- selects the slot
---@param slot integer the slot to select
---@return boolean success true if the slot was selected
function turtleInventory:select(slot)
    assert(slot >= 1 and slot <= 16, "bad argument #1 (expected number between 1 and 16)")
    self.selectedSlot = slot
    return true
end

--- gets the item count in the selected slot or the specified slot
---@param slot integer the slot to get the item-count from
---@return integer count the amount of items in the slot
function turtleInventory:getItemCount(slot)
    return self._base.getItemCount(self, slot or self.selectedSlot)
end


--- ### Description:
--- Compare the item in the selected slot to the item in the specified slot.
---@param slot integer
---@return boolean equal true if the items are equal
function turtleInventory:compareTo(slot)
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
function turtleInventory:transferTo(slot, count)
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

function turtleInventory:getItemDetail(slot)
    return self._base.getItemDetail(self, slot or self.selectedSlot)
end

function turtleInventory:getItemSpace(slot)
    return self._base.getItemSpace(self, slot or self.selectedSlot)
end

return turtleInventory