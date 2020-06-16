local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local lastBlinks = {}

local blinkTime = math.random(25, 40)/10

local function blink(lavaPart)
    local model = lavaPart.Parent
    local eyes = {}
    for _, v in pairs(model:GetChildren()) do
        if v.Name == "Eye2" then
            table.insert(eyes, v)
        end
    end
    local eye = eyes[math.random(1, #eyes)]
    if not eye:FindFirstChild("GodEyeBlink") then
        local anim = game.ReplicatedStorage.Animations.GodEyeBlink:Clone()
        anim.Parent = eye
        local track = eye.AnimationController:LoadAnimation(anim)
        track:Play()
        Messages:send("PlaySoundOnClient",{
            instance = game.ReplicatedStorage.Sounds["Mud"..tostring(math.random(1,3))],
            part = eye
        })
    else
        local track = eye.AnimationController:LoadAnimation(eye.GodEyeBlink)
        track:Play()
        Messages:send("PlaySoundOnClient",{
            instance = game.ReplicatedStorage.Sounds["Mud"..tostring(math.random(1,3))],
            part = eye
        })
    end
end

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

    if not lastBlinks[lavaPart] then
        lastBlinks[lavaPart] = time()
        blink(lavaPart)
    else
        if time() - lastBlinks[lavaPart] > blinkTime then
            blinkTime = math.random(25, 40)/10
            blink(lavaPart)
            lastBlinks[lavaPart] = time()
        end
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