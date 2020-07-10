local import = require(game.ReplicatedStorage.Shared.Import)

local CollectionService = game:GetService("CollectionService")

local Messages = import "Shared/Utils/Messages"

local ropes = {}
local freezeWelds = {}
local objectWelds = {}

local ConstraintManager = {}

function ConstraintManager.hasAnyRopesAttached(item)
	for _, rope in pairs(ropes) do
		if rope.baseObject == item or rope.attachObject == item then
			return true
		end
	end
	return false
end

function ConstraintManager.destroyConstraintFromData(data)
	data.instance:Destroy()
	data.valueInstance:Destroy()
end

function ConstraintManager.freezeWeld(item, hit)
	for _, rope in pairs(ropes) do
		if rope.baseObject == item or rope.attachObject == item then
			warn(item, " is already roped and cant be le freezd")
			return
		end
	end
	local freezeWeld = Instance.new("WeldConstraint", item)
	freezeWeld.Part0 = item.PrimaryPart
	freezeWeld.Part1 = hit
	freezeWeld.Name = "FreezeWeld"

	if hit.Parent:FindFirstChild("ID") then
		local frozenTo = Instance.new("StringValue", item)
		frozenTo.Value = hit.Parent.ID.Value
		frozenTo.Name = "FrozenTo"

		table.insert(freezeWelds, {
			baseObject = hit.Parent,
			attachObject = item,
			instance = freezeWeld,
			valueInstance = frozenTo,
		})
	end
end

function ConstraintManager.destroyAllWelds(object)
	if object:FindFirstChild("FreezeWeld") then
		ConstraintManager.unfreeze(object)
	end
	if object:FindFirstChild("ObjectWeld") then
		object.ObjectWeld:Destroy()
		object.ObjectWeldedTo:Destroy()
	end
end

function ConstraintManager.createObjectWeld(attaching, attachTo, intendedPosition, intendedOrientation)
	attaching:SetPrimaryPartCFrame(CFrame.new(intendedPosition))
	if intendedOrientation then
		attaching:SetPrimaryPartCFrame(attaching.PrimaryPart.CFrame * intendedOrientation)
	end
	local objectWeld = Instance.new("WeldConstraint", attaching)
	objectWeld.Name = "ObjectWeld"
	objectWeld.Part0 = attaching.PrimaryPart
	objectWeld.Part1 = attachTo.PrimaryPart

	local objectWeldedTo = Instance.new("StringValue", attaching)
	objectWeldedTo.Name = "ObjectWeldedTo"
	objectWeldedTo.Value = attachTo.ID.Value

	table.insert(objectWelds, {
		baseObject = attachTo,
		attachObject = attaching,
		instance = objectWeld,
		valueInstance = objectWeldedTo,
	})
end

function ConstraintManager.unfreeze(object)
	local weld = object:FindFirstChild("FreezeWeld", true)
	if weld then
		weld:Destroy()
	end
	if object:FindFirstChild("FrozenTo") then
		object.FrozenTo:Destroy()
	end
	for _, v in pairs(object:GetChildren()) do
		if v:IsA("BasePart") then
			v.CanCollide = true
			v.Anchored = false
		end
	end
end

function ConstraintManager.canBeRoped(object)
	if (not object.PrimaryPart) or
		not object:FindFirstChild("ID") or
		object:FindFirstChild("ServerWeld", true)
	then
		return false
	end
	return true
end

function ConstraintManager.clearRopeData(object)
	if object:FindFirstChild("RopedTo") then
		object.RopedTo:Destroy()
	end
end

function ConstraintManager.removeDuplicateRopes(object1, object2)
	for i = #ropes, 1, -1 do
		local rope = ropes[i]
		if rope.baseObject == object1 and rope.attachObject == object2 then
			ConstraintManager.clearRopeData(rope.attachObject)
			rope.instance:Destroy()
			table.remove(ropes, i)
		elseif rope.attachObject == object1 and rope.baseObject == object2 then
			ConstraintManager.clearRopeData(rope.attachObject)
			rope.instance:Destroy()
			table.remove(ropes, i)
		end
	end
end

function ConstraintManager.removeAllRelevantConstraints(object)
	local tabs = {objectWelds, ropes, freezeWelds}
	for _, tab in pairs(tabs) do
		for i = #tab, 1, -1 do
			local constraint = tab[i]
			if constraint.baseObject == object or constraint.attachObject == object or constraint.valueInstance.Value == object then
				constraint.instance:Destroy()
				constraint.valueInstance:Destroy()
				table.remove(tab, i)
			end
		end
	end
end

function ConstraintManager.createRopeBetween(creator, object1, object1Pos, object2, object2Pos)
	if not (ConstraintManager.canBeRoped(object1) and ConstraintManager.canBeRoped(object2)) then
		print("CAN NOT BE ROPED")
		return
	end

	if object1:FindFirstChild("GameRope") then
		print("OBJECTG 1 ALREADY HAS GAME ROPE")
		return
	end

	local x = object1:Clone()

	for _, v in pairs(x:GetChildren()) do
		if v:IsA("BasePart") then
			v.Anchored = true
			v.Transparency = .5
			v.CanCollide = false
		end
	end

	CollectionService:RemoveTag(x, "Item")
	x.Parent = workspace

	local x = object2:Clone()

	for _, v in pairs(x:GetChildren()) do
		if v:IsA("BasePart") then
			v.Anchored = true
			v.Transparency = .5
			v.CanCollide = false
		end
	end
	CollectionService:RemoveTag(x, "Item")
	x.Parent = workspace

	ConstraintManager.unfreeze(object1)
	ConstraintManager.unfreeze(object2)
	ConstraintManager.removeDuplicateRopes(object1, object2)

	local attach0 = Instance.new("Attachment", object1.PrimaryPart)
	attach0.WorldPosition = object1Pos
	local attach1 = Instance.new("Attachment", object2.PrimaryPart)
	attach1.WorldPosition = object2Pos

	local gameRope = Instance.new("RopeConstraint", object1)
	gameRope.Name = "GameRope"
	gameRope.Visible = true
	gameRope.Length = (attach0.WorldPosition - attach1.WorldPosition).magnitude + .5
	gameRope.Attachment0 = attach0
	gameRope.Attachment1 = attach1

	local ropeData = Instance.new("StringValue")
	ropeData.Name = "RopedTo"
	ropeData.Value = object2.ID.Value
	ropeData.Parent = object1

	local ropeObject = {
		creator = creator,
		baseObject = object1,
		attachObject = object2,
		instance = gameRope,
		valueInstance = ropeData,
	}

	table.insert(ropes, ropeObject)

	Messages:send("PlaySound", "RopeTie", object2Pos)
end

function ConstraintManager.removeRopesAttachedTo(object)
	for i = #ropes, 1, -1 do
		local rope = ropes[i]
		if rope.baseObject == object or rope.attachObject == object then
			ConstraintManager.clearRopeData(object)
			rope.instance.Enabled = false
			rope.instance:Destroy()
			table.remove(ropes, i)
		end
	end
end

function ConstraintManager:start()
	Messages:hook("RemoveRopesAttachedTo", function(player, object)
		-- TODO: auth check
		ConstraintManager.removeRopesAttachedTo(object)
	end)
	-- TODO another auth check
	Messages:hook("CreateRopeBetween", ConstraintManager.createRopeBetween)
end

return ConstraintManager
