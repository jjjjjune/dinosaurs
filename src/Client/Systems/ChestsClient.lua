local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"

local originalTransparencies = {}
local originalColors = {}
local originalMaterials = {}

local ChestsClient = {}

function ChestsClient:start()
	Messages:hook("PlayChestEffect", function(chest)
		Messages:send("PlayParticleSystem", "Confetti", chest.PrimaryPart.Position)
		Messages:send("PlaySoundOnClient", {
			instance = game.ReplicatedStorage.Sounds.MineStone,
			part = chest.PrimaryPart
		})
		for _, v in pairs(chest:GetChildren()) do
			if v:IsA("BasePart") then
				if not originalTransparencies[v] then
					originalTransparencies[v] = v.Transparency
				end
				if not originalColors[v] then
					originalColors[v] = v.Color
				end
				if not originalMaterials[v] then
					originalMaterials[v] = v.Material
				end
				v.Material = Enum.Material.Neon
				if v.Transparency ~= 1 then
					v.Transparency = .2
				end
				if v.Name == "Lock" then
					v.Transparency = 1
				else
					v.Color = Color3.fromRGB(38, 0, 255)
				end
				v.CanCollide = false
			end
		end
		delay(10, function()
			for _, v in pairs(chest:GetChildren()) do
				if v:IsA("BasePart") then
					v.Transparency = originalTransparencies[v]
					v.CanCollide = true
					v.Material = originalMaterials[v]
					if v.Name ~= "Lock" then
						v.Color = originalColors[v]
					end
				end
			end
		end)
	end)
end

return ChestsClient
