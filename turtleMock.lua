---@alias direction "forward" | "back" | "up" | "down"
---@alias facing
---| 0 North
---| 1 East
---| 2 South
---| 3 West
---@alias north integer
---@alias east integer
---@alias height integer
---@alias position {x: north, y: east, z: height}


---@class TurtleMock
local turtleMock = {
    ---@type position
    position = nil,
    ---@type facing
    facing = nil,
    canMoveToCheck = nil,
    canPrint = nil,
    fuelLevel = 0,
}
---@param self TurtleMock
---@param direction string the direction to move to
---@return boolean success if the turtle can move to the direction
---@return string | nil errorReason the reason why the turtle can't move to the direction
local function canMoveTo(self, direction)
    if self.canMoveToCheck ~= nil and type(self.canMoveToCheck) == "function" then
        if not self.canMoveToCheck(direction) then
            return false, "Can't move to " .. direction
        else
            return true
        end
    else
        --TODO implement a check for the world
        return false, "Move to  " .. direction .. " is not implemented yet."
    end
end

local function forward(self)
    if self.facing == 0 then
        self.position.x = self.position.x + 1
    elseif self.facing == 1 then
        self.position.z = self.position.z + 1
    elseif self.facing == 2 then
        self.position.x = self.position.x - 1
    elseif self.facing == 3 then
        self.position.z = self.position.z - 1
    end
    return true
end

local function back(self)
    if self.facing == 0 then
        self.position.x = self.position.x - 1
    elseif self.facing == 1 then
        self.position.z = self.position.z - 1
    elseif self.facing == 2 then
        self.position.x = self.position.x + 1
    elseif self.facing == 3 then
        self.position.z = self.position.z + 1
    end
    return true
end

local function up(self)
    self.position.y = self.position.y + 1
    return true
end

local function down(self)
    self.position.y = self.position.y - 1
    return true
end


function turtleMock.createMock()
    ---@class Turtle : TurtleMock
    local turtle = {
        position = { x = 0, y = 0, z = 0 },
        facing = 0,
        canMoveToCheck = nil,
        fuelLevel = 0,
        canPrint = true,
    }
    setmetatable(turtle, { __index = turtleMock })

    ---@class TurtleProxy : Turtle
    local proxy = {}
    local mt = {}
    mt.__index = function(_, key)
        local value = turtle[key]
        if type(value) == "function" then
            return function(...)
                local mightBeSelf = select(1, ...)
                if mightBeSelf == turtle then
                    return value(...)
                elseif mightBeSelf == proxy then
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
    return proxy
end

function turtleMock:forward()
    local c, e = canMoveTo(self, "forward")
    if not c then
        return c, e
    end
    return forward(self)
end

function turtleMock:back()
    local c, e = canMoveTo(self, "back")
    if not c then
        return c, e
    end
    return back(self)
end

function turtleMock:up()
    local c, e = canMoveTo(self, "up")
    if not c then
        return c, e
    end
    return up(self)
end

function turtleMock:down()
    local c, e = canMoveTo(self, "down")
    if not c then
        return c, e
    end
    return down(self)
end

function turtleMock:turnLeft()
    self.facing = (self.facing - 1) % 4
    return true
end

function turtleMock:turnRight()
    self.facing = (self.facing + 1) % 4
    return true
end

function turtleMock:getFuelLevel()
    return self.fuelLevel
end

local function functionNotFoundError(key)
    return error("Function " .. key .. " not found")
end

local mt = {
    __index = function(table, key)
        return rawget(table, key) or functionNotFoundError(key)
    end
}

function turtleMock:print(...)
    return self.canPrint == true and print(...)
end

setmetatable(turtleMock, mt)

return turtleMock
