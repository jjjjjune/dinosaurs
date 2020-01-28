local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Roact = import "Roact"
local SpectateButton = Roact.PureComponent:extend("SpectateButton")

function SpectateButton:init(suppliedProps)
	self:setState({
		isSpectating = false
	})
end

function SpectateButton:render()
	local text = "Spectate"
	if self.state.isSpectating then
		text = "Stop Spectating"
	end
	return Roact.createElement("TextButton", {
		Text = text,
		TextScaled = true,
		Size = UDim2.new(0,50,0,20),
		Position = UDim2.new(0,0,.5,-10),
		[Roact.Event.Activated] = function()
			self:setState(function(currentState)
				currentState.isSpectating = not currentState.isSpectating
				return currentState
			end)
			Messages:send("SetSpectating",self.state.isSpectating)
		end
	})
end

return SpectateButton
