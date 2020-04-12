local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local Players = game:GetService("Players")

local PlayerWrapper = {}

function PlayerWrapper:start()
    Players.PlayerAdded:connect(function(player)
        Messages:send("PlayerAdded", player)
    end)
    Players.PlayerRemoving:connect(function(player)
        Messages:send("PlayerRemoving", player)
    end)
    for _, p in pairs(game.Players:GetPlayers()) do -- funny studio
        Messages:send("PlayerAdded", p)
    end
end

return PlayerWrapper