local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"

local CollectionService = game:GetService("CollectionService")

local function onCharAdded(player, character)
    warn("onCharAdded firing ", tick())

    repeat wait() until character:IsDescendantOf(game)

    Messages:send("CharacterAdded", player, character)

    Messages:sendClient(player, "CharacterAddedClient", character)

    character:WaitForChild("Humanoid").Died:connect(function()
        Messages:send("PlayerDied", player, character)
        Messages:sendClient(player, "DiedClient", character)
    end)

    character:WaitForChild("Health"):Destroy()

    if character.HumanoidRootPart:FindFirstChild("Died") then
        character.HumanoidRootPart.Died:Destroy()
    end

    CollectionService:AddTag(character, "Character")

    local hitbox = Instance.new("Part")
    hitbox.Size = Vector3.new(4,7,4)
    hitbox.Transparency = 1
    hitbox.CanCollide = false
    hitbox.Name = "Hitbox"

    CollectionService:AddTag(hitbox, "Hitbox")

    hitbox.CFrame = character.PrimaryPart.CFrame
    hitbox.Parent = character

    local w = Instance.new("WeldConstraint", hitbox)
    w.Part0 = hitbox
    w.Part1 = character.PrimaryPart
end

local CharacterWrapper = {}

function CharacterWrapper:start()
    Messages:hook("PlayerAdded", function(player)
        player.CharacterAdded:connect(function(character)
            onCharAdded(player, character)
        end)
    end)
end

return CharacterWrapper