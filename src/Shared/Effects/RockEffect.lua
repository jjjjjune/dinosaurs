local import = require(game.ReplicatedStorage.Shared.Import)
local RockHealths = import "Shared/Data/RockHealths"

local TweenService = game:GetService("TweenService")
local rockTweening = {}

return function(rock)
    for _, part in pairs(rock:GetChildren()) do
        if part:IsA("BasePart") then
            if not rockTweening[part] then
                local maxHealth = RockHealths[rock.Type.Value]
                rockTweening[part] = true
                local cf = part.CFrame
                local endCF=  part.CFrame + Vector3.new(0, (rock:GetModelSize().Y/(maxHealth+1)) * -.75,0)-- so that when it is no longer visible (its only 4 studs tall) is when it gets destroyed
                local easingStyled = TweenInfo.new(0.2, Enum.EasingStyle.Quart)
                local goal = {}
                goal.CFrame = endCF
                local tween = game:GetService("TweenService"):Create(part, easingStyled, goal)
                tween:Play()
                spawn(function()
                    wait(.2)
                    rockTweening[part] = false
                end)
            end
        end
    end
end