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
				local dist = (pos - Rope.object1.PrimaryPart.Position).magnitude
				if dist > 60 then
					Messages:send("PlaySoundOnClient", {
						instance = game.ReplicatedStorage.Sounds.NewUICancel
					})
					Messages:send("Notify", "HUNGER_COLOR_DARK", "ANGRY", "DISTANCE TOO HIGH.")
					return
				end
				print("second")
				Rope.object2 = object
				Rope.object2Pos = pos - object.PrimaryPart.Position

				Messages:sendServer("CreateRopeBetween",
					Rope.object1,
					Rope.object1.PrimaryPart.Position + Rope.object1Pos,
					Rope.object2, Rope.object2.PrimaryPart.Position + Rope.object2Pos
				)
				Messages:send("PlaySoundOnClient", {
					instance = game.ReplicatedStorage.Sounds.NewUIBonk
				})
				Rope.object1 = nil
				Rope.object2 = nil
			else
				if object:FindFirstChild("GameRope") then
					Messages:send("PlaySoundOnClient", {
						instance = game.ReplicatedStorage.Sounds.NewUICancel
					})
					Messages:send("Notify", "HUNGER_COLOR_DARK", "ANGRY", "TWO ROPES CANNOT ORIGINATE FROM THE SAME OBJECT.")
					return
				end
				Messages:send("Notify", "THIRST_COLOR_DARK", "SNOWFLAKE", "SELECT A SECOND OBJECT.")
				Messages:send("PlaySoundOnClient", {
					instance = game.ReplicatedStorage.Sounds.NewUIClickHigh
				})
				Rope.object1 = object
				Rope.object1Pos =  pos - object.PrimaryPart.Position
			end
		end
	end
end

function Rope.serverUse(player, item)

end

function Rope.clientEquip(item)
	Rope.object1 = nil
	Rope.object2 = nil
	Messages:send("Notify", "THIRST_COLOR_DARK", "SNOWFLAKE", "SELECT AN OBJECT TO START THE ROPE FROM.")
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
