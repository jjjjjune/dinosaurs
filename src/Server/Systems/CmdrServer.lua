-- This is a script you would create in ServerScriptService, for example.
local import = require(game.ReplicatedStorage.Shared.Import)
local Cmdr = import "Lib/Cmdr"

local CmdrServer = {}

function CmdrServer:start()
    Cmdr:RegisterDefaultCommands()
    Cmdr:RegisterCommandsIn(import "Shared/CmdrCommands")
end

return CmdrServer