--- ### Definitions
---@alias checkActionValid table | string | fun(equipslots: equipslots ,action : string, block: block): true
---@alias block {item: item, checkActionValid: checkActionValid, position: position, onInteration: fun(turtle: turtleMock, block: block, action: string): nil}

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

---@class TurtleEmulator
local turtleEmulator = {
    ---@type table<number, TurtleProxy>
    turtles = {},
    ---@type table<string, block>
    blocks = {},
    createTurtle = function(self)
        ---@type TurtleProxy
        local t = turtleM.createMock(self)
        table.insert(self.turtles, t)
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
    self.blocks[createPositionKey(block.position)] = block
end

--- Removes a block from the emulated world
---@param position position
function turtleEmulator:removeBlock(position)
    self.blocks[createPositionKey(position)] = nil
end

--- Reads the blocks from the scanner-result and adds them to the emulated world
---@param scannResult ScanDataTable
function turtleEmulator:readBlocks(scannResult)
    for _, v in pairs(scannResult) do
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
    for _, t in ipairs(self.turtles) do
        if t.position.x == position.x and t.position.y == position.y and t.position.z == position.z then
            return t
        end
    end
    return self.blocks[createPositionKey(position)]
end

function turtleEmulator:clearTurtles()
    self.turtles = {}
end

return turtleEmulator
