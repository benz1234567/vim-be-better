local log = require("vim-be-better.log")
local types = require("vim-be-better.types")
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
    local highscorepath = stdpath .. "/vim-be-better-highscores"
    vim.fn.system("mkdir -p " .. highscorepath)
    for idx = 1, #types.games do
        vim.fn.system("touch " .. highscorepath .. "/" .. types.games[idx])
    end
    sf = io.open(self.file, "r")
    local matchinglines = {}
    for line in sf:lines() do
        if line:match("^eg") then
            table.insert(matchinglines, line)
            local game, difficulty, average = parseScores(line)
            hsf, err = io.open(highscorepath .. "/" .. game, "r")
            if not hsf then
                print("hsf error:", err)
                return
            end
            for hsline in hsf:lines() do
                if hsline:match("^" .. difficulty) then
                    print(hsline)
                    local highscore = tonumber(hsline:match('easy (.*)'))
                    if average > highscore then
                        print("new highscore")
                    end
                end
            end
            hsf:close()
        end
    end
    sf:close()
end

return statistics
