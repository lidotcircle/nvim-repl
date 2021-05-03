
local M = {}

---@param source table
---@return table
function M.proxyObject(source)
    assert(type(source) == type({}))
    local proxy = {}

    setmetatable(proxy, {
        __index = function(_, key)
            return source[key]
        end;
        __newindex = function(_, key, val)
            source[key] = val
        end;
    })

    return proxy
end

return M

