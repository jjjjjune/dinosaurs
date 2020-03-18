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
    --[[Messages:hook("SeasonSetTo", function(currentSeason)
        if currentSeason == 1 then
            Messages:send("WetAllWater")
        elseif currentSeason == 2 then
            Messages:send("DryAllWater")
        elseif currentSeason == 4 then

        end
    end)--]]
    Messages:hook("CreateWeather", function(weatherType, duration)
        createWeather(weatherType, duration)
    end)
    Messages:hook("PlayerAdded", function(player)
        if tick() < weatherEnd then
            Messages:sendClient(player, "WeatherSetTo", currentWeather)
        end
    end)
end

return Weather