
local M = {}

---@param text string
function M.lua_stdout(text) --<
    local ans = {}
    local lines = vim.split(text, '\n')
    for _, line in ipairs(lines) do
        local include = true
        if include and string.match(line, "^Lua.*Copyright.*$") then
            include = false
        end

        if include and string.match(line, "^>.*") then
            include = false
        end

        if include then
            ans[#ans + 1] = line
        end
    end

    if #ans > 0 and string.match(ans[1], "^%s*$") then
        table.remove(ans, 1)
    end

    return #ans > 0 and table.concat(ans, '\n') or nil, nil
end -->

function M.lua_stderr(text)
    local lines = vim.split(text, '\n')
    if #lines > 0 and string.match(lines[#lines], "^%s*$") then
        table.remove(lines, #lines)
    end
    return nil, table.concat(lines, '\n')
end

return M

