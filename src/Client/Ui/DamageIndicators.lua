local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"

local RunService = game:GetService("RunService")

local GetCharacter = import "Shared/Utils/GetCharacter"

local damageIndicatorScreenGui = game.Players.LocalPlayer.PlayerGui:WaitForChild("DamageIndicators")
local damageIndicatorTemplate = damageIndicatorScreenGui:WaitForChild("DamageIndicator")

local TweenService = game:GetService("TweenService")

local allDamageIndicators = {}

local function stepDamageIndicators()
	for i, indicator in pairs(allDamageIndicators) do
		local vector, onScreen = workspace.CurrentCamera:WorldToScreenPoint(indicator.pos)
		local timeSinceStart = tick() - indicator.timeCreated
		indicator.instance.Position = UDim2.new(0, vector.X, 0, vector.Y  - (timeSinceStart*25))
		indicator.instance.TextTransparency = math.max(0, ((timeSinceStart*2) - .5))
		indicator.instance.TextStrokeTransparency = math.max(0, ((timeSinceStart*5) - .5))
		if timeSinceStart > 1.5 then
			indicator.instance:Destroy()
			allDamageIndicators[i] = nil
		end
	end
end

local function createDamageIndicator(pos, text, textColor)
	local damageIndicatorInstance = damageIndicatorTemplate:Clone()
	damageIndicatorInstance.Parent = damageIndicatorScreenGui
	damageIndicatorInstance.Visible = true
	damageIndicatorInstance.Text = text
	damageIndicatorInstance.TextColor3 = textColor
	damageIndicatorInstance.Rotation = -15

	-- local tweenInfo = TweenInfo.new(.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	-- local tween = TweenService:Create(damageIndicatorInstance, tweenInfo, {Rotation = 0})

	-- tween.Completed:connect(function()
	-- 	local tweenInfo = TweenInfo.new(.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	-- 	local tween = TweenService:Create(damageIndicatorInstance, tweenInfo, {Rotation = 15})
	-- 	tween.Completed:connect(function()
	-- 		local tweenInfo = TweenInfo.new(.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	-- 		local tween = TweenService:Create(damageIndicatorInstance, tweenInfo, {Rotation = math.random(-5,5)})
	-- 		tween:Play()
	-- 	end)
	-- 	tween:Play()
	-- end)

	-- tween:Play()

	local vector, onScreen = workspace.CurrentCamera:WorldToScreenPoint(pos)
	damageIndicatorInstance.Position = UDim2.new(0, vector.X, 0, vector.Y)

	table.insert(allDamageIndicators, {
		instance = damageIndicatorInstance,
		pos = pos,
		timeCreated = tick(),
	})
end

local DamageIndicator = {}

function DamageIndicator:start()
	Messages:hook("CreateDamageIndicator", createDamageIndicator)
	RunService.RenderStepped:connect(function()
		stepDamageIndicators()
	end)
end

return DamageIndicator
