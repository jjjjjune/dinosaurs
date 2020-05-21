local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local CollectionService = game:GetService("CollectionService")

local tagsToEffectsMap = {
    Rock = import "Shared/Effects/RockEffect",
    Character = import "Shared/Effects/CharacterDamageEffect",
    Animal = import "Shared/Effects/AnimalDamageEffect"
}

local function playDamageEffect(object, ...)
    for tag, effect in pairs(tagsToEffectsMap) do
        if CollectionService:HasTag(object, tag) then
            effect(object, ...)
            return
        end
    end
end

local DamageEffects = {}

function DamageEffects:start()
    Messages:hook("PlayDamageEffect",playDamageEffect)
end

return DamageEffects