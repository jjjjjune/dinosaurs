local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local SERVER_DATA_STORE = "ServerDataStore"

local DataStoreService = game:GetService("DataStoreService")

local function getServerId()
    return "TestServer31"
end

local ServerData = {}

function ServerData:setValue(key, value)
    self.cache[key] = value
end

function ServerData:getValue(key, value)
    return self.cache[key]
end

function ServerData:start()
    self.dataStore = DataStoreService:GetGlobalDataStore(SERVER_DATA_STORE)
    self.cache = self.dataStore:GetAsync(getServerId()) or {}
    spawn(function()
        while wait(30) do
            print("server data save")
            self.dataStore:SetAsync(getServerId(), self.cache)
            print("done")
        end
    end)
end

return ServerData