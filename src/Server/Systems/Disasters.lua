local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local CollectionService = game:GetService("CollectionService")

local FastSpawn = import "Shared/Utils/FastSpawn"

local allowedDisasters = {
    [1] = {"Drought", "Firestorm"},
    [2] = {"Swarm", "Firestorm"},
    [3] = {"Drought", "Swarm", "Firestorm",},
    [4] = {"Drought", "Swarm", "Firestorm",},
}

local fruitBearingTrees = {
    ["Thorn Vine"] = true,
    Corn = true,
    Apple = true,
    Cactus = true,
    ["Banana Tree"] = true,
}

local function destroySomeFruitPlants()
    local destroyChance = 60
    for _, plant in pairs(CollectionService:GetTagged("Plant")) do
        if plant:IsDescendantOf(workspace) then
            if fruitBearingTrees[plant.Type.Value] then
                if math.random(1, 100) <= destroyChance then
                    plant:Destroy()
                end
            end
        end
    end
end

local function doFirestorm()
    local burnables = {}
    for _, v in pairs(CollectionService:GetTagged("Organic")) do
        if not v:IsDescendantOf(game.ReplicatedStorage) then
            table.insert(burnables, v)
        end
    end
    for _, v in pairs(CollectionService:GetTagged("Plant")) do
        if not v:IsDescendantOf(game.ServerStorage) then
            table.insert(burnables, v)
        end
    end
    local newBurnables = {}
    for i, v in pairs(burnables) do
        if math.random(1,2)  == 1 then
            table.insert(newBurnables, v)
        end
    end
    FastSpawn(function()
        for _, burnable in pairs(newBurnables) do
            Messages:send("SetOnFire", burnable)
            wait()
        end
    end)
end

local disasters = {
    Swarm = function()
        Messages:sendAllClients("Notify", "HEALTH_COLOR_DARK", "ANGRY", "THE GODS SEND LOCUSTS. YOUR CROPS ARE CONSUMED.")--, "VIBRATE")
        Messages:send("CreateWeather", "Swarm", 10)
        destroySomeFruitPlants()
    end,
    Drought = function()
        Messages:sendAllClients("Notify", "HEALTH_COLOR_DARK", "ANGRY", "THE GODS DISPLEASED. ALL WATER RECEDED TO DUST.")--, "VIBRATE")
        Messages:send("DryAllWater")
    end,
    Firestorm = function()
        Messages:sendAllClients("Notify", "HEALTH_COLOR_DARK", "ANGRY", "FIRE CONSUMES THE LAND.")--, "VIBRATE")
        doFirestorm()
    end,
}

local function createDisaster(currentSeason)
    local disaster = allowedDisasters[currentSeason][math.random(1, #allowedDisasters[currentSeason])]
    disasters[disaster]()
end

local Disasters = {}

function Disasters:start()
    Messages:hook("CreateDisaster", createDisaster)
end

return Disasters
