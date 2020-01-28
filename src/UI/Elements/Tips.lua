local import = require(game.ReplicatedStorage.Shared.Import)
local UiState = import "UI/UiState"
local Messages = import "Shared/Utils/Messages"

local FastSpawn = import "Shared/Utils/FastSpawn"

local Tips = {}

function Tips:start()
	local frame = UiState:GetElement("TipFrame")
	Messages:hook("Tip",function(tipName)
		frame[tipName].Position = UDim2.new(0.5,0,0.6,0)
		frame[tipName].Visible = true
		frame[tipName]:TweenPosition(UDim2.new(0.5,0,0.5,0),"Out","Back",0.5,true)
		frame[tipName].timer.Size = UDim2.new(1,0,0.025,0)
		frame[tipName].timer:TweenSize(UDim2.new(0,0,0.025,0),"Out","Linear",8,true)
		FastSpawn(function()
			wait(8)
			frame[tipName].Visible = false
		end)
	end)
end

return Tips
