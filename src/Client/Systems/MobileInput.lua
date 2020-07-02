local UserInputService = game:GetService("UserInputService")

local MobileInput = {}

function MobileInput:start()
	MobileInput.lastMouseRay = nil
	UserInputService.InputBegan:connect(function(inputObject, gameProcessed)
		if not gameProcessed then
			if inputObject.UserInputType == Enum.UserInputType.Touch then
				local ray = game.Players.LocalPlayer:GetMouse().UnitRay
				MobileInput.lastMouseRay = {
					Origin = ray.Origin,
					Direction = ray.Direction
				}
			end
		end
	end)
end

function MobileInput.getMouseRay()
	return MobileInput.lastMouseRay
end

return MobileInput
