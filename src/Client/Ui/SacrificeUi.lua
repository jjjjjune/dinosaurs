local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local SacrificeUiInstance = game.Players.LocalPlayer.PlayerGui:WaitForChild("SacrificeProgress")

local FastSpawn = import "Shared/Utils/FastSpawn"
local SeasonsData = import "Shared/Data/SeasonsData"

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local nextSeasonChange = tick()
local lastSeasonChange = tick()
local lastSeasonLength = 120
local lastCurrentSeason = 1

local seasonColors = {-- spring summer fall winter
    {
        bg = Color3.fromRGB(107,194,136),
        fg = Color3.fromRGB(211,249,105),
        icon = "rbxassetid://4898590164",
        name = "spring",
    },
    {
        bg = Color3.fromRGB(144,95,95),
        fg = Color3.fromRGB(255,95,95),
        icon = "rbxassetid://4898590697",
        name = "summer",
    },
    {
        bg = Color3.fromRGB(194,101,46),
        fg = Color3.fromRGB(255,145,46),
        icon = "rbxassetid://4898590465",
        name = "fall",
    },
    {
        bg = Color3.fromRGB(82,179,159),
        fg = Color3.fromRGB(136,255,204),
        icon = "rbxassetid://4898590596",
        name = "winter",
    },
}

local function updateSacrificePercent(newPercent)
    newPercent = math.min(1, newPercent)
    SacrificeUiInstance.ContainerRealBack.Background.Holder.Progress:TweenPosition(UDim2.new((1-newPercent)*-1,0,0,0), "Out", "Quad", .3)
    --SacrificeUiInstance.Background.Holder.Progress.FG:TweenPosition(UDim2.new(1+(newPercent),0,1,0), "Out", "Quad", .3)
end

local function initializeAndHookSeasonUi()

    local currentSeason, timeProgressed, seasonLength = Messages:requestServer("GetSeason")
    lastSeasonChange = tick()
    nextSeasonChange = tick() + (seasonLength - timeProgressed)
    lastSeasonLength = seasonLength
    lastCurrentSeason = currentSeason
    SacrificeUiInstance.ContainerRealBack.SeasonIcon.Image = seasonColors[lastCurrentSeason].icon
    SacrificeUiInstance.ContainerRealBack.ImageColor3 = seasonColors[lastCurrentSeason].fg

    Messages:hook("SeasonSetTo",function(seasonIndex, seasonLength)
        lastSeasonChange = tick()
        nextSeasonChange = tick() + (seasonLength)
        lastSeasonLength = seasonLength
        lastCurrentSeason = seasonIndex
        local goals = {
            ImageColor3 = seasonColors[currentSeason].fg
        }
        local info = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(SacrificeUiInstance.ContainerRealBack, info, goals)
        tween:Play()
        SacrificeUiInstance.ContainerRealBack.SeasonIcon.Image = seasonColors[lastCurrentSeason].icon
    end)
end

local function step()

    local timeRemaining = nextSeasonChange - tick()
    local alpha = 1 - (timeRemaining/lastSeasonLength)

    Messages:send("SetRadialProgressButtonAmount", SacrificeUiInstance.ContainerRealBack.SeasonProgress, alpha, seasonColors[lastCurrentSeason].bg, seasonColors[lastCurrentSeason].fg)

end

local SacrificeUi = {}

function SacrificeUi:start(playerGui)
    Messages:hook("UpdateSacrificePercent",updateSacrificePercent)
    SacrificeUiInstance:WaitForChild("ContainerRealBack")
    initializeAndHookSeasonUi()
    RunService.RenderStepped:connect(step)
end

return SacrificeUi