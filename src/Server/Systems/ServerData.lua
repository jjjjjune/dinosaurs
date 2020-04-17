local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local SERVER_DATA_STORE = "ServerDataStore"

local DataStoreService = game:GetService("DataStoreService")

local function getServerId()
    return "TestServer47"
end

local ServerData = {}

function ServerData:setValue(key, value)
    self.cache[key] = value
end

function ServerData:getValue(key, value)
    return self.cache[key]
end

function ServerData:saveCache()
    self.dataStore:SetAsync(getServerId(), self.cache)
end

function ServerData:start()
    self.dataStore = DataStoreService:GetGlobalDataStore(SERVER_DATA_STORE)
    self.cache = self.dataStore:GetAsync(getServerId()) or {}
    spawn(function()
        while wait(60) do
            self:saveCache()
        end
    end)
    game:BindToClose(function() self:saveCache() end)
end

return ServerData