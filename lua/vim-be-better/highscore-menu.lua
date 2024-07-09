local types = require("vim-be-good.types")
local createEmpty = require("vim-be-good.game-utils").createEmpty

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
