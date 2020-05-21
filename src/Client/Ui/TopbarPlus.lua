local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local TopbarPlus = {}

function TopbarPlus:start()
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local topbarPlus = replicatedStorage:WaitForChild("HDAdmin"):WaitForChild("Topbar+")
    local iconController = require(topbarPlus.IconController)
end

return TopbarPlus