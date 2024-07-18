local WindowHandler = require("vim-be-better.window");
local types = require("vim-be-better.types");

local hsmenu = { }
function hsmenu:go(window)
    local lines = { "",
    "Highscores: Select a game",
    "",
}
    local menuObj = {
        window = window,
        buffer = window.buffer,
    }
    window.buffer:clear()

    for idx = 1, #types.difficulty do
        table.insert(lines, types.difficulty[idx])
    end

    window.buffer:render(lines)
    return menuObj
end

return hsmenu
