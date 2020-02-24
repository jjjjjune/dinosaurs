local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"

local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")

local GetCharacter = import "Shared/Utils/GetCharacter"

local Carrying = {}

function Carrying:start()
    Messages:hook("SetCarryingObject", function(object)

    end)
    Messages:hook("CarryAction", function()
        
    end)
end

return Carrying