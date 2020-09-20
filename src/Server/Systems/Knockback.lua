local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local KNOCKBACK_LENGTH = 0.3
local knockbackedCharacters = {}

local Knockback = {}

function Knockback:start()
	Messages:hook("Knockback", function(character, direction, t, horizontalMode)
		local player = game.Players:GetPlayerFromCharacter(character)
		if player then
			Messages:sendClient(player, "Knockback", direction, t, horizontalMode)
		else
			knockbackedCharacters[character] = {
				start = time(),
				direction = direction,
				length = t or KNOCKBACK_LENGTH,
				horizontal = horizontalMode or false
			}
		end
	end)
	game:GetService("RunService").Heartbeat:connect(function()
		for character, characterInfo in pairs(knockbackedCharacters) do
			if time() - characterInfo.start < characterInfo.length then
				local root = character:FindFirstChild("HumanoidRootPart")
				if root then
					if (characterInfo.horizontalMode and math.abs(characterInfo.direction.Y)<5) then
						root.Velocity = characterInfo.direction*Vector3.new(1,0,1)
					else
						root.Velocity = characterInfo.direction
					end
				end
			end
		end
	end)
end

return Knockback


