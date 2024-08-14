local GameUtils = require("vim-be-better.game-utils")
local log = require("vim-be-better.log")

math.randomseed(os.time())

local instructions = {
    "Change the number to the other one given",
}

local Numbers = {}
function Numbers:new(difficulty, window)
    log.info("NewNumbers", difficulty, window)
    local round = {
        window = window,
        difficulty = difficulty,
    }

    self.__index = self
    return setmetatable(round, self)
end

function Numbers:getInstructions()
    return instructions
end

function Numbers:getConfig()
    return {
        roundTime = GameUtils.difficultyToTime[self.difficulty],
    }
end

function Numbers:checkForWin()
    local lines = self.window.buffer:getGameLines()
    local trimmed = GameUtils.trimLines(lines)
    local concatenated = table.concat(GameUtils.filterEmptyLines(trimmed), "")

    winner = false

        winner = concatenated == whatnumber .. "lalalathisisafunctionorsomething(random, stuff, " .. changenumber .. ")"

    return winner
end

function Numbers:render()
    local lines = GameUtils.createEmpty(20)
    local cursorIdx = 5

    orignumber = math.random(0, 9)
    changenumber = math.random(0, 9)
    while changenumber and changenumber == orignumber do
        changenumber = math.random(0, 9)
    end

    whatnumber = "Change the number " .. orignumber .. " to " .. changenumber
    lines[5] = whatnumber

    numberline = "lalalathisisafunctionorsomething(random, stuff, " .. orignumber .. ")"
    lines[math.random(7, 15)] = numberline

    return lines, cursorIdx
end

function Numbers:name()
    return "numbers"
end

return Numbers
