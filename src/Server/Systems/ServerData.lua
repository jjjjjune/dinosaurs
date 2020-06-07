local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Constants = import "Shared/Data/DataConstants"

local SERVER_DATA_STORE = "ServerDataStore"

local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

local Immutable = import "Immutable"

local IS_SAVING_IN_STUDIO = false

local function getServerId()
    return "TestServer70"
end

local function copy(value)
	if type(value) == "table" then
		return Immutable.deepCopy(value)
	else
		return value
	end
end

local function getDefaultData()
    local defaultData = {}
    for key, value in pairs(Constants.DEFAULT_SERVER_DATA) do
        defaultData[key] = copy(value)
	end
	if game:GetService("RunService"):IsStudio() or game.PlaceId == 3725285976 or game.PlaceId == 3725292176 then
		for key, value in pairs(Constants.TEST_SERVER_DATA) do
			defaultData[key] = copy(value)
		end
	end
    return defaultData
end

local function getDefaultPlayerData()
    local defaultData = {}
    for key, value in pairs(Constants.DEFAULT_SERVER_PLAYER_DATA) do
        defaultData[key] = copy(value)
	end
	if game:GetService("RunService"):IsStudio() or game.PlaceId == 3725285976 or game.PlaceId == 3725292176 then
		for key, value in pairs(Constants.TEST_SERVER_PLAYER_DATA) do
			defaultData[key] = copy(value)
		end
	end
    return defaultData
end


local ServerData = {}

function ServerData:updated()

end

function ServerData:updatedPlayers()
    for _, player in pairs(game.Players:GetPlayers()) do
        Messages:sendClient(player, "UpdatePlayerServerData", self.cache.players[player.UserId])
    end
end

function ServerData:setPlayerValue(player, key, value)
    self.cache.players[player.UserId][key] = value
    self:updatedPlayers()
end

function ServerData:getPlayerValue(player, key)
    return self.cache.players[player.UserId][key]
end

function ServerData:setValue(key, value)
    self.cache[key] = value
    self:updated()
end

function ServerData:getValue(key, value)
    return self.cache[key]
end

function ServerData:saveCache()
    if RunService:IsStudio() then
        if IS_SAVING_IN_STUDIO == false then
            warn("no data save in studio")
            return
        end
    end
    self.dataStore:SetAsync(getServerId(), self.cache)
end

function ServerData:start()
    self.dataStore = DataStoreService:GetGlobalDataStore(SERVER_DATA_STORE)
    self.cache = self.dataStore:GetAsync(getServerId()) or getDefaultData()
    spawn(function()
        while wait(60) do
            self:saveCache()
        end
    end)
    game:BindToClose(function() self:saveCache() end)
    game:GetService("Players").PlayerAdded:connect(function(player)
        if not self.cache.players[player.UserId] then
            self.cache.players[player.UserId] = getDefaultPlayerData()
        end
    end)
    for _, player in pairs(game.Players:GetPlayers()) do
        if not self.cache.players[player.UserId] then
            self.cache.players[player.UserId] = getDefaultPlayerData()
        end
    end
end

return ServerData