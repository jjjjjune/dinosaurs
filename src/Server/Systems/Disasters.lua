local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local CollectionService = game:GetService("CollectionService")

local allowedDisasters = {
    [1] = {"Drought"},
    [2] = {"Swarm"},
    [3] = {"Drought", "Swarm"},
    [4] = {"Drought", "Swarm"},
}

local fruitBearingTrees = {
    Pine = true,
    Corn = true,
    Apple = true,
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