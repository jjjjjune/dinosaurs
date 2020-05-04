local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local StatsUi = {}

function StatsUi:start(playerGui)
    local statsUi = playerGui:WaitForChild("Stats")
    local statsHolder = statsUi:WaitForChild("StatsHolder")

    --SacrificeUiInstance.ContainerRealBack.Background.Holder.Progress:TweenPosition(UDim2.new((1-newPercent)*-1,0,0,0), "Out", "Quad", .3)
    Messages:hook("UpdateStatUi", function(statName, statValue, statMax)
        for _, v in pairs(statsHolder:GetChildren()) do
            if string.lower(v.Name) == string.lower(statName) then

                local statFrame = v
                local newPercent = statValue/statMax

                statFrame.Holder.Progress:TweenPosition(UDim2.new(-(1-newPercent),0,0,0), "Out", "Quad", .3)
                statFrame.Holder.Progress.FG:TweenPosition(UDim2.new((1-newPercent),0,0,0), "Out", "Quad", .3)
                statFrame.Holder.AmountLabel.Text = round(statValue, 0)..""
            end
        end
    end)

    local statFrame = statsHolder["Health"]
    local newPercent = 1

    statFrame.Holder.Progress:TweenPosition(UDim2.new(-(1-newPercent),0,0,0), "Out", "Quad", .3)
    statFrame.Holder.Progress.FG:TweenPosition(UDim2.new((1-newPercent),0,0,0), "Out", "Quad", .3)
    statFrame.Holder.AmountLabel.Text = "100"
end

return StatsUi