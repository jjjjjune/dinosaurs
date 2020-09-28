local import = require(game.ReplicatedStorage.Shared.Import)

local TweenService = game:GetService("TweenService")

local Messages = import "Shared/Utils/Messages"
local DamageColors = import "Shared/Data/DamageColors"

local totalTweenlength = .3

local info = TweenInfo.new(totalTweenlength/2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)

local tweening = {}

return function(character, damageType, particlePart)
    if tweening[character] then
        return
    end

    tweening[character] = true

    damageType = damageType or "normal"

    local goals = {
        Transparency = 0
    }

    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") and part.Transparency ~= 1 then
            local faces = {
                "Front",
                "Back",
                "Left",
                "Right",
                "Top",
                "Bottom"
            }
            local endGoals = {
                Transparency = 1
            }
            for _, face in pairs(faces) do
                local decal = Instance.new("Decal", part)
                decal.Color3 = DamageColors[damageType]
                decal.Texture = "rbxassetid://132155326"
                decal.Face = face
                decal.Transparency = 1
                local tween = TweenService:Create(decal, info, goals)
                tween.Completed:connect(function()
                    tween = TweenService:Create(decal, info, endGoals)

                    tween.Completed:connect(function()
						decal:Destroy()
						tweening[character] = false
                    end)

                    tween:Play()
                end)
                tween:Play()
            end
        end
    end

    Messages:send("PlayParticleColor", "DamageSmoke", DamageColors[damageType], 8, particlePart or character.Hitbox)
end
