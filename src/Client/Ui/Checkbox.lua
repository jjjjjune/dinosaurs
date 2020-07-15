local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local RunService = game:GetService("RunService")

local function registerCheckbox(checkboxFrame, callback)
	checkboxFrame.CheckboxFG.Button.Activated:connect(function()
		checkboxFrame.CheckboxFG.Checkmark.Visible = not checkboxFrame.CheckboxFG.Checkmark.Visible
		if checkboxFrame.CheckboxFG.Checkmark.Visible == true then
			Messages:send("PlaySoundOnClient",{
				instance = game.ReplicatedStorage.Sounds.NewUIIn
			})
			callback(true)
		else
			Messages:send("PlaySoundOnClient",{
				instance = game.ReplicatedStorage.Sounds.NewUIOut
			})
			callback(false)
		end
	end)
end

local Checkbox = {}

function Checkbox:start()
	Messages:hook("RegisterCheckbox", registerCheckbox)
end

return Checkbox
