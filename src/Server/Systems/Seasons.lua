local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local SeasonsData = import "Shared/Data/SeasonsData"
local RunService = game:GetService("RunService")

local currentSeason = 1
local seasonLength = 3

local function getSeasonLengthModifier()
    return SeasonsData[currentSeason].lengthModifier
end

local function advanceSeason()
    currentSeason = currentSeason + 1
    if currentSeason > #SeasonsData then
        currentSeason = 1
    end
    Messages:send("SeasonSetTo", currentSeason)
    Messages:sendAllClients("SeasonSetTo", currentSeason)
end

local function initializeMainSeasonLoop()
    local lastSeasonChange = tick()
    RunService.Stepped:connect(function()
        if tick() - lastSeasonChange > seasonLength*getSeasonLengthModifier() then
            advanceSeason()
            lastSeasonChange = tick()
        end
    end)
end

local Seasons = {}

function Seasons:start()
    initializeMainSeasonLoop()
    Messages:hookRequest("GetSeason", function(player)
        return currentSeason
    end)
end

return Seasons