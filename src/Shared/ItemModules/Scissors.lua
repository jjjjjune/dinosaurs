local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"

local GetMouseHit = import "Shared/Utils/GetMouseHit"

local CollectionService = game:GetService("CollectionService")

local Scissors = {}

Scissors.debounce = .5

function Scissors.clientUse(item)
	local hit, pos, normal = GetMouseHit({Scissors.object1, Scissors.object2})
	if hit then
		local object = hit.Parent
		if CollectionService:HasTag(object, "Building") or CollectionService:HasTag(object, "Monster") or CollectionService:HasTag(object, "Item") then
			Messages:sendServer("RemoveRopesAttachedTo", object)
			Messages:send("PlayAnimationClient", "SwingEnd")
		end
	end
end

function Scissors.serverUse(player, item)
	Messages:send("PlaySound", "Scissors", item.PrimaryPart.Position)
end

function Scissors.clientEquip(item)

end

function Scissors.serverEquip(player, item)
end

function Scissors.clientUnequip(item)

end

function Scissors.serverUnequip(player, item)
end

return Scissors
