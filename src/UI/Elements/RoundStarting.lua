local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"
local UiState= import "UI/UiState"
local Window = import "UI/Menus/Window"

local FastSpawn = import "Shared/Utils/FastSpawn"

local RoundStarting = {}

function RoundStarting:start()
	local frame = UiState:GetElement("RoundIntroFrame")
	Messages:hook("RoundStarting",function(gameMode, mapName)
		UiState:transition(false)
		UiState.Sounds.RoundStarting:Play()
		frame.Map.Text = "MAP: "..mapName
		frame.Position = UDim2.new(0.5,0,-0.25,0)
		frame:TweenPosition(UDim2.new(0.5,0,0.3,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.5,true)
		frame.Visible = true
	end)
	Messages:hook("TweenOutRoundStarting",function()
		if frame.Visible then
			FastSpawn(function()
				frame:TweenPosition(UDim2.new(0.5,0,-0.25,0),Enum.EasingDirection.In,Enum.EasingStyle.Back,0.5,true)
				wait(0.5)
				frame.Visible = false
			end)
		end
	end)
end

return RoundStarting
