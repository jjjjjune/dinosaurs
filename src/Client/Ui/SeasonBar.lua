local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local FastSpawn = import "Shared/Utils/FastSpawn"
local SeasonsData = import "Shared/Data/SeasonsData"

local TweenService = game:GetService("TweenService")

local seasonRotations = {
    310.5, -- spring start
    221, -- summer
    131.5, -- fall
    41.5 -- tween to -49.5 after this
}

local function getNextSeasonRotation(seasonIndex)
    local nextIndex = seasonIndex + 1
    if nextIndex > #SeasonsData then
        nextIndex = 1
    end
    return seasonRotations[nextIndex]
end

local function getSeasonName(seasonIndex)
    return SeasonsData[seasonIndex].name
end

local function initializeAndHookSeasonUi()
    local SeasonUi = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("StatusBar")
    local wheel = SeasonUi.MainImage.SeasonWheel.Wheel
    FastSpawn(function()
        local currentSeasonIndex, timeProgressed, seasonLength = Messages:requestServer("GetSeason")
        local alpha = timeProgressed/seasonLength
        local startRotation = seasonRotations[currentSeasonIndex]
        local goalRotation = getNextSeasonRotation(currentSeasonIndex)
        local realStartRotation = (startRotation +  (goalRotation - startRotation)*alpha)
        wheel.Rotation = realStartRotation
        local tweenInfo = TweenInfo.new(seasonLength - timeProgressed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        local tween = TweenService:Create(wheel, tweenInfo, {Rotation = goalRotation})
        tween:Play()
    end)
    Messages:hook("SeasonSetTo",function(seasonIndex, seasonLength)
        wheel.Rotation = seasonRotations[seasonIndex]
        local goalRotation = getNextSeasonRotation(seasonIndex)
        if seasonIndex == #SeasonsData then
            goalRotation = -49.5
        end
        local tweenInfo = TweenInfo.new(seasonLength, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        local tween = TweenService:Create(wheel, tweenInfo, {Rotation = goalRotation})
        tween:Play()
    end)
end

local SeasonBar = {}

function SeasonBar:start()
    FastSpawn(function()
        initializeAndHookSeasonUi()
    end)
end

return SeasonBar