---@type ccClass
local class = require("ccClass")
---@class GeoScanner : PeripheralActions
local geoScanner = class(function (a, turtle, scanResult)
    a.computer = turtle
    a.scanResult = scanResult or {}
end)

---@type ScanDataTable
geoScanner.scanResult = nil
---@type TurtleMock | nil
geoScanner.computer = nil
geoScanner.scanEmulator = false

---comment
---@param radius number
---@return ScanDataTable
function geoScanner:scan(radius)
    assert(type(radius) == "number", "radius must be a number")
    if not self.scanEmulator then
        return self.scanResult
    end
    local result = {}
    assert(self.computer, "No turtle found, needs to be provided in the constructor via playPeripheralProxy as the third parameter")
    local e = self.computer.emulator
    assert(e, "No emulator found")
    for positionString, block in pairs(e.blocks) do
        --- check if the block is in the radius x of the turtle
        local length = (block.position - self.computer.position).length
        if (block.position - self.computer.position):length() <= radius then
            table.insert(result, {name = block.item.name
                ,x = block.position.x
                ,y = block.position.y
                ,z = block.position.z
                ,tags = block.item.tags
            })
        end
    end    
    for id, turtle in ipairs(e.turtles) do
        if turtle.id ~= self.computer.id then
            local length = (turtle.position - self.computer.position).length
            if length <= radius then
                table.insert(result, {name = "computercraft:turtle_advanced"
                    ,x = turtle.position.x
                    ,y = turtle.position.y
                    ,z = turtle.position.z
                })
            end
        end
    end
    return result
    
end

function geoScanner:getType()
    return "geoScanner"
end

return geoScanner