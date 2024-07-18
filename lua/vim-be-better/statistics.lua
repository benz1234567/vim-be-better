local log = require("vim-be-better.log")
local default_config =  {
    plugin = 'VimBeGoodStats',

    save_statistics = true--vim.g["vim_be_good_save_statistics"] or false,

}

local statistics = {}

local stdpath = vim.api.nvim_call_function('stdpath', {'data'})

function statistics:new(config)
    config = config or {}
    config = vim.tbl_deep_extend("force", default_config, config)

    local stats = {
        file = string.format('%s/%s.log', stdpath, config.plugin),
        saveStats = config.save_statistics
    }
    self.__index = self
    return setmetatable(stats, self)
end

function statistics:logResult(result)
    if self.saveStats then
        local fp = io.open(self.file, "a")
        local str = string.format("%s,%s,%s,%s,%s,%f\n",
        result.timestamp, result.roundNum, result.difficulty, result.roundName, result.success, result.time)
        fp:write(str)
        fp:close()
    end
end

function statistics:logEnd(game, avg, difficulty)
    if self.saveStats then
        local fp = io.open(self.file, "a")
        local str = string.format("eg,%s,%s,%s\n", game, difficulty, avg)
        fp:write(str)
        fp:close()
    end
end

local function parseScores(line)
    local game, difficulty, average = line:match('eg,(.-),(.-),(.*)')
    return game, difficulty, tonumber(average)
end

function statistics:updateHighScores()
    local highscorepath = stdpath .. "/vim-be-good-highscores"
    vim.fn.system("mkdir -p " .. highscorepath)
    fr = io.open(self.file, "r")
    local matchinglines = {}
    for line in fr:lines() do
        if line:match("^eg") then
            table.insert(matchinglines, line)
            local game, difficulty, average = parseScores(line)
        end
    end
    fr:close()
end

return statistics
