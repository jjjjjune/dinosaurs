local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"

local ropes = {}

local ConstraintManager = {}

--[[
	create rope
	create building weld
	create player weld
]]

function ConstraintManager.freezeWeld(item, hit)
	for _, rope in pairs(ropes) do
		if rope.baseObject == item or rope.attachObject == item then
			return
		end
	end
	local freezeWeld = Instance.new("WeldConstraint", item)
	freezeWeld.Part0 = item.PrimaryPart
	freezeWeld.Part1 = hit
	freezeWeld.Name = "FreezeWeld"
end

function ConstraintManager.destroyAllWelds(object)
	if object:FindFirstChild("FreezeWeld") then
		object.FreezeWeld:Destroy()
	end
	if object:FindFirstChild("ObjectWeld") then
		object.ObjectWeld:Destroy()
	end
end

function ConstraintManager.createObjectWeld(attaching, attachTo, intendedPosition)
	attaching:SetPrimaryPartCFrame(CFrame.new(intendedPosition))
	local objectWeld = Instance.new("WeldConstraint", attaching)
	objectWeld.Name = "ObjectWeld"
	objectWeld.Part0 = attaching.PrimaryPart
	objectWeld.Part1 = attachTo.PrimaryPart
end

function ConstraintManager.unfreeze(object)
	local weld = object:FindFirstChild("FreezeWeld", true)
	if weld then
		weld:Destroy()
	end
end

function ConstraintManager.canBeRoped(object)
	if (not object.PrimaryPart) or
		object.PrimaryPart.Anchored or
		not object:FindFirstChild("ID") or
		object:FindFirstChild("PlayerWeld", true)
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

function ConstraintManager.createRopeBetween(creator, object1, object1Pos, object2, object2Pos)
	if not (ConstraintManager.canBeRoped(object1) and ConstraintManager.canBeRoped(object2)) then
		return
	end

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
	gameRope.Length = (object1Pos - object2Pos).magnitude
	gameRope.Attachment0 = attach0
	gameRope.Attachment1 = attach1

	local ropeObject = {
		creator = creator,
		baseObject = object1,
		attachObject = object2,
		instance = gameRope,
	}

	local ropeData = Instance.new("StringValue")
	ropeData.Name = "RopedTo"
	ropeData.Value = object2.ID.Value

	table.insert(ropes, ropeObject)

	Messages:send("PlaySound", "RopeTie", object2Pos)
end

function ConstraintManager.removeRopesAttachedTo(object)
	for i = #ropes, 1, -1 do
		local rope = ropes[i]
		if rope.baseObject == object or rope.attachObject == object then
			ConstraintManager.clearRopeData(object)
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