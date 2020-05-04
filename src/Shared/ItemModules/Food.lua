local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local Damage = import "Shared/Utils/Damage"

local Food = {}

function Food.clientUse(item)
    Messages:send("PlayAnimationClient", "Eat")
    if item:FindFirstChild("Health") then
        if item.Health.Value > 0 then
            Messages:send("PlayDamageEffect", game.Players.LocalPlayer.Character, "heal")
        else
            Messages:send("PlayDamageEffect", game.Players.LocalPlayer.Character, "normal")
        end
    end
end

function Food.serverUse(player, item)
    Messages:send("PlaySound", "Eating", item.Base.Position)
    Messages:send("AddStat", player, "hunger", item.Hunger.Value)
    Messages:send("AddStat", player, "thirst", item.Thirst.Value)
    if item:FindFirstChild("Health") then
        Damage(player.Character, {damage = -item.Health.Value, type = "normal"})
    end
    return true
end

function Food.clientEquip(item)
end

function Food.serverEquip(player, item)
end

function Food.clientUnequip(item)
end

function Food.serverUnequip(player, item)
end

return Food