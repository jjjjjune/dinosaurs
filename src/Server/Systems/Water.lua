local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")

local function dryAllWater()
    for _, freshWater in pairs(CollectionService:GetTagged("FreshWater")) do
        freshWater.Sand.Material = Enum.Material.Marble
        freshWater.Water.Transparency = 1
        CollectionService:AddTag(freshWater.Water, "RayIgnore")
        Messages:send("PlaySound", "Smoke", freshWater.Water)
    end
end

local function wetAllWater()
    for _, freshWater in pairs(CollectionService:GetTagged("FreshWater")) do
        freshWater.Sand.Material = Enum.Material.SmoothPlastic
        freshWater.Water.Transparency = .2
        CollectionService:RemoveTag(freshWater.Water, "RayIgnore")
        Messages:send("PlaySound", "Drinking", freshWater.Water)
    end
end

local function connectEvent(freshWater)
    --[[freshWater.Water.Touched:connect(function(hit)
        if freshWater.Water.Transparency < 1 then 
            if hit.Parent:FindFirstChild("Humanoid") then
                local player = game.Players:GetPlayerFromCharacter(hit.Parent)
                if player then
                    Messages:send("AddStat", player, "thirst", 1)
                end
            end
        end
    end)--]]
end

local Water = {}

function Water:start()
    Messages:hook("DryAllWater", dryAllWater)
    Messages:hook("WetAllWater", wetAllWater)
    CollectionService:GetInstanceAddedSignal("FreshWater"):connect(function(freshWater)
        connectEvent(freshWater)
    end)
    for _, freshWater in pairs(CollectionService:GetTagged("FreshWater")) do
        connectEvent(freshWater)
    end
end

return Water