package.path = package.path .. ";./lua/?.lua;./third_party/luaunit/?.lua"

local cls = require('class')
local lu  = require('luaunit')

function TestBasic()
    local obj1 = cls.Object.new()
    lu.assertEquals(cls.InstanceOf(obj1, cls.Object), true)

    local c1 = cls.Extend()
    local c2 = cls.Extend(c1, cls.Object)
    local c3 = cls.Extend()
    local obj2 = c2.new()
    lu.assertEquals(cls.InstanceOf(obj2, cls.Object), true)
    lu.assertEquals(cls.InstanceOf(obj2, c1), true)
    lu.assertEquals(cls.InstanceOf(obj2, c2), true)
    lu.assertEquals(cls.InstanceOf(obj2, c3), false)
end

function TestMixin()
    local c1 = cls.Extend()
    function c1:hello() return 'hello' end
    local m1 = {}
    function m1:hello() return 'world' end
    local m2 = {}
    function m2:hello() return 'worldx' end
    local m3 = {}

    cls.Mixins(c1, m1, m2, m3)
    local obj1 = c1.new()
    lu.assertEquals(cls.InstanceOf(obj1, c1), true)
    lu.assertEquals(cls.InstanceOf(obj1, m1), true)
    lu.assertEquals(cls.InstanceOf(obj1, m2), true)
    lu.assertEquals(cls.InstanceOf(obj1, m3), true)
    lu.assertEquals(obj1:hello(), "world")
end


os.exit( lu.LuaUnit.run() )

