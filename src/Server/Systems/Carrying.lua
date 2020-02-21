local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"

local CollectionService = game:GetService("CollectionService")

local Carrying = {}

function Carrying:start()
    Messages:hook("PutDownCarry",function(player)
        local character = player.Character
        for _, v in pairs(character:GetChildren()) do
            if CollectionService:HasTag(v, "Carryable") then
                for _, x in pairs(v:GetJoints()) do
                    x:Destroy()
                end
                v.Parent = workspace
                v.Massless = false
                v.CanCollide = true
            end
        end
    end)
    Messages:hook("CarryObject",function(player, target)
        if not target.Parent:FindFirstChild("Humanoid") then
            target.Parent = player.Character
            target.CFrame = player.Character.Head.CFrame * CFrame.new(0, target.Size.Y/2 + player.Character.Head.Size.Y/2, 0)
            target.Massless = true
            target.CanCollide = false
            local weld = Instance.new("WeldConstraint", target)
            weld.Part0 = target 
            weld.Part1 = player.Character.Head
            target:SetNetworkOwner(player)
            Messages:sendClient(player, "SetCarryingObject", target)
        end
    end)
end

return Carrying