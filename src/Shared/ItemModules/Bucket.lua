local import = require(game.ReplicatedStorage.Shared.Import)
local CollectionService = game:GetService("CollectionService")
local Messages = import "Shared/Utils/Messages"
local CastRay = import "Shared/Utils/CastRay"

local Item = {}

function Item.clientUse(item)
    -- monch, clone Item item for effect, effect
end

function Item.serverUse(player, item)
    local pos = player.Character and player.Character.PrimaryPart and player.Character.PrimaryPart.Position

    local testPart = Instance.new("Part")
    testPart.Size = Vector3.new(10,10,10)
    testPart.Touched:connect(function()end)
    testPart.Anchored = true
    testPart.CFrame = CFrame.new(pos)
    testPart.Transparency = 1
    testPart.CanCollide = false
    CollectionService:AddTag(testPart, "RayIgnore")
    testPart.Parent = workspace

    local touchingParts = testPart:GetTouchingParts()
    local foundFreshWater
    local foundContainer

    local shouldTransform = false
    local foundFire = false

    for _, part in pairs(touchingParts) do
        if CollectionService:HasTag(part.Parent, "FreshWater") then
            if (item.Name == "Bucket" and part.Parent.Amount.Value > 0) or (item.Name == "Water Bucket" and part.Parent.Amount.Value < part.Parent.Amount.MaxValue) then
                if CollectionService:HasTag(part.Parent, "Building") then
                    foundContainer = part.Parent
                else
                    foundFreshWater = part.Parent
                end
            end
        end
        if CollectionService:HasTag(part.Parent, "Burning") then
            if item.Name == "Water Bucket" then
                Messages:send("PutOutFire", part.Parent)
                foundFire = true
            end
        end
    end

    if item.Name == "Water Bucket" then
        if foundContainer then
            Messages:send("FillContainer", foundContainer)
            shouldTransform = true
        elseif foundFreshWater then
            Messages:send("FillContainer", foundFreshWater)
            shouldTransform = true
        end
    elseif item.Name == "Bucket" then
        if foundFreshWater then
            Messages:send("TakeFromContainer", foundFreshWater)
            shouldTransform = true
        elseif foundContainer then
            Messages:send("TakeFromContainer", foundContainer)
            shouldTransform = true
        end
    end

    if foundFire then
        shouldTransform = true
    end

    if shouldTransform then
        if item.Name == "Bucket" then
            item.Name = "Water Bucket"
            item.Water.Transparency = 0.4
        else
            item.Name = "Bucket"
            item.Water.Transparency = 1
        end
    end

    testPart:Destroy()
end

function Item.clientEquip(item)
end

function Item.serverEquip(player, item)
end

function Item.clientUnequip(item)
end

function Item.serverUnequip(player, item)
end

return Item
