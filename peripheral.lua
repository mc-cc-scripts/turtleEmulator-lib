--[[

The Peripheral is a Module for the Turtle-Mock
--------------

Notes:


- Each turtle will get their own module instance, which is in turn linked to the turtle.

- The peripheral-Module will enable the usage of Peripherals in the Suit.

- Each Peripheral will be wrapped by the peripheral-Module and can then be accessed by the turtle,
to simulate the normal behavior of a turtle interacting with a peripheral.

]]


--#region Definitions
---@alias filterFunc fun(name: string, wrapped: table):boolean

---@alias relativePosition
--- | "front"
--- | "back"
--- | "top"
--- | "bottom"
--- | "left"
--- | "right"



---@class PeripheralModule
---@field turtle TurtleMock
---@field linkToTurtle fun(peripheral: PeripheralModule, turtle: TurtleMock):PeripheralModule
---@field find fun(peripheral: PeripheralModule, typeName: string, filterFunc: filterFunc | nil):table | nil
---@field getMethods fun(peripheral: PeripheralModule, name: any):string[] | nil
---@field getNames fun(peripheral: PeripheralModule):string[]
---@field isPresent fun(peripheral: PeripheralModule, positionOrname: any):boolean
---@field getType fun(peripheral: PeripheralModule, Peripheral: peripheralActions):string|nil
---@field __index PeripheralModule
--#endregion

---@type Vector
local vector = require("vector")

local relativePositionOptions = {
    ["right"] = true,
    ["left"] = true,
    ["front"] = true,
    ["back"] = true,
    ["top"] = true,
    ["bottom"] = true
}
--- Maps the relative positions of the turtle to the absolute positions of the emulator
---@param turtle TurtleMock
---@return table<relativePosition, Vector>
local function positionMapper(turtle)
    return {
        ["front"] = turtle.position + turtle.facing,
        ["back"] = turtle.position - turtle.facing,
        ["left"] = turtle.position - turtle.facing:cross(vector.new(0, 1, 0)),
        ["right"] = turtle.position + turtle.facing:cross(vector.new(0, 1, 0)),
        ["top"] = turtle.position + vector.new(0, 1, 0),
        ["bottom"] = turtle.position + vector.new(0, -1, 0),
    }
end

---@param turtle TurtleMock
---@return table<number, block>
local function getNearbyPeripheralBlocks(turtle)
    local positions = {}
    for _, position in pairs(positionMapper(turtle)) do
        local block = turtle.emulator:getBlock(position)
        if block and block.peripheralActions then
            table.insert(positions, block)
        end
    end
    return positions
end

---@type PeripheralModule
---@diagnostic disable-next-line: missing-fields
local peripheralModule = {}
---create a new instance of a peripheral and link it to a turtle
---@param turtle TurtleMock
---@return PeripheralModule
function peripheralModule:linkToTurtle(turtle)
    assert(turtle, "Parameters: 1. self and 2. 'turtle' which must be of type TurtleMock")
    local _peripheralModule = {
        turtle = turtle,
    }
    setmetatable(_peripheralModule, {__index = peripheralModule})
    local mt = {}
    local proxy = {}
    mt.__index = function (_, key)
        local value = _peripheralModule[key]
        if type(value) == "function" then
            return function(...)
                local mightBeSelf = select(1, ...)
                if mightBeSelf == _peripheralModule then
                    return value(...)
                elseif mightBeSelf == proxy then
                ---@diagnostic disable-next-line: missing-parameter
                    return value(_peripheralModule, select(2, ...))
                end
                return value(_peripheralModule, ...)
            end
        end
        return value
    end
    mt.__newindex = function (_, key, value)
        _peripheralModule[key] = value
    end
    
    setmetatable(proxy, mt)
    return proxy
    
end

---@param self PeripheralModule
---@param typeName string
---@param filterFunc filterFunc | nil
---@return table | nil
function peripheralModule:find(typeName, filterFunc)
    assert(self.turtle, "Peripheral is not linked to a turtle")
    local positions = getNearbyPeripheralBlocks(self.turtle)
    local peripheral
    for _, position in pairs(positions) do
        local block = position
        if block and block.peripheralName and block.peripheralName == typeName then
            peripheral = self.turtle.emulator:playPeripheralProxy(block.position)
            if peripheral and ((not filterFunc) or filterFunc(block.item.name, peripheral)) then
                return peripheral
            end
        end
    end
end

---returns all the functions of a peripheral with the given name
---@param name any
---@return string[] | nil
function peripheralModule:getMethods(name)
    local inventoryMethods = {
        "list",
        "getItemDetail",
        "size",
        "pushItems",
        "pullItems",
        "getItemLimit"
    }
    if name == "inventory" then
        return inventoryMethods
    end
end

---@return string[]
function peripheralModule:getNames()
    local names = {}
    local blocks = getNearbyPeripheralBlocks(self.turtle)
    for _, block in ipairs(blocks) do
        if block and block.peripheralName then
            if block.peripheralActions then
                table.insert(names, block.item.name)
            end
        end
    end
    return names
end

--- Checks if a peripheral is present at the given position or with a given name
---@param positionOrname any
---@return boolean
function peripheralModule:isPresent(positionOrname)
    assert(type(positionOrname) == "string", "Parameter: 'positionOrname' must be a string")
    if relativePositionOptions[positionOrname] ~= nil then
        local position = positionMapper(self.turtle)[positionOrname]
        local block = self.turtle.emulator:getBlock(position)
        return (block ~= nil) and (block.peripheralActions ~= nil)
    else
        local peripheral = self:find(positionOrname)
        return peripheral ~= nil
    end
end


---Gets the type of the peripheral at the given position
---@param peripheralActions peripheralActions
---@return string|nil
function peripheralModule:getType(peripheralActions)
    return peripheralActions:getType();
end

return peripheralModule