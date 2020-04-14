local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local StatsUi = {}

function StatsUi:start(playerGui)
    local statsUi = playerGui:WaitForChild("Stats")
    local statsHolder = statsUi:WaitForChild("StatsHolder")
    Messages:hook("UpdateStatUi", function(statName, statValue, statMax)
        for _, v in pairs(statsHolder:GetChildren()) do
            if string.lower(v.Name) == string.lower(statName) then
        
                local statFrame = v
                local newPercent = statValue/statMax

                statFrame.Holder.Progress:TweenPosition(UDim2.new((1-newPercent)*-1,0,0,0), "Out", "Quad", .3)
                statFrame.Holder.Progress.FG:TweenPosition(UDim2.new((newPercent),0,1,0), "Out", "Quad", .3)
                statFrame.Holder.AmountLabel.Text = statValue..""
            end
        end
    end)

    local statFrame = statsHolder["Health"]
    local newPercent = 1

    statFrame.Holder.Progress:TweenPosition(UDim2.new((1-newPercent)*-1,0,0,0), "Out", "Quad", .3)
    statFrame.Holder.Progress.FG:TweenPosition(UDim2.new((newPercent),0,1,0), "Out", "Quad", .3)
    statFrame.Holder.AmountLabel.Text = "100"
end

return StatsUi