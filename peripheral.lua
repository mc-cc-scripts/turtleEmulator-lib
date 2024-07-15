---@alias filterFunc fun(name: string, wrapped: table):boolean

---@alias relativePosition
--- | "front"
--- | "back"
--- | "top"
--- | "bottom"
--- | "left"
--- | "right"

---@class peripheral
---@field turtle TurtleMock
---@field linkToTurtle fun(peripheral: peripheral, turtle: TurtleMock):peripheral
---@field find fun(peripheral: peripheral, typeName: string, filterFunc: filterFunc | nil):table | nil
---@field getMethods fun(peripheral: peripheral, name: any):string[] | nil
---@field getNames fun(peripheral: peripheral):string[]
---@field isPresent fun(peripheral: peripheral, positionOrname: any):boolean
---@field __index peripheral

---@param turtle TurtleMock
---@return position[]
local function getPositions(turtle)

    return pos
end

---@type peripheral
---@diagnostic disable-next-line: missing-fields
local peripheral = {}
---create a new instance of a peripheral and link it to a turtle
---@param turtle TurtleMock
---@return peripheral
function peripheral:linkToTurtle(turtle)
    local mt = {
        turtle = turtle,
    }
    local proxy = {}
    mt.__index = function (_, key)
        local value = peripheral[key]
        if type(value) == "function" then
            return function(...)
                local mightBeSelf = select(1, ...)
                if mightBeSelf == peripheral then
                    return value(...)
                elseif mightBeSelf == proxy then
                ---@diagnostic disable-next-line: missing-parameter
                    return value(peripheral, select(2, ...))
                end
                return value(peripheral, ...)
            end
        end
        return value
    end
    mt.__newindex = function (_, key, value)
        peripheral[key] = value
    end
    
    setmetatable(proxy, mt)
    return proxy
    
end

---@param self peripheral
---@param typeName string
---@param filterFunc filterFunc | nil
---@return table
function peripheral:find(typeName, filterFunc)
    assert(self.turtle, "Peripheral is not linked to a turtle")
    local positions = getPositions(self.turtle.position)
    local peripheral
    for _, position in pairs(positions) do
        local block = self.turtle.emulator:getBlock(position)
        if block and block.peripheralName and block.peripheralName == typeName then
            peripheral = self.turtle.emulator:playPeripheralProxy(block)
            if peripheral and ((not filterFunc) or filterFunc(block.item.name, peripheral)) then
                return peripheral
            end
        end
    end
end

---returns all the functions of a peripheral with the given name
---@param name any
---@return string[] | nil
function peripheral:getMethods(name)
    local p = self:find(name)
    if not p then return nil end
    local methods = {}
    for k, v in pairs(p) do
        if type(v) == "function" then
            table.insert(methods, k)
        end
    end
    return methods
end

---@return string[]
function peripheral:getNames()
    local names = {}
    local positions = getPositions(self.turtle.position)
    for _, position in pairs(positions) do
        local block = self.turtle.emulator:getBlock(position)
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
function peripheral:isPresent(positionOrname)

end

return peripheral