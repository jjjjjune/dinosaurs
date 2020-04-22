local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Constants = import "Shared/Data/DataConstants"

local SERVER_DATA_STORE = "ServerDataStore"

local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

local Immutable = import "Immutable"

local IS_SAVING_IN_STUDIO = false

local function getServerId()
    return "TestServer49"
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


local ServerData = {}

function ServerData:updated()
    --[[local Data = import "Shared/Systems/Data"
    for _, player in pairs(game.Players:GetPlayers()) do
        Data:set(player, "server", self.cache)
    end--]] 
    -- not a good way to do this
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
            warn(" WE ARE NOT SAVCING DATA IN STGUDIO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
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
end

return ServerData