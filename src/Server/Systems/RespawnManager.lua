local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local RespawnManager = {}

function RespawnManager:start()
    Messages:hook("PlayerDied", function(player, characterThatDied)
        delay(5, function()
            player:LoadCharacter()
        end)
    end)
    Messages:hook("PlayerAdded", function(player)
        player:LoadCharacter()
    end)
end

return RespawnManager
