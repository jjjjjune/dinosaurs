local import = require(game.ReplicatedStorage.Shared.Import)

local CollectionService = game:GetService("CollectionService")

local Messages = import "Shared/Utils/Messages"

local lastContact = tick()

local HIT_DEBOUNCE = .75

local function onHitSpikyThing(part)

    Messages:send("PlayDamageEffect", game.Players.LocalPlayer.Character, "normal")
    Messages:sendServer("ReportCollision", part.Parent)

    local dir = CFrame.new(game.Players.LocalPlayer.Character.PrimaryPart.Position, part.Position).lookVector
    dir = dir + Vector3.new(0,-1,0)

    Messages:send("Knockback", -dir*50, .2)

end

local function onHitboxContact(part)
    if CollectionService:HasTag(part.Parent, "Spiky") then
        if tick() - lastContact > HIT_DEBOUNCE then
            onHitSpikyThing(part)
            lastContact = tick()
        end
    end
    if CollectionService:HasTag(part.Parent, "FreshWater") then
        Messages:sendServer("ReportCollision", part.Parent)
    end
end

local ClientCollisions = {}

function ClientCollisions:start()
    Messages:hook("CharacterAddedClient", function(character)
        lastContact = 0
        local hitbox = character:WaitForChild("Hitbox")
        hitbox.Touched:connect(onHitboxContact)
    end)
end

return ClientCollisions