local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Food = {}

function Food.clientUse(item)
    print("client use")
    -- monch, clone food item for effect, effect
end

function Food.serverUse(player, item)
    print("server use")
    Messages:send("PlaySound", "Eating", item.Base.Position)
    -- destroy item
    return true
end

function Food.clientEquip(item)
    print("client equip")
end

function Food.serverEquip(player, item)
    print("server equip")
end

function Food.clientUnequip(item)
    print('client unequip')
end

function Food.serverUnequip(player, item)
    print('serve runequip')
end

return Food