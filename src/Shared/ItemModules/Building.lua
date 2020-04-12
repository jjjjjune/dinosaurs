local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Item = {}

function Item.clientUse(item)
end

function Item.serverUse(player, item)
end

function Item.clientEquip(item)
    Messages:send("StartBuilding", item)
end

function Item.serverEquip(player, item)
end

function Item.clientUnequip(item)
    Messages:send("EndBuilding", item)
end

function Item.serverUnequip(player, item)
end

return Item