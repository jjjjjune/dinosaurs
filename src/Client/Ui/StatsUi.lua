local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local StatsUi = {}

function StatsUi:start(playerGui)
    Messages:hook("UpdateStatUi", function(statName, statValue, statMax)
        local MainImage = playerGui:WaitForChild("StatusBar"):WaitForChild("MainImage")
        for _, v in pairs(MainImage:GetChildren()) do
            if string.lower(v.Name) == string.lower(statName) then
                local progress = statValue/statMax
                Messages:send("SetRadialProgressButtonAmount", v, progress)
            end
        end
    end)
    local MainImage = playerGui:WaitForChild("StatusBar"):WaitForChild("MainImage")
    for _, v in pairs(MainImage:GetChildren()) do
        if v:FindFirstChild("N0") then
            local progress = 1
            Messages:send("SetRadialProgressButtonAmount", v, progress)
        end
    end
end

return StatsUi