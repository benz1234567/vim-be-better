local log = require("vim-be-better.log")
local types = require("vim-be-better.types")
local default_config =  {
    plugin = 'VimBeBetterStats',

    save_statistics = vim.g["vim_be_better_save_statistics"] or true,

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
        --vim.fn.system("touch " .. highscorepath .. "/" .. types.games[idx])
        local hsfile, err = io.open(highscorepath .. "/" .. types.games[idx], "r")
        if hsfile then
            hsfile:close()
        else
            local file = io.open(highscorepath .. "/" .. types.games[idx], "w")
            for idx = 2, #types.difficulty do
                file:write(string.format('%s %s\n', types.difficulty[idx], '999999999'))
            end
            file:close()
        end
    end
    sf = io.open(self.file, "r")
    local matchinglines = {}
    if not sf then
        print("file not found: " .. self.file)
    end
    for line in sf:lines() do
        if line:match("^eg") then
            table.insert(matchinglines, line)
            local game, difficulty, average = parseScores(line)
            hsf, err = io.open(highscorepath .. "/" .. game, "r")
            if not hsf then
                return
            end
            local hsftable = {}
            for hsline in hsf:lines() do
                if hsline:match("^" .. difficulty) then
                    local highscore = tonumber(hsline:match(difficulty .. ' (.*)'))
                    if average < highscore then
                        table.insert(hsftable, (string.format('%s %s\n', difficulty, average)))
                        print("New Highscore!")
                    else
                        table.insert(hsftable, hsline .. '\n')
                    end
                else
                    table.insert(hsftable, hsline .. '\n')
                end
            end
            hsf:close()
            local hsfw = io.open(highscorepath .. "/" .. game, "w")
            if not hsf then
                print("file not found: " .. highscorepath .. "/" .. game)
            end
            for idx = 1, #hsftable do
                hsfw:write(hsftable[idx])
            end
            hsfw:close()
        end
    end
    sf:close()
end

function statistics:getHighScore(game, difficulty)
    self:updateHighScores()
    local highscorepath = stdpath .. "/vim-be-better-highscores/"
    local hsf = io.open(highscorepath .. game, "r")
    local highscore = nil
    for hsline in hsf:lines() do
        if hsline:match("^" .. difficulty) then
            highscore = tonumber(hsline:match(difficulty .. ' (.*)'))
            break
        end
    end
    hsf:close()
    return highscore
end

return statistics
