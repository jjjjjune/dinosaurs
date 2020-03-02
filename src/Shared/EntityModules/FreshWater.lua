local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Entity = {}

function Entity.clientUse(entityInstance)
    local drinkSound = "Drinking"
    if entityInstance.Water.Transparency == 1 then
        drinkSound = "Fireputout"
    end
    Messages:send("PlaySoundOnClient",{
        instance = game.ReplicatedStorage.Sounds[drinkSound],
    })
end

function Entity.serverUse(player, entityInstance)
    local drinkSound = "Drinking"
    if entityInstance.Water.Transparency == 1 then
        drinkSound = "Fireputout"
    else
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            Messages:send("AddStat", player, "thirst", 1)
        end
    end
    Messages:reproOnClients(player, "PlaySound", drinkSound)
end

return Entity