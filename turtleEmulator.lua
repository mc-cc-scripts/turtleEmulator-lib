--- ### Definitions

---@alias toolName string
---@alias checkActionName string
---@alias checkActionValidFunc fun(equipslots: equipslots ,action : checkActionName, block: block): true
---@alias checkActionValid checkActionValidFunc | table<checkActionName, toolName|checkActionValidFunc>  # e.g. {["dig"] = "pickaxe", ["place"] = func()}
---@alias onInteration fun(turtle: TurtleProxy, block: block | TurtleProxy, action: string): nil
---@alias block {item: item, checkActionValid: checkActionValid, position: position, onInteration: onInteration}

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
local defaultInteration = require("./defaultInteraction")
local defaultcheckActionValid = require("./defaultcheckActionValid")

---@class TurtleEmulator
local turtleEmulator = {
    ---@type table<number, TurtleProxy>
    turtles = {},
    ---@type table<string, block>
    blocks = {},
    turtleID = 1,
    createTurtle = function(self)
        ---@type TurtleProxy
        local t = turtleM.createMock(self, self.turtleID)
        self.turtles[self.turtleID] = t
        self.turtleID = self.turtleID + 1
        return t
    end,
}

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
---@param scannResult ScanDataTable
---@param checkActionValid checkActionValid | nil
function turtleEmulator:readBlocks(scannResult, checkActionValid)
    for _, v in pairs(scannResult) do
        v.checkActionValid = v.checkActionValid or checkActionValid
        self:createBlock(v)
    end
end

--- Removes all blocks from the emulated world
function turtleEmulator:clearBlocks()
    self.blocks = {}
end

--- Returns the block at the given position
---@param position position
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

return turtleEmulator
