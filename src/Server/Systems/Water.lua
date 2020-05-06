local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")

local originalBaseOffsets = {}
local originalHeights = {}
local allWater = {}

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
    if amount == entityInstance.Amount.MaxValue and not originalHeights[entityInstance] then -- spawning for the first time
        return
    end
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
            dry(entityInstance)
        else
            wet(entityInstance)
        end
    end
end

local function dryAllWater()
    print("DRYING ALL WATER")
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

local function takeFromContainer(container)
    container.Amount.Value = container.Amount.Value - 1
    updateWaterAppearance(container)
    Messages:send("PlaySound", "Drinking", container.PrimaryPart)
end

local function fillContainer(container)
    container.Amount.Value = container.Amount.Value + 1
    updateWaterAppearance(container)
    Messages:send("PlaySound", "Drinking", container.PrimaryPart)
end

local Water = {}


local function isWithin(position, part)
    local barrierCorner1 = part.Position - Vector3.new(part.Size.X/2,0,part.Size.Z/2)
    local barrierCorner2 = part.Position + Vector3.new(part.Size.X/2,0,part.Size.Z/2)
    local x1, y1, x2, y2 = barrierCorner1.X, barrierCorner1.Z, barrierCorner2.X, barrierCorner2.Z
    local realY1 = part.Position.Y - 3
    local realY2 = part.Position.Y + 3
    if position.X > x1 and position.X < x2 then
        if position.Z > y1 and position.Z < y2 then
            if position.Y > realY1 and position.Y < realY2 then 
                return true
            end
        end
    end
end

function Water.isPositionWithinWater(position)
    for water, _ in pairs(allWater) do
        if isWithin(position, water.Water) then
            return true
        end
    end
end

function Water:start()
    Messages:hook("DryAllWater", dryAllWater)
    Messages:hook("WetAllWater", wetAllWater)
    Messages:hook("DrinkWater", drinkWater)
    Messages:hook("TakeFromContainer",takeFromContainer)
    Messages:hook("FillContainer",fillContainer)
    CollectionService:GetInstanceAddedSignal("FreshWater"):connect(function(freshWater)
        updateWaterAppearance(freshWater)
        allWater[freshWater] = true
    end)
    CollectionService:GetInstanceRemovedSignal("FreshWater"):connect(function(freshWater)
        allWater[freshWater] = nil
    end)
    for _, v in pairs(CollectionService:GetTagged("FreshWater")) do
        updateWaterAppearance(v)
    end
end

return Water