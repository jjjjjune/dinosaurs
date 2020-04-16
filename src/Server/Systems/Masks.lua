local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local function spawnEffectPlayed(player, character)
    spawn(function()
        wait(1)
        local head = character:WaitForChild("Head")
        local mask = game.ServerStorage.Mask:Clone()
        mask:SetPrimaryPartCFrame(head.CFrame)
        local weldConstraint = Instance.new("WeldConstraint")
        weldConstraint.Parent = mask.PrimaryPart
        weldConstraint.Part0 = mask.PrimaryPart
        weldConstraint.Part1 = head
        mask.Parent = character
        Messages:send("MaskAdded",player, character)
    end)
end

local Masks = {}

function Masks:start()
    Messages:hook("SpawnEffectPlayed", spawnEffectPlayed)
end

return Masks