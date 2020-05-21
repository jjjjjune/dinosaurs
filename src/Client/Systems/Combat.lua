local import = require(game.ReplicatedStorage.Shared.Import)

local GetCharacter = import "Shared/Utils/GetCharacter"

local Messages = import "Shared/Utils/Messages"

local CollectionService = game:GetService("CollectionService")

local HitboxesFolder = game.ReplicatedStorage.Hitboxes

local function registerHitbox(hitboxName, callback)
    local character = GetCharacter()
    local root = character and character.PrimaryPart
    if root then
        local hitboxModel = HitboxesFolder[hitboxName]:Clone()
        hitboxModel.Parent = character
        hitboxModel:SetPrimaryPartCFrame(root.CFrame)
        hitboxModel.PrimaryPart:Destroy()

        hitboxModel.Hitbox.Touched:connect(function()end)
        local touchingParts = hitboxModel.Hitbox:GetTouchingParts()
        local damaged = {}
        for _, p in pairs(touchingParts) do
            if p.Parent:IsA("Model") and not damaged[p.Parent] then
                callback(p)
            end
        end
        hitboxModel:Destroy()
    end
end

local Combat = {}

function Combat:start()
    Messages:hook("RegisterHitbox", registerHitbox)
end

return Combat