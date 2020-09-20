local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local ServerData = import "Server/Systems/ServerData"
local CastRay = import "Shared/Utils/CastRay"

local SaveableObjectManager = import "Server/Systems/SaveableObjectManager"

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local ITEM_DESPAWN_TIME = 300 -- five mins
local ITEM_FREEZE_TIME = 2

local lastPositions = {}
local lastMoved = {}
local lastInteractedOrInStorageTimer = {}
local lastStorageCheck = tick()

local function onItemAdded(item)
    lastInteractedOrInStorageTimer[item] = tick()
end

local function isInStorage(item)
	for _, storageInstance in pairs(CollectionService:GetTagged("Storage")) do
		local origin = storageInstance.PrimaryPart.Position
		local base = storageInstance.PrimaryPart
		local range = base.Size.X + 2
		local vec1 = (origin + Vector3.new(-range,-(range*2),-range))
		local vec2 = (origin + Vector3.new(range,(range*2),range))
		local region = Region3.new(vec1, vec2)
		local parts = workspace:FindPartsInRegion3(region,nil, 10000)
		for _, part in pairs(parts) do
			if part.Parent == item then
				return true
			end
		end
	end
	if item:FindFirstChild("ObjectWeld") then -- items with object welds are regarded as in storage
		return true
	end
	return false
end

local function checkStorage()
    for item, t in pairs(lastInteractedOrInStorageTimer) do
        if item.Parent ~= nil then
            if isInStorage(item) or item.Parent:FindFirstChild("Humanoid") then
                lastInteractedOrInStorageTimer[item] = tick()
            end
        end
    end
end

local function checkFreezeWeld(item, position)
	local ConstraintManager = import "Server/Systems/ConstraintManager"
	if not item:FindFirstChild("FreezeWeld") and not item:FindFirstChild("GameRope") and not CollectionService:HasTag(item, "Building") and not ConstraintManager.hasAnyRopesAttached(item) then
		local hit, pos = CastRay(position, Vector3.new(0,-5,0), {item})
		if hit and hit.Anchored then
			local ConstraintManager = import "Server/Systems/ConstraintManager"
			ConstraintManager.freezeWeld(item, hit)
			for _, v in pairs(item:GetChildren()) do
				if v:IsA("BasePart") then
					v.Anchored = true
					v.CanCollide = false
				end
			end
		end
	end
end

local function checkMoved(item)
	local position = item.PrimaryPart.Position
	if not lastMoved[item] then
		lastMoved[item] = tick()
	end
    if not lastPositions[item] then
        lastPositions[item] = position
    else
        local dist = (position - lastPositions[item]).magnitude
		if dist > 2 then
			lastMoved[item] = tick()
            lastInteractedOrInStorageTimer[item] = tick()
            lastPositions[item] = position
		else
			if lastMoved[item] and tick() - lastMoved[item] > ITEM_FREEZE_TIME then
				checkFreezeWeld(item, position)
			end
        end
    end
end

local function checkDespawn()
    for item, t in pairs(lastInteractedOrInStorageTimer) do
        if item.Parent ~= nil and (item.PrimaryPart) then
            if tick() - t > ITEM_DESPAWN_TIME and (not CollectionService:HasTag(item, "Building")) then
                if item:IsDescendantOf(workspace) then
                    item:Destroy()
                else
                    lastInteractedOrInStorageTimer[item] = tick()
                end
                lastInteractedOrInStorageTimer[item] = nil
			else
				checkMoved(item)
            end
        else
            lastInteractedOrInStorageTimer[item] = nil
        end
    end
end

local function backupItems()
	SaveableObjectManager.saveTag("Item")
end

local function step()
    if tick() - lastStorageCheck > 1 then
        lastStorageCheck = tick()
        checkStorage()
        checkDespawn()
    end
    backupItems()
end

local Storage = {}

function Storage:start()
    CollectionService:GetInstanceAddedSignal("Item"):connect(onItemAdded)
	for _, item in pairs(CollectionService:GetTagged("Item")) do
		if item:IsDescendantOf(workspace) then
			onItemAdded(item)
		end
    end
    Messages:hook("OnItemThrown", function(item)
        lastInteractedOrInStorageTimer[item] = tick()
    end)
	CollectionService:GetInstanceAddedSignal("Item"):connect(function(item)
		if item:IsDescendantOf(workspace) then
			ServerData:generateIdForInstanceOfType(item, "I")
		end
	end)
	for _, item in pairs(CollectionService:GetTagged("Item")) do
		if item:IsDescendantOf(workspace) then
			ServerData:generateIdForInstanceOfType(item, "I")
		end
	end
	Messages:hook("FirstMapRenderComplete", function()
		RunService.Stepped:connect(function()
			step()
		end)
	end)
end

return Storage
