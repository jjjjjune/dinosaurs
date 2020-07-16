local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local RunService = game:GetService("RunService")

local callbacks = {}
local options = {}
local indexes = {}

local function shakeEffect(optionFrame)
	for i = 1, math.random(8,12) do
		optionFrame.LabelFG.Title.Position = UDim2.new(.5,math.random(-2,2), .5, math.random(-2,2))
		RunService.RenderStepped:Wait()
	end
	optionFrame.LabelFG.Title.Position = UDim2.new(.5,0, .5, 0)
end

local function registerMultipleOption(optionFrame, providedOptions, callback, desiredValue)
	callbacks[optionFrame] = callback
	indexes[optionFrame] = 1
	options[optionFrame] = providedOptions
	if desiredValue then
		for i, v in pairs(providedOptions) do
			if v == desiredValue then
				indexes[optionFrame] = i
				optionFrame.LabelFG.Title.Text = desiredValue
			end
		end
	end
	Messages:send("RegisterButton", optionFrame.LabelFG.Left.Button, nil, function()
		local originalValue = indexes[optionFrame]
		indexes[optionFrame] = indexes[optionFrame] - 1
		if indexes[optionFrame] < 1 then
			indexes[optionFrame] = #options[optionFrame]
		end
		local option = providedOptions[indexes[optionFrame]]
		if callback(option) then
			optionFrame.LabelFG.Title.Text = option
			Messages:send("PlaySoundOnClient",{
				instance = game.ReplicatedStorage.Sounds.NewUIBonk
			})
		else
			spawn(function() shakeEffect(optionFrame) end)
			indexes[optionFrame] = originalValue
			Messages:send("PlaySoundOnClient",{
				instance = game.ReplicatedStorage.Sounds.NewUICancel
			})
		end
	end)
	Messages:send("RegisterButton", optionFrame.LabelFG.Right.Button, nil, function()
		local originalValue = indexes[optionFrame]
		indexes[optionFrame] = indexes[optionFrame] + 1
		if indexes[optionFrame] > # options[optionFrame] then
			indexes[optionFrame] = 1
		end
		local option = providedOptions[indexes[optionFrame]]
		if callback(option) then
			if optionFrame:FindFirstChild("LabelFG") then
				optionFrame.LabelFG.Title.Text = option
			end
			Messages:send("PlaySoundOnClient",{
				instance = game.ReplicatedStorage.Sounds.NewUIBonk
			})
		else
			if optionFrame:FindFirstChild("LabelFG") then
				spawn(function() shakeEffect(optionFrame) end)
			end
			indexes[optionFrame] = originalValue
			Messages:send("PlaySoundOnClient",{
				instance = game.ReplicatedStorage.Sounds.NewUICancel
			})
		end
	end)
end

local MultipleOption = {}

function MultipleOption:start()
	Messages:hook("RegisterMultipleOption", registerMultipleOption)
end

return MultipleOption
