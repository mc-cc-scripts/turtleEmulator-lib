--- ### Definitions

---@alias peripheralActions
---| inventory

---@alias toolName string
---@alias checkActionName string
---@alias checkActionValidFunc fun(equipslots: equipslots ,action : checkActionName, block: block): true
---@alias checkActionValid checkActionValidFunc | table<checkActionName, toolName|toolName[]|checkActionValidFunc>  # e.g. {["dig"] = "pickaxe", ["place"] = func()}
---@alias onInteration fun(turtle: TurtleProxy, block: block | TurtleProxy, action: string): nil

---@class block
---@field item item
---@field checkActionValid checkActionValid | nil
---@field position Vector | nil
---@field onInteration onInteration | nil
---@field state table<string, any> | nil
---@field peripheralActions peripheralActions | nil
---@field peripheralName string | nil

---@class Suits
---@field vector Vector
---@field deepCopy fun(table: table): table
---
--- used from the Scanner, as the blocks will most likely be scanned, saved and then inserted into the turtleEmulator for testing
---@class ScanData
---@field x number
---@field y number
---@field z number
---@field name string
---@field checkActionValid checkActionValid | nil

---@class ScanDataTable
---@field _ ScanData



---@type TurtleMock
local turtleM = require("./turtleMock")
local defaultInteration = require("../defaultInteraction")
local defaultcheckActionValid = require("./defaultcheckActionValid")
local inventory = require("./inventory")

---@class TurtleEmulator
local turtleEmulator = {
    ---@type table<number, TurtleProxy>
    turtles = {},
    ---@type table<string, block>
    blocks = {},
    turtleID = 1,
    createTurtle = function(self)
        assert(self.suit.vector, "No Vector-Lib found")
        ---@type TurtleProxy
        local t = turtleM.createMock(self, self.turtleID, self.suit, self.suit.vector.new(0,0,0), self.suit.vector.new(1, 0, 0))
        self.turtles[self.turtleID] = t
        self.turtleID = self.turtleID + 1
        return t
    end,
    ---@type Suits
    suit = {}
}

--- Converts a vector to a point with the format "x,y,z"
---@param position Vector
---@return string
local function createPositionKey(position)
    return position.x .. "," .. position.y .. "," .. position.z
end

--- required for vector-library
---@param vector Vector
---@param copyTableFunction fun(table: table): table
function turtleEmulator:init(vector, copyTableFunction)
    assert("table" == type(vector), "vector is not a table, but of type: " .. type(vector))
    assert("function" == type(copyTableFunction), "copyTableFunction is not a function, but of type: " .. type(copyTableFunction))
    turtleEmulator.suit.vector = vector
    turtleEmulator.suit.deepCopy = copyTableFunction
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
---@param position position
---@return peripheralActions | nil
function turtleEmulator:addInventoryToBlock(position)
    local block = self:getBlock(position)
    if block == nil then
        return
    end
    block.peripheralActions = inventory:createInventory(nil, self.suit.deepCopy)
    block.peripheralName = "inventory"
    return self:playPeripheralProxy(position)
end

--- The Emulator needs to play Proxy for the peripheral
--- to set the self reference in all the peripheral - calls
---@param position any
---@return peripheralActions | nil
function turtleEmulator:playPeripheralProxy(position)
    local block = self:getBlock(position)
    assert(block, "No block at position")
    local blockAction = block.peripheralActions
    if blockAction == nil then
        return nil
    end
    local proxy = {}
    local mt = {}
    mt.__index = function (_, key)
        local value = blockAction[key]
        if type(value) == "function" then
            return function(...)
                local mightBeSelf = select(1, ...)
                if mightBeSelf == blockAction then
                    return value(...)
                elseif mightBeSelf == proxy then
                ---@diagnostic disable-next-line: missing-parameter
                    return value(blockAction, select(2, ...))
                end
                return value(blockAction, ...)
            end
        end
        return value
    end
    mt.__newindex = function (_, key, value)
        blockAction[key] = value
    end
    
    setmetatable(proxy, mt)
    return proxy
end

---set vector-lib for the turtleEmulator
return turtleEmulator
