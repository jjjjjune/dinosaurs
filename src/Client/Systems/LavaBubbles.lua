local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local function tickLava(lavaPart)
    local limitForPart = lavaPart.Size.magnitude * 1
    local lavaDist = lavaPart.Size.X/3
    if #lavaPart:GetChildren() < limitForPart then
        local bubblePart = Instance.new("Part")
        bubblePart.Material = lavaPart.Material
        bubblePart.Color = Color3.new(lavaPart.Color.r * .98, lavaPart.Color.g * .98, lavaPart.Color.b * .98)
        bubblePart.Name = "Bubble"
        bubblePart.CanCollide = false
        bubblePart.Anchored = true
        bubblePart.Size = Vector3.new()
        bubblePart.Shape = Enum.PartType.Ball
        bubblePart.CFrame = lavaPart.CFrame * CFrame.Angles(0, math.rad(math.random(1, 360)), 0) * CFrame.new(0,0, math.random(1, lavaDist)*-1)

        bubblePart.Parent = lavaPart

        local lifetime = math.random(5, 10)/10
        local tweenInfo = TweenInfo.new(lifetime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

        local sizeProps = {
            Size = (Vector3.new(1,1,1) * math.random()) * math.random(1,3)
        }

        local sizeTween = TweenService:Create(bubblePart, tweenInfo, sizeProps)
        sizeTween.Completed:connect(function()
            if math.random(1, 3) < 3 then 
                local sizeTween2 = TweenService:Create(bubblePart, tweenInfo, {Size = Vector3.new(0,0,0)})
                sizeTween2.Completed:connect(function()
                    bubblePart:Destroy()
                end)
                sizeTween2:Play()
            else
                bubblePart:Destroy()
            end
        end)
        sizeTween:Play()

    end
end

local LavaBubbles = {}

function LavaBubbles:start()
    RunService.RenderStepped:connect(function()
        if workspace.Buildings:FindFirstChild("Altar") and workspace.Buildings.Altar:FindFirstChild("Lava") then
            tickLava(workspace.Buildings.Altar.Lava)
        end
    end)
end

return LavaBubbles