local class = require("./TestSuite-lib/ccClass/ccClass")
local inventory = require("../inventory/inventory")
---@class ChestInventory : Inventory
local chestInventory = class(inventory)

--- ### Description:
--- List all items in this inventory.
--- This returns a table, with an entry for each slot.
function chestInventory:list()
    ---todo: implement
    local items = {}
    for i = 1, inventory.inventorySize do
        table.insert(items, inventory:getItemDetail(i))
    end
    return items
end

function chestInventory:getItemLimit(slot)
    return self[slot].maxcount or self.defaultMaxSlotSize
end

function chestInventory:getType()
    return "inventory"
end


function chestInventory:pushItems(toName, fromSlot, limit, toSlot)
    error("TODO")
end

function chestInventory:pullItems(fromName, fromSlot, limit, toSlot)
    error("TODO")
end

local function getMethods()
    return {
        "list",
        "getType",
        "pushItems",
        "pullItems"
    }
end

return chestInventory