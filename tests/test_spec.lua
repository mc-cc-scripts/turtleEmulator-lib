---@diagnostic disable: need-check-nil, missing-parameter, param-type-mismatch
---@class are
---@field same function
---@field equal function
---@field equals function

---@class is
---@field truthy function
---@field falsy function
---@field not_true function
---@field not_false function

---@class has
---@field error function
---@field errors function

---@class assert
---@field are are
---@field is is
---@field are_not are
---@field is_not is
---@field has has
---@field has_no has
---@field True function
---@field False function
---@field has_error function
---@field is_true function
---@field equal function
assert = assert

-- functions provided by busted, only available in the global scope
describe = describe
it = it
setup = setup
before_each = before_each

local turtleEmulator = require("../turtleEmulator")
describe("Disabled Movement", function()
    local turtle
    setup(function()
        turtle = turtleEmulator:createTurtle()
        turtle.canMoveToCheck = function()
            return false
        end
    end)
    it("Can't move to forward", function()
        local c, e = turtle.forward()
        assert.is.falsy(c)
        assert.are.equal("Can't move to forward", e)
    end)
    it("Can't move to back", function()
        local c, e = turtle.back()
        assert.is.falsy(c)
        assert.are.equal("Can't move to back", e)
    end)
    it("Can't move to up", function()
        local c, e = turtle.up()
        assert.is.falsy(c)
        assert.are.equal("Can't move to up", e)
    end)
    it("Can't move to down", function()
        local c, e = turtle.down()
        assert.is.falsy(c)
        assert.are.equal("Can't move to down", e)
    end)
end)
describe("Enabled Movement", function()
    local turtle
    setup(function()
        turtle = turtleEmulator:createTurtle()
        turtle["canMoveToCheck"] = function()
            return true
        end
    end)
    it("Can move to forward", function()
        local c, e = turtle.forward()
        assert.is.truthy(c)
        assert.are.equal(nil, e)
    end)
    it("Can move to back", function()
        local c, e = turtle.back()
        assert.is.truthy(c)
        assert.are.equal(nil, e)
    end)
    it("Can move to up", function()
        local c, e = turtle.up()
        assert.is.truthy(c)
        assert.are.equal(nil, e)
    end)
    it("Can move to down", function()
        local c, e = turtle.down()
        assert.is.truthy(c)
        assert.are.equal(nil, e)
    end)
end)
describe("Track Movement", function()
    local turtle
    setup(function()
        turtle = turtleEmulator:createTurtle()
        turtle["canMoveToCheck"] = function()
            return true
        end
    end)
    before_each(function()
        turtle.position.x = 0
        turtle.position.z = 0
        turtle.position.y = 0
        turtle.facing = 0
    end)
    it("Move forward", function()
        local c, e = turtle.forward()
        assert.is.truthy(c)
        assert.are.equal(nil, e)
        assert.are.equal(1, turtle.position.x)
        assert.are.equal(0, turtle.position.z)
        assert.are.equal(0, turtle.position.y)
    end)
    it("Move back", function()
        local c, e = turtle.back()
        assert.is.truthy(c)
        assert.are.equal(nil, e)
        assert.are.equal(-1, turtle.position.x)
        assert.are.equal(0, turtle.position.z)
        assert.are.equal(0, turtle.position.y)
    end)
    it("Move up", function()
        local c, e = turtle.up()
        assert.is.truthy(c)
        assert.are.equal(nil, e)
        assert.are.equal(0, turtle.position.x)
        assert.are.equal(0, turtle.position.z)
        assert.are.equal(1, turtle.position.y)
    end)
    it("Move down", function()
        local c, e = turtle.down()
        assert.is.truthy(c)
        assert.are.equal(nil, e)
        assert.are.equal(0, turtle.position.x)
        assert.are.equal(0, turtle.position.z)
        assert.are.equal(-1, turtle.position.y)
    end)
end)
describe("Track Facing Direction", function()
    local turtle
    setup(function()
        turtle = turtleEmulator:createTurtle()
        turtle["canMoveToCheck"] = function()
            return true
        end
    end)
    before_each(function()
        turtle.position.x = 0
        turtle.position.z = 0
        turtle.position.y = 0
        turtle.facing = 0
    end)
    it("Turn right", function()
        turtle.turnRight()
        assert.are.equal(1, turtle.facing)
    end)
    it("Turn left", function()
        turtle.turnLeft()
        assert.are.equal(3, turtle.facing)
    end)
    it("Turn right twice", function()
        turtle.turnRight()
        turtle.turnRight()
        assert.are.equal(2, turtle.facing)
    end)
    it("Turn right four times", function()
        turtle.turnRight()
        turtle.turnRight()
        turtle.turnRight()
        turtle.turnRight()
        assert.are.equal(0, turtle.facing)
    end)
end)
describe("Complexer Movement", function()
    local turtle
    setup(function()
        turtle = turtleEmulator:createTurtle()
        turtle["canMoveToCheck"] = function()
            return true
        end
    end)
    before_each(function()
        turtle.position.x = 0
        turtle.position.z = 0
        turtle.position.y = 0
        turtle.facing = 0
    end)
    it("Move forward, turn right and turn forward", function()
        assert.is_true(turtle.forward())
        assert.is_true(turtle.turnRight())
        local c, e = turtle.forward()
        assert.is.truthy(c)
        assert.are.equal(nil, e)
        assert.are.equal(1, turtle.facing)
        assert.are.equal(1, turtle.position.x)
        assert.are.equal(1, turtle.position.z)
        assert.are.equal(0, turtle.position.y)
    end)
    it("Move back, up, right, up, forward and then left", function()
        assert.is_true(turtle.back())
        assert.is_true(turtle.up())
        assert.is_true(turtle.turnRight())
        assert.is_true(turtle.up())
        assert.is_true(turtle.forward())
        assert.is_true(turtle.turnLeft())
        assert.are.equal(0, turtle.facing)
        assert.are.equal(-1, turtle.position.x)
        assert.are.equal(1, turtle.position.z)
        assert.are.equal(2, turtle.position.y)
    end)
end)
describe("multiple Turtles", function()
    local turtle1
    local turtle2
    setup(function()
        turtle1 = turtleEmulator:createTurtle()
        turtle2 = turtleEmulator:createTurtle()
        turtle1["canMoveToCheck"] = function()
            return true
        end
        turtle2["canMoveToCheck"] = function()
            return true
        end
    end)
    before_each(function()
        turtle1.position.x = 0
        turtle1.position.z = 0
        turtle1.position.y = 0
        turtle1.facing = 0
        turtle2.position.x = 0
        turtle2.position.z = 0
        turtle2.position.y = 0
        turtle2.facing = 0
    end)

    it("Move forward with both turtles and turn right with turtle2", function()
        assert.is_true(turtle1:forward())
        assert.is_true(turtle2:forward())
        assert.is_true(turtle2:turnRight())
        assert.is_true(turtle2:forward())
        assert.are.equal(1, turtle1.position.x)
        assert.are.equal(0, turtle1.position.z)
        assert.are.equal(0, turtle1.position.y)
        assert.are.equal(0, turtle1.facing)
        assert.are.equal(1, turtle2.position.x)
        assert.are.equal(1, turtle2.position.z)
        assert.are.equal(0, turtle2.position.y)
        assert.are.equal(1, turtle2.facing)
    end)
end)
describe("ProxyTests", function()
    local turtle
    setup(function()
        turtle = turtleEmulator:createTurtle()
        turtle["canMoveToCheck"] = function()
            return true
        end
    end)

    it("Create own key Value", function()
        local functionGotCalled = false
        function turtle:thisIsATest(RandomString)
            assert.are_not.equal(self, turtle, "The self reference is the Proxy instead of the turtle object")
            assert.are.equal("RandomString", RandomString, "Parameter 2 not correct, might be a self reference?")
            functionGotCalled = true
        end

        turtle:thisIsATest("RandomString")
        assert.are.equal(true, functionGotCalled, "Function was not called")
    end)

    it("Change Metatable", function()
        local mt = getmetatable(turtle)
        local newMt = {}
        local gotCalled = 0
        assert.has_error(function()
            gotCalled = gotCalled + 1
            setmetatable(turtle, newMt)
        end)
        mt.__metatable = nil
        assert.has_no.errors(function()
            gotCalled = gotCalled + 1
            setmetatable(turtle, newMt)
        end)
        assert.are.equal(2, gotCalled, "asserts did not run as expected")
    end)
end)
describe("InventoryTests", function()
    ---@type TurtleProxy
    local turtle
    before_each(function()
    end)
    describe("Adding Items for Testing", function()
        before_each(function()
            turtle = turtleEmulator:createTurtle()
            turtle:addItemToInventory({ name = "minecraft:coal", count = 64, maxcount = 64, fuelgain = 64 }, 1)
            turtle:addItemToInventory({ name = "minecraft:wood_plank", count = 64, maxcount = 64, fuelgain = 8 }, 2)
        end)
        it("Throw Error when adding Item to full slot", function()
            assert.has_error(function()
                turtle:addItemToInventory(
                    { name = "minecraft:Stone", count = 64, maxcount = 64 },
                    1
                )
            end)
        end)
        it("Throw Error when adding Item to invalid slot", function()
            assert.has_error(function()
                turtle:addItemToInventory(
                    { name = "minecraft:Stone", count = 64, maxcount = 64 },
                    0)
            end)
        end)
        it("Adding two different items to the same slot", function()
            local succ = turtle:addItemToInventory(
                { name = "minecraft:Stone", count = 32, maxcount = 64 },
                3)
            assert.is_true(succ)
            assert.has_error(function()
                turtle:addItemToInventory(
                    { name = "minecraft:Woods", count = 32, maxcount = 64 },
                    3)
            end)
        end)
        it("Adding item to Slot 3", function()
            local succ = turtle:addItemToInventory(
                { name = "minecraft:Wood", count = 64, maxcount = 64, },
                3)
            assert.is_true(succ)
            assert.are.equal(64, turtle.inventory[3].count)
        end)
        it("Adding items to slot 4 twice", function()
            local succ = turtle:addItemToInventory(
                { name = "minecraft:Wood", count = 32, maxcount = 64 },
                4)
            assert.is_true(succ)
            succ = turtle:addItemToInventory(
                { name = "minecraft:Wood", count = 32, maxcount = 64 },
                4)
            assert.is_true(succ)
            assert.are.equal(64, turtle.getItemDetail(4).count)
            assert.are.equal(64, turtle.inventory[4].count)
        end)
        it("Adding more items than maxcount without a specific slot", function()
            turtle:addItemToInventory(
                { name = "minecraft:Stone", count = 1, maxcount = 64 }, 4)
            local succ = turtle:addItemToInventory(
                { name = "minecraft:Wood", count = 128, maxcount = 64 })
            assert.is_true(succ)
            assert.are.equal(64, turtle.getItemCount(3))
            assert.are.equal(1, turtle.getItemCount(4))
            assert.are.equal(64, turtle.getItemCount(5))
            assert.are.equal(0, turtle.getItemCount(6))
        end)
    end)
    describe("Remaining Inventory Tests", function()
        before_each(function()
            turtle = turtleEmulator:createTurtle()
            turtle:addItemToInventory({ name = "minecraft:coal", count = 64, maxcount = 64, fuelgain = 64 }, 1)
            turtle:addItemToInventory({ name = "minecraft:wood_plank", count = 64, maxcount = 64, fuelgain = 8 }, 2)
            turtle:getSocket()
        end)
        it("transferTo Slot 2", function()
            turtle:select(2)
            local succ = turtle:transferTo(4, 16)
            assert.is_true(succ)
            assert.are.equal(16, turtle.inventory[4].count)
            assert.are.equal(48, turtle.inventory[2].count)
            assert.are.equal("minecraft:wood_plank", turtle.inventory[4].name)
            succ = turtle:transferTo(4, 48)
            assert.is_true(succ)
            assert.are.equal(64, turtle.inventory[4].count)
            assert.are.equal(nil, turtle.inventory[2])
        end)
        it("getItemInfos", function()
            local items = turtle:getItemDetail()
            assert.are_not.equal(nil, items)
            assert.are.equal("minecraft:coal", items.name)
            assert.are.equal(64, items.count)
            items = turtle:getItemDetail(2)
            assert.are_not.equal(nil, items)
            assert.are.equal("minecraft:wood_plank", items.name)
            assert.are.equal(64, items.count)
        end)
        it("getItemCount", function()
            local count = turtle.getItemCount()
            assert.are.equal(64, count)
            count = turtle.getItemCount(2)
            assert.are.equal(64, count)
        end)
        it("getitemSpace", function()
            local space = turtle.getItemSpace()
            assert.are.equal(0, space)
            space = turtle.getItemSpace(2)
            assert.are.equal(0, space)
            space = turtle.getItemSpace(3)
            assert.are.equal(64, space)
        end)
        it("getSelectedSlot", function()
            local slot = turtle.getSelectedSlot()
            assert.are.equal(1, slot)
            turtle:select(2)
            slot = turtle.getSelectedSlot()
            assert.are.equal(2, slot)
        end)
    end)
end)
