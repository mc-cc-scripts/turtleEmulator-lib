---@type ccClass
local class = require("ccClass")
---@class Modem : PeripheralActions
local modem = class(function (a, turtle)
    a.computer = turtle
end)

modem.computer = nil

function modem:accessValid(key, item)
    local computer = self.computer
    assert(computer, "No not linked to a turtle (turtle.getPeripheralModule) !")
    ---@cast computer TurtleProxy
    local succ, valid = pcall(function () 
        return (computer.equipslots.left.name == item.name or computer.equipslots.right.name == item.name) and self.isWrapped
     end)
    return succ and valid
end

function modem:getType()
    return "modem"
end

function modem:locate()
    assert(self.computer, "No not linked to a turtle (turtle.getPeripheralModule) !")
    return
            self.computer.position.x, self.computer.position.y, self.computer.position.z
end

return modem