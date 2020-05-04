local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

return function(target, damageInfo)
    print("damaging!")
    print("damage is: ", damageInfo.damage)
    target.Humanoid.Health = target.Humanoid.Health - damageInfo.damage
    print("Health loewered")
    if damageInfo.damage < 0 then
        damageInfo.type = "heal"
    else
        Messages:send("PlaySound", "DamagedSDS", target.PrimaryPart.Position)
    end
    local player = game:GetService("Players"):GetPlayerFromCharacter(target)
    if player then
        Messages:reproOnClients(player, "PlayDamageEffect", target, damageInfo.type)
    else
        Messages:sendAllClients("PlayDamageEffect", target, damageInfo.type)
    end
end