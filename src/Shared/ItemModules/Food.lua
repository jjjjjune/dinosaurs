local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Food = {}

function Food.clientUse(item)
    -- monch, clone food item for effect, effect
end

function Food.serverUse(player, item)
    Messages:send("PlaySound", "Eating", item.Base.Position)
    Messages:send("AddStat", player, "hunger", item.Hunger.Value)
    Messages:send("AddStat", player, "thirst", item.Thirst.Value)
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