local WindowHandler = require("vim-be-better.window");
local types = require("vim-be-better.types");
local log = require("vim-be-better.log")
local bind = require("vim-be-better.bind")
local statistics = require("vim-be-better.statistics")
local createEmpty = require("vim-be-better.game-utils").createEmpty

local header = {
    "Highscores: Select a game",
    " ",
}

local hsmenu = { }
function hsmenu:go(window, onMenuSelect)
    local menuObj = {
        window = window,
        buffer = window.buffer,
        onMenuSelect = onMenuSelect,
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
    local maxCount = #lines + 1
    local idx = startIdx
    local i = 1
    local found = false

    while found == false and idx <= maxCount and i <= #compareSet do
        if lines[idx] == nil or lines[idx]:find(compareSet[i], 1, true) == nil then
            found = true
        else
            i = i + 1
            idx = idx + 1
        end
    end

    return found, i, idx
end

function hsmenu:onChange()
    local lines = self.window.buffer:getAllLines()
    local maxCount = gethsmenuLength()

    if #lines == maxCount then
        return
    end

    local found, i, idx = getTableChanges(lines, header, 1)
    if found and not viewinghs then
        self:close()
        return
    end

    local found, i, idx = getTableChanges(lines, types.games, idx)
    if found and not viewinghs then
        scores = { types.games[i] .. " highscores (delete any line to go back to menu)", " " }
        local highscorepath = vim.api.nvim_call_function('stdpath', {'data'}) .. "/vim-be-better-highscores/"
        local hsf = io.open(highscorepath .. types.games[i], "r")
        for line in hsf:lines() do
            table.insert(scores, line)
        end
        hsf:close()
        viewinghs = true
        vim.api.nvim_buf_set_lines(vim.api.nvim_get_current_buf(), 0, -1, false, scores)
        return
    end

    local found, i, idx = getTableChanges(lines, scores, idx)
    if found and viewinghs then
        self:close()
        viewinghs = nil
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
    vim.api.nvim_buf_set_lines(vim.api.nvim_get_current_buf(), 0, -1, false, lines)
end

function hsmenu:close()
    self.buffer:removeListener(self._onChange)
    pcall(self.onMenuSelect)
end

return hsmenu
