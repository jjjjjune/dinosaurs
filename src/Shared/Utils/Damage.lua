local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

return function(target, damageInfo)

	local damageColor = Color3.fromRGB(255,255,255)

	local healthToTake = "Health"

	if damageInfo.type == "tame" then
		healthToTake = "TamedHealth"
		damageColor = Color3.fromRGB(111, 86, 255)
	end

	if damageInfo.type == "tame" and target:FindFirstChild("Tamed") and target.Tamed.Value == true then
		return
	end

	if target:FindFirstChild("Humanoid") then
		if damageInfo.type == "tame" then
			damageInfo.damage = 1
		end
        target.Humanoid.Health = target.Humanoid.Health - damageInfo.damage
	else
		if healthToTake == "Health" then
			if target.Health.Value == 0 then -- trigger changed event trolololololollo
				target.Health.Value = 1
			end
			target.Health.Value = target.Health.Value - damageInfo.damage
		else
			target[healthToTake].Value = target[healthToTake].Value - damageInfo.damage
			if target[healthToTake].Value == 0 and damageInfo.type == "tame" then
				target.Tame:Fire(damageInfo.murderer)
			end
		end
    end

    if damageInfo.damage < 0 then
		damageInfo.type = "heal"
		damageColor = Color3.fromRGB(16, 219, 255)
    end

    local player = game:GetService("Players"):GetPlayerFromCharacter(target)

    --warn("remember the server application config thing for when youre doing the effect from server")

    if player and not damageInfo.serverApplication then
        Messages:reproOnClients(player, "PlayDamageEffect", target, damageInfo.type)
    else
        if not damageInfo.ignorePlayer then
            Messages:sendAllClients("PlayDamageEffect", target, damageInfo.type)
        else
            Messages:reproOnClients(damageInfo.ignorePlayer, "PlayDamageEffect", target, damageInfo.type)
        end
	end

	if damageInfo.damage > 20 then
		damageColor = Color3.fromRGB(255, 196, 32)
	end

	if target.PrimaryPart then
		local x = math.random(-10,10)/10
		local y = math.random(-10,10)/10
		local z = math.random(-10,10)/10
		local randomVector = Vector3.new(x, y, z)
		Messages:sendAllClients("CreateDamageIndicator", target.PrimaryPart.Position + randomVector, damageInfo.damage, damageColor)
	end
end
