local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Gamemode = {}

function Gamemode:start()
    self.selectedMode = "Survival"
    self.difficulty = "Easy"
    self.loaded = false
    Messages:hook("MapDoneGenerating", function()
        self.loaded = true
        Messages:send("GameLoaded")
    end)
end

return Gamemode