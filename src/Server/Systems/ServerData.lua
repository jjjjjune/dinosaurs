local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local SERVER_DATA_STORE = "ServerDataStore"

local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

local IS_SAVING_IN_STUDIO = false

local function getServerId()
    return "TestServer49"
end

local ServerData = {}

function ServerData:setValue(key, value)
    self.cache[key] = value
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
    self.cache = self.dataStore:GetAsync(getServerId()) or {}
    spawn(function()
        while wait(60) do
            self:saveCache()
        end
    end)
    game:BindToClose(function() self:saveCache() end)
end

return ServerData