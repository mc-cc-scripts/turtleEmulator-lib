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
---@field is_false function
---@field is_true function
---@field equal function
assert = assert

local spath =
    debug.getinfo(1,'S').source:sub(2):gsub("/+", "/"):gsub("[^/]*$",""):gsub("/tests", ""):gsub("tests", "")
if spath == "" then
    spath = "./"
end
local package = spath.."ccPackage"
require(package)

-- load the other suits
local vector = require("vector")

local turtleEmulator = require("turtleEmulator")
describe("Disabled Movement", function()
    local turtle
    setup(function()
        turtleEmulator:clearTurtles()
        turtleEmulator:clearBlocks()
        turtle = turtleEmulator:createTurtle()
    end)
    before_each(function()
        turtleEmulator:clearBlocks();
    end)
    it("Can't move to forward", function()
        turtleEmulator:createBlock({ item = { name = "minecraft:stone" }, position = vector.new(1, 0, 0) })
        local c, e = turtle.forward()
        assert.is.falsy(c)
        assert.are.equal(1, string.find(e, "Movement obstructed"))
    end)
    it("Can't move to back", function()
        turtleEmulator:createBlock({ item = { name = "minecraft:stone" }, position = vector.new(-1, 0, 0) })


        local c, e = turtle.back()
        assert.is.falsy(c)
        assert.are.equal(1, string.find(e, "Movement obstructed"))
    end)
    it("Can't move to up", function()
        turtleEmulator:createBlock({ item = { name = "minecraft:stone" }, position = vector.new(0, 1, 0) })
        local c, e = turtle.up()
        assert.is.falsy(c)
        assert.are.equal(1, string.find(e, "Movement obstructed"))
    end)
    it("Can't move to down", function()
        turtleEmulator:createBlock({ item = { name = "minecraft:stone" }, position = vector.new(0, -1, 0) })
        local c, e = turtle.down()
        assert.is.falsy(c)
        assert.are.equal(1, string.find(e, "Movement obstructed"))
    end)
end)
describe("Enabled Movement", function()
    local turtle
    setup(function()
        turtleEmulator:clearTurtles()
        turtleEmulator:clearBlocks()
        turtle = turtleEmulator:createTurtle()
        turtle.addItemToInventory({ name = "minecraft:coal", count = 64, maxcount = 64, fuelgain = 16 }, 1)
        turtle.refuel(64)
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
    before_each(function()
        turtleEmulator:clearTurtles()
        turtleEmulator:clearBlocks()
        turtle = turtleEmulator:createTurtle()
        turtle.addItemToInventory({ name = "minecraft:coal", count = 64, maxcount = 64, fuelgain = 16 }, 1)
        turtle.refuel(64)
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
        assert.are.equal(0, turtle.position.x)
        assert.are.equal(0, turtle.position.z)
        assert.are.equal(0, turtle.position.y)
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
    end)
    before_each(function()
        turtleEmulator:clearTurtles()
        turtle = turtleEmulator:createTurtle()
    end)
    it("Turn right", function()
        turtle.turnRight()
        assert.are.equal("-0,0,1", tostring(turtle.facing))
    end)
    it("Turn left", function()
        turtle.turnLeft()
        assert.are.equal("0,0,-1", tostring(turtle.facing))
    end)
    it("Turn right twice", function()
        turtle.turnRight()
        turtle.turnRight()
        assert.are.equal("-1,0,-0", tostring(turtle.facing))
    end)
    it("Turn right four times", function()
        turtle.turnRight()
        turtle.turnRight()
        turtle.turnRight()
        turtle.turnRight()
        assert.are.equal("1,0,0", tostring(turtle.facing))
    end)
end)
describe("Complexer Movement", function()
    local turtle
    before_each(function()
        turtleEmulator:clearTurtles()
        turtleEmulator:clearBlocks()
        turtle = turtleEmulator:createTurtle()
        turtle.addItemToInventory({ name = "minecraft:coal", count = 64, maxcount = 64, fuelgain = 16 }, 1)
        turtle.refuel(64)
    end)
    it("Move forward, turn right and turn forward", function()
        assert.is_true(turtle.forward())
        assert.is_true(turtle.turnRight())
        local c, e = turtle.forward()
        assert.is.truthy(c)
        assert.are.equal(nil, e)
        assert.are.equal("-0,0,1", tostring(turtle.facing))
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
        assert.are.equal("1,0,0", tostring(turtle.facing))
        assert.are.equal(-1, turtle.position.x)
        assert.are.equal(1, turtle.position.z)
        assert.are.equal(2, turtle.position.y)
    end)
end)
describe("multiple Turtles", function()
    local turtle1
    local turtle2
    before_each(function()
        turtleEmulator:clearTurtles()
        turtleEmulator:clearBlocks()
        turtle1 = turtleEmulator:createTurtle()
        turtle2 = turtleEmulator:createTurtle()
        turtle1.addItemToInventory({ name = "minecraft:coal", count = 64, maxcount = 64, fuelgain = 16 }, 1)
        turtle1.refuel(64)
        turtle2.addItemToInventory({ name = "minecraft:coal", count = 64, maxcount = 64, fuelgain = 16 }, 1)
        turtle2.refuel(64)
    end)

    it("Move forward with both turtles", function()
        assert.is_true(turtle1:forward())
        assert.is_false(turtle2:forward())
        assert.is_true(turtle1:up())
        assert.is_true(turtle2:forward())
        assert.is_true(turtle2:forward())
        assert.is_true(turtle2:up())
        assert.is_false(turtle2:back())
        assert.are.equal(1, turtle1.position.x)
        assert.are.equal(1, turtle1.position.y)
        assert.are.equal(0, turtle1.position.z)
        assert.are.equal(2, turtle2.position.x)
        assert.are.equal(1, turtle2.position.y)
        assert.are.equal(0, turtle2.position.z)
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
    describe("Adding Items for Testing", function()
        before_each(function()
            turtle = turtleEmulator:createTurtle()
            turtle:addItemToInventory({ name = "minecraft:coal", count = 64, maxcount = 64, fuelgain = 16 }, 1)
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
    describe("Refueling", function()
        local fuelGainPerCoal = 16
        before_each(function()
            turtle = turtleEmulator:createTurtle()
            turtle:addItemToInventory({ name = "minecraft:coal", count = 64, maxcount = 64, fuelgain = fuelGainPerCoal },
                1)
            turtle:addItemToInventory({ name = "minecraft:wood_plank", count = 64, maxcount = 64, fuelgain = 8 }, 2)
        end)
        it("Refuel with coal", function()
            turtle.select(1)
            local succ = turtle.refuel()
            assert.is_true(succ)
            assert.are.equal(fuelGainPerCoal, turtle.getFuelLevel())
            assert.are.equal(63, turtle.getItemCount())
            succ = turtle.refuel(63)
            assert.is_true(succ)
            assert.are.equal(fuelGainPerCoal * 64, turtle.getFuelLevel())
            assert.are.equal(0, turtle.getItemCount())
            local succ = turtle.refuel()
            assert.is_false(succ)
            turtle.select(3)
            turtle:addItemToInventory({ name = "minecraft:stone", count = 64, maxcount = 64 }, 3)
            succ = turtle.refuel()
            assert.is_false(succ)
            assert.are.equal(fuelGainPerCoal * 64, turtle.getFuelLevel())
        end)
    end)
    describe("Remaining Inventory Tests", function()
        before_each(function()
            turtle = turtleEmulator:createTurtle()
            turtle:addItemToInventory({ name = "minecraft:coal", count = 64, maxcount = 64, fuelgain = 16 }, 1)
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
describe("Equipment", function()
    ---@type TurtleProxy
    local turtle
    before_each(function()
        turtle = turtleEmulator:createTurtle()
        turtle:addItemToInventory({ name = "minecraft:coal", count = 64, maxcount = 64, fuelgain = 16 }, 1)
        turtle:addItemToInventory({ name = "minecraft:wood_plank", count = 64, maxcount = 64, fuelgain = 8 }, 2)
    end)
    it("Equip non Equipment", function()
        local succ = turtle.equipLeft()
        assert.is_false(succ)
    end)
    it("Equip Equipment", function()
        turtle:addItemToInventory({ name = "CCTweaked:chat_box", count = 2, maxcount = 2, equipable = true }, 3)
        turtle:select(3)
        local succ = turtle.equipLeft()
        assert.is_true(succ)
        assert.are.equal(turtle.equipslots.left.name, "CCTweaked:chat_box")
        assert.are.equal(turtle.equipslots.left.count, 1)
    end)
    it("Upgrade Equipment", function()
        turtle:addItemToInventory({ name = "CCTweaked:chat_box", count = 2, maxcount = 2, equipable = true }, 3)
        turtle:select(3)
        local succ = turtle.equipLeft()
        assert.is_true(succ)
        assert.are.equal(turtle.equipslots.left.name, "CCTweaked:chat_box")
        assert.are.equal(turtle.equipslots.left.count, 1)
    end)

    it("Upgrade Equipment and Replace in inventory", function()
        turtle:addItemToInventory({ name = "CCTweaked:chat_box", count = 2, maxcount = 2, equipable = true }, 3)
        turtle:addItemToInventory({ name = "CCTweaked:chunk_loader", count = 1, maxcount = 1, equipable = true }, 4)
        turtle:select(3)
        local succ = turtle.equipLeft()
        assert.is_true(succ)
        assert.are.equal(turtle.equipslots.left.name, "CCTweaked:chat_box")
        assert.are.equal(turtle.equipslots.left.count, 1)
        turtle:select(4)
        succ = turtle.equipLeft()
        assert.is_true(succ)
        assert.are.equal(turtle.equipslots.left.name, "CCTweaked:chunk_loader")
        assert.are.equal(turtle.equipslots.left.count, 1)
        assert.are.equal(turtle.inventory[4].count, 1)
        assert.are.equal(turtle.inventory[4].name, "CCTweaked:chat_box")
        assert.are.equal(turtle.inventory[3].count, 1)
        assert.are.equal(turtle.inventory[3].name, "CCTweaked:chat_box")
    end)

    it("Equip Left and RightSlot", function()
        turtle:addItemToInventory({ name = "CCTweaked:chat_box", count = 2, maxcount = 2, equipable = true }, 3)
        turtle.select(3)
        local succ = turtle.equipRight()
        assert.is_true(succ)
        assert.are.equal(turtle.equipslots.right.name, "CCTweaked:chat_box")
        assert.are.equal(turtle.equipslots.right.count, 1)
        assert.are.equal(turtle.inventory[3].name, "CCTweaked:chat_box")
        assert.are.equal(turtle.inventory[3].count, 1)
    end)
end)
describe("EmulatorTesting", function()
    setup(function()
        turtleEmulator:clearTurtles();
    end)
    describe("Adding Blocks", function()
        it("Add Block", function()
            turtleEmulator:createBlock({ item = { name = "minecraft:stone", maxcount = 64 }, position = vector.new(0, 0,
                1) })
            assert.are_not.equal(nil, turtleEmulator.blocks["0,0,1"])
            assert.are.equal("minecraft:stone", turtleEmulator.blocks["0,0,1"].item.name)
            assert.are.equal(nil, turtleEmulator.blocks["0,0,2"])
        end)
        it("Add Block and remove it", function()
            local block = { item = { name = "minecraft:stone", maxcount = 64 }, position = vector.new(1, 0, 0) }
            turtleEmulator:createBlock(block)
            assert.are_not.equal(nil, turtleEmulator.blocks["1,0,0"])
            assert.are.equal("minecraft:stone", turtleEmulator.blocks["1,0,0"].item.name)
            turtleEmulator:removeBlock(block.position)
            assert.are.equal(nil, turtleEmulator.blocks["1,0,0"])
        end)
    end)
    describe("Read Blocks", function()
        ---TODO: Implement
    end)
    describe("Return Block", function()
        local block = {
            item = { name = "minecraft:stone", maxcount = 64 },
            position = vector.new(1, 0, 0)
        }
        turtleEmulator:createBlock(block)
        assert.are_not.equal(nil, turtleEmulator.blocks["1,0,0"])
        assert.are_not.equal(nil, turtleEmulator:getBlock(block.position))
        local b = turtleEmulator:getBlock(block.position)
        assert.is.falsy(b.emulator)
        assert.are.equal(block.item.name, b.item.name)
    end)
end)
describe("ActionAccepted", function()
    ---@type TurtleProxy
    local turtle1
    ---@type TurtleProxy
    local turtle2

    local toolsStone = "minecraft:pickaxe"
    local toolsWood = { "minecraft:pickaxe", "minecraft:axe" }
    ---@type checkActionValid
    local toolsWheed = function(equipslots, action, blockRef)
        local tool1 = equipslots.left and equipslots.left.name or nil
        local tool2 = equipslots.right and equipslots.right.name or nil
        return (tool1 == "minecraft:hoe" or tool2 == "minecraft:hoe") and action == "dig"
    end;

    ---@type onInteration
    local dirtInteraction = function(turtle, block, action)
        if block.item.name == "minecraft:dirt" and action == "dig" then
            block.item.name = "minecraft:farmland"
            return
        end
    end;
    before_each(function()
        turtleEmulator:clearTurtles()
        turtleEmulator:clearBlocks()
        turtleEmulator:createBlock({ item = { name = "minecraft:wood" }, position = vector.new(1, 0, 0), checkActionValid = { ["dig"] = toolsWood } })
        turtleEmulator:createBlock({ item = { name = "minecraft:stone" }, position = vector.new(0, 1, 0), checkActionValid = { ["dig"] = toolsStone } })

        turtleEmulator:createBlock({
            item = { name = "minecraft:dirt" },
            position = vector.new(0, -1, 0),
            checkActionValid = { ["dig"] = toolsWheed },
            onInteration =
                dirtInteraction
        })
        turtleEmulator:createBlock({ item = { name = "minecraft:cobblestone" }, position = vector.new(0, -1, 3), checkActionValid = { ["dig"] = {} } })
        turtle1 = turtleEmulator:createTurtle()
        turtle1:addItemToInventory({ name = "minecraft:axe", count = 1, maxcount = 1, equipable = true }, 1)
        turtle1:addItemToInventory({ name = "minecraft:pickaxe", count = 1, maxcount = 1, equipable = true }, 2)
        turtle1:addItemToInventory({ name = "minecraft:hoe", count = 1, maxcount = 1, equipable = true }, 3)
        turtle1:addItemToInventory({ name = "minecraft:stone", count = 64, maxcount = 64 }, 4)
        turtle1:addItemToInventory({ name = "minecraft:coal", count = 64, maxcount = 64, fuelgain = 8 }, 16)
        turtle1.select(16)
        turtle1.refuel(64)
        turtle1.select(1)
    end)
    it("Dig Up with String", function()
        turtle1.select(2)
        assert.True(turtle1.equipLeft())
        assert.are.equal("minecraft:pickaxe", turtle1.equipslots.left.name)
        -- assert.is_true(turtleEmulator:getBlock(vector.new(0, 1, 0)))
        local succ = turtle1.digUp()
        assert.is_true(succ)
        assert.are.equal("minecraft:stone", turtle1.getItemDetail().name)
        assert.are.equal(nil, turtleEmulator:getBlock({ x = 0, y = 1, z = 0 }))
    end)
    it("Dig Front with Table<string>", function()
        turtle1.select(1)
        assert.True(turtle1.equipRight())
        assert.are.equal("minecraft:axe", turtle1.equipslots.right.name)
        local succ = turtle1.dig()
        assert.is_true(succ)
        assert.are.equal(turtleEmulator:getBlock({ x = 1, y = 0, z = 0 }), nil)
        assert.are.equal("minecraft:wood", turtle1.getItemDetail().name)
    end)
    it("Dig Down with table<string, function>", function()
        turtle1.select(3)
        assert.True(turtle1.equipLeft())
        assert.are.equal("minecraft:hoe", turtle1.equipslots.left.name)
        local succ = turtle1.digDown()
        assert.is_true(succ)
        assert.are.equal(nil, turtle1.getItemDetail())
        assert.are.equal("minecraft:farmland", turtleEmulator:getBlock({ x = 0, y = -1, z = 0 }).item.name)
    end)
    it("Dig Distant Block", function()
        turtle1.turnRight()
        assert.is_true(turtle1.forward())
        assert.is_true(turtle1.forward())
        assert.is_true(turtle1.forward())
        assert.are.equal("0,0,3", tostring(turtle1.position))
        assert.is_true(turtle1.digDown())
        assert.is_true(turtle1.up())
        assert.are.equal("computercraft:turtle_normal", turtleEmulator:getBlock({ x = 0, y = 1, z = 3 }).item.name)
        turtle1.select(5)
        assert.are.equal("minecraft:cobblestone", turtle1.getItemDetail().name)
    end)
    it("Dig up a Turtle", function()
        turtleEmulator:clearBlocks()
        turtle1.forward()
        turtle1.forward()
        turtle2 = turtleEmulator:createTurtle()
        turtle2:addItemToInventory({ name = "minecraft:coal", count = 64, maxcount = 64, fuelgain = 8 }, 1)
        turtle2.refuel(64)
        turtle2.forward()
        assert.is_false(turtle2.forward())
        turtle2.canPrint = true
        assert.is_false(turtle2.dig())
        assert.is_true(turtle2:addItemToInventory(
            { name = "minecraft:pickaxe", count = 1, maxcount = 1, equipable = true }, 1))
        assert.is_true(turtle2.equipLeft())
        assert.is_true(turtle2.dig())
        assert.are.equal(nil, turtleEmulator:getBlock({ x = 2, y = 0, z = 0 }))
        assert.are.equal(2, turtleEmulator:getBlock({ x = 1, y = 0, z = 0 }).id)
        assert.is_true(turtle2.forward())
        assert.are.equal(2, turtleEmulator:getBlock({ x = 2, y = 0, z = 0 }).id)
        assert.are.equal("computercraft:turtle_normal", turtleEmulator:getBlock({ x = 2, y = 0, z = 0 }).item.name)
        assert.are.equal("computercraft:turtle_normal", turtle2.getItemDetail().name)
    end)
end)
describe("Detect, Compare, Inspect", function()
    ---@type TurtleProxy
    local turtle
    before_each(function()
        turtleEmulator:clearBlocks()
        turtleEmulator:clearTurtles()
        turtle = turtleEmulator:createTurtle()
        turtleEmulator:createBlock({ item = { name = "minecraft:stone" }, position = vector.new(1, 0, 0) })
        turtleEmulator:createBlock({ item = { name = "minecraft:wood" }, position = vector.new(0, 1, 0), state = { burning = true } })
    end)
    it("Detect", function()
        turtleEmulator:createBlock({ item = { name = "minecraft:stone" }, position = vector.new(1, 0, 0) })
        assert.is_true(turtle.detect())
        assert.is_true(turtle.detectUp())
        assert.is_false(turtle.detectDown())
        turtleEmulator:createBlock({ item = { name = "minecraft:obsidian", tag = { ["minecraft:minable/pickaxe"] = true } }, position =
            vector.new(0, -1, 0) })
        assert.is_true(turtle.detectDown())
    end)
    it("Compare", function()
        assert.is_false(turtle.compare())
        turtle:addItemToInventory({ name = "minecraft:stone", count = 1, maxcount = 64 })
        assert.is_true(turtle.compare())
        assert.is_false(turtle.compareUp())
        turtleEmulator:createBlock({ item = { name = "minecraft:obsidian", tag = { ["minecraft:minable/pickaxe"] = true } }, position =
        vector.new(0, -1, 0) })
        assert.is_false(turtle.compareDown())
        turtle:addItemToInventory({ name = "minecraft:obsidian", count = 1, maxcount = 64 })
        turtle.select(2)
        assert.is_true(turtle.compareDown())
    end)
    it("CompareTo", function()
        assert.is_true(turtle.compareTo(2))
        turtle:addItemToInventory({ name = "minecraft:stone", count = 1, maxcount = 64 })
        assert.is_false(turtle.compareTo(2))
        turtle:addItemToInventory({ name = "minecraft:obsidian", count = 1, maxcount = 64 })
        assert.is_false(turtle.compareTo(2))
        turtle:addItemToInventory({ name = "minecraft:obsidian", count = 1, maxcount = 64 }, 3)
        turtle.select(2)
        assert.is_true(turtle.compareTo(3))
    end)
    it("Inspect", function()
        local succ, info = turtle.inspect()
        assert.is_true(succ)
        ---@cast info inspectResult
        assert.are.equal("minecraft:stone", info.name)
        assert.are.equal(nil, info.state)
        assert.are.equal(nil, info.tags)
        succ, info = turtle.inspectUp()
        assert.is_true(succ)
        ---@cast info inspectResult
        assert.are.equal("minecraft:wood", info.name)
        assert.are.equal(true, info and info.state and info.state.burning)
        assert.are.equal(nil, info.tags)
        succ, info = turtle.inspectDown()
        assert.is_false(succ)
        assert.are.equal(nil, info)
        turtleEmulator:createBlock({ item = { name = "minecraft:obsidian", tags = { ["minecraft:minable/pickaxe"] = true } }, position =
        vector.new(0, -1, 0) })
        succ, info = turtle.inspectDown()
        assert.is_true(succ)
        ---@cast info inspectResult
        assert.are.equal("minecraft:obsidian", info.name)
        assert.are.equal(true, info and info.tags and info.tags["minecraft:minable/pickaxe"])
        local turtle2 = turtleEmulator:createTurtle()
        turtle2.addItemToInventory({ name = "minecraft:coal", count = 64, maxcount = 64, fuelgain = 8 }, 1)
        turtle2.refuel(64)
        turtle2.dig()
        assert.is_true(turtle2.forward())
        succ, info = turtle.inspect()
        assert.is_true(succ)
        assert.are.equal("computercraft:turtle_normal", info.name)
        assert.are.equal(nil, info.state)
        assert.are.equal(nil, info.tags)
    end)
end)
describe("Place", function()
    ---@type TurtleProxy
    local turtle
    before_each(function()
        turtleEmulator:clearBlocks()
        turtleEmulator:clearTurtles()
        turtle = turtleEmulator:createTurtle()
    end)
    it("Place", function()
        assert.is_false(turtle.place())
        turtle:addItemToInventory({ name = "minecraft:stone", count = 1, maxcount = 64, placeAble = true }, 1)
        assert.is_true(turtle.place())
        local block = turtleEmulator:getBlock({ x = 1, y = 0, z = 0 })
        assert.are.equal("minecraft:stone", block.item.name)
    end)
    it("PlaceUp", function()
        assert.is_false(turtle.placeUp())
        turtle:addItemToInventory({ name = "minecraft:stone", count = 1, maxcount = 64, placeAble = true }, 1)
        assert.is_true(turtle.placeUp())
        local block = turtleEmulator:getBlock({ x = 0, y = 1, z = 0 })
        assert.are.equal("minecraft:stone", block.item.name)
    end)
    it("PlaceDown", function()
        assert.is_false(turtle.placeDown())
        turtle:addItemToInventory({ name = "minecraft:stone", count = 1, maxcount = 64, placeAble = true }, 1)
        assert.is_true(turtle.placeDown())
        local block = turtleEmulator:getBlock({ x = 0, y = -1, z = 0 })
        assert.are.equal("minecraft:stone", block.item.name)
    end)
    it("Place with placeFunction", function()
        assert.is_false(turtle.place())
        ---@type placeAction | function
        local placeAction = function(turtle, item, position)
            item.name = "minecraft:bucket"
            turtleEmulator:createBlock({ item = { name = "minecraft:water" }, position = position })
            return true
        end
        local item = {
            name = "minecraft:water_bucket",
            count = 1,
            maxcount = 64,
            placeAble = true,
            placeAction =
                placeAction
        }
        turtle:addItemToInventory(item, 1)
        local position = vector.new(1, 0, 0)
        local block = turtleEmulator:getBlock(position)
        assert.are.equal(nil, block)
        turtle.place()
        block = turtleEmulator:getBlock(position)
        assert.are.equal("minecraft:water", block.item.name)
    end)
end)
describe("peripherals", function()
    ---@type TurtleProxy
    local turtle
    ---@type PeripheralModule
    local peripheral
    before_each(function()
        turtleEmulator:clearBlocks()
        turtleEmulator:clearTurtles()
        turtle = turtleEmulator:createTurtle()
        peripheral = turtle.getPeripheralModule()
    end)
    it("Create Chests", function()
        turtleEmulator:clearBlocks()
        turtleEmulator:clearTurtles()
        local block = turtleEmulator:createBlock({ item = { name = "minecraft:chest" }, position = vector.new(1, 0, 0) })
        local chest = turtleEmulator:addInventoryToItem(block.item)
        chest:addItemToInventory({ name = "minecraft:stone", count = 64, maxcount = 64 })

        local block2 = turtleEmulator:createBlock({ item = { name = "minecraft:chest" }, position = vector.new(2, 0,
            0) })
        local chest2 = turtleEmulator:addInventoryToItem(block2.item)
        assert.is_true(chest2:addItemToInventory({ name = "minecraft:stone", count = 64, maxcount = 64 }, 2))
        assert.are.equal(64, chest:getItemCount(1))
        assert.are.equal(0, chest:getItemCount(2))
        assert.are.equal(0, chest2.getItemCount(1))
        assert.are.equal(64, chest2.getItemCount(2))
        -- check the ORIGINAL block in the emulator
        -- since the return is just a proxy
        assert.are.equal(64, block2.item.peripheralActions[2].count)
    end)
    it("isPresent", function()
        turtle.position = vector.new(5, 0, 5 )
        turtle.facing = vector.new(1, 0, 0)
        local block = turtleEmulator:createBlock({ item = { name = "minecraft:chest" }, position = vector.new(5, 0, 6 ) })
        turtleEmulator:addInventoryToItem(block.item)
        ---     o.o
        --- ___|___|___
        --- ___|_t_|_x_
        ---    |   |
        -- assert.is_false(peripheral.isPresent("front"))
        -- assert.is_false(peripheral.isPresent("left"))
        -- assert.is_false(peripheral.isPresent("back"))
        -- assert.is_false(peripheral.isPresent("up"))
        -- assert.is_false(peripheral.isPresent("down"))
        -- assert.is_false(peripheral.isPresent("right"))
        local block2 = turtleEmulator:createBlock({ item = { name = "minecraft:chest2" }, position = vector.new(6, 0, 5) })
        turtleEmulator:addInventoryToItem(block2.item)
        ---     o.o
        --- ___|_x_|___
        --- ___|_t_|_x_
        ---    |   |
        assert.is_true(peripheral.isPresent("front"))
        assert.is_false(peripheral.isPresent("right"))
        assert.is_false(peripheral.isPresent("left"))
        assert.is_false(peripheral.isPresent("back"))
        turtle.turnRight()
        ---     
        --- ___|_x_|___
        --- ___|_t_|_x_ o.o
        ---    |   |
        assert.is_false(peripheral.isPresent("right"))
        assert.is_false(peripheral.isPresent("back"))
        assert.is_false(peripheral.isPresent("left"))
        assert.is_true(peripheral.isPresent("front"))
        turtle.turnRight()
        --- ___|_x_|___
        --- ___|_t_|_x_
        --- ___|   |   
        ---     o.o
        assert.is_false(peripheral.isPresent("back"))
        assert.is_false(peripheral.isPresent("left"))
        assert.is_false(peripheral.isPresent("front"))
        assert.is_false(peripheral.isPresent("right"))
        turtle.turnRight()
        ---      ___|_x_|___
        --- o.o  ___|_t_|_x_
        ---      ___|   |   
        assert.is_false(peripheral.isPresent("left"))
        assert.is_false(peripheral.isPresent("front"))
        assert.is_false(peripheral.isPresent("right"))
        assert.is_false(peripheral.isPresent("back"))
        turtle.turnRight()
        ---         o.o
        ---     ___|_x_|___
        ---     ___|_t_|_x_
        ---     ___|   |
        assert.is_true(peripheral.isPresent("front"))
        assert.is_false(peripheral.isPresent("right"))
        assert.is_false(peripheral.isPresent("left"))
        assert.is_false(peripheral.isPresent("back"))
    end)
    it("Can Access Chest", function()
        turtle.position = vector.new(5, 0, 5 )
        turtle.facing = vector.new(1, 0, 0)
        local block = turtleEmulator:createBlock({ item = { name = "minecraft:chest" }, position = vector.new(6, 0, 5 ) })
        local chest = turtleEmulator:addInventoryToItem(block.item)
        chest:addItemToInventory({ name = "minecraft:stone", count = 64, maxcount = 64 })
        ---@type ChestInventory | nil
        local chestPeripheral = peripheral.find("inventory")
        assert.True(chestPeripheral ~= nil)
        assert.are.equal(64, chestPeripheral.getItemCount(1))
    end)
    it("Can drop items", function ()
        local block = turtleEmulator:createBlock({ item = { name = "minecraft:chest" }, position = vector.new(1, 0, 0 ) })
        local chest = turtleEmulator:addInventoryToItem(block.item)
        turtle.addItemToInventory({ name = "minecraft:stone", count = 64, maxcount = 64 }, 1)
        turtle.addItemToInventory({ name = "minecraft:stone", count = 64, maxcount = 64 }, 2)
        turtle.select(1)
        assert.is_true(turtle.drop())
        assert.are.equal(1, chest.getItemCount(1))
        turtle.select(2)
        assert.is_true(turtle.drop(64))
        assert.are.equal(64, chest.getItemCount(1))
        assert.are.equal(1, chest.getItemCount(2))
        assert.are.equal(63,turtle.getItemCount(1))
        assert.are.equal(0,turtle.getItemCount(2))
        turtle.select(1)
        assert.is_true(turtle.dropDown())
        assert.are.equal(62, turtle.getItemCount(1))
        assert.is_true(turtle.dropUp(64)) -- will work even if there are not enough items
        assert.are.equal(0, turtle.getItemCount(1))
    end)
    it("Can find chest", function()
        local block = turtleEmulator:createBlock({ item = { name = "minecraft:chest" }, position = vector.new(1, 0, 0 ) })
        local chest = turtleEmulator:addInventoryToItem(block.item)
        ---@type inventory | nil
        local chestPeripheral = peripheral.find("inventory")
        assert.True(chestPeripheral ~= nil)
        assert.are.equal(0,chestPeripheral.getItemCount(1))
        assert.are.equal("inventory", chestPeripheral.getType())
    end)
    it("Check turtleEquips", function()
        turtle.addItemToInventory({ name = "minecraft:testItem", count = 1, maxcount = 1, equipable = true }, 1)
        turtleEmulator:addInventoryToItem(turtle.inventory[1])
        turtle.equipLeft()
        assert.is_true(peripheral.isPresent("left"))
        local testItem = peripheral.wrap("left")
        ---@type ChestInventory | nil
        assert.is_true(testItem ~= nil)
        assert.are.equal("inventory", testItem.getType())
        testItem.addItemToInventory({ name = "minecraft:stone", count = 64, maxcount = 64 })
        assert.are.equal(64, testItem.getItemCount(1))
    end)
end)
