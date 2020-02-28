local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local FastSpawn = import "Shared/Utils/FastSpawn"

local PlayerGui

local stats = {}

local function onStatUpdated(statName, statValue, statMax)
    stats[statName] = statValue
    if statMax then
        stats[statName.."max"] = statMax
    end
    Messages:send("UpdateStatUi", statName, statValue, stats[statName.."max"] or statValue)
end

local StatsClient = {}

function StatsClient:start()
    onStatUpdated("health", 100)
    onStatUpdated("healthmax", 100)
    Messages:hook("OnStatUpdated", function(statName, statValue, statMax)
        onStatUpdated(statName, statValue, statMax)
    end)
    Messages:hook("CharacterAddedClient", function(character)
        local humanoid = character:WaitForChild("Humanoid")
        onStatUpdated("healthmax", humanoid.MaxHealth)
        onStatUpdated("health", humanoid.Health)
        onStatUpdated("hungermax", 10)
        onStatUpdated("hunger", 10)
        onStatUpdated("thirstmax", 10)
        onStatUpdated("thirst", 10)
        local signal = humanoid:GetPropertyChangedSignal("Health")
        signal:connect(function()
            onStatUpdated("health", humanoid.Health)
        end)
    end)
    if game.Players.LocalPlayer.Character then
        Messages:send("CharacterAddedClient", game.Players.LocalPlayer.Character)
    end
end

return StatsClient