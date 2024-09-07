--#region Definitions

---@alias peripheralActions
---| Inventory

---@alias toolName string
---@alias checkActionName string
---@alias checkActionValidFunc fun(equipslots: equipslots ,action : checkActionName, block: block): true
---@alias checkActionValid checkActionValidFunc | table<checkActionName, toolName|toolName[]|checkActionValidFunc>  # e.g. {["dig"] = "pickaxe", ["place"] = func()}
---@alias onInteration fun(turtle: TurtleProxy, block: block | TurtleProxy, action: string): nil

---@class block
---@field item Item
---@field checkActionValid checkActionValid | nil
---@field position Vector | nil
---@field onInteration onInteration | nil
---@field state table<string, any> | nil


--- used from the Scanner, as the blocks will most likely be scanned, saved and then inserted into the turtleEmulator for testing
---@class ScanData
---@field x number
---@field y number
---@field z number
---@field name string
---@field checkActionValid checkActionValid | nil

---@class ScanDataTable
---@field _ ScanData

--#endregion

---@type TurtleMock
local turtleM = require("turtleMock")
local defaultInteration = require("defaultInteraction")
local defaultcheckActionValid = require("defaultcheckActionValid")
local chestInventory = require("chestInventory")
---@type Vector
local vector = require("vector")

---comment
---@param position Vector
---@param item Item
local function itemFallsDown(position, item)
    --TODO: implement ItemBehavior
end

---@class TurtleEmulator
local turtleEmulator = {
    ---@type table<number, TurtleProxy>
    turtles = {},
    ---@type table<string, block>
    blocks = {},
    turtleID = 1,
    createTurtle = function(self)
        assert(vector, "No Vector-Lib found")
        ---@type TurtleProxy
        local t =  turtleM(self, self.turtleID, vector.new(0,0,0), vector.new(1, 0, 0))
        self.turtles[self.turtleID] = t
        self.turtleID = self.turtleID + 1
        return t
    end,
}

--- Converts a vector to a point with the format "x,y,z"
---@param position Vector
---@return string
local function createPositionKey(position)
    return position.x .. "," .. position.y .. "," .. position.z
end

--- Adds a block to the emulated world
---@param block block
function turtleEmulator:createBlock(block)
    assert(block.position, "Block has no position")
    if block.onInteration == nil then
        block.onInteration = defaultInteration
    end
    if block.checkActionValid == nil then
        block.checkActionValid = defaultcheckActionValid
    end
    self.blocks[createPositionKey(block.position)] = block
    return self.blocks[createPositionKey(block.position)]
end

--- Removes a block from the emulated world
---@param position position
function turtleEmulator:removeBlock(position)
    self.blocks[createPositionKey(position)] = nil
end

---@param turtle TurtleProxy | number
function turtleEmulator:removeTurtle(turtle)
    if type(turtle) == "number" then
        turtle = self.turtles[turtle]
    end
    self.turtles[turtle.id] = nil
end

--- Reads the blocks from the scanner-result and adds them to the emulated world
--- TODO: Test and Refactor
---@param scannResult ScanDataTable
---@param checkActionValid checkActionValid | nil
function turtleEmulator:readBlocks(scannResult, checkActionValid)
    for _, v in pairs(scannResult) do
        v.checkActionValid = v.checkActionValid or checkActionValid
        self:createBlock(v)
    end
end

--- Returns the block at the given position
---@param position Vector
---@return block | TurtleProxy | nil
function turtleEmulator:getBlock(position)
    for _, t in pairs(self.turtles) do
        if t.position.x == position.x and t.position.y == position.y and t.position.z == position.z then
            return t
        end
    end
    return self.blocks[createPositionKey(position)]
end

function turtleEmulator:clearTurtles()
    self.turtles = {}
    self.turtleID = 1
end

function turtleEmulator:clearBlocks()
    self.blocks = {}
end

--- Adds an inventory to the block at the given position
---@param item Item
---@return ChestInventory | nil
function turtleEmulator:addInventoryToItem(item)
    if item == nil then
        return
    end
    if item.peripheralActions ~= nil then
        return item.peripheralActions
    end
    item.peripheralActions = chestInventory()
    item.peripheralName = "inventory"
    local proxy = self:playPeripheralProxy(item)
    ---@cast proxy ChestInventory
    return proxy
end

--- The Emulator needs to play Proxy for the peripheral
--- to set the self reference in all the peripheral - calls
---@param item Item
---@return peripheralActions | nil
function turtleEmulator:playPeripheralProxy(item)
    local action = item.peripheralActions
    if action == nil then
        error("No peripheralActions found")
    end
    if item.peripheralProxy then
        return item.peripheralProxy
    end
    local proxy = {}
    local mt = {}
    mt.__index = function (_, key)
        local value = action[key]
        if value == nil then
            error("no field found for key: " .. item.peripheralName .. "." .. key)
        end
        if type(value) == "function" then
            return function(...)
                local mightBeSelf = select(1, ...)
                if mightBeSelf == action then
                    return value(...)
                elseif mightBeSelf == proxy then
                ---@diagnostic disable-next-line: missing-parameter
                    return value(action, select(2, ...))
                end
                return value(action, ...)
            end
        end
        error("return base evaule because of type: " .. type(value))
        return value
    end
    mt.__newindex = function (_, key, value)
        action[key] = value
    end   
    setmetatable(proxy, mt)

    item.peripheralProxy = proxy
    return proxy
end

---@param position Vector
---@param item Item
---@return boolean Success
---@return string | nil Error
function turtleEmulator:turtleDrop(position, item)
    local block = self:getBlock(position)
    -- if there is no block at the position, the item will fall down (currently voided)
    if block and block.item and block.item.peripheralActions then
        if block.item.peripheralName == "inventory" then
            return block.item.peripheralActions:addItemToInventory(item)
        end
    -- if there is a block, but no peripheralActions, the item will fall down (somewhere, currently voided)
    end
    itemFallsDown(position, item)
    return true
end
---set vector-lib for the turtleEmulator
return turtleEmulator
