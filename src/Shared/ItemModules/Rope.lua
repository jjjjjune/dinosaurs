local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"

local GetMouseHit = import "Shared/Utils/GetMouseHit"

local CollectionService = game:GetService("CollectionService")

local Rope = {}

function Rope.clientUse(item)
	local hit, pos, normal = GetMouseHit({Rope.object1, Rope.object2})
	if hit then
		local object = hit.Parent
		if CollectionService:HasTag(object, "Building") or CollectionService:HasTag(object, "Monster") or CollectionService:HasTag(object, "Item") then
			if Rope.object1 then
				print("second")
				Rope.object2 = object
				Rope.object2Pos = pos

				Messages:sendServer("CreateRopeBetween", Rope.object1, Rope.object1Pos, Rope.object2, Rope.object2Pos)
				Rope.object1 = nil
				Rope.object2 = nil
			else
				print("first")
				Rope.object1 = object
				Rope.object1Pos = pos
			end
		else
			print('has nothing')
		end
	end
end

function Rope.serverUse(player, item)

end

function Rope.clientEquip(item)
	Rope.object1 = nil
	Rope.object2 = nil
end

function Rope.serverEquip(player, item)
end

function Rope.clientUnequip(item)
	Rope.object1 = nil
	Rope.object2 = nil
end

function Rope.serverUnequip(player, item)
end

return Rope
