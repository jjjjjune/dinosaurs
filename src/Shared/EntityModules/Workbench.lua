local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Entity = {}

function Entity.clientUse(entityInstance)
    Messages:send("PlaySoundOnClient",{
        instance = game.ReplicatedStorage.Sounds.Pop
    })
    Messages:send("OpenCrafting", "Workbench")
end

function Entity.serverUse(player, entityInstance)
    
end

return Entity