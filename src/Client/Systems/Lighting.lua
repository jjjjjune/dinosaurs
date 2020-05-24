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

local function onSeasonSetTo(currentSeason, isNight)
    for _, tween in pairs(lastTweens) do
        if tween.PlaybackState == Enum.PlaybackState.Playing then
            tween:Pause()
        end
    end
    lastTweens = {}
    currentSeasonName = (SeasonsData[currentSeason] and SeasonsData[currentSeason].name) or currentSeason
    if isNight then
        currentSeasonName = currentSeasonName.."Night"
    end
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
        local currentSeason = Messages:requestServer("GetSeason") or 1
        currentSeasonName = SeasonsData[currentSeason].name
        onSeasonSetTo(currentSeason)
    end)
end

local function weatherStep()
    if currentWeather ~= nil then
        if not WeatherEffectsFolder:FindFirstChild(currentWeather) then
            if WeatherParticles:FindFirstChild(currentWeather) then
                local effect = WeatherParticles:FindFirstChild(currentWeather):Clone()
                effect.Parent = WeatherEffectsFolder
                for _, s in pairs(effect:GetChildren()) do
                    if s:IsA("Sound") then
                        s:Play()
                    end
                end
            end
        end
        local effect = WeatherEffectsFolder:FindFirstChild(currentWeather)
        local pos = GetCharacterPosition()
        if pos then
            if not effect:FindFirstChild("LockToPlayer") then 
                local hit, hitPos = CastRay(pos, Vector3.new(0,100,0), {workspace})
                effect.CFrame = CFrame.new(hitPos)
            else
                effect.CFrame = CFrame.new(pos)
            end
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
    end)
    Messages:hook("SeasonSetTo", function(currentSeason, length, isNight)
        onSeasonSetTo(currentSeason, isNight)
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