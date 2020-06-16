local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local function addMask(player, character)
    local head = character:WaitForChild("Head")
    local mask = game.ServerStorage.Mask:Clone()
    mask:SetPrimaryPartCFrame(head.CFrame)
    local weldConstraint = Instance.new("WeldConstraint")
    weldConstraint.Parent = mask.PrimaryPart
    weldConstraint.Part0 = mask.PrimaryPart
    weldConstraint.Part1 = head
    mask.Parent = character
    Messages:send("PlaySound", "AppearSmoke", mask.PrimaryPart.Position)
    Messages:send("PlayParticle", "AppearSmoke",  10, mask.PrimaryPart)
    Messages:send("MaskAdded",player, character)
end

local Masks = {}

function Masks:start()
    Messages:hook("CharacterAppearanceSet", addMask)
end

return Masks