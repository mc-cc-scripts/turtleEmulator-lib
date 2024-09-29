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

---@class PeripheralActions
---@field getType fun():string
---@field accessValid nil | fun(self: PeripheralActions, key: string, item: Item):boolean, string
---@field isWrapped boolean | nil

---@class PeripheralModule
---@field type string
---@field computer TurtleMock
---@field linkToTurtle fun(peripheral: PeripheralModule, turtle: TurtleMock):PeripheralModule
---@field find fun(peripheral: PeripheralModule, typeName: string, filterFunc: filterFunc | nil):table | nil
---@field getMethods fun(peripheral: PeripheralModule, name: any):string[] | nil
---@field getNames fun(peripheral: PeripheralModule):string[]
---@field isPresent fun(peripheral: PeripheralModule, positionOrname: any):boolean
---@field getType fun(peripheral: PeripheralModule, Peripheral: PeripheralActions):string|nil
---@field wrap fun(peripheral: PeripheralModule, positionOrname: any):PeripheralActions | nil
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
---@param computer TurtleMock
---@return table<relativePosition, Vector>
local function positionMapper(computer)
    return {
        ["front"] = computer.position + computer.facing,
        ["back"] = computer.position - computer.facing,
        ["left"] = computer.position - computer.facing:cross(vector.new(0, 1, 0)),
        ["right"] = computer.position + computer.facing:cross(vector.new(0, 1, 0)),
        ["top"] = computer.position + vector.new(0, 1, 0),
        ["bottom"] = computer.position + vector.new(0, -1, 0),
    }
end

---@param pModule PeripheralModule
---@return table<number, Item>
local function getNearbyPeripheralItems(pModule)
    local positions = {}
    for direction, position in pairs(positionMapper(pModule.computer)) do
        local block = pModule.computer.emulator:getBlock(position)
        if block and block.item.peripheralActions then
            positions[direction] = block.item
        end
    end
    if pModule.type == "turtle" then
        positions["left"] = nil
        positions["right"] = nil
        positions["back"] = nil
        if pModule.computer.equipslots["left"] and pModule.computer.equipslots["left"].peripheralName ~= nil then
            positions["left"] = pModule.computer.equipslots["left"]
        end
        if pModule.computer.equipslots["right"] and pModule.computer.equipslots["right"].peripheralName ~= nil then
            positions["left"] = pModule.computer.equipslots["right"]
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
        computer = turtle,
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
    proxy.type = "turtle"
    return proxy
    
end

---@param self PeripheralModule
---@param typeName string
---@param filterFunc filterFunc | nil
---@return table | nil
function peripheralModule:find(typeName, filterFunc)
    assert(self.computer, "Peripheral is not linked to a turtle")
    local positionOfItems = getNearbyPeripheralItems(self)
    local peripheral
    for _, item in pairs(positionOfItems) do
        if item and item.peripheralName and item.peripheralName == typeName then
            
            peripheral = self.computer.emulator:playPeripheralProxy(item)
            if peripheral and ((not filterFunc) or filterFunc(item.name, peripheral)) then
                peripheral.isWrapped = true
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
    local positionOfItems = getNearbyPeripheralItems(self)
    for _, item in ipairs(positionOfItems) do
        if item and item.peripheralName then
            if item.peripheralActions then
                table.insert(names, item.name)
            end
        end
    end
    return names
end

--- Checks if a peripheral is present at the given position or with a given name
---@param position string
---@return boolean
function peripheralModule:isPresent(position)
    assert(type(position) == "string", "Parameter: 'positionOrname' must be a string")
    if relativePositionOptions[position] ~= nil then
        local positionOfItems = getNearbyPeripheralItems(self)
        return positionOfItems[position] ~= nil
    end
    return false
end

---@param position string
---@return PeripheralActions | nil
function peripheralModule:wrap(position)
    assert(type(position) == "string", "Parameter: 'positionOrname' must be a string")
    if relativePositionOptions[position] ~= nil then
        local positionOfItems = getNearbyPeripheralItems(self)
        if positionOfItems[position] ~= nil then
            local peripheral = self.computer.emulator:playPeripheralProxy(positionOfItems[position])
            peripheral.isWrapped = true
            return peripheral
        end
    end
    return nil
end

---Gets the type of the peripheral at the given position
---@param peripheralActions PeripheralActions
---@return string|nil
function peripheralModule:getType(peripheralActions)
    return peripheralActions:getType();
end

return peripheralModule