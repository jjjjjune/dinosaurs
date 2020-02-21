local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local SeasonsData = import "Shared/Data/SeasonsData"
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

local function onSeasonChanged(newSeason)
    local seasonData = SeasonsData[newSeason]
    for _, grass in pairs(CollectionService:GetTagged("Grass")) do
        local color = seasonData.grassColor
        local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
        local properties = {Color = color}
        if typeof(color) == "table" then
            properties = {Color = color[math.random(1, #color)]}
        end
        local tween = TweenService:Create(grass, tweenInfo, properties)
        tween:Play()
    end
    for _, leaf in pairs(CollectionService:GetTagged("Leaf")) do
        local color = seasonData.leafColor
        local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
        local properties = {Color = color}
        if typeof(color) == "table" then
            properties = {Color = color[math.random(1, #color)]}
        end
        local tween = TweenService:Create(leaf, tweenInfo, properties)
        tween:Play()
    end
end

local Plants = {}

function Plants:start()
    Messages:hook("SeasonSetTo",function(newSeason)
        onSeasonChanged(newSeason)
    end)
end

return Plants