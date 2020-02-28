local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local SeasonLighting = import "Shared/Data/SeasonLighting"
local SeasonsData = import "Shared/Data/SeasonsData"
local TweenService = game:GetService("TweenService")
local FastSpawn = import "Shared/Utils/FastSpawn"
local RunService = game:GetService("RunService")
local WeatherParticles = import "ReplicatedStorage/WeatherParticles"
local GetCharacterPosition = import "Shared/Utils/GetCharacterPosition"
local CastRay = import "Shared/Utils/CastRay"
local WeatherEffectsFolder = Instance.new("Folder", workspace)
WeatherEffectsFolder.Name = "WeatherEffects"

local currentSeasonName = "Winter"
local currentWeather = nil

local lastTweens = {}

local function onSeasonSetTo(currentSeason)
    for _, tween in pairs(lastTweens) do
        if tween.PlaybackState == Enum.PlaybackState.Playing then
            tween:Pause()
        end
    end
    lastTweens = {}
    currentSeasonName = (SeasonsData[currentSeason] and SeasonsData[currentSeason].name) or currentSeason
    -- that last bit there is for weather
    local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
    for instance, properties in pairs(SeasonLighting[currentSeasonName]) do
        local tween = TweenService:Create(instance, tweenInfo, properties)
        table.insert(lastTweens, tween)
        tween:Play()
    end
end

local function setInitialLighting()
    spawn(function()
        local currentSeason = Messages:requestServer("GetSeason")
        currentSeasonName = SeasonsData[currentSeason].name
    end)
end

local function weatherStep()
    if currentWeather ~= nil then
        if not WeatherEffectsFolder:FindFirstChild(currentWeather) then
            if WeatherParticles:FindFirstChild(currentWeather) then
                local effect = WeatherParticles:FindFirstChild(currentWeather):Clone()
                effect.Parent = WeatherEffectsFolder
            end
        end
        local effect = WeatherEffectsFolder:FindFirstChild(currentWeather)
        local pos = GetCharacterPosition()
        local hit, hitPos = CastRay(pos, Vector3.new(0,100,0), {game.Players.LocalPlayer.Character, WeatherEffectsFolder})
        if not hit then
            effect.ParticleEmitter.Rate = 300
            effect.CFrame = CFrame.new(hitPos)
        else
            effect.ParticleEmitter.Rate = 0
        end
    else
        WeatherEffectsFolder:ClearAllChildren()
    end
end

local Lighting = {}

function Lighting:start()
    FastSpawn(function()
        workspace:WaitForChild("Effects"):WaitForChild("Sky")
        setInitialLighting()
        Messages:hook("SeasonSetTo", function(currentSeason)
            onSeasonSetTo(currentSeason)
        end)
    end)
    Messages:hook("WeatherSetTo", function(weather)
        if SeasonLighting[weather] then
            onSeasonSetTo(weather)
        else
            local seasonNumber = 1
            for i, seasonInfo in pairs(SeasonsData) do
                if seasonInfo.name == currentSeasonName then
                    seasonNumber = i
                end
            end
            onSeasonSetTo(seasonNumber)
        end
        currentWeather = weather
    end)
    RunService.Stepped:connect(function()
        weatherStep()
    end)
end

return Lighting