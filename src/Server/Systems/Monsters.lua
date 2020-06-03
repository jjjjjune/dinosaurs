local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"
local TagsToModulesMap = import "Shared/Data/TagsToModulesMap"
local AnimalLimits = import "Shared/Data/AnimalLimits"
local AnimalSpawnPoints = import "Shared/Data/AnimalSpawnPoints"
local ServerData = import "Server/Systems/ServerData"

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local monsterSpawnStep = 5 -- only check every 5 seconds if we should spawn a monster
local nextMonsterSpawnStep = tick() + monsterSpawnStep

local activeMonsters = {
	"Lizard"
}

local function getComponent(monster)
	for tagName, moduleState in pairs(TagsToModulesMap.Monsters) do
		if CollectionService:HasTag(monster, tagName) then
			return moduleState
		end
	end
end

local function spawnMonster(monsterName, position)
	local monster = game.ServerStorage.Monsters[monsterName]:Clone()
	monster.PrimaryPart.CFrame = CFrame.new(position)
	monster.Parent = workspace
	local component = getComponent(monster).new()
	component:init(monster)
end

local function shouldSpawnNewMonster(monsterName)
	local currentMonstersOfType = 0
	for _, monster in pairs(CollectionService:GetTagged("Animal")) do
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
	return currentMonstersOfType < AnimalLimits[monsterName](ServerData:getValue("seasonsSurvived"))
end

local function getValidSpawnPoint(monsterName)
	local spawnInfo = AnimalSpawnPoints[monsterName]
	if spawnInfo.type == "Plant" then
		local plants = {}
		for _, plant in pairs(CollectionService:GetTagged("Plant")) do
			if plant.Type.Value == spawnInfo.name and plant:IsDescendantOf(workspace) then
				table.insert(plants, plant)
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
			print("SHOULD SPAWN")
			local point = getValidSpawnPoint(monsterName)
			if point then
				print("spoawning")
				spawnMonster(monsterName, point.PrimaryPart.Position + Vector3.new(0,20,0))
			end
		end
	end
end

local Monsters = {}

function Monsters:start()
	RunService.Stepped:connect(function(dt)
		if tick() > nextMonsterSpawnStep then
			nextMonsterSpawnStep = tick() + monsterSpawnStep
			monsterStep()
		end
	end)
end

return Monsters