local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"

local MIN_FIND_DISTANCE = 12

local CollectionService = game:GetService("CollectionService")

local function getClosestAnimal(position, tag)
    local closestDistance = MIN_FIND_DISTANCE
    local closestItem
    for _, item in pairs(CollectionService:GetTagged("Animal")) do
        local itemPos = item.PrimaryPart and item.PrimaryPart.Position
        if itemPos and not CollectionService:HasTag(item, "Rideable") then
            local dist = (position - itemPos).magnitude
            if (dist < closestDistance) then
                closestDistance = dist
                closestItem = item
            end
        end
    end
    return closestItem, closestDistance
end

local Item = {}

function Item.clientUse(item)

end

function Item.serverUse(player, item)
    local pos = player.Character and player.Character.PrimaryPart and player.Character.PrimaryPart.Position
    if pos then
        local animal = getClosestAnimal(pos)
        animal.Tame:Fire(player)
        Messages:sendClient(player, "Notify", "HEALTH_COLOR", "SPRING", "THE ANIMAL HAS BEEN TAMED.")
        return true
    else
        Messages:sendClient(player, "Notify", "HUNGER_COLOR_DARK", "ANGRY", "NO ANIMAL FOUND.")
        return false
    end
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