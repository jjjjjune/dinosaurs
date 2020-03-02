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
    if pos then
        local hit, pos = CastRay(pos, Vector3.new(0,-6,0), {player.Character})
        if hit and hit.Name ~= "Water" then
            if CollectionService:HasTag(hit, "Grass") or hit.BrickColor.Name == "Pine Cone" or CollectionService:HasTag(hit, "Sand") then
                Messages:send("CreatePlant", item.Plant.Value, pos, 1)
                Messages:send("PlaySound", "Rustle", pos)
                Messages:send("PlayParticle", "Leaf", 20, pos)
                return true
            end
        end
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