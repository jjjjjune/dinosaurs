local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"
local ConstraintManager = import "Server/Systems/ConstraintManager"

local CollectionService = game:GetService("CollectionService")

local POSITION_RESOLUTION = .1
local ROTATION_RESOLUTION_ITEM = 45
local ROTATION_RESOLUTION_OTHER = 5
local OFFSET_RESOLUTION = .25

local function join(a, b)
	local new = {}

	for key, value in pairs(a) do
		new[key] = value
	end

	for key, value in pairs(b) do
		new[key] = value
	end

	return new
end

local function round(n, mult)
    mult = mult or 1
    return math.floor((n + mult/2)/mult) * mult
end

local function resolutionize(n, resolution)
	n = round(n, resolution)
	return (n/resolution)
end

local function deresolutionize(n, resolution)
	return n*resolution
end

local function getPositionalAndRotationalData(tag, object)
	local pos = object.PrimaryPart.Position
	local ox, oy, oz  = object.PrimaryPart.CFrame:toOrientation()

	ox = math.deg(ox)
	oy = math.deg(oy)
	oz = math.deg(oz)

	local data = {}

	data.px = resolutionize(pos.x, POSITION_RESOLUTION)
	data.py = resolutionize(pos.y, POSITION_RESOLUTION)
	data.pz = resolutionize(pos.z, POSITION_RESOLUTION)

	local rotationResolution = ROTATION_RESOLUTION_ITEM
	if tag == "Building" or tag == "SaveableMapEntity" then
		rotationResolution = ROTATION_RESOLUTION_OTHER
	end

	data.ox = resolutionize(ox, rotationResolution)
	data.oy = resolutionize(oy, rotationResolution)
	data.oz = resolutionize(oz, rotationResolution)

	return data
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
	for _, v in pairs(CollectionService:GetTagged("SaveableMapEntity")) do
		table.insert(entities, v)
	end
	for _, v in pairs(entities) do
		if v:IsDescendantOf(workspace) then
			if v:FindFirstChild("ID") and v.ID.Value == ID then
				return v
			end
		end
	end
end

local function getAttachmentData(object)
	local data = {}
	local offset, entity

	if object:FindFirstChild("RopedTo") then
		entity = getEntityByID(object.RopedTo.Value)

		local offsetPos0 = object.GameRope.Attachment0.Position
		local offsetPos1 = object.GameRope.Attachment1.Position

		data.rt = object.RopedTo.Value

		data.r0x = resolutionize(offsetPos0.X, OFFSET_RESOLUTION)
		data.r0y = resolutionize(offsetPos0.Y, OFFSET_RESOLUTION)
		data.r0z = resolutionize(offsetPos0.Z, OFFSET_RESOLUTION)
		data.r1x = resolutionize(offsetPos1.X, OFFSET_RESOLUTION)
		data.r1y = resolutionize(offsetPos1.Y, OFFSET_RESOLUTION)
		data.r1z = resolutionize(offsetPos1.Z, OFFSET_RESOLUTION)
		if not entity then
			ConstraintManager.removeAllRelevantConstraints(object.RopedTo.Value)
			return {}
		end
	elseif object:FindFirstChild("FrozenTo") then
		data.ft = object.FrozenTo.Value
		entity = getEntityByID(object.FrozenTo.Value)
		if not entity then
			ConstraintManager.removeAllRelevantConstraints(object.RopedTo.Value)
			return {}
		end
	elseif object:FindFirstChild("ObjectWeldedTo") then
		data.ot = object.ObjectWeldedTo.Value
		entity = getEntityByID(object.ObjectWeldedTo.Value)
		if not entity then
			ConstraintManager.removeAllRelevantConstraints(object.RopedTo.Value)
			return {}
		end
	else
		-- item is attached to nothing, no need to store any of this
		return {}
	end

	offset = entity.PrimaryPart.CFrame:ToObjectSpace(object.PrimaryPart.CFrame).p

	data._x = resolutionize(offset.X, OFFSET_RESOLUTION)
	data._y = resolutionize(offset.Y, OFFSET_RESOLUTION)
	data._z = resolutionize(offset.Z, OFFSET_RESOLUTION)

	return data
end

local function getMetadata(object)
	local data = {}

	for _, v in pairs(object:GetChildren()) do
		if v:IsA("ValueBase") then
			data[v.Name] = v.Value
		end
	end

	return data
end

local function getObjectSaveData(tag, object)
	local data = {}
	if tag == "Item" then
		data = join(data, getPositionalAndRotationalData(tag, object))
		data = join(data, getAttachmentData(object))
	elseif tag == "Building" then
		data = join(data, getPositionalAndRotationalData(tag, object))
		data = join(data, getAttachmentData(object))
		data = join(data, getMetadata(object))
	elseif tag == "SaveableMapEntity" then
		data = join(data, getPositionalAndRotationalData(tag, object))
	elseif tag == "Monster" then
		data = join(data, getPositionalAndRotationalData(tag, object))
		data = join(data, getMetadata(object))
	end
	if object:FindFirstChild("ID") then
		data.i = object.ID.Value
	end
	data.n = object.Name
	return data
end

local function createItemWithAttachData(entity, itemData)

	local offset = CFrame.new(
		deresolutionize(itemData._x, OFFSET_RESOLUTION),
		deresolutionize(itemData._y, OFFSET_RESOLUTION),
		deresolutionize(itemData._z, OFFSET_RESOLUTION)
	)

	local rotationCF = CFrame.fromOrientation(
		math.rad(deresolutionize(itemData.ox, ROTATION_RESOLUTION_ITEM)),
		math.rad(deresolutionize(itemData.oy, ROTATION_RESOLUTION_ITEM)),
		math.rad(deresolutionize(itemData.oz, ROTATION_RESOLUTION_ITEM))
	)

	local Items = import "Server/Systems/Items"
	local physicalItem = Items.createItem(itemData.n, Vector3.new(), itemData.i)

	local cf = entity.PrimaryPart.CFrame * offset * rotationCF

	physicalItem:SetPrimaryPartCFrame(cf)

	-- for _, v in pairs(physicalItem:GetChildren()) do

	-- end

	if itemData.rt then
		local deResPos0 = Vector3.new(
		deresolutionize(itemData.r0x, OFFSET_RESOLUTION),
		deresolutionize(itemData.r0y, OFFSET_RESOLUTION),
		deresolutionize(itemData.r0z, OFFSET_RESOLUTION))

		local deResPos1 = Vector3.new(
		deresolutionize(itemData.r1x, OFFSET_RESOLUTION),
		deresolutionize(itemData.r1y, OFFSET_RESOLUTION),
		deresolutionize(itemData.r1z, OFFSET_RESOLUTION))

		local rotation = CFrame.fromOrientation(math.rad(deresolutionize(itemData.ox, ROTATION_RESOLUTION_ITEM)),
			math.rad(deresolutionize(itemData.oy, ROTATION_RESOLUTION_ITEM)),
			math.rad(deresolutionize(itemData.oz, ROTATION_RESOLUTION_ITEM))
		)

		local cf = CFrame.new(
			deresolutionize(itemData.px, POSITION_RESOLUTION),
			deresolutionize(itemData.py, POSITION_RESOLUTION),
			deresolutionize(itemData.pz, POSITION_RESOLUTION)
		) * rotation

		physicalItem:SetPrimaryPartCFrame(cf) -- for ropes we don't want to use the relative position because it can result in a lot of innacuracy
		-- (because the item rotation isn't stored at a high resolution the CF can be off by a lot)

		local ropePos0 = physicalItem.PrimaryPart.Position + deResPos0
		local ropePos1 = entity.PrimaryPart.Position + deResPos1
		ConstraintManager.createRopeBetween(nil, physicalItem, ropePos0, entity, ropePos1)
	elseif itemData.ot then
		local cf = entity.PrimaryPart.CFrame * offset
		ConstraintManager.createObjectWeld(physicalItem, entity,cf.p, rotationCF)
	elseif itemData.ft then
		ConstraintManager.freezeWeld(physicalItem, entity.PrimaryPart)
	end

	physicalItem.Parent = workspace
end

local function createBuildingWithAttachData(entity, buildingData)
	local offset = CFrame.new(
		deresolutionize(buildingData._x, OFFSET_RESOLUTION),
		deresolutionize(buildingData._y, OFFSET_RESOLUTION),
		deresolutionize(buildingData._z, OFFSET_RESOLUTION)
	)

	local rotationCF = CFrame.fromOrientation(
		math.rad(deresolutionize(buildingData.ox, ROTATION_RESOLUTION_OTHER)),
		math.rad(deresolutionize(buildingData.oy, ROTATION_RESOLUTION_OTHER)),
		math.rad(deresolutionize(buildingData.oz, ROTATION_RESOLUTION_OTHER))
	)

	local Buildings = import "Server/Systems/Buildings"
	local physicalBuilding = Buildings.createBuilding(buildingData.n, Vector3.new(), buildingData.i)
	physicalBuilding:SetPrimaryPartCFrame(entity.PrimaryPart.CFrame * offset * rotationCF)
	physicalBuilding.Parent = workspace.Buildings

	if buildingData.rt then
		local deResPos0 = Vector3.new(
		deresolutionize(buildingData.r0x, OFFSET_RESOLUTION),
		deresolutionize(buildingData.r0y, OFFSET_RESOLUTION),
		deresolutionize(buildingData.r0z, OFFSET_RESOLUTION))

		local deResPos1 = Vector3.new(
		deresolutionize(buildingData.r1x, OFFSET_RESOLUTION),
		deresolutionize(buildingData.r1y, OFFSET_RESOLUTION),
		deresolutionize(buildingData.r1z, OFFSET_RESOLUTION))

		local ropePos0 = physicalBuilding.PrimaryPart.Position + deResPos0
		local ropePos1 = entity.PrimaryPart.Position + deResPos1
		ConstraintManager.createRopeBetween(nil, physicalBuilding, ropePos0, entity, ropePos1)
	elseif buildingData.ot then
		local cf = entity.PrimaryPart.CFrame * offset
		ConstraintManager.createObjectWeld(physicalBuilding, entity,cf.p, rotationCF)
	end
end


local function loadObject(tag, objectData)

	local rotationResolution = ROTATION_RESOLUTION_ITEM
	if tag == "Building" or tag == "SaveableMapEntity" then
		rotationResolution = ROTATION_RESOLUTION_OTHER
	end

	local rotation = CFrame.fromOrientation(math.rad(deresolutionize(objectData.ox, rotationResolution)),
		math.rad(deresolutionize(objectData.oy, rotationResolution)),
		math.rad(deresolutionize(objectData.oz, rotationResolution))
	)

	local cf = CFrame.new(
		deresolutionize(objectData.px, POSITION_RESOLUTION),
		deresolutionize(objectData.py, POSITION_RESOLUTION),
		deresolutionize(objectData.pz, POSITION_RESOLUTION)
	) * rotation

	if objectData._x then
		local waitID = objectData.rt or objectData.ft or objectData.ot
		if tag == "Item" then
			Messages:send("WaitForEntityWithID", waitID, function(entity)
				createItemWithAttachData(entity, objectData)
			end)
		elseif tag == "Building" then
			Messages:send("WaitForEntityWithID", waitID, function(entity)
				createBuildingWithAttachData(entity, objectData)
			end)
		elseif tag == "Monster" then

		end
	else
		if tag == "Item" then
			Messages:send("CreateItem", objectData.n, cf.p, objectData.i, rotation)
		elseif tag == "Building" then
			local Buildings = import "Server/Systems/Buildings"
			local physicalBuilding = Buildings.createBuilding(objectData.n, Vector3.new(), objectData.i)
			physicalBuilding:SetPrimaryPartCFrame(cf)
			physicalBuilding.Parent = workspace.Buildings
		elseif tag == "SaveableMapEntity" then
			local Buildings = import "Server/Systems/Buildings"
			local physicalBuilding = Buildings.createBuilding(objectData.n, Vector3.new(), objectData.i)
			physicalBuilding:SetPrimaryPartCFrame(cf)
			physicalBuilding.Parent = workspace.Buildings
		elseif tag == "Monster" then
			local Monsters = import "Server/Systems/Monsters"
			Monsters.createMonster(objectData.n, cf.p, objectData.i)
		end
	end
end

local SaveableObjectManager = {}

function SaveableObjectManager.saveTag(tag)
	local ServerData = import "Server/Systems/ServerData"
	local tagData = {}
	for _, object in pairs(CollectionService:GetTagged(tag)) do
		if object:IsDescendantOf(workspace) and object.PrimaryPart then
			local data = getObjectSaveData(tag, object)
			table.insert(tagData, data)
		end
	end
	ServerData:setValue(tag, tagData)
end

function SaveableObjectManager.loadTag(tag)
	local ServerData = import "Server/Systems/ServerData"
	local tagData = ServerData:getValue(tag)
	if tagData then
		for _, objectData in pairs(tagData) do
			loadObject(tag, objectData)
		end
	end
end

function SaveableObjectManager:start()

end

return SaveableObjectManager
