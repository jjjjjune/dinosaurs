local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")

local originalBaseOffsets = {}
local originalHeights = {}

local function dry(freshWater)
    freshWater.Sand.Material = Enum.Material.Marble
    freshWater.Water.Transparency = 1
    CollectionService:AddTag(freshWater.Water, "RayIgnore")
    Messages:send("PlaySound", "Smoke", freshWater.Water)
end

local function wet(freshWater)
    freshWater.Sand.Material = Enum.Material.SmoothPlastic
    freshWater.Water.Transparency = .2
    CollectionService:RemoveTag(freshWater.Water, "RayIgnore")
    Messages:send("PlaySound", "Drinking", freshWater.Water)
end

local function updateWaterAppearance(entityInstance)
    local amount = entityInstance.Amount.Value
    if CollectionService:HasTag(entityInstance, "Building") then
        if not originalBaseOffsets[entityInstance] then
            originalBaseOffsets[entityInstance] = entityInstance.Water.CFrame:toObjectSpace(entityInstance.PrimaryPart.CFrame)
            originalHeights[entityInstance] = entityInstance.Water.Size.Y
        end
        local water = entityInstance.Water
        local originalOffset = originalBaseOffsets[entityInstance]
        local amountAlpha = amount/entityInstance.Amount.MaxValue
        local newHeight = originalHeights[entityInstance] * amountAlpha
        local newSize = Vector3.new(water.Size.X, newHeight, water.Size.Z)
        local diff = 1 - amountAlpha
        local newCF = entityInstance.PrimaryPart.CFrame * originalOffset * CFrame.new(0, -diff/2, 0)
        water.Size = newSize
        water.CFrame = newCF
        if amount == 0 then
            entityInstance.Water.Transparency = 1
        else
            entityInstance.Water.Transparency = .2
        end
    else
        if amount == 0 then
            dry(entityInstance)
        else
            wet(entityInstance)
        end
    end
end

local function dryAllWater()
    for _, freshWater in pairs(CollectionService:GetTagged("FreshWater")) do
        if not CollectionService:HasTag(freshWater, "Building") then
            if freshWater:IsDescendantOf(workspace) then
                freshWater.Amount.Value = 0
                updateWaterAppearance(freshWater)
            end
        end
    end
end

local function wetAllWater()
    for _, freshWater in pairs(CollectionService:GetTagged("FreshWater")) do
        if freshWater:IsDescendantOf(workspace) then
            freshWater.Amount.Value = freshWater.Amount.MaxValue
            updateWaterAppearance(freshWater)
        end
    end
end

local function drinkWater(player, entityInstance)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local Stats = import "Server/Systems/Stats"
        local stat = Stats.getStat(player, "thirst")
        if stat.current < stat.max then 
            Messages:send("AddStat", player, "thirst", 1)
            entityInstance.Amount.Value = entityInstance.Amount.Value - 1
        end
    end
    updateWaterAppearance(entityInstance)
end

local Water = {}

function Water:start()
    Messages:hook("DryAllWater", dryAllWater)
    Messages:hook("WetAllWater", wetAllWater)
    Messages:hook("DrinkWater", drinkWater)
    CollectionService:GetInstanceAddedSignal("FreshWater"):connect(function(freshWater)
        updateWaterAppearance(freshWater)
    end)
end

return Water