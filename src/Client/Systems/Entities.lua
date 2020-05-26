local import = require(game.ReplicatedStorage.Shared.Import)
local CollectionService = game:GetService("CollectionService")
local Binds = import "Client/Systems/Binds"
local Messages = import "Shared/Utils/Messages"
local TagsToModulesMap = import "Shared/Data/TagsToModulesMap"

local function useEntity(item)
    for tagName, entityState in pairs(TagsToModulesMap.Entities) do
        if  CollectionService:HasTag(item, tagName) then
            entityState.clientUse(item)
            Messages:sendServer("UseEntity", item)
            break
        end
    end
end

local Entities = {}

function Entities:start()
    Binds.bindTagToAction("Entity", "INTERACT", function(item)
        useEntity(item)
    end)
end
 
return Entities