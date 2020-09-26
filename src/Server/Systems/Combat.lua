local import = require(game.ReplicatedStorage.Shared.Import)

local TagsToModulesMap = import "Shared/Data/TagsToModulesMap"

local Messages = import "Shared/Utils/Messages"
local Damage = import "Shared/Utils/Damage"

local CollectionService = game:GetService("CollectionService")

local nextDamages = {}

local function getItemModule(itemInstance)
    local itemModule
    for tag, moduleState in pairs(TagsToModulesMap.Items) do
        if CollectionService:HasTag(itemInstance, tag) then
            itemModule = moduleState
            break
        end
    end
    if not itemModule then
        itemModule = import "Shared/ItemModules/Default"
    end
    return itemModule
end

local function registerHit(murdererPlayer, victim, knockback)
    local character = murdererPlayer.Character
    if not character then return end
    if not victim.PrimaryPart then return end

    local distance = (character.PrimaryPart.Position - victim.PrimaryPart.Position).magnitude

    if distance > 20 then
        return
    end

    local item, itemModule do
        for _, v in pairs(murdererPlayer.Character:GetChildren()) do
            if CollectionService:HasTag(v, "Item") then
                item = v
                itemModule = getItemModule(item)
                break
            end
        end
    end

    local canDamage do
        if not nextDamages[murdererPlayer] then
            nextDamages[murdererPlayer] = 0
            canDamage = true
        else
            canDamage = tick() >= nextDamages[murdererPlayer]
        end
    end

    if canDamage then
        local damageType = itemModule.damageType
        local damage = itemModule.damage
        Damage(victim, {
            damage = damage,
            type = damageType,
			ignorePlayer = murdererPlayer,
			murderer = murdererPlayer,
        })
        if knockback then
            Messages:send("Knockback", victim, knockback, .15)
        end
        nextDamages[murdererPlayer] = tick() + itemModule.debounce
    end
end

local Combat = {}

function Combat:start()
    Messages:hook("RegisterHit", registerHit)
end

return Combat
