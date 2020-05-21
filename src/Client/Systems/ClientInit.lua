local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local ClientInit = {}

function ClientInit:start()
    Messages:sendServer("ReplicationReady")
    game.StarterGui:SetCoreGuiEnabled("PlayerList",false)
end

return ClientInit