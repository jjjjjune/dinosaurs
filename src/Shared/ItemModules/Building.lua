local Item = {}

function Item.clientUse(item)
end

function Item.serverUse(player, item)
end

function Item.clientEquip(item)
    print("INITIATE BUILDING MODE")
end

function Item.serverEquip(player, item)
end

function Item.clientUnequip(item)
    print("GET RID OF BUILDIN MODE")
end

function Item.serverUnequip(player, item)
end

return Item