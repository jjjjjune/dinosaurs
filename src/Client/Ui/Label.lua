local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local RunService = game:GetService("RunService")

local function registerLabel(labelFrame, callback)
	labelFrame.FocusLost:connect(function()
		Messages:send("PlaySoundOnClient",{
			instance = game.ReplicatedStorage.Sounds.NewUIClickHigh
		})
		callback(labelFrame.Text)
	end)
end

local Label = {}

function Label:start()
	Messages:hook("RegisterLabel", registerLabel)
end

return Label
