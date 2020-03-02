local import = require(game.ReplicatedStorage.Shared.Import)
local CollectionService = game:GetService("CollectionService")
local Messages = import "Shared/Utils/Messages"
local TagsToModulesMap = import "Shared/Data/TagsToModulesMap"

local function useEntity(player, item)
    if not CollectionService:HasTag(item, "Entity") then
        player:Kick("what")
    end
    for tagName, entityState in pairs(TagsToModulesMap) do
        if  CollectionService:HasTag(item, tagName) then
            entityState.serverUse(player, item)
            break
        end
    end
end
local Entities = {}

function Entities:start()
    Messages:hook("UseEntity", useEntity)
end

return Entities