local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local SacrificeUiInstance = game.Players.LocalPlayer.PlayerGui:WaitForChild("SacrificeProgress")

local function updateSacrificePercent(newPercent)
    newPercent = math.min(.97, newPercent)
    SacrificeUiInstance.Container.Progress:TweenSize(UDim2.new(newPercent,0,.8,0), "Out", "Quad", .3)
end

local SacrificeUi = {}

function SacrificeUi:start(playerGui)
    Messages:hook("UpdateSacrificePercent",updateSacrificePercent)
end

return SacrificeUi