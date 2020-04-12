local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local CharacterWrapper = {}

function CharacterWrapper:start()
    Messages:hook("PlayerAdded", function(player)
        player.CharacterAdded:connect(function(character)

            Messages:send("CharacterAdded", player, character)
            Messages:sendClient(player, "CharacterAddedClient", character)
            character:WaitForChild("Humanoid").Died:connect(function()
                Messages:send("PlayerDied", player, character)
                Messages:sendClient(player, "DiedClient", character)
            end)
        end)
    end)
end

return CharacterWrapper