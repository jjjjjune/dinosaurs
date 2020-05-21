local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local ClientInit = {}

function ClientInit:start()
    Messages:sendServer("ReplicationReady")
    local StarterGui = game:GetService("StarterGui")
    StarterGui:SetCore("TopbarEnabled", false)
    game.StarterGui:SetCoreGuiEnabled("PlayerList",false)
end

return ClientInit