local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local RunService = game:GetService("RunService")

local BIOME_CHECK_TIME = 1

local biomeToPlantsMap = {}
local lastBiomeCheck = tick()

local function bytesum(str)
    local amount = 0
    for i = 1, #str do
        local c = str:sub(i,i)
        amount = amount + string.byte(c)
    end
    return amount
end

local function selectBiomePlant(plants)
    local t = {}
end

local function createPlantForBiome(biome, allBiomeTiles)
    local data = import "Shared/Data/BiomeData/"..biome
    local tile = allBiomeTiles[math.random(1, #allBiomeTiles)]
    local plantName = selectBiomePlant(data.plants)
end

local function tickBiome(biome, allBiomeTiles)
    if not biomeToPlantsMap[biome] then
        biomeToPlantsMap[biome] = {}
        for _, plant in pairs(CollectionService:GetTagged("Plant")) do
            if plant.Biome.Value == biome then
                table.insert(biomeToPlantsMap[biome], plant)
            end
        end
    else
        local validPlants ={}
        for _, plant in pairs(biomeToPlantsMap[biome]) do
            if plant.Parent ~= nil then
                table.insert(validPlants, plant)
            end
        end
        biomeToPlantsMap[biome] = validPlants
    end
    local data = import "Shared/Data/BiomeData/"..biome

    local totalseed = 0

    for _, tile in pairs(allBiomeTiles) do
        totalseed= totalseed +bytesum(tile.Name)
    end

    local maxPlantsPerTile = data.maxPlantsPerTile
    local minPlantsPerTile = data.minPlantsPerTile

    local plantsAmountRandom = Random.new(totalseed)
    local plantsAmount = plantsAmountRandom:NextInteger(minPlantsPerTile*(#allBiomeTiles), maxPlantsPerTile*(#allBiomeTiles))
    
    local currentPlantsCount = #biomeToPlantsMap[biome]

    if currentPlantsCount < plantsAmount then
        print("POPULATING PLANT")
        createPlantForBiome(biome, allBiomeTiles)
    end
end

local function performBiomeCheck()
    local MapGeneration = import "Server/Systems/MapGeneration"

    local tileModelsToTileInfoMap = MapGeneration.tileModelsToTileInfoMap

    local allBiomes = {}

    for _, tileInfo in pairs(tileModelsToTileInfoMap) do
        if not allBiomes[tileInfo.biome] then
            allBiomes[tileInfo.biome] = true
        end
    end

    for biome, _ in pairs(allBiomes) do
        local allBiomeTiles = {}
        for tile in pairs(tileModelsToTileInfoMap) do
            if tile.Parent ~= nil then
                table.insert(allBiomeTiles, tile)
            end
        end
        tickBiome(biome, allBiomeTiles)
    end
end

local function step()
    if tick() - lastBiomeCheck > BIOME_CHECK_TIME then
        lastBiomeCheck = tick()
        performBiomeCheck()
    end
end

local Biomes = {}

function Biomes:start()
    RunService.Stepped:connect(step)
end

return Biomes