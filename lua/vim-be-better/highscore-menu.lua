local types = require("vim-be-better.types")

local HighScoreMenu = {}

local highscoreHeader = {
    "",
    "High Scores",
    "Select a Difficulty (delete from the list to view scores)",
    "----------------------------------------------------------",
}

local credits = {
    "",
    "Created by ThePrimeagen",
    "Brandoncc",
    "polarmutex",
    "",
    "https://github.com/ThePrimeagen/vim-be-better",
    "https://twitch.tv/ThePrimeagen",
}

function HighScoreMenu:new(window)
    local menuObj = {
        window = window,
        buffer = window.buffer,
    }

    window.buffer:clear()
    self.__index = self
    local createdMenu = setmetatable(menuObj, self)

    createdMenu._onChange = bind(createdMenu, "onChange")
    window.buffer:onChange(createdMenu._onChange)

    createdMenu:render()
    return createdMenu
end

local function getMenuLength()
    return #types.difficulty + #highscoreHeader + #credits
end

local function getTableChanges(lines, compareSet, startIdx)
    local maxCount = #lines
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

function HighScoreMenu:onChange()
    local lines = self.window.buffer:getGameLines()
    local maxCount = getMenuLength()

    if #lines == maxCount then
        return
    end

    local found, i, idx = getTableChanges(lines, highscoreHeader, 1)
    if found then
        self:render()
        return
    end

    found, i, idx = getTableChanges(lines, types.difficulty, idx)
    if found then
        local selectedDifficulty = types.difficulty[i]
        self:showScoresForDifficulty(selectedDifficulty)
        return
    end
end

function HighScoreMenu:showScoresForDifficulty(difficulty)
    local scores = self:getScoresForDifficulty(difficulty)  -- Replace with actual logic to fetch scores
    self.window.buffer:clearGameLines()

    local lines = {
        "",
        "High Scores for " .. difficulty,
        "------------------------------------",
    }

    for idx, score in ipairs(scores) do
        table.insert(lines, score)
    end

    table.insert(lines, "")
    table.insert(lines, "Press 'q' to go back")

    self.window.buffer:render(lines)
end

function HighScoreMenu:getScoresForDifficulty(difficulty)
    -- Placeholder: Replace with actual logic to fetch high scores for the given difficulty
    return {
        "Player1: 1000",
        "Player2: 900",
        "Player3: 800",
    }
end

function HighScoreMenu:render()
    self.window.buffer:clearGameLines()

    local lines = { }
    for idx = 1, #highscoreHeader do
        table.insert(lines, highscoreHeader[idx])
    end

    for idx = 1, #types.difficulty do
        table.insert(lines, "[ ] " .. types.difficulty[idx])
    end

    for idx = 1, #credits do
        table.insert(lines, credits[idx])
    end

    self.window.buffer:render(lines)
end

function HighScoreMenu:close()
    self.buffer:removeListener(self._onChange)
end

return HighScoreMenu

