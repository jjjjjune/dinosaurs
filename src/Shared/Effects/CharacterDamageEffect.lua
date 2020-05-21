local import = require(game.ReplicatedStorage.Shared.Import)

local TweenService = game:GetService("TweenService")

local Messages = import "Shared/Utils/Messages"
local DamageColors = import "Shared/Data/DamageColors"

local totalTweenlength = .6

local info = TweenInfo.new(totalTweenlength/2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)

local tweening = {}

return function(character, damageType)
    if tweening[character] then
        return
    end

    tweening[character] = true

    damageType = damageType or "normal"

    local goals = {
        Color = DamageColors[damageType]
    }

    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            local endGoals = {
                Color = part.Color
            }
            local tween = TweenService:Create(part, info, goals)
            tween.Completed:connect(function()
                tween = TweenService:Create(part, info, endGoals)

                tween.Completed:connect(function()
                    tweening[character] = false
                end)

                tween:Play()
            end)
            tween:Play()
        end
    end

    Messages:send("PlayParticleColor", "DamageSmoke", DamageColors[damageType], 8, character.Head.Position)
    if game:GetService("RunService"):IsClient() then 
        Messages:send("PlaySoundOnClient",{
            instance = game.ReplicatedStorage.Sounds.DamagedSDS,
            part = character.Head,
        })
    else
        Messages:send("PlaySound", "DamagedSDS", character.Head.Position)
    end
end