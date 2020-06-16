local import = require(game.ReplicatedStorage.Shared.Import)

local Cmdr = require(game.ReplicatedStorage:WaitForChild("CmdrClient"))

local CmdrClient = {}

function CmdrClient:start()
    Cmdr:SetActivationKeys({Enum.KeyCode.Semicolon})
end

return CmdrClient