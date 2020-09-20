local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Knockback = {}

local knockbackStart = -1000
local knockbackLength = .2
local knockbackVelocity = 0
local player = game.Players.LocalPlayer

function Knockback:start()
	Messages:hook("Knockback", function(velocity, t , upwardsAllowed)
		if t then knockbackLength = t end
		knockbackStart = tick()
		knockbackVelocity = velocity
	end)
	game:GetService("RunService").Heartbeat:connect(function(dt)
		local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			if tick() - knockbackStart < knockbackLength then
				local gravityTranslation = dt*workspace.Gravity
				knockbackVelocity = Vector3.new(knockbackVelocity.X, math.max(0, knockbackVelocity.Y - gravityTranslation), knockbackVelocity.Z)
				if knockbackVelocity.Y <= 0 then
					hrp.Velocity = Vector3.new(knockbackVelocity.X, hrp.Velocity.Y, knockbackVelocity.Z)
				else
					hrp.Velocity = knockbackVelocity
				end
			end
		end
	end)
end

return Knockback
