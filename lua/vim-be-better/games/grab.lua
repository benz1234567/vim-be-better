local GameUtils = require("vim-be-better.game-utils")
local log = require("vim-be-better.log")

math.randomseed(os.time())

local closeOpts = {
    ")",
    "]",
    "}",
    ">",
}

local openOpts = {
    "(",
    "[",
    "{",
    "<",
}

local copythis = "'ThisIsWhatYouNeedToCopyItIsVeryLongBecauseIWantYouToDoItCorrectlyAndBecomeBetterAtRealWorldProgramming'"

local instructions = {
    "Type dawd = ( ), [ ], or { }, depending on which one you are given",
    "yank the contents of grabthis and paste them into dawd",
    "you can do for example #jyi(g;vi(p",
    "the point is to copy the insides with yi(, so don't do yy or VY",
    "))) to close the parenthesis so it doesn't mess you up"
}

local grabRound = {}
function grabRound:new(difficulty, window)
    log.info("New", difficulty, window)
    local round = {
        window = window,
        difficulty = difficulty,
    }

    self.__index = self
    return setmetatable(round, self)
end

function grabRound:getInstructions()
    return instructions
end

function grabRound:getConfig()
    log.info("getConfig", self.difficulty, GameUtils.difficultyToTime[self.difficulty])
    return {
        roundTime = GameUtils.difficultyToTime[self.difficulty] + 8000
    }
end

function grabRound:checkForWin()
    local lines = self.window.buffer:getGameLines()
    local trimmed = GameUtils.trimLines(lines)
    local concatenated = table.concat(trimmed)

    winner = false
        --winner = lowercased == "if (" .. self.config.randomWord .. ") {bar}"
        
    winner = concatenated == "dawd = " .. open .. copythis .. close .. table.concat(blockyi) .. table.concat(grabthis)

    return winner
end

function grabRound:render()
    loc = math.random(17, 25)
    braces = math.random(1, 4)
    open = openOpts[braces]
    close = closeOpts[braces]
    local lines = GameUtils.createEmpty(30)
    local cursorIdx = 7

    blockyi = {
        "blockyi = " .. open,
        "'This is to make it so that you have to jump',",
        "'to grab what you need. In the real world there',",
        "'is going to be lots of arrays/functions, not',",
        "'just one that you can yi + whatever brace to'",
        close,
    }

    grabthis = {
        "grabthis = " .. open,
        copythis,
        close,
    }

    for idx = 1, #blockyi do
        lines[idx + 10] = blockyi[idx]
    end

    for idx = 1, #grabthis do
        lines[idx + loc] = grabthis[idx]
    end

    return lines, cursorIdx
end

function grabRound:name()
    return "grab"
end

return grabRound


