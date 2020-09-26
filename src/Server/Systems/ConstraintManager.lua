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
	--print('unfreeze being called')
	local weld = object:FindFirstChild("FreezeWeld", true)
	if weld then
		weld:Destroy()
	end
	if object:FindFirstChild("FrozenTo") then
		object.FrozenTo:Destroy()
	end
	for _, v in pairs(object:GetChildren()) do
		if v:IsA("BasePart") then
			--v.CanCollide = true
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

function ConstraintManager.removeAllRelevantConstraints(object)
	local tabs = {objectWelds, ropes, freezeWelds}
	for _, tab in pairs(tabs) do
		for i = #tab, 1, -1 do
			local constraint = tab[i]
			if constraint.baseObject == object or constraint.attachObject == object or constraint.valueInstance.Value == object then
				constraint.instance:Destroy()
				constraint.valueInstance:Destroy()
				if constraint.attach1 then
					constraint.attach1:Destroy()
					constraint.attach0:Destroy()
				end
				table.remove(tab, i)
			end
		end
	end
end

function ConstraintManager.createRopeBetween(creator, object1, object1Pos, object2, object2Pos)
	local Permissions = import "Server/Systems/Permissions"
	if not Permissions:playerHasPermission(creator, "can make ropes") then
		Messages:sendClient(creator, "Notify", "HUNGER_COLOR_DARK", "ANGRY", "YOUR RANK LACKS PERMISSIONS.")
		return
	end

	if not (ConstraintManager.canBeRoped(object1) and ConstraintManager.canBeRoped(object2)) then

		return
	end

	if object1:FindFirstChild("GameRope") then

		return
	end

	ConstraintManager.unfreeze(object1)
	ConstraintManager.unfreeze(object2)

	local attach0 = Instance.new("Attachment", object1.PrimaryPart)
	attach0.WorldPosition = object1Pos
	attach0.Visible = true
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
		attach1 = attach1,
		attach0 = attach0,
	}

	table.insert(ropes, ropeObject)

	Messages:send("PlaySound", "RopeTie", object2Pos)
end

function ConstraintManager.removeRopesAttachedTo(object)
	local tabs = {ropes}
	for _, tab in pairs(tabs) do
		for i = #tab, 1, -1 do
			local constraint = tab[i]
			if constraint.baseObject == object or constraint.attachObject == object or constraint.valueInstance.Value == object then
				constraint.instance:Destroy()
				constraint.valueInstance:Destroy()
				if constraint.attach1 then
					constraint.attach1:Destroy()
					constraint.attach0:Destroy()
				end
				table.remove(tab, i)
			end
		end
	end
end

function ConstraintManager:start()
	Messages:hook("RemoveRopesAttachedTo", function(player, object)
		local Permissions = import "Server/Systems/Permissions"
		if not Permissions:playerHasPermission(player, "can delete ropes") then
			Messages:sendClient(player, "Notify", "HUNGER_COLOR_DARK", "ANGRY", "YOUR RANK LACKS PERMISSIONS.")
			return
		end
		-- TODO: auth check
		ConstraintManager.removeRopesAttachedTo(object)
	end)
	-- TODO another auth check
	Messages:hook("CreateRopeBetween", ConstraintManager.createRopeBetween)
end

return ConstraintManager
