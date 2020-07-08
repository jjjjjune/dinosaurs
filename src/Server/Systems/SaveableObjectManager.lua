local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"

local CollectionService = game:GetService("CollectionService")

local POSITION_RESOLUTION = .1
local ROTATION_RESOLUTION_ITEM = 45
local ROTATION_RESOLUTION_OTHER = 1
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
	return math.floor(n/resolution)
end

local function deresolutionize(n, resolution)
	return n*resolution
end

local function getPositionalAndRotationalData(tag, object)
	local pos = object.PrimaryPart.Position
	local ox, oy, oz  = object.PrimaryPart.CFrame:toOrientation()

	local data = {}

	data.px = resolutionize(pos.x, POSITION_RESOLUTION)
	data.py = resolutionize(pos.y, POSITION_RESOLUTION)
	data.pz = resolutionize(pos.z, POSITION_RESOLUTION)

	local rotationResolution = ROTATION_RESOLUTION_ITEM
	if tag == "Building" then
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
	for _, v in pairs(entities) do
		if v:IsDescendantOf(workspace) then
			if v.ID.Value == ID then
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
	elseif object:FindFirstChild("FrozenTo") then
		data.ft = object.FrozenTo.Value
		entity = getEntityByID(object.FrozenTo.Value)
	elseif object:FindFirstChild("ObjectWeldedTo") then
		data.ot = object.ObjectWeldedTo.Value
		entity = getEntityByID(object.ObjectWeldedTo.Value)
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

local function getObjectSaveData(tag, object)
	local data = {}
	if tag == "Item" then
		data = join(data, getPositionalAndRotationalData(tag, object))
		data = join(data, getAttachmentData(object))
	end
	if object:FindFirstChild("ID") then
		data.i = object.ID.Value
	end
	data.n = object.Name
	return data
end

local function createItemWithAttachData(entity, itemData)
	local Items = import "Server/Systems/Items"

	local offset = CFrame.new(itemData._x, itemData._y, itemData._z)

	local physicalItem = Items.createItem(itemData.n, Vector3.new(), itemData.i)
	physicalItem:SetPrimaryPartCFrame(entity.PrimaryPart.CFrame * offset)

	local ConstraintManager = import "Server/Systems/ConstraintManager"

	if itemData.rt then
		local ropePos0 = physicalItem.PrimaryPart.Position + Vector3.new(itemData.r0x, itemData.r0y, itemData.r0z)
		local ropePos1 = entity.PrimaryPart.Position + Vector3.new(itemData.r1x, itemData.r1y, itemData.r1z)
		ConstraintManager.createRopeBetween(nil, physicalItem, ropePos0, entity, ropePos1)
	elseif itemData.ot then
		local cf = entity.PrimaryPart.CFrame * CFrame.new(itemData._x, itemData._y, itemData._z)
		ConstraintManager.createObjectWeld(physicalItem, entity,cf.p)
	elseif itemData.ft then
		ConstraintManager.freezeWeld(physicalItem, entity.PrimaryPart)
	end
end


local function loadObject(tag, objectData)

	local rotationResolution = ROTATION_RESOLUTION_ITEM
	if tag == "Building" then
		rotationResolution = ROTATION_RESOLUTION_OTHER
	end

	local cf = CFrame.new(
		deresolutionize(objectData.px, POSITION_RESOLUTION),
		deresolutionize(objectData.py, POSITION_RESOLUTION),
		deresolutionize(objectData.pz, POSITION_RESOLUTION)
	) * CFrame.fromOrientation(deresolutionize(objectData.ox, rotationResolution),
		deresolutionize(objectData.oy, rotationResolution),
		deresolutionize(objectData.oz, rotationResolution)
	)

	if objectData._x then
		local waitID = objectData.rt or objectData.ft or objectData.ot
		if tag == "Item" then
			Messages:send("WaitForEntityWithID", waitID, function(entity)
				createItemWithAttachData(entity, objectData)
			end)
		end
	else
		Messages:send("CreateItem", objectData.n, cf.p, objectData.i)
	end
end

local SaveableObjectManager = {}

function SaveableObjectManager.saveTag(tag)
	local ServerData = import "Server/Systems/ServerData"
	local tagData = {}
	for _, object in pairs(CollectionService:GetTagged(tag)) do
		if object:IsDescendantOf(workspace) then
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
