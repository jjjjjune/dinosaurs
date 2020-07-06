local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local ActionBinds = import "Shared/Data/ActionBinds"
local GetDevice = import "Shared/Utils/GetDevice"

local RunService = game:GetService("RunService")

local PlayerGui = game.Players.LocalPlayer.PlayerGui
local TooltipGeneric = PlayerGui:WaitForChild("Tooltips"):WaitForChild("TooltipGeneric")
local ItemNameLabel = PlayerGui.Tooltips:WaitForChild("ItemNameLabel")
local ItemNameLabelShadow = PlayerGui.Tooltips:WaitForChild("ItemNameLabelShadow")

local GetCharacterPosition = import "Shared/Utils/GetCharacterPosition"

local lastTarget

local currentTargets = {}
local tooltipFrames = {}
local hiddenTooltips = {}
local altNames = {}

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

local function getName(target)
	if altNames[target] then
		return altNames[target]
	else
		if target:FindFirstChild("AlternateName") \then
			altNames[target] = target.AlternateName.Value
			return altNames[target]
		else
			altNames[target] = target.Name
			return altNames[target]
		end
	end
end

local function displayItemName()
	local foundFrame
	for actionFrame, frame in pairs(tooltipFrames) do
		if frame and frame.Visible == true then
			foundFrame = true
		end
	end
	local target = lastTarget
	if foundFrame and target then
		local vector, onScreen = workspace.CurrentCamera:WorldToScreenPoint(target.PrimaryPart.Position)
		ItemNameLabel.Visible = true
		ItemNameLabel.Text = getName(target)
		ItemNameLabelShadow.Text = getName(target)
		ItemNameLabel.Position = UDim2.new(0, vector.X, 0, vector.Y - 32)
		ItemNameLabelShadow.Position = UDim2.new(0, vector.X, 0, vector.Y - 31)
	else
		ItemNameLabel.Visible = false
		ItemNameLabelShadow.Visible = false
	end
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

local function setButtonTransparency(button, transparency)
    button.ImageTransparency = transparency
    button.ImageLabel.ImageTransparency = transparency
    button.TextLabel.TextTransparency = transparency
    button.TextLabelShadow.TextTransparency = transparency
end

local Tooltips = {}

function Tooltips:start()
    Messages:hook("ShowTooltip", function(actionName, worldPosition, target)
		local button = getTooltipButton(actionName)
		if hiddenTooltips[actionName] then
			button.Visible = false

			return
		end

        button.Visible = true
        local vector, onScreen = workspace.CurrentCamera:WorldToScreenPoint(worldPosition)
        local foundSameTarget = false
        for ac, actionTarget in pairs(currentTargets) do
            if actionTarget == target and ac ~= actionName then
                foundSameTarget = ac
            end
        end
        if not foundSameTarget then
            currentTargets[actionName] = target
            button.Position = UDim2.new(0, vector.X, 0, vector.Y)
		else
			local otherButton = tooltipFrames[foundSameTarget]
			otherButton.Position = otherButton.Position - UDim2.new(0,18,0,0)
            button.Position = UDim2.new(0, vector.X + 18, 0, vector.Y)
		end
		lastTarget = target
        -- local characterPosition = GetCharacterPosition()
        -- if characterPosition then
        --     if (characterPosition - worldPosition).magnitude < 8 then
        --         setButtonTransparency(button, .6)
        --     else
        --         setButtonTransparency(button, 0)
        --     end
        -- end
    end)
    Messages:hook("HideTooltip", function(actionName)
        currentTargets[actionName] = nil
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
        --[[Messages:send("PlaySoundOnClient",{
            instance = game.ReplicatedStorage.UiSounds.Select,
        })--]]
	end)
	Messages:hook("SetTooltipHidden", function(actionName, isHidden)
		hiddenTooltips[actionName] = not isHidden
		if isHidden then
			local button = getTooltipButton(actionName)
			if button then
				button.Visible = false
			end
		end
	end)
    RunService.RenderStepped:connect(function()
		skinTooltipsToDevice()
		displayItemName()
    end)
end

return Tooltips
