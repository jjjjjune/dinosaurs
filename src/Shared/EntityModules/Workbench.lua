local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Entity = {}

function Entity.clientUse(entityInstance)
    Messages:send("OpenCrafting", "Workbench", entityInstance)
end

function Entity.serverUse(player, entityInstance)

end

return Entity
