local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local RockDrops = import "Shared/Data/RockDrops"

local rockRespawn = 60

local function random(min, max)
    local randomObj = Random.new()
    return randomObj:NextInteger(min, max)
end

local function chop(entity)
    local Items = import "Server/Systems/Items"
    local pos = entity.PrimaryPart.Position
    local dropTable = RockDrops[entity.Type.Value]
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
        Items.createItem(itemName, newPos)
        Messages:send("PlayParticle", "DeathSmoke",  20, newPos)
    end
end

local function damageRock(player, rock, item)
    if not rock:FindFirstChild("Health") then
        local health = Instance.new("IntConstrainedValue", rock)
        health.Name = "Health"
        health.MaxValue = 5
        health.Value = 5
    else
        rock.Health.Value = rock.Health.Value - 1
        if rock.Health.Value == 1 then
            wait(.2) -- this is for studio because 0 ping
            chop(rock)
            rock.Health.Value = 6
            rock.Parent = nil
            delay(rockRespawn, function()
                rock.Parent = workspace
                rock:SetPrimaryPartCFrame(rock.PrimaryPart.CFrame)
            end)
        end
    end
    Messages:reproOnClients(player, "PlayDamageEffect", rock)
end

local Rocks = {}

function Rocks:start()
    print("ROCKS START")
    Messages:hook("DamageRock", damageRock)
end

return Rocks