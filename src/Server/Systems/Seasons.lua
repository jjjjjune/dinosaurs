local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local SeasonsData = import "Shared/Data/SeasonsData"
local RunService = game:GetService("RunService")
local ServerData = import "Server/Systems/ServerData"
local FastSpawn = import "Shared/Utils/FastSpawn"
local GameConstants = import "Shared/Data/GameConstants"

local currentSeason = 1
local seasonsSurvived = 0
local seasonLength = 1
local lastSeasonChange = tick()

local isNight = false

local function getSeasonLengthModifier()
	return SeasonsData[currentSeason].lengthModifier
end

local function advanceSeason()
	currentSeason = currentSeason + 1

	seasonLength = GameConstants.SEASON_LENGTH

	if currentSeason > #SeasonsData then
		currentSeason = 1
	end

	seasonsSurvived = seasonsSurvived + 1

	ServerData:setValue("seasonsSurvived", seasonsSurvived)
	ServerData:setValue("currentSeason", currentSeason)

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
	local hasLoadedSeasonData = false
	Messages:hookRequest("GetSeason", function(player)
		repeat wait() until hasLoadedSeasonData
		return currentSeason, (tick() - lastSeasonChange), seasonLength*getSeasonLengthModifier()
	end)
	FastSpawn(function()
		currentSeason = ServerData:getValue("currentSeason") or 1
		seasonsSurvived = ServerData:getValue("seasonsSurvived") or 1
		hasLoadedSeasonData = true
		Messages:send("SeasonSetTo", currentSeason, true) -- this order is important for dumb tween reasons
	end)
	initializeMainSeasonLoop()
end

return Seasons