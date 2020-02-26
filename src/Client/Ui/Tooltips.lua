local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local ContextActionService = game:GetService("ContextActionService")
local ActionBinds = import "Shared/Data/ActionBinds"
local PlayerGui = game.Players.LocalPlayer.PlayerGui
local TooltipGeneric = PlayerGui:WaitForChild("Tooltips"):WaitForChild("TooltipGeneric")
local GetDevice = import "Shared/Utils/GetDevice"
local RunService = game:GetService("RunService")

local tooltipFrames = {} 

local CONTROLS_PRIORITY = 2

local function skin(tooltipFrame, actionName)
    local bindInfo = ActionBinds[actionName]
    tooltipFrame.Name = actionName
    tooltipFrame.ImageLabel.ImageColor3 = bindInfo.color
    tooltipFrame.ImageColor3 = Color3.new(bindInfo.color.r - .2, bindInfo.color.g - .2, bindInfo.color.b - .2)
    tooltipFrame.Parent = TooltipGeneric.Parent
end

local function connectEvents(tooltip, actionName)
    tooltip.Activated:connect(function()
        local Binds = import "Client/Systems/Binds"
        if Binds.actionActivatedCallbacks[actionName] then
            Binds.actionActivatedCallbacks[actionName]()
        end
    end)
end

local function getTooltipButton(actionName)
    if not tooltipFrames[actionName] then
        local newTooltipUi = TooltipGeneric:Clone()
        tooltipFrames[actionName] = newTooltipUi
        connectEvents(newTooltipUi, actionName)
        skin(newTooltipUi, actionName)
    end
    return tooltipFrames[actionName]
end

local function skinTooltipsToDevice()
    local device = GetDevice()
    for _, tooltip in pairs(tooltipFrames) do
        local bindInfo = ActionBinds[tooltip.Name]
        if device == "Desktop" then
            tooltip.TextLabel.Text = bindInfo.pc
        elseif device == "Gamepad" then
            tooltip.TextLabel.Text = bindInfo.gamepad
        else
            tooltip.TextLabel.Text = ""
        end
        tooltip.TextLabelShadow.Text = tooltip.TextLabel.Text
    end
end

local Tooltips = {}

function Tooltips:start()
    Messages:hook("ShowTooltip", function(actionName, worldPosition)
        local button = getTooltipButton(actionName)
        button.Visible = true
        local vector, onScreen = workspace.CurrentCamera:WorldToScreenPoint(worldPosition)
        button.Position = UDim2.new(0, vector.X, 0, vector.Y)
    end)
    Messages:hook("HideTooltip", function(actionName)
        local button = getTooltipButton(actionName)
        button.Visible = false
    end)
    Messages:hook("PlayPressedEffect", function(actionName)
        local button = getTooltipButton(actionName)
        for _, v in pairs(button:GetChildren()) do
            if not v:FindFirstChild("Tweening") then 
                local tweening = Instance.new("BoolValue", v)
                tweening.Name = "Tweening"
                v:TweenPosition(v.Position + UDim2.new(0,0,0,4), "Out", "Quad", .1, false, function()
                    v:TweenPosition(v.Position - UDim2.new(0,0,0,4), "Out", "Quad", .1, false, function()
                        tweening:Destroy()
                    end)
                end)
            end
        end
    end)
    RunService.RenderStepped:connect(function()
        skinTooltipsToDevice()
    end)
    --[[Binds.bindTagToAction("Entity", "INTERACT", function(item)
        print("the entity is: ", item and item.Name)
    end)--]]
end

return Tooltips