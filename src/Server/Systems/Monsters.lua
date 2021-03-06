local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"
local TagsToModulesMap = import "Shared/Data/TagsToModulesMap"
local MonsterLimits = import "Shared/Data/MonsterLimits"
local MonsterSpawnPoints = import "Shared/Data/MonsterSpawnPoints"
local ServerData = import "Server/Systems/ServerData"

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local monsterSpawnStep = 5 -- only check every 5 seconds if we should spawn a monster
local nextMonsterSpawnStep = tick() + monsterSpawnStep

local activeMonsters = {
	"Lizard",
	"Alpaca",
	"FireLizard",
	"DesertAlpaca",
	"RedTurtle",
}

local function getComponent(monster)
	for tagName, moduleState in pairs(TagsToModulesMap.Monsters) do
		if CollectionService:HasTag(monster, tagName) then
			return moduleState
		else
			print(monster, "does not have tag ", tagName)
		end
	end
end

local function onMonsterAdded(monster)
	ServerData:generateIdForInstanceOfType(monster, "M")
end

local function spawnMonster(monsterName, position, presumedId)
	local monster = game.ServerStorage.Monsters[monsterName]:Clone()
	monster.PrimaryPart.CFrame = CFrame.new(position)
	if presumedId then
		local ID = Instance.new("StringValue", monster)
		ID.Name = "ID"
		ID.Value = presumedId
	end
	monster.Parent = workspace
	local component = getComponent(monster).new()
	component:init(monster)
	onMonsterAdded(monster)
	return monster
end

local function shouldSpawnNewMonster(monsterName)
	local currentMonstersOfType = 0
	for _, monster in pairs(CollectionService:GetTagged("Monster")) do
		if monster:IsDescendantOf(workspace) then
			if monster.Name == monsterName then
				if monster.Tamed.Value == true then
					currentMonstersOfType = currentMonstersOfType + .5
				else
					currentMonstersOfType = currentMonstersOfType + 1
				end
			end
		end
	end
	return currentMonstersOfType < MonsterLimits[monsterName](ServerData:getValue("seasonsSurvived"))
end

local function getValidSpawnPoint(monsterName)
	local spawnInfo = MonsterSpawnPoints[monsterName]
	if spawnInfo.type == "Plant" then
		local plants = {}
		for _, plant in pairs(CollectionService:GetTagged("Plant")) do
			if plant:IsDescendantOf(workspace) and plant.Type.Value == spawnInfo.name then
				if plant.PrimaryPart and plant.PrimaryPart.Position.Y > workspace.Effects.Water.Position.Y then
					table.insert(plants, plant)
				end
			end
		end
		if #plants > 0 then
			return plants[math.random(1, #plants)]
		end
	end
	return nil
end

local function monsterStep()
	for _, monsterName in pairs(activeMonsters) do
		if shouldSpawnNewMonster(monsterName) then
			local point = getValidSpawnPoint(monsterName)
			if point then
				spawnMonster(monsterName, point.PrimaryPart.Position + Vector3.new(0,20,0))
			end
		end
	end
end

local function round(n, mult)
    mult = mult or 1
    return math.floor((n + mult/2)/mult) * mult
end

local function backupMonsters()
    -- local ServerData = import "Server/Systems/ServerData"
    -- local monsters = {}
    -- for _, monster in pairs(CollectionService:GetTagged("Monster")) do
    --     if monster:IsDescendantOf(workspace) then
    --         local primaryPart = monster.PrimaryPart
    --         local pos = primaryPart.Position

    --         local info = {}
    --         info.name = monster.Name
    --         info.position = {x = round(pos.X, .15), y = round(pos.Y, .15), z = round(pos.Z, .15)}

    --         for _, v in pairs(monster:GetChildren()) do
    --             if v:IsA("ValueBase") then
    --                 info[v.Name] = v.Value
    --             end
    --         end

    --         table.insert(monsters, info)
    --     end
    -- end
	-- ServerData:setValue("monsters", monsters)
	local SaveableObjectManager = import "Server/Systems/SaveableObjectManager"
	SaveableObjectManager.saveTag("Monster")
end

local function loadMonsters()
    -- local ServerData = import "Server/Systems/ServerData"
    -- local monsters = ServerData:getValue("monsters")
    -- if monsters then
    --     for _, monster in pairs(monsters) do
    --         local model = game.ServerStorage.Monsters[monster.name]:Clone()
    --         local pos = monster.position
    --         local posCF = CFrame.new(Vector3.new(pos.x, pos.y, pos.z))
	-- 		model:SetPrimaryPartCFrame(posCF)

	-- 		local ID = Instance.new("StringValue", model)
	-- 		ID.Name = "ID"
	-- 		ID.Value = monster.ID

    --         for propName, value in pairs(monster) do
    --             if model:FindFirstChild(propName) then
    --                 if model[propName]:IsA("ValueBase") then
    --                     model[propName].Value = value
    --                 end
    --             end
    --         end

	-- 		model.Parent = workspace

	-- 		local component = getComponent(model).new()
	-- 		component:init(model)
    --     end
	-- end
	local SaveableObjectManager = import "Server/Systems/SaveableObjectManager"
	SaveableObjectManager.loadTag("Monster")
end

local function prepareMonsters()
	for _, monster in pairs(game.ServerStorage.Monsters:GetChildren()) do
		local tamedHealth = monster.Health:Clone()
		tamedHealth.Name = "TamedHealth"
		tamedHealth.Parent = monster
	end
end

local Monsters = {}

function Monsters.createMonster(monsterName, pos, presumedId)
	return spawnMonster(monsterName, pos, presumedId)
end

function Monsters:start()
	prepareMonsters()
	RunService.Stepped:connect(function(dt)
		if tick() > nextMonsterSpawnStep then
			nextMonsterSpawnStep = tick() + monsterSpawnStep
			monsterStep()
			backupMonsters()
		end
	end)
	Messages:hook("FirstMapRenderComplete", function()
		loadMonsters()
	end)
	Messages:hook("SpawnMonster", spawnMonster)
end

return Monsters
