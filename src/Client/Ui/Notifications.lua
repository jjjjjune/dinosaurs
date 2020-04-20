local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local Icons = import "Shared/Data/Icons"
local ColorConstants = import "Shared/Data/ColorConstants"
local Debris = game:GetService("Debris")

local NotificationsUi = game.Players.LocalPlayer.PlayerGui:WaitForChild("Notifications")
local Holder = NotificationsUi.Frame

local RunService = game:GetService("RunService")

local DISPLAY_TIME = 10

local effects = {
    VIBRATE = function(frame)
        frame.Container.Position = UDim2.new(0, math.random(-1,1), 0, math.random(-1,1))
    end
}
local effectPools = {
    VIBRATE = {}
}

local function newNotification(color, image, text, effect)
    local frame do
        if string.len(text) > 24 then
            frame = Holder.HugeFrame:Clone()
        elseif string.len(text) > 14 then
            frame = Holder.BigFrame:Clone()
        else
            frame = Holder.SmollFrame:Clone()
        end
    end
    image = Icons[image] or image
    color = ColorConstants[color] or color
    frame.Container.Position = UDim2.new(-1, 0, 0,0)
    frame.Parent = Holder
    frame.Visible = true
    frame.Container:TweenPosition(UDim2.new(0,0,0,0), "Out", "Back", .3)
    frame.Container.SeasonIcon.Image = image
    frame.Container.SeasonIconShadow.Image = image
    frame.Container.TextLabel.Text = text
    frame.Container.TextLabelShadow.Text = text
    frame.Container.ImageColor3 = color
    delay(DISPLAY_TIME, function()
        frame.Container:TweenPosition(UDim2.new(-1.5,0,0,0), "Out", "Quad", .3)
        wait(.3)
        frame:Destroy()
    end)
    if effect then
        table.insert(effectPools[effect], frame)
    end
end

local function runEffects()
    for effectName, func in pairs(effects) do
        local newEffectFrameTable = {}
        for _, effectFrame in pairs(effectPools[effectName]) do
            if effectFrame.Parent ~= nil then
                table.insert(newEffectFrameTable, effectFrame)
                func(effectFrame)
            end
        end
        effectPools[effectName] = newEffectFrameTable
    end
end

local Notifications = {}

function Notifications:start()
    Messages:hook("Notify", newNotification)
    RunService.Heartbeat:connect(runEffects)
end

return Notifications