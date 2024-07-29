local WindowHandler = require("vim-be-better.window");
local types = require("vim-be-better.types");
local log = require("vim-be-better.log")
local bind = require("vim-be-better.bind")
local createEmpty = require("vim-be-better.game-utils").createEmpty

local header = {
    "Highscores: Select a game",
    " ",
}

local hsmenu = { }
function hsmenu:go(window)
    local menuObj = {
        window = window,
        buffer = window.buffer,
    }

    window.buffer:setInstructions({})
    window.buffer:clear()
    vim.api.nvim_win_set_cursor(0, {5, 1})

    self.__index = self
    local hsmenuObj = setmetatable(menuObj, self)

    hsmenuObj._onChange = bind(hsmenuObj, "onChange")
    window.buffer:onChange(hsmenuObj._onChange)

    return hsmenuObj
end

local function gethsmenuLength()
    return #header + #types.games
end

local function getTableChanges(lines, compareSet, startIdx)
    local maxCount = #lines
    local idx = startIdx
    local i = 1
    local found = false
    --for idx = 1, #compareSet do
    --    print(compareSet[idx])
    --    vim.fn.system("sleep 1")
    --end

    while found == false and idx <= maxCount and i <= #compareSet do
        if lines[idx] == nil or lines[idx]:find(compareSet[i], 1, true) == nil then
            print(lines[idx])
            found = true
        else
            i = i + 1
            idx = idx + 1
        end
    end

    return found, i, idx
end

--local changed = 1

function hsmenu:onChange()
    local lines = self.window.buffer:getAllLines()
    local maxCount = gethsmenuLength()
    --print(changed)
    --changed = changed + 1

    if #lines == maxCount then
        return
    end

    local found, i, idx = getTableChanges(lines, header, 1)
    if found then
        self:render()
        return
    end

    local found, i, idx = getTableChanges(lines, types.games, 3)
    if found then
        --local lines = {}
        --table.insert(lines, types.games[i])
        print(i)
        vim.api.nvim_buf_set_lines(vim.api.nvim_get_current_buf(), 0, 35, false, { types.games[i], ' ', 'scores', 'scores', 'scores', 'scores', 'scores', 'scores' })
        return
    end
end

function hsmenu:render()
    self.window.buffer:clearGameLines()
    local lines = {}
    for idx = 1, #header do
        table.insert(lines, header[idx])
    end
    for idx = 1, #types.games do
        table.insert(lines, types.games[idx])
    end
    --self.window.buffer:render(lines)
    vim.api.nvim_buf_set_lines(vim.api.nvim_get_current_buf(), 0, 35, false, lines)
end

function hsmenu:close()
    self.buffer:removeListener(self._onChange)
end

return hsmenu
