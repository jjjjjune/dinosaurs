local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local SeasonsData = import "Shared/Data/SeasonsData"
local RunService = game:GetService("RunService")

local currentSeason = 1
local seasonLength = 30
local lastSeasonChange = tick()

local isNight = false

local function getSeasonLengthModifier()
    return SeasonsData[currentSeason].lengthModifier
end

local function advanceSeason()
    currentSeason = currentSeason + 1
    if currentSeason > #SeasonsData then
        currentSeason = 1
    end
    if currentSeason == 4 then
        --isNight = not isNight
    end
    Messages:sendAllClients("SeasonSetTo", currentSeason, seasonLength*getSeasonLengthModifier(), isNight)
    Messages:send("SeasonSetTo", currentSeason) -- this order is important for dumb tween reasons   
end

local function initializeMainSeasonLoop()
    RunService.Stepped:connect(function()
        if tick() - lastSeasonChange > seasonLength*getSeasonLengthModifier() then
            lastSeasonChange = tick()
            advanceSeason()
        end
    end)
end

local Seasons = {}

function Seasons:start()
    initializeMainSeasonLoop()
    Messages:hookRequest("GetSeason", function(player)
        return currentSeason, (tick() - lastSeasonChange), seasonLength*getSeasonLengthModifier()
    end)
end

return Seasons