local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local SacrificeUiInstance = game.Players.LocalPlayer.PlayerGui:WaitForChild("SacrificeProgress")

local function updateSacrificePercent(newPercent)
    newPercent = math.min(.97, newPercent)
    SacrificeUiInstance.Background.Progress:TweenPosition(UDim2.new((1-newPercent)*-1,0,0,0), "Out", "Quad", .3)
    SacrificeUiInstance.Background.Progress.FG:TweenPosition(UDim2.new((1+newPercent),0,1,0), "Out", "Quad", .3)
end

local SacrificeUi = {}

function SacrificeUi:start(playerGui)
    Messages:hook("UpdateSacrificePercent",updateSacrificePercent)
end

return SacrificeUi