local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local TweenService = game:GetService("TweenService")

local totalTweenlength = 2

local info = TweenInfo.new(totalTweenlength,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)

local function playRespawnEffect(player, character)
    for _, part in pairs(character:GetDescendants()) do
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
                decal.Color3 = Color3.fromRGB(255,185,0)
                decal.Texture = "rbxassetid://132155326"
                decal.Face = face
                decal.Transparency = 0

                local tween = TweenService:Create(decal, info, endGoals)

                tween.Completed:connect(function()
                    decal:Destroy()
                end)

                delay(1, function()
                    tween:Play()
                end)
            end
        end
    end
end

local SpawnEffect = {}

function SpawnEffect:start()
    Messages:hook("MaskAdded", function(player, character)
        playRespawnEffect(player, character)
    end)
end

return SpawnEffect
