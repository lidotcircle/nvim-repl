
--[[
--  APIs:
--      class      Object
--      function   Extend(...: class[])
--      function   InstanceOf(object, class)
--      function   Mixins(class, ...: class[])
--
--  Protocol:
--      protected Object:init(...: any[])
--      static Object.new(...: any[])
--]]

local M = {}
local key_constructor = 'constructor';
local key_proto       = '__proto__';

--@return number
local function indexof(table, obj)
    for i, value in ipairs(table) do
        if value == obj then return i end
    end

    return 0
end

local function __index(obj, key)
    local oproto = obj[key_constructor][key_proto]
    assert(type(oproto) == 'table')

    for _, base in ipairs(oproto) do
        local val = rawget(base, key)
        if type(val) == 'function' then return val end
    end

    return nil
end

local function construct(obj, constructor)
    assert(obj[key_constructor] == nil)
    obj[key_constructor] = constructor
    setmetatable(obj, {__index = __index})
end


local Object = {}
M.Object = Object
Object[key_proto] = { Object }
function Object:getClass() return self[key_constructor] end
function Object:init() end
function Object.new()
    local obj = {}
    construct(obj, Object)
    obj:init()
    return obj
end


function M.Extend(...)
    local ans = {}
    function ans:getClass() return ans end

    local bases
    if ... == nil then bases = { Object } else bases = { ... } end
    for _, base in ipairs(bases) do assert(base[key_proto] ~= nil) end

    local proto = { ans }
    for _, base in ipairs(bases) do
        if indexof(proto, base) == 0 then
            proto[#proto + 1] = base
        end

        for _, t in ipairs(base[key_proto]) do
            if indexof(proto, t) == 0 then
                proto[#proto + 1] = t
            end
        end
    end
    ans[key_proto] = proto

    function ans.construct(obj)
        construct(obj, ans)
    end
    function ans.new()
        local obj = {}
        ans.construct(obj)
        return obj
    end

    return ans
end

function M.InstanceOf(object, base)
    local proto = object[key_constructor][key_proto]
    assert(proto ~= nil)
    for _, b in ipairs(proto) do
        if b == base then return true end
    end
    return false
end

function M.Mixins(base, ...)
    assert(type(base[key_proto]) == 'table')
    if ... == nil then return end

    local proto = { ... }
    for _, b in ipairs(base[key_proto]) do
        assert(type(b) == 'table')
        proto[#proto + 1] = b
    end
    base[key_proto] = proto
end


return M

