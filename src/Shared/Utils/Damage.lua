local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

return function(target, damageInfo)

    if target:FindFirstChild("Humanoid") then
        target.Humanoid.Health = target.Humanoid.Health - damageInfo.damage
    else
        if target.Health.Value == 0 then -- trigger changed event trolololololollo
            target.Health.Value = 1
        end
        target.Health.Value = target.Health.Value - damageInfo.damage
    end

    if damageInfo.damage < 0 then
        damageInfo.type = "heal"
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

end