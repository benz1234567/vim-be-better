local types = require("vim-be-better.types")
local createEmpty = require("vim-be-better.game-utils").createEmpty

local highscores = { }

function renderHighScoreMenu()
    self.window.buffer:clearGameLines()
    
    local lines = { }
    table.insert(lines, "View your Highscores: Choose a difficulty")

    for idx = 1, #types.difficulty do
        table.insert(lines, types.difficulty[idx])
    end

    self.window.buffer:render(lines)
end

return highscores
