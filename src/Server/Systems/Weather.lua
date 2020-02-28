local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local currentWeather = nil
local weatherEnd = tick() - 100

local function createWeather(weatherType, length)
    currentWeather = weatherType
    weatherEnd = tick() + length
    Messages:sendAllClients("WeatherSetTo", weatherType)
    delay(length, function()
        Messages:sendAllClients("WeatherSetTo", nil)
    end)
end

local Weather = {}

function Weather:start()
    Messages:hook("SeasonSetTo", function(currentSeason)
        if currentSeason == 1 then
            createWeather("Rain", 8)
            Messages:send("WetAllWater")
        elseif currentSeason == 2 then
            Messages:send("DryAllWater")
        elseif currentSeason == 4 then
            createWeather("Snow", 8)
        end
    end)
    Messages:hook("PlayerAdded", function(player)
        if tick() < weatherEnd then
            Messages:sendClient(player, "WeatherSetTo", currentWeather)
        end
    end)
end

return Weather