
--#region Definitions

---@alias direction "forward" | "back" | "up" | "down"
---@alias north integer
---@alias east integer
---@alias height integer

---@alias left string
---@alias right string
---@alias equipslots {left: Item, right: Item}

---@alias inspectResult {name: string, tags: table<string, any> | nil, state: table<string, any> | nil} | nil

---@class GPSModule
---@field locate fun():number, number, number

---@class TurtleMock
---@field position Vector | nil
---@field facing Vector | nil
---@field canPrint boolean | nil
---@field fuelLevel integer | nil
---@field inventory TurtleInventory | nil
---@field fuelLimit integer | nil
---@field equipslots equipslots | nil
---@field emulator TurtleEmulator | nil
---@field id number | nil
---@field peripheralModule PeripheralModule
---@field forward fun(act: boolean | nil):boolean, string | nil, position
---@field back fun(act: boolean | nil):boolean, string | nil, position
---@field up fun(act: boolean | nil):boolean, string | nil, position
---@field down fun(act: boolean | nil):boolean, string | nil, position
---@field turnRight fun():boolean
---@field turnLeft fun():boolean
---@field getSelectedSlot fun():integer
---@field getItemCount fun(slot: integer):integer
---@field getItemSpace fun(slot: integer):integer
---@field getItemDetail fun(slot: integer | nil):Item | nil
---@field compareTo fun(slot: integer):boolean
---@field transferTo fun(slot: integer, count: integer):boolean, string | nil
---@field select fun(slot: integer):boolean
---@field getFuelLevel fun():integer
---@field getFuelLimit fun():integer
---@field refuel fun(count: integer | nil):boolean, string | nil
---@field equipLeft fun():boolean
---@field equipRight fun():boolean
---@field dig fun():boolean, string | nil
---@field digUp fun():boolean, string | nil
---@field digDown fun():boolean, string | nil
---@field detect fun():boolean
---@field detectUp fun():boolean
---@field detectDown fun():boolean
---@field compare fun():boolean
---@field compareUp fun():boolean
---@field compareDown fun():boolean
---@field inspect fun():boolean, inspectResult
---@field inspectUp fun():boolean, inspectResult
---@field inspectDown fun():boolean, inspectResult
---@field place fun():boolean, string | nil
---@field placeUp fun():boolean, string | nil
---@field placeDown fun():boolean, string | nil
---@field dropDown fun(count: integer):boolean
---@field dropUp fun(count: integer):boolean
---@field drop fun(count: integer):boolean
---@field getGPSModule fun():table
---@field print fun(...: any):nil only exists for testing purposes
---@field getPeripheralModule fun():PeripheralModule only exists for testing purposes
---@field addItemToInventory fun(item: Item, slot: number | nil):boolean only exists for testing purposes
---@field removeItem fun(turtle: TurtleMock, slot: integer, count: integer):boolean only exists for testing purposes

---@class TurtleProxy : TurtleMock
--#endregion



local peripheral = require("peripheral")
local turtleInventory = require("turtleInventory")
---@type Vector
local vector = require("vector")
local defaultInteraction = require("defaultInteraction")
local deepCopy = require("helperFunctions").deepCopy


--- this class should not be used directly, use the createMock of the turtleEmulator function instead, which will set the proxy
---@type TurtleMock
---@diagnostic disable-next-line: missing-fields
local turtleMock = {}

--- first parameter will automaticly be filled by the .__call metamethod
---@param emulator TurtleEmulator
---@param id number
---@param position Vector
---@param facingPos Vector
---@return TurtleProxy
local function createTurtleMock(_, emulator, id, position, facingPos)
    assert(emulator ~= nil, "Emulator was not given")
    local turtle = {
        ---@type Vector
        position = position or vector.new(0, 0, 0),
        ---@type Vector
        facing = facingPos or vector.new(1, 0, 0),
        ---@type number
        fuelLevel = 0,
        ---@type boolean
        canPrint = false,
        ---@type inventory
        inventory = turtleInventory(16),
        ---@type integer
        selectedSlot = 1,
        ---@type integer
        fuelLimit = 100000,
        equipslots = {},
        emulator = emulator,
        id = id,
        item = { name = "computercraft:turtle_normal" },
        checkActionValid = {["dig"] = function (turtle, action, block)
            if turtle.equipslots.left and turtle.equipslots.left.name == "minecraft:pickaxe" then
                return true
            end
            if turtle.equipslots.right and turtle.equipslots.right.name == "minecraft:pickaxe" then
                return true
            end
            return false
        end},
        onInteraction = defaultInteraction,
    }
    setmetatable(turtle, { __index = turtleMock })

    local proxy = {}
    local mt = {}
    mt.__index = function(_, key)
        local value = turtle[key]
        if type(value) == "function" then
            return function(...)
                if value == turtle.onInteraction then
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
    proxy.peripheralModule = peripheral:linkToTurtle(proxy)
    return proxy
end

---@param self TurtleProxy | TurtleMock
---@param act boolean | nil
---@return boolean
---@return string | nil
---@return Vector
local function forward(self, act)
    if act == nil then
        act = true
    end

    ---@type Vector
    local newPosition = self.position + self.facing
    if self.emulator:getBlock(newPosition) ~= nil then
        return false, "Movement obstructed by " .. self.emulator:getBlock(newPosition).item.name, newPosition
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
---@return Vector
local function back(self, act)
    if act == nil then
        act = true
    end
    local newPosition = self.position + (self.facing * -1)
    if self.emulator:getBlock(newPosition) ~= nil then
        return false, "Movement obstructed by " .. self.emulator:getBlock(newPosition).item.name, newPosition
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
---@return Vector
local function up(self, act)
    if act == nil then
        act = true
    end
    local newPosition = self.position + vector.new(0, 1, 0)
    if self.emulator:getBlock(newPosition) ~= nil then
        return false, "Movement obstructed by " .. self.emulator:getBlock(newPosition).item.name, newPosition
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
---@return Vector
local function down(self, act)
    if act == nil then
        act = true
    end
    local newPosition = self.position + vector.new(0, -1, 0)
    if self.emulator:getBlock(newPosition) ~= nil then
        return false, "Movement obstructed by " .. self.emulator:getBlock(newPosition).item.name, newPosition
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
    turtle:removeItem(slot, 1)
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
---@param block TurtleProxy | block | nil
---@param action string
---@return boolean
local function canDoAction(turtle, block, action)
    assert(block, "Block is nil in canDoAction")
    local text = "Block cannot be interacted with whatsoever, missing Setup."..
        "If you want to prevent the turtle from interacting with the block, "..
        "set checkActionValid to {'<action>' = {}}"
    assert(block.checkActionValid, text)
        -- check typeof function
    if type(block.checkActionValid) == "function" then
        return block.checkActionValid(turtle, action, block)
    end
    assert(block.checkActionValid[action] ~= nil, text)
    if type(block.checkActionValid[action]) == "function" then
        return block.checkActionValid[action](turtle, action, block)
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
        local allTools = true
        ---@diagnostic disable-next-line: param-type-mismatch
        for _, requiredTool in pairs(block.checkActionValid[action]) do
            allTools = false
            if type(requiredTool) == "string" then
                if turtle.equipslots.left and requiredTool == turtle.equipslots.left.name then
                    return true
                end
                if turtle.equipslots.right and requiredTool == turtle.equipslots.right.name then
                    return true
                end
            end
            if type(requiredTool) == "function" then
                return requiredTool(turtle, action, block)
            end
        end
        return allTools
    end
    return false
end 

--- ### Description:
---
--- Digs the specified block, if possible
---@param turtle TurtleProxy | TurtleMock
---@param block TurtleProxy | block | nil
---@return boolean
---@return string | nil
local function dig(turtle, block)
    if block == nil then
        return false, "Nothing to dig here"
    end
    if not canDoAction(turtle, block, "dig") then
        return false, "Cannot beak block with this tool"
    end
    ---@cast turtle TurtleProxy
    if(not block.onInteraction) then
        error(block.item)
    end
    block.onInteraction(turtle, block, "dig")
    return true, "Cannot beak block with this tool"
end

---@param block block | nil
---@return boolean
local function detect(block)
    return block and true or false
end

---@param block block | nil
---@param compareItem Item | nil
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
        return false, "No items to place"
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

---@param turtle TurtleProxy | TurtleMock
---@param position Vector
---@param count number
local function drop(turtle, position, count)
    local _item = turtle.inventory[turtle.inventory.selectedSlot]
    if _item == nil then
        return false, "No item to drop"
    end
    local item = deepCopy(_item)
    count = count or 1
    item.count = count

    local succ = turtle.emulator:turtleDrop(position, item)
    if succ then
        return turtle.inventory:removeItem(turtle.inventory.selectedSlot, count)
    end
    return false
end

function turtleMock:getPeripheralModule()
    return self.peripheralModule;
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

function turtleMock:turnRight()
    local newX = self.facing.x
    self.facing.x = self.facing.z * -1
    self.facing.z = newX
    return true
end

function turtleMock:turnLeft()
    local newZ = self.facing.z
    self.facing.z = self.facing.x * -1
    self.facing.x = newZ
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
---@return Item | nil item the item in the slot
function turtleMock:getItemDetail(slot)
    return self.inventory:getItemDetail(slot)
end

--- Compare the item in the selected slot to the item in the specified slot.
---@param slot integer
---@return boolean equal true if the items are equal
function turtleMock:compareTo(slot)
    return self.inventory:compareTo(slot)
end

---@param slot integer
---@param count integer
---@return boolean
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
---@param item Item
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
    local blockPos = self.position + self.facing
    local block = self.emulator:getBlock(blockPos)
    return dig(self, block)
end

function turtleMock:digUp()
    local blockPos = (self.position + vector.new(0, 1, 0))
    local block = self.emulator:getBlock(blockPos)
    return dig(self, block)
end

function turtleMock:digDown()
    local blockPos = (self.position + vector.new(0, -1, 0))
    local block = self.emulator:getBlock(blockPos)
    return dig(self, block)
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

---@param count integer
---@return boolean
function turtleMock:dropDown(count)
    return drop(self, self.position + vector.new(0, -1, 0), count)
end

---@param count integer
---@return boolean
function turtleMock:dropUp(count)
    return drop(self, self.position + vector.new(0, 1, 0), count)
end

---@param count integer
---@return boolean
function turtleMock:drop(count)
    return drop(self, self.position + self.facing, count)
end

---will only print content if canPrint is set to true
---@param ... any
---@return nil
function turtleMock:print(...)
    if (self.canPrint == true) then
        print(...)
    end
end

local mt = {}
mt.__call = function(_, emulator, id, position, facingPos)
    return createTurtleMock(_, emulator, id, position, facingPos)
end
setmetatable(turtleMock, mt)


return turtleMock
