local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local function storeTool(itemInstance)
    itemInstance.Parent = game.Lighting
    Messages:send("PlayAnimationClient", "Store")
    Messages:send("PlaySoundOnClient",{
        instance = game.ReplicatedStorage.Sounds.Store,
        part = game.Players.LocalPlayer.Character.Head
    })
    Messages:sendServer("StoreTool", itemInstance)
end

local ToolStorage = {}

function ToolStorage:start()
    Messages:hook("StoreTool", storeTool)
end

return ToolStorage