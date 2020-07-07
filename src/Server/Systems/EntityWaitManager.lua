local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"

local CollectionService = game:GetService("CollectionService")

local entitiesBeingWaitedOn = {}
local activeEntities = {}

local function updateQueue()
	for id, callbacks in pairs(entitiesBeingWaitedOn) do
		if activeEntities[id] then
			for _, callback in pairs(callbacks) do
				callback(activeEntities[id])
			end
			entitiesBeingWaitedOn[id] = nil
		end
	end
end

local function onEntityAdded(entity)
	if not entity:IsDescendantOf(game.Workspace) then
		return
	end
	wait()
	if entity:FindFirstChild("ID") then
		activeEntities[entity.ID.Value] = entity
	end
	updateQueue()
end

local function waitForEntityWithID(id, callback)
	if not entitiesBeingWaitedOn[id] then
		entitiesBeingWaitedOn[id] = {}
	end
	print("waiting on", id)
	table.insert(entitiesBeingWaitedOn[id], callback)
	updateQueue()
end

local EntityWaitManager = {}

function EntityWaitManager:start()
	Messages:hook("WaitForEntityWithID", function(id, callback)
		print("MSG CALLED", id, callback)
		waitForEntityWithID(id, callback)
	end)
	print("hooked")
	CollectionService:GetInstanceAddedSignal("Item"):connect(function(entity)
		onEntityAdded(entity)
	end)
	CollectionService:GetInstanceAddedSignal("Monster"):connect(function(entity)
		onEntityAdded(entity)
	end)
	CollectionService:GetInstanceAddedSignal("Building"):connect(function(entity)
		onEntityAdded(entity)
	end)
	for _, entity in pairs(CollectionService:GetTagged("Item")) do
		onEntityAdded(entity)
	end
	for _, entity in pairs(CollectionService:GetTagged("Monster")) do
		onEntityAdded(entity)
	end
	for _, entity in pairs(CollectionService:GetTagged("Building")) do
		onEntityAdded(entity)
	end
end

return EntityWaitManager
