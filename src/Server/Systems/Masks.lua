local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local function characterAdded(player, character)
    spawn(function()
        local head = character:WaitForChild("Head")
        local mask = game.ServerStorage.Mask:Clone()
        mask:SetPrimaryPartCFrame(head.CFrame)
        local weldConstraint = Instance.new("WeldConstraint")
        weldConstraint.Parent = mask.PrimaryPart
        weldConstraint.Part0 = mask.PrimaryPart
        weldConstraint.Part1 = head
        mask.Parent = character
    end)
end

local Masks = {}

function Masks:start()
    Messages:hook("CharacterAdded", characterAdded)
end

return Masks