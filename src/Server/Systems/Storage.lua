local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local ServerData = import "Server/Systems/ServerData"
local CastRay = import "Shared/Utils/CastRay"

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
        if item.Parent ~= nil then
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

local function getEntityByID(ID)
	local entities = {}
	for _, v in pairs(CollectionService:GetTagged("Monster")) do
		table.insert(entities, v)
	end
	for _, v in pairs(CollectionService:GetTagged("Item")) do
		table.insert(entities, v)
	end
	for _, v in pairs(CollectionService:GetTagged("Building")) do
		table.insert(entities, v)
	end
	for _, v in pairs(entities) do
		if v:IsDescendantOf(workspace) then
			if v.ID.Value == ID then
				return v
			end
		end
	end
end

local function backupItems()
	print("backing up items")
    local items = {}
    for _, item in pairs(CollectionService:GetTagged("Item")) do
        if item:IsDescendantOf(workspace) then
            local pos = item.PrimaryPart.Position
            local info = {}
            info.name = item.Name
			info.position = {x = round(pos.X, .15), y = round(pos.Y, .15), z = round(pos.Z, .15)}

			if item:FindFirstChild("ID") then
				info.id = item.ID.Value
			else
				print("WE DID NOT FIND AN ID IN", item.Name)
			end

			if item:FindFirstChild("RopedTo") then
				local offsetPos0 = item.GameRope.Attachment0.Position
				local offsetPos1 = item.GameRope.Attachment1.Position
				local entity = getEntityByID(item.RopedTo.Value)
				local offset = item.PrimaryPart.CFrame:ToObjectSpace(entity.PrimaryPart.CFrame).p
				info.ropedTo = item.RopedTo.Value
				info.offset = {x = round(offset.X, .15), y = round(offset.Y, .15), z = round(offset.Z, .15)}
				info.ropePosOffset0 = {x = round(offsetPos0.X, .15), y = round(offsetPos0.Y, .15), z = round(offsetPos0.Z, .15)}
				info.ropePosOffset1 = {x = round(offsetPos1.X, .15), y = round(offsetPos1.Y, .15), z = round(offsetPos1.Z, .15)}
			elseif item:FindFirstChild("FrozenTo") then
				info.frozenTo = item.FrozenTo.Value
				local entity = getEntityByID(item.FrozenTo.Value)
				local offset = item.PrimaryPart.CFrame:ToObjectSpace(entity.PrimaryPart.CFrame).p
				info.offset = {x = round(offset.X, .15), y = round(offset.Y, .15), z = round(offset.Z, .15)}
			elseif item:FindFirstChild("ObjectWeldedTo") then
				info.objectWeldedTo = item.ObjectWeldedTo.Value
				local entity = getEntityByID(item.ObjectWeldedTo.Value)
				local offset = item.PrimaryPart.CFrame:ToObjectSpace(entity.PrimaryPart.CFrame).p
				info.offset = {x = round(offset.X, .15), y = round(offset.Y, .15), z = round(offset.Z, .15)}
			end
            table.insert(items, info)
        end
    end
    ServerData:setValue("items", items)
end

local function createItemWithAttachData(entity, itemData)
	local Items = import "Server/Systems/Items"
	local pos = Vector3.new(itemData.position.x, itemData.position.y, itemData.position.z)
	local offset = CFrame.new(itemData.offset.x, itemData.offset.y, itemData.offset.z)

	print("ID OF WHAT WE ARTE LOADING IS", itemData.id)

	local physicalItem = Items.createItem(itemData.name, pos, itemData.id)
	physicalItem:SetPrimaryPartCFrame(entity.PrimaryPart.CFrame * offset)

	local ConstraintManager = import "Server/Systems/ConstraintManager"

	if itemData.ropedTo then
		local ropePos0 = physicalItem.PrimaryPart.Position + Vector3.new(itemData.ropePosOffset0.x, itemData.ropePosOffset0.y, itemData.ropePosOffset0.z)
		local ropePos1 = entity.PrimaryPart.Position + Vector3.new(itemData.ropePosOffset1.x, itemData.ropePosOffset1.y, itemData.ropePosOffset1.z)
		ConstraintManager.createRopeBetween(nil, physicalItem, ropePos0, entity, ropePos1)
	elseif itemData.objectWeldedTo then
		ConstraintManager.createObjectWeld(physicalItem, entity, physicalItem.PrimaryPart.Position)
	elseif itemData.frozenTo then
		ConstraintManager.freezeWeld(physicalItem, entity.PrimaryPart)
	end
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
			if item.ropedTo or item.frozenTo or item.objectWeldedTo then
				local waitID = item.ropedTo or item.frozenTo or item.objectWeldedTo
				Messages:send("WaitForEntityWithID", waitID, function(entity)
					createItemWithAttachData(entity, item, item.id)
				end)
			else
				local pos = Vector3.new(item.position.x, item.position.y, item.position.z)
				Messages:send("CreateItem", item.name, pos, item.id)
			end
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
	Messages:hook("MapDoneGenerating", function()
		loadSerializedItems()
	end)
end

return Storage
