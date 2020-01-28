local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local CollectionService = game:GetService("CollectionService")

local ELEMENTS = import "Shared/Data/Elements"

local function getElement(material)
    for _, element in pairs(ELEMENTS) do
        if CollectionService:HasTag(material, element) then
            return element
        end
    end
end

local transformationFunctions = {}

transformationFunctions.Coal = function(material)
    material.BrickColor = BrickColor.new("Black")
    material.Material = Enum.Material.Pebble
end

local function transformMaterial(material, targetMaterialName)
    local baseElement = getElement(material)
    CollectionService:RemoveTag(material, baseElement)
    CollectionService:AddTag(material, targetMaterialName)
    if transformationFunctions[targetMaterialName] then
        transformationFunctions[targetMaterialName](material)
    end
    for _, v in pairs(material:GetChildren()) do
        if v:IsA("Texture") or v:IsA("ParticleEmitter") then
            v:Destroy()
        end
    end
end

local ReactionFunctions = {}

ReactionFunctions.Fire = {}
ReactionFunctions.Fire.Wood = function(baseMaterial, touchingMaterial)
    CollectionService:AddTag(touchingMaterial, "Fire")
    CollectionService:AddTag(touchingMaterial, "Active")
end
ReactionFunctions.Fire.Coal = function(baseMaterial, touchingMaterial)
    CollectionService:AddTag(touchingMaterial, "Fire")
    CollectionService:AddTag(touchingMaterial, "Active")
end

ReactionFunctions.Water = {}
ReactionFunctions.Water.Fire = function(baseMaterial, touchingMaterial)
    CollectionService:RemoveTag(touchingMaterial, "Fire")
    CollectionService:RemoveTag(touchingMaterial, "Active")
    for _, v in pairs(touchingMaterial:GetChildren()) do
        if v:IsA("Texture") or v:IsA("ParticleEmitter") then
            v:Destroy()
        end
    end
    if not CollectionService:HasTag(touchingMaterial, "Coal") then
        transformMaterial(touchingMaterial, "Coal")
    end
end


return ReactionFunctions