local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local RunService = game:GetService("RunService")

local STATS = {
    {name = "hunger", max = 10, decayRate = 90, decayAmount = -1},
    {name = "thirst", max = 10, decayRate = 90, decayAmount = -1},
}

local playerStats = {}

local function statStep()
    for _, player in pairs(game.Players:GetPlayers()) do
        local stats = playerStats[player]
        if stats then
            for _, stat in pairs(stats) do
                if tick() - stat.lastTick > stat.decayRate then
                    stat.current = math.max(0, stat.current + stat.decayAmount)
                    stat.lastTick = tick()
                    Messages:sendClient(player, "OnStatUpdated", stat.name, stat.current, stat.max)
                end
                if stat.current == 0 then
                    local hum = player.Character and player.Character:FindFirstChild("Humanoid")
                    hum.Health = hum.Health - .025
                end
            end
        end
    end
end

local function getDefaultStatValues()
    local values = {}
    for i, stat in pairs(STATS) do
        local newStatValue = {}
        newStatValue.name = stat.name
        newStatValue.current = stat.max
        newStatValue.statIndex = i
        newStatValue.lastTick = tick()
        newStatValue.decayRate = stat.decayRate
        newStatValue.decayAmount = stat.decayAmount
        newStatValue.max = stat.max
        table.insert(values, newStatValue)
    end
    return values
end

local function updateStatsForPlayer(player)
    for _, stat in pairs(playerStats[player]) do
        Messages:sendClient(player, "OnStatUpdated", stat.name, stat.current, stat.max)
    end
end

local function resetAllStats(player)
    playerStats[player] = getDefaultStatValues()
    updateStatsForPlayer(player)
end

local Stats = {}

function Stats.getStat(player, statName)
    local stat
    for _, v in pairs(playerStats[player]) do
        if v.name == statName then
            stat = v
        end
    end
    return stat
end

function Stats:start()
    Messages:hook("AddStat", function(player, statName, statValue)
        for _, stat in pairs(playerStats[player]) do
            if stat.name == statName then
                stat.current = math.min(stat.max, stat.current + 1)
            end
        end
        updateStatsForPlayer(player)
    end)
    Messages:hook("AddStatMax", function(player, statName, statValue)
        for _, stat in pairs(playerStats[player]) do
            if stat.name == statName then
                stat.max = stat.max + 1
            end
        end
        updateStatsForPlayer(player)
    end)
    Messages:hook("PlayerAdded", function(player)
        playerStats[player] = getDefaultStatValues()
    end)
    Messages:hook("CharacterAdded", function(player, character)
        resetAllStats(player)
    end)
    RunService.Stepped:connect(function()
        statStep()
    end)
end

return Stats
