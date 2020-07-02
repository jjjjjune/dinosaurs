local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"

-- todo keep track of when items are ropoed to other items
-- and game ropes

local function createRopeBetween(player, object1, object1Pos, object2, object2Pos)
	if object1:FindFirstChild("GameRope") then
		object1.GameRope:Destroy()
	end
	if object2:FindFirstChild("GameRope") then
		object2.GameRope:Destroy()
	end
	if object1:FindFirstChild("FreezeWeld") then
		object1.FreezeWeld:Destroy()
	end
	if object2:FindFirstChild("FreezeWeld") then
		object2.FreezeWeld:Destroy()
	end
	local GameRope = Instance.new("RopeConstraint", object1)
	GameRope.Name = "GameRope"
	GameRope.Visible = true
	local attach0 = Instance.new("Attachment", object1.PrimaryPart)
	attach0.WorldPosition = object1Pos
	local attach1 = Instance.new("Attachment", object2.PrimaryPart)
	attach1.WorldPosition = object2Pos
	GameRope.Length = (object1Pos - object2Pos).magnitude
	GameRope.Attachment0 = attach0
	GameRope.Attachment1 = attach1
end

local Rope = {}

function Rope:start()
	Messages:hook("CreateRopeBetween", createRopeBetween)
end

return Rope
