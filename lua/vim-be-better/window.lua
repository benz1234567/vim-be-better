local log = require("vim-be-better.log")
local Buffer = require("vim-be-better.buffer")
local WindowHandler = {}

local function generateConfig(rowPadding, colPadding)
    rowPadding = rowPadding or 2
    colPadding = colPadding or 2
    local vimStats = vim.api.nvim_list_uis()[1]
    local w = vimStats.width
    local h = vimStats.height

    local rowHalfPadding = math.floor(rowPadding / 2)
    local colHalfPadding = math.floor(colPadding / 2)

    return {
        row = rowHalfPadding,
        col = colHalfPadding,
        width = w - colPadding,
        height = h - rowPadding,
        relative = "editor",
    }
end

function WindowHandler:new(rowPadding, colPadding)

    local newWindow = {
        config = generateConfig(rowPadding, colPadding),
        rowPadding = rowPadding,
        colPadding = colPadding,
        bufh = 0,
        buffer = nil,
        winId = 0,
    }

    self.__index = self
    return setmetatable(newWindow, self)
end

function WindowHandler:close()
    if self.winId ~= 0 then
        vim.api.nvim_win_close(self.winId, true)
    end

    self.winId = 0

    log.info("window#close", debug.traceback())
    if self.buffer then
        self.buffer:close()
    end

    self.bufh = 0
    self.buffer = nil
end

function WindowHandler:isValid()
    return vim.api.nvim_win_is_valid(self.winId)
end

function WindowHandler:show()
    if self.bufh == 0 then
        self.bufh = vim.api.nvim_create_buf(false, true)
        self.buffer = Buffer:new(self.bufh, self)
    end

    if self.winId == 0 then
        if vim.g["vim_be_better_play_in_new_window"] == "true" then
            self.winId = vim.api.nvim_open_win(self.bufh, true, self.config)
        else
            vim.api.nvim_set_current_buf(self.bufh)
        end
    else
        vim.api.nvim_win_set_config(self.winId, self.config)
    end
end

function WindowHandler:onResize()
    if not vim.api.nvim_win_is_valid(self.winId) then
        return false
    end

    local ok, msg = pcall(function()
        print("onResize before", vim.inspect(self.config))
        self.config = generateConfig(self.rowPadding, self.colPadding)
        print("onResize", vim.inspect(self.config))
        self:show()
    end)

    if not ok then
        log.info("WindowHandler:onResize", msg)
    end

    return ok
end

return WindowHandler

