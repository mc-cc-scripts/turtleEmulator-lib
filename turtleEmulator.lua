local turtleM = require("./turtleMock")
---@class TurtleEmulator
local turtleEmulator = {
    turtles = {},
    createTurtle = function(self)
        local t = turtleM.createMock()
        table.insert(self.turtles, t)
        return t
    end,
}

return turtleEmulator
