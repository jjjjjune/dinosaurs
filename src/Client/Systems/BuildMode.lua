local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"

local ContextActionService = game:GetService("ContextActionService")

local BuildMode = {}

BuildMode.isBuilding = false

function BuildMode.toggleBuilding()
	BuildMode.isBuilding = not BuildMode.isBuilding
	if not BuildMode.isBuilding then
		Messages:send("PlaySoundOnClient",{
			instance = game.ReplicatedStorage.Sounds.NewUIOut,
		})
		game.Players.LocalPlayer.PlayerGui.BuildMode.BuildModeIcon.Visible = false
	else
		Messages:send("PlaySoundOnClient",{
			instance = game.ReplicatedStorage.Sounds.NewUIIn,
		})
		game.Players.LocalPlayer.PlayerGui.BuildMode.BuildModeIcon.Visible = true
	end
end

function BuildMode:start()
	ContextActionService:BindAction("toggleBuildMode", function(contextActionName, inputState, inputObject)
		if inputState == Enum.UserInputState.Begin then
			BuildMode.toggleBuilding()
		end
	end, false, Enum.KeyCode.Q, Enum.KeyCode.ButtonB)
end

return BuildMode
