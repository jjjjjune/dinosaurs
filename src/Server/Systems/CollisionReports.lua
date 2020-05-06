local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local CollectionService = game:GetService("CollectionService")

local Damage = import "Shared/Utils/Damage"

local CollisionReports = {}

function CollisionReports:start()
    Messages:hook("ReportCollision", function(player, object)
        if (object.PrimaryPart.Position - player.Character.PrimaryPart.Position).magnitude < 50 then
            if CollectionService:HasTag(object, "Spiky") then
                Damage(player.Character, {damage = -10, type = "normal"})
            end
        end
    end)
end

return CollisionReports