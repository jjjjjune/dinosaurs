local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Knockback = {}

local knockbackStart = -1000
local KNOCKBACK_LENGTH = .2
local knockbackVelocity = 0
local player = game.Players.LocalPlayer

function Knockback:start()
	Messages:hook("Knockback", function(velocity, t )
		if t then KNOCKBACK_LENGTH = t end
		knockbackStart = tick()
		knockbackVelocity = velocity
	end)
	game:GetService("RunService").Stepped:connect(function(dt)
		local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			if tick() - knockbackStart < KNOCKBACK_LENGTH then
				--player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
				local gravityTranslation = dt*workspace.Gravity
				knockbackVelocity = Vector3.new(knockbackVelocity.X, math.max(0, knockbackVelocity.Y - gravityTranslation), knockbackVelocity.Z)
				if knockbackVelocity.Y <= 0 then
					hrp.Velocity = Vector3.new(knockbackVelocity.X, hrp.Velocity.Y, knockbackVelocity.Z)
				else
					hrp.Velocity = knockbackVelocity
				end
			else
				--[[if player.Character.Humanoid:GetState() == Enum.HumanoidStateType.Physics then
					player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Running)
				end--]]
			end
		end
	end)
end

return Knockback
