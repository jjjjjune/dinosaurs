local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

local tagsToEffectsMap = {
    Rock = import "Shared/Effects/RockEffect"
}

local function playDamageEffect(object)
    for tag, effect in pairs(tagsToEffectsMap) do
        if CollectionService:HasTag(object, tag) then
            effect(object)
            return
        end
    end
end

local DamageEffects = {}

function DamageEffects:start()
    Messages:hook("PlayDamageEffect",playDamageEffect)
end

return DamageEffects