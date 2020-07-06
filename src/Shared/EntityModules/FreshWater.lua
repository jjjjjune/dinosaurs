local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Entity = {}

function Entity.clientUse(entityInstance)
    local drinkSound = "Drinking"
    if entityInstance.Water.Transparency == 1 or entityInstance.Amount.Value == 0 then
        drinkSound = "Fireputout"
    end
    Messages:send("PlaySoundOnClient",{
        instance = game.ReplicatedStorage.Sounds[drinkSound],
    })
end

function Entity.serverUse(player, entityInstance)
    if entityInstance.Amount.Value > 0 then
        Messages:send("DrinkWater", player, entityInstance)
    else
        local drinkSound = "Fireputout"
        Messages:reproOnClients(player, "PlaySound", drinkSound)
    end
end

return Entity
