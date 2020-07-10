local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local PlantDrops = import "Shared/Data/PlantDrops"

local function random(min, max)
    local randomObj = Random.new()
    return randomObj:NextInteger(min, max)
end

local function chop(entity)
    local Items = import "Server/Systems/Items"
    local pos = entity.PrimaryPart.Position
    local dropTable = PlantDrops[entity.Type.Value]
    local itemsToMake = {}
    for i, itemTable in pairs(dropTable) do
        if itemTable.min > 0 then
            for i = 1, itemTable.min do
                table.insert(itemsToMake, itemTable.name)
            end
        end
        local remaining = math.random(0, itemTable.max - itemTable.min)
        if remaining > 0 then
            for i = 1, remaining do
                local n = random(1, 100)
                if n < itemTable.chance then
                    table.insert(itemsToMake, itemTable.name)
                end
            end
        end
    end
    for _, itemName in pairs(itemsToMake) do
        local newPos = pos + Vector3.new(random(-5,5), 0, random(-5,5))
		local item = Items.createItem(itemName, newPos)
		item.Parent = workspace
        Messages:send("PlayParticle", "DeathSmoke",  20, newPos)
    end
end

local Entity = {}

function Entity.clientUse(entityInstance)
    local sound = "Chop"
    Messages:send("PlaySoundOnClient",{
        instance = game.ReplicatedStorage.Sounds[sound],
        part = game.Players.LocalPlayer.Character.Head
    })
end

function Entity.serverUse(player, entityInstance)
    local sound = "Chop"
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        if (player.Character.PrimaryPart.Position - entityInstance.PrimaryPart.Position).magnitude < 40  then
            chop(entityInstance)
            Messages:reproOnClients(player, "PlaySound", sound, entityInstance.PrimaryPart.Position)
            entityInstance:Destroy()
        end
    end
end

return Entity
