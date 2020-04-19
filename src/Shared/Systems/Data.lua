local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local Immutable = import "Immutable"
local Constants = import "Shared/Data/DataConstants"
local dataStoreService = game:GetService("DataStoreService")
local IsStudio = game:GetService("RunService"):IsStudio()

local FastSpawn = import "Shared/Utils/FastSpawn"

local doNotSave = {}

local function getServerType()
	if game.PrivateServerId ~= "" then
		if game.PrivateServerOwnerId ~= 0 then
			return "VIPServer"
		else
			return "ReservedServer"
		end
	else
		return "StandardServer"
	end
end

local SAVE_TIME = 30

local data = {}
local dataReady = {}

local function copy(value)
	if type(value) == "table" then
		return Immutable.deepCopy(value)
	else
		return value
	end
end

local function getDefaultData()
    local defaultData = {}
    for key, value in pairs(Constants.DEFAULT_DATA) do
        defaultData[key] = copy(value)
	end
	if game:GetService("RunService"):IsStudio() or game.PlaceId == 3725285976 or game.PlaceId == 3725292176 then
		for key, value in pairs(Constants.TEST_DATA) do
			defaultData[key] = copy(value)
		end
	end
    return defaultData
end

local yieldCache = {}


local function yieldUntilDataReady(player)
    --[[if dataReady[player.UserId] then
        return
	end
	yieldCache[player.UserId] = tick()
	repeat wait()
		if tick() - yieldCache[player.UserId] > 10 then warn ("yield cache going for: "..(tick() - yieldCache[player.UserId]).."seconds")
			 return
		end
	until
		(dataReady[player.UserId] ~= nil) or player == nil or player.Parent == nil--]]
end

function data:onDataChanged(player)
	yieldUntilDataReady(player)
	if player == nil or player.Parent == nil then
		return
	end
	Messages:sendClient(player, "PlayerDataSet", self.cache[player.UserId])
	Messages:send("PlayerDataSet", player, self.cache[player.UserId])
end

function data:get(player,key)
	if not player then return nil end
	yieldUntilDataReady(player)
	if player == nil or player.Parent == nil then
		return nil
	end
	if not self.cache[player.UserId] then
		warn("get user not in cache: ", player.UserId)
		return nil
	end
    return self.cache[player.UserId][key]
end

function data:set(player, key, value)
	yieldUntilDataReady(player)
	if player == nil or player.Parent == nil then
		return
	end
	if not self.cache[player.UserId] then
		warn(" setnot in cache", player.UserId)
		return
	end
    self.cache[player.UserId][key] = value
    self:onDataChanged(player)
end

function data:add(player, key, value)
	yieldUntilDataReady(player)
	if player.Parent == nil then
		return
	end
	local data = self.cache[player.UserId]
	if not data[key] then
		data[key] = 0
	end
    data[key] = data[key] + value
    self:onDataChanged(player)
end

function data:loadIntoCache(player)
	local data = getDefaultData()
	local loadedData
	local iterations = 0
	local status, err

	repeat
		-- try loading someone's data multiple times in case there is an error
		status, err = pcall(function()
			loadedData = self.dataStore:GetAsync(player.UserId)
			--error("test error")
		end)
		if err then
			wait(1)
		end
		iterations = iterations + 1
	until
		loadedData or (not err) or (iterations > 5)

	if err or iterations > 5 then
		-- data did not load properly within the 5 tries, the player's data will not save this session
		warn("data did not load, will not save")
		Messages:sendClient(player, "Notify", "There was an error loading your data! Nothing you do will be saved this session.", "ERROR", "NOENTRY")
		doNotSave[player.UserId] = true
	else
		doNotSave[player.UserId] = false
	end

    if loadedData then
        for key, value in pairs(loadedData) do
            data[key] = value
        end
    end
    self.cache[player.UserId] = data
    self:onDataChanged(player)
end

function data:save(player, callback)
	if doNotSave[player.UserId] then
		warn("can not save data for: ", player)
		--Messages:sendClient(player, "Notify", "There was an error loading your data! Nothing you do will be saved this session.", "ERROR", "NOENTRY")
		return false
	end
	local data = self.cache[player.UserId]
	local _, err
	if data then
		_, err = pcall(function()
			self.dataStore:SetAsync(player.UserId, data)
			if callback then
				callback(self)
			end
		end)
	else
		warn("no data to save", player)
		if callback then
			callback(self)
		end
		return false
	end
	if not err then
		return true
	else
		warn("error while saving data: ", err)
		return false
	end
end

function data:forceSave(player)
	return self:save(player)
end

function data:saveCache()
    for id, data in pairs(self.cache) do -- stagger these calls so they are less likely to throttle
        wait(1)
		local player = game.Players:GetPlayerByUserId(id)
		if player then
			self:save(player)
		end
    end
end

function data:clearFromCache(player)
	self.cache[player.UserId] = nil
	doNotSave[player.UserId] = nil
	dataReady[player.UserId] = nil
end

function data:isReady(player)
	return dataReady[player.UserId]
end

local lastSave = time()

function data:start()
    self.cache = {}
    local dataStore = Constants.TEST_STORE
    if game.PlaceId == 3725149043 and not game:GetService("RunService"):IsStudio() then
        dataStore = Constants.PRODUCTION_STORE
	end
	if game.PlaceId == 3725285976 then
		dataStore = Constants.TEST_STORE
	end

    self.dataStore = dataStoreService:GetDataStore(dataStore)

    if self.initialized then
        return
    else
        self.initialized = true
    end

	game.Players.PlayerAdded:connect(function(player)
		doNotSave[player.UserId] = true
		self.cache[player.UserId] = getDefaultData()
		self:loadIntoCache(player)
		Messages:send("PlayerAddedAfterData", player)
    end)

	game.Players.PlayerRemoving:connect(function(player)
		self:save(player, function(self)
			self:clearFromCache(player)
		end)
	end)

	game:GetService("RunService").Stepped:connect(function()
		if time() - lastSave > SAVE_TIME then
			lastSave = time()
			FastSpawn(function() self:saveCache() end) -- savecache is asynchronous
		end
	end)

	Messages:hook("DataReadySignal", function(player)
		--print("WE GOT DATA READY SIGNAL FOR ", player)
		self:onDataChanged(player)
		warn("i made data changes last night that do this, data no longer yields until someone is ready to receive msgs, but rather works normally and then replicates it to them if they send data ready")
        dataReady[player.UserId] = true
	end)

	if not IsStudio then
		game:BindToClose(function() self:saveCache() end)
	end --because of the cool bug that makes shutdowns take 30s
end

return data
