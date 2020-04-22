local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'

local FastSpawn = import "Shared/Utils/FastSpawn"
local CameraShaker = import "Shared/Utils/Camera/CameraShaker"

--tyler wrote this!! thank you tyler

local ClientEffects = {}

function ClientEffects:shake(amp, amount) -- how much in degrees, how long in frames
	if self.shaking then
		return
	end
	self.shaking = true
    for _ = 1, amount, 1 do
        local shakeCF_Y = CFrame.Angles(0, math.rad(amp) * (math.random() * 2 - 1), 0)
        local shakeCF_X = CFrame.Angles(math.rad(amp) * (math.random() * 2 - 1), 0, 0)

        local newCF = workspace.CurrentCamera.CFrame * shakeCF_Y * shakeCF_X

        workspace.CurrentCamera.CFrame = newCF
        game:GetService("RunService").RenderStepped:wait()
    end
	self.shaking = false
end

function ClientEffects:start()
	local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCf)
		workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * shakeCf
	end)
	camShake:Start()

	Messages:hook("ShakeCamera", function(preset)
		FastSpawn(function()
			camShake:Shake(CameraShaker.Presets[preset])
		end)
	end)
end

return ClientEffects
