local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local function setProgressAmount(ui, progress)
    local backgroundColor = ui.N1.ImageColor3
    local foregroundColor = ui.B.ImageColor3
    local angle = progress*360
	local n0 = ui.N0
    --n0.Rotation = angle%180
    local hook
    hook = RunService.RenderStepped:connect(function()
        local angle = n0.Rotation
        --print("angle is: ", angle)
        if angle < 180 then
            n0.Img.ImageColor3 = backgroundColor
        else
            n0.Img.ImageColor3 = foregroundColor
        end
    end)
    local tweenInfo = TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local properties = {
        Rotation = angle%180,
    }
    local tween = TweenService:Create(n0, tweenInfo, properties)
    tween.Completed:connect(function()
        hook:disconnect()
        hook = nil
    end)
    tween:Play()
end

local RadialProgress = {}

function RadialProgress:start()
    Messages:hook("SetRadialProgressButtonAmount", function(progressButton, progress)
        setProgressAmount(progressButton, progress)
    end)
end

return RadialProgress