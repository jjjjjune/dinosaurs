local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local ServerData = import "Server/Systems/ServerData"
local CastRay = import "Shared/Utils/CastRay"

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local ITEM_DESPAWN_TIME = 300 -- five mins
local ITEM_FREEZE_TIME = 5

local lastPositions = {}
local lastInteractedOrInStorageTimer = {}
local lastStorageCheck = tick()

local function onItemAdded(item)
    lastInteractedOrInStorageTimer[item] = tick()
end

local function round(n, mult)
    mult = mult or 1
    return math.floor((n + mult/2)/mult) * mult
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
	if item.PrimaryPart and item.PrimaryPart.Anchored == false then
		for _, v in pairs(item.Base:GetConnectedParts()) do -- if an item is connected to an animal or player, it will no longer despawn
			if v.Parent ~= item then
				return true
			end
		end
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

local function checkMoved(item)
    if item:FindFirstChild("VehicleWeld") then -- already welded to something we should let it BE
        lastInteractedOrInStorageTimer[item] = tick()
        return
    end
    local position = item.PrimaryPart.Position
    if not lastPositions[item] then
        lastPositions[item] = position
    else
        local dist = (position - lastPositions[item]).magnitude
        if dist > .5 then
            lastInteractedOrInStorageTimer[item] = tick()
            lastPositions[item] = position
        else
            if tick() - lastInteractedOrInStorageTimer[item] > ITEM_FREEZE_TIME then
                if not item:FindFirstChild("FreezeWeld") then 
                    local hit, pos = CastRay(position, Vector3.new(0,-5,0), {item})
                    if hit and hit.Anchored then
                        local freezeWeld = Instance.new("WeldConstraint", item)
                        freezeWeld.Part0 = item.PrimaryPart
                        freezeWeld.Part1 = hit
                        freezeWeld.Name = "FreezeWeld"
                    end
                end
            end
        end
    end
end

local function checkDespawn()
    for item, t in pairs(lastInteractedOrInStorageTimer) do
        if item.Parent ~= nil then
            if tick() - t > ITEM_DESPAWN_TIME then
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
    local items = {}
    for _, item in pairs(CollectionService:GetTagged("Item")) do
        if not item:IsDescendantOf(game.ReplicatedStorage) then
            local pos = item.PrimaryPart.Position
            local info = {}
            info.name = item.Name
            info.position = {x = round(pos.X, .15), y = round(pos.Y, .15), z = round(pos.Z, .15)}
            table.insert(items, info)
        end
    end
    ServerData:setValue("items", items)
end

local function step()
    if tick() - lastStorageCheck > 1 then
        lastStorageCheck = tick()
        checkStorage()
        checkDespawn()
    end
    backupItems()
end

local function loadSerializedItems()
    local items = ServerData:getValue("items")
    if items then
        for _, item in pairs(items) do
            local pos = Vector3.new(item.position.x, item.position.y, item.position.z)
            Messages:send("CreateItem", item.name, pos)
        end
    end
    RunService.Stepped:connect(function()
        step()
    end)
end



local Storage = {}

function Storage:start()
    CollectionService:GetInstanceAddedSignal("Item"):connect(onItemAdded)
    for _, item in pairs(CollectionService:GetTagged("Item")) do
        onItemAdded(item)
    end
    Messages:hook("OnItemThrown", function(item)
        lastInteractedOrInStorageTimer[item] = tick()
    end)
    loadSerializedItems()
end

return Storage