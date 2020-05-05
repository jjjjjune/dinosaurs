local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

return function(target, damageInfo)

    target.Humanoid.Health = target.Humanoid.Health - damageInfo.damage

    if damageInfo.damage < 0 then
        damageInfo.type = "heal"
    end

    local player = game:GetService("Players"):GetPlayerFromCharacter(target)

    warn("remember the server application config thing for when youre doing the effect from server")

    if player and not damageInfo.serverApplication then
        Messages:reproOnClients(player, "PlayDamageEffect", target, damageInfo.type)
    else
        Messages:sendAllClients("PlayDamageEffect", target, damageInfo.type)
    end

end