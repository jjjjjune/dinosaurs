local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local Constants = import "Shared/Data/DataConstants"

local function getDefaultData()
    local data = {}
    for key, value in pairs(Constants.DEFAULT_DATA) do
        data[key] = value
    end
    return data
end

_G.Data = getDefaultData()

Messages:hook("PlayerDataSet", function(data)
    _G.Data = data
end)

Messages:sendServer("DataReadySignal")
