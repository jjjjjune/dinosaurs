local Item = {}

function Item.clientUse(item)
    print("client use")
    -- monch, clone Item item for effect, effect
end

function Item.serverUse(player, item)
    print("server use")
    -- destroy item
end

function Item.clientEquip(item)
    print("client equip")
end

function Item.serverEquip(player, item)
    print("server equip")
end


function Item.clientUnequip(item)

end

function Item.serverUnequip(player, item)
    
end

return Item