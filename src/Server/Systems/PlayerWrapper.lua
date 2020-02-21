local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local Players = game:GetService("Players")

local PlayerWrapper = {}

function PlayerWrapper:start()
    Players.PlayerAdded:connect(function(player)
        Messages:send("PlayerAdded", player)
    end)
end

return PlayerWrapper