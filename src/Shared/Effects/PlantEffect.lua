local import = require(game.ReplicatedStorage.Shared.Import)

local TweenService = game:GetService("TweenService")

local originalSizes = {}

return function(plant)
	for _, part in pairs(plant:GetChildren()) do
		if part.Name == "Leaf" then
			if not originalSizes[part] then
				originalSizes[part] = part.Size
			end
			local endSize = part.Size + Vector3.new(math.random(-3,3), math.random(-3,3), math.random(-3,3))
			local easingStyled = TweenInfo.new(0.2, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 0, true)
			local goal = {}
			goal.Size = endSize
			local tween = TweenService:Create(part, easingStyled, goal)
			tween:Play()
		end
    end
end
