local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local RunService = game:GetService("RunService")

local ServerData = import "Server/Systems/ServerData"
local GetValidPlantPos = import "Shared/Utils/GetValidPlantPos"
local FastSpawn = import "Shared/Utils/FastSpawn"

local CollectionService = game:GetService("CollectionService")

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
    for plantName, amount in pairs(plants) do
        for i = 1, amount do
            table.insert(t, plantName)
        end
    end
    return t[math.random(1, #t)]
end

local function createPlantForBiome(biome, allBiomeTiles, isFirstTime, maxPlantsAmount)
    local name = "Shared/Data/BiomeData/"..biome
    local data = import(name)
    local tile = allBiomeTiles[math.random(1, #allBiomeTiles)]
    local plantName = selectBiomePlant(data.plants)
    local pos = GetValidPlantPos(tile, plantName, biome)
    if pos then
        local count = #biomeToPlantsMap[biome]
        if count < maxPlantsAmount then
            -- do this check again because the get position method is asynchronous
            local Plants = import "Server/Systems/Plants"
            local phase = 1
            if isFirstTime then
                phase = math.random(1, #(game.ServerStorage.PlantPhases[plantName]:GetChildren()))
            end
            local plant = Plants.createPlant(plantName, pos, phase, false)
            plant.Biome.Value = biome
            table.insert(biomeToPlantsMap[biome], plant)
        end
    end
end

local function getBiomePlants(biomeName)
    local count = 0
    for _, plant in pairs(CollectionService:GetTagged("Plant")) do
        if plant.Biome.Value == biomeName then
            count = count + 1
        end
    end
    return count
end

local function tickBiome(biome, allBiomeTiles, isFirstTime)
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
    local name = "Shared/Data/BiomeData/"..biome
    local data = import(name)

    local totalseed = 0

    for _, tile in pairs(allBiomeTiles) do
        totalseed= totalseed +bytesum(tile.Name)
    end

    local maxPlantsPerTile = data.maxPlantsPerTile
    local minPlantsPerTile = data.minPlantsPerTile

    local plantsAmountRandom = Random.new(totalseed)
    local plantsAmount = plantsAmountRandom:NextInteger(minPlantsPerTile*(#allBiomeTiles), maxPlantsPerTile*(#allBiomeTiles))

    --print("plants amount is: ", plantsAmount)

    local currentPlantsCount = getBiomePlants(biome)

    FastSpawn(function()
        if currentPlantsCount < plantsAmount then
            for i = 1, (plantsAmount - currentPlantsCount) do
                createPlantForBiome(biome, allBiomeTiles, isFirstTime, plantsAmount)
            end
        end
    end)
end

local function performBiomeCheck(isFirstTime)
    local allBiomes = {}

    -- going to have to change this to just look at all rendered tiles
    for _, tile in pairs(CollectionService:GetTagged("Tile")) do
        if not allBiomes[tile.Biome.Value] then
            allBiomes[tile.Biome.Value] = true
        end
    end

    for biome, _ in pairs(allBiomes) do
        local allBiomeTiles = {}
        for i, tileFolder in pairs(workspace.Tiles:GetChildren()) do
            for _, tile in pairs(tileFolder:GetChildren()) do
                if tile.Biome.Value == biome then
                    table.insert(allBiomeTiles, tile)
                end
            end
        end
        tickBiome(biome, allBiomeTiles, isFirstTime)
    end
end

local Biomes = {}

function Biomes:start()
    Messages:hook("FirstMapRenderComplete", function()
        if not ServerData:getValue("FirstBiomeCheck") then
            ServerData:setValue("FirstBiomeCheck", true)
            performBiomeCheck(true)
        end
    end)
    Messages:hook("WeatherSetTo", function(weather)
        if weather == "Rain" then
            delay(2, function()
                performBiomeCheck(false)
            end)
        end
    end)
end

return Biomes