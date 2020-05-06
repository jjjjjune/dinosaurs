local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local currentWeather = nil
local weatherEnd = tick() - 100

local lastRainRefill = tick()

local weatherFunctions = {
    Rain = function()
        if tick() - lastRainRefill > 2 then
            lastRainRefill = tick()
            Messages:send("FillSkyReceptacles")
        end
    end,
}

local function createWeather(weatherType, length)
    currentWeather = weatherType
    weatherEnd = tick() + length
    Messages:sendAllClients("WeatherSetTo", weatherType)
    Messages:send("WeatherSetTo", weatherType)
end

local Weather = {}

function Weather:start()
    spawn(function()
        while wait() do
            if tick() > weatherEnd and currentWeather then
                Messages:sendAllClients("WeatherSetTo", nil)
                currentWeather = nil
            end
            if currentWeather and weatherFunctions[currentWeather] then
                weatherFunctions[currentWeather]()
            end
        end
    end)
    Messages:hook("CreateWeather", function(weatherType, duration)
        if currentWeather then
            Messages:sendAllClients("WeatherSetTo", nil)
            currentWeather = nil
        end
        if weatherType == "Rain" then
            --Messages:send("WetAllWater")
        end
        createWeather(weatherType, duration)
        weatherEnd = tick() + duration
    end)
    Messages:hook("PlayerAdded", function(player)
        if tick() < weatherEnd then
            Messages:sendClient(player, "WeatherSetTo", currentWeather)
        end
    end)
end

return Weather