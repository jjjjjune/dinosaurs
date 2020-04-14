local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local ServerData = import "Server/Systems/ServerData"

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local ITEM_DESPAWN_TIME = 10

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

local function checkDespawn()
    for item, t in pairs(lastInteractedOrInStorageTimer) do
        if item.Parent ~= nil then
            if tick() - t > ITEM_DESPAWN_TIME then
                if item:IsDescendantOf(workspace) then
                    item:Destroy()
                end
                lastInteractedOrInStorageTimer[item] = nil
            end
        else
            lastInteractedOrInStorageTimer[item] = nil
        end
    end
end

local function backupItems()
    local items = {}
    for _, item in pairs(CollectionService:GetTagged("Item")) do
        if not item:IsDescendantOf(game.ServerStorage) then
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
    Messages:hook("OnItemThrown", function(item)
        lastInteractedOrInStorageTimer[item] = tick()
    end)
    loadSerializedItems()
end

return Storage