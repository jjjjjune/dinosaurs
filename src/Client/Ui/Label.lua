local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local RunService = game:GetService("RunService")

local function registerLabel(labelFrame, callback, desiredValue, isReadOnly)
	if desiredValue then
		labelFrame.Text = tostring(desiredValue)
	end
	if not isReadOnly then
		labelFrame.FocusLost:connect(function()
			Messages:send("PlaySoundOnClient",{
				instance = game.ReplicatedStorage.Sounds.NewUIClickHigh
			})
			callback(labelFrame.Text)
		end)
	else
		labelFrame.FocusLost:connect(function()
			labelFrame.Text = desiredValue
			Messages:send("PlaySoundOnClient",{
				instance = game.ReplicatedStorage.Sounds.NewUICancel
			})
			Messages:send("Notify", "HUNGER_COLOR_DARK", "ANGRY", "CANNOT EDIT THIS.")
		end)
	end
end

local Label = {}

function Label:start()
	Messages:hook("RegisterLabel", registerLabel)
end

return Label
