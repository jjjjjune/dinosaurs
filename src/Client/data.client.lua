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

local function getDefaultPlayerServerData()
    local defaultData = {}
    for key, value in pairs(Constants.DEFAULT_SERVER_PLAYER_DATA) do
        defaultData[key] = value
	end
	if game:GetService("RunService"):IsStudio() or game.PlaceId == 3725285976 or game.PlaceId == 3725292176 then
		for key, value in pairs(Constants.TEST_SERVER_PLAYER_DATA) do
			defaultData[key] = value
		end
	end
    return defaultData
end

local function getDefaultServerData()
	local defaultData = {}
    for key, value in pairs(Constants.DEFAULT_SERVER_DATA) do
        defaultData[key] = value
	end
	if game:GetService("RunService"):IsStudio() or game.PlaceId == 3725285976 or game.PlaceId == 3725292176 then
		for key, value in pairs(Constants.TEST_SERVER_DATA) do
			defaultData[key] = value
		end
	end
    return defaultData
end


_G.Data = getDefaultData()
_G.Data.server = getDefaultPlayerServerData()
_G.replicatedServerData = getDefaultServerData()

Messages:hook("PlayerDataSet", function(data)
    local serverData = {}
    if _G.Data.server then
        serverData = _G.Data.server
    end
    _G.Data = data
    _G.Data.server = serverData
end)

Messages:hook("UpdateReplicatedServerData", function (key, value)
	print("recieved some replicated server data", key, value)
	_G.replicatedServerData[key] = value
end)

Messages:hook("UpdatePlayerServerData", function(playerServerData)
    _G.Data.server = playerServerData
    Messages:send("PlayerDataSet", _G.Data)
end)

Messages:sendServer("DataReadySignal")

local mod = {}

return mod
