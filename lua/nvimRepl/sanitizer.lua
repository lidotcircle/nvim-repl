
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

function M.lua_stderr(text) --<
    local lines = vim.split(text, '\n')
    if #lines > 0 and string.match(lines[#lines], "^%s*$") then
        table.remove(lines, #lines)
    end
    return nil, table.concat(lines, '\n')
end -->

-- '> ' in head and tail, and keep last expression
function M.node_stdout(text) --<
    if not text then return end
    local stdout = {}
    local stderr = {}

    local lines = vim.split(text, '\n')
    table.remove(lines, #lines)

    if #lines > 0 then
        lines[1] = string.gsub(lines[1], "> ", "")
        if string.match(lines[1], "^%s*$") then
            table.remove(lines, 1)
        end
    end

    local iserror = false
    for _, line in ipairs(lines) do
        local include = true
        if iserror or string.match(line, "Uncaught") then
            iserror = true
        end

        if string.match(line, "^Welcome to")
            or string.match(line, "^Type \".help") then
            include = false;
        end

        if include then
            if iserror     then stderr[#stderr + 1] = line end
            if not iserror then stdout[#stdout + 1] = line end
        end
    end

    return #stdout > 0 and table.concat(stdout, '\n') or nil,
           #stderr > 0 and table.concat(stderr, '\n') or nil
end -->

-- seems output of node only come from stdout
function M.node_stderr(text) --<
    return nil, text
end -->

function M.python_stdout(text)
    return text, nil
end

function M.python_stderr(text)
    if string.match(text, "^>>> ...") or string.match(text, "^Python%s+%d%.%d%.%d") then return end
    if string.match(text, "^>>>$")    or string.match(text, "^Type \"help\"") then return end
    if string.match(text, "^>>> ...") or string.match(text, "^Python%s+%d%.%d%.%d") then return end

    return nil, text
end

return M

