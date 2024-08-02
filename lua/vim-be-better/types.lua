local difficulty = {
    "noob",
    "easy",
    "medium",
    "hard",
    "nightmare",
    "tpope",
}

local games = { }

local function getBaseName(file)
    return file:match("(.+)%..+$")
end

local function requireGames()
    local gamesPath = debug.getinfo(1).source:match("@?(.*/)") .. "games/"
    
    local files = vim.fn.readdir(gamesPath)

    for _, file in ipairs(files) do
        local gameName = getBaseName(file)
        if gameName then
            table.insert(games, gameName)
        end
    end
    table.insert(games, "random")
end

requireGames()

return {
    difficulty = difficulty,
    games = games
}

