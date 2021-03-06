local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Constants = import "Shared/Data/DataConstants"

local SERVER_DATA_STORE = "ServerDataStore"

local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

local Immutable = import "Immutable"

local IS_SAVING_IN_STUDIO = false

local keysToReplicateToClients = {
	["permissions"] = true,
	["ranks"] = true,
}

local function getServerId()
    return "TestServer150"
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

function ServerData:generateIdForInstanceOfType(instance, type)
	if instance:FindFirstChild("ID") then
		return
	else
		local idValue = Instance.new("StringValue", instance)
		idValue.Name = "ID"
	end
	local valueString = type
	if not self:getValue("ID"..type) then
		self:setValue("ID"..type, 0)
	end
	local n = self:getValue("ID"..type)
	valueString = valueString..n+1
	self:setValue("ID"..type, n+1)
	instance.ID.Value = valueString
end


function ServerData:updated(key, value)
	if keysToReplicateToClients[key] then
		Messages:sendAllClients("UpdateReplicatedServerData", key, value)
	end
end

function ServerData:updatedPlayers()
    for _, player in pairs(game.Players:GetPlayers()) do
		Messages:sendClient(player, "UpdatePlayerServerData", self.cache.players[tostring(player.UserId)])
		for key, value in pairs(self.cache) do
			if keysToReplicateToClients[key] then
				Messages:sendClient(player, "UpdateReplicatedServerData", key, value)
			end
		end
    end
end

function ServerData:updatedPlayer(player)
	Messages:sendClient(player, "UpdatePlayerServerData", self.cache.players[tostring(player.UserId)])
	for key, value in pairs(self.cache) do
		if keysToReplicateToClients[key] then
			Messages:sendClient(player, "UpdateReplicatedServerData", key, value)
		end
	end
end

function ServerData:setPlayerValue(player, key, value)
    self.cache.players[tostring(player.UserId)][key] = value
    self:updatedPlayers()
end

function ServerData:getPlayerValue(player, key)
    return self.cache.players[tostring(player.UserId)][key]
end

function ServerData:setValue(key, value)
    self.cache[key] = value
    self:updated(key, value)
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
		if not self.cache.players[tostring(player.UserId)] then
            self.cache.players[tostring(player.UserId)] = getDefaultPlayerData()
		end
		self:updatedPlayer(player)
    end)
    for _, player in pairs(game.Players:GetPlayers()) do
		if not self.cache.players[tostring(player.UserId)] then
            self.cache.players[tostring(player.UserId)] = getDefaultPlayerData()
		end
		self:updatedPlayer(player)
    end
end

return ServerData
