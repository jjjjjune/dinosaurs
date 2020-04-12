local import = require(game.ReplicatedStorage.Shared.Import)
local CollectionService = game:GetService("CollectionService")
local Binds = import "Client/Systems/Binds"
local Messages = import "Shared/Utils/Messages"
local TagsToModulesMap = import "Shared/Data/TagsToModulesMap"

local function useEntity(item)
    for tagName, entityState in pairs(TagsToModulesMap.Entities) do
        if  CollectionService:HasTag(item, tagName) then
            print("usijg entity")
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
    -- this will be before 
    -- Binds.bindTagToAction("Grabbable", "GRAB", function(item)
    --     -- this will be for picking up and moving small plants or other structures, which will probably happen in an "edit" mode
    -- end)
end
 
return Entities