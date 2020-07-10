local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local RockDrops = import "Shared/Data/RockDrops"

local ServerData = import "Server/Systems/ServerData"
local TileRenderer = import "Server/MapRenderComponents/TileRenderer"

local GetRockName = import "Shared/Utils/GetRockName"

local CollectionService = game:GetService("CollectionService")

local spawnerRocks = {}
local rockSpawners = {}

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
		local item = Items.createItem(itemName, newPos)
		item.Parent = workspace
        Messages:send("PlayParticle", "DeathSmoke",  20, newPos)
    end
end

local function getSpawnerId(spawner)
	local base = spawner.PrimaryPart
	return tostring(math.floor(base.Position.X))..tostring(math.floor(base.Position.Y))..tostring(math.floor(base.Position.Z))
end


local function onMined(rock)
	rock.Parent = nil
	local spawner = rockSpawners[rock]
	local id = getSpawnerId(spawner)
	local spawners = ServerData:getValue("rockSpawners")
	spawners[id].lastMine = os.time()
	ServerData:setValue("rockSpawners", spawners)
end

local function damageRock(player, rock, item)
    if not rock:FindFirstChild("Health") then
        local health = Instance.new("IntConstrainedValue", rock)
        health.Name = "Health"
        health.MaxValue = 5
		health.Value = 5
	end
	rock.Health.Value = rock.Health.Value - 1
	if rock.Health.Value == 0 then
		wait(.2) -- this is for studio because 0 ping
		chop(rock)
		rock.Health.Value = rock.Health.MaxValue
		onMined(rock)
	end
    Messages:reproOnClients(player, "PlayDamageEffect", rock)
end

local function newSpawnerData()
	return {
		rock = nil,
		lastMine = 0,
		yLevel = 0
	}
end

local function respawnRock(spawner, spawnerData)
	if not spawnerRocks[spawner] then
		spawnerRocks[spawner] = game.ServerStorage.Rocks[spawnerData.rock]:Clone()
		local rock = spawnerRocks[spawner]
		rockSpawners[rock] = spawner
		rock.Parent = workspace.Rocks
		rock:SetPrimaryPartCFrame(spawner.PrimaryPart.CFrame)
	else
		spawnerRocks[spawner].Parent = workspace.Rocks
		spawnerRocks[spawner]:SetPrimaryPartCFrame(spawner.PrimaryPart.CFrame)
	end
end

local function onRockSpawnAdded(spawner)
	spawner.PrimaryPart.Transparency = 1
	spawner.PrimaryPart.CanCollide = false

	CollectionService:AddTag(spawner.PrimaryPart, "RayIgnore")

	local yLevel = TileRenderer.getCellYLevelOfPosition(spawner.PrimaryPart.Position)

	local rockSpawners = ServerData:getValue("rockSpawners")
	local spawnerId = getSpawnerId(spawner)

	local spawnerData = rockSpawners[spawnerId]

	if not spawnerData then
		rockSpawners[spawnerId] = newSpawnerData()
		rockSpawners[spawnerId].yLevel = yLevel
	end

	if not rockSpawners[spawnerId].rock then
		rockSpawners[spawnerId].rock = GetRockName(rockSpawners[spawnerId].yLevel)
	end

	ServerData:setValue("rockSpawners", rockSpawners)
end

local function skinRockSpawners()
	for _, spawner in pairs(CollectionService:GetTagged("RockSpawn")) do

		local spawnerId = getSpawnerId(spawner)
		local rockSpawners = ServerData:getValue("rockSpawners")
		local spawnerData = rockSpawners[spawnerId]

		if spawnerData then

			local respawnTime = 5

			if os.time() - spawnerData.lastMine > respawnTime then
				if spawnerData.rock then
					if spawnerRocks[spawner] == nil or spawnerRocks[spawner].Parent == nil then
						respawnRock(spawner, spawnerData)
					end
				end
			end
			onRockSpawnAdded(spawner)
		end

	end
end


local Rocks = {}

function Rocks:start()
	Messages:hook("DamageRock", damageRock)
	CollectionService:GetInstanceAddedSignal("RockSpawn"):connect(function(child)
		onRockSpawnAdded(child)
	end)
	for _, spawner in pairs(CollectionService:GetTagged("RockSpawn")) do
		if spawner:IsDescendantOf(workspace) then
			onRockSpawnAdded(spawner)
		end
	end
	spawn(function()
		while wait(1) do
			skinRockSpawners()
		end
	end)
end

return Rocks
