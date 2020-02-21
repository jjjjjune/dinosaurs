local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local SeasonLighting = import "Shared/Data/SeasonLighting"
local SeasonsData = import "Shared/Data/SeasonsData"
local TweenService = game:GetService("TweenService")
local FastSpawn = import "Shared/Utils/FastSpawn"

local currentSeasonName = "Winter"

local function onSeasonSetTo(currentSeason)
    currentSeasonName = SeasonsData[currentSeason].name
    local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
    for instance, properties in pairs(SeasonLighting[currentSeasonName]) do
        local tween = TweenService:Create(instance, tweenInfo, properties)
        tween:Play()
    end
end

local function setInitialLighting()
    spawn(function()
        local currentSeason = Messages:requestServer("GetSeason")
        currentSeasonName = SeasonsData[currentSeason].name
    end)
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
end

return Lighting