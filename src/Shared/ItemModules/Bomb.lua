local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local Damage = import "Shared/Utils/Damage"

local FastSpawn = import "Shared/Utils/FastSpawn"

local Bomb = {}

function Bomb.clientUse(item)
	--Messages:send("Throw")
	item.Fuse.Attachment.Fire.Enabled = true
	item.Fuse.Attachment.PointLight.Enabled = true
	item.Fuse.Fuse:Play()
end

function Bomb.serverUse(player, item)
	FastSpawn(function()
		local pos = item.PrimaryPart.Position
		local t = 1
		local ticks = 15
		for i = 1, ticks do
			if not item.PrimaryPart then
				return
			end
			if item.Base.Color == Color3.fromRGB(51, 88, 130) then
				item.Base.BrickColor = BrickColor.new("Persimmon")
			else
				item.Base.Color = Color3.fromRGB(51, 88, 130)
			end
			pos = item.PrimaryPart.Position
			Messages:send("PlaySound", "Click", pos, 1 + i/10)
			t = t * .9
			wait(t)
		end
		Messages:send("DestroyItem", item)
		Messages:send("CreateExplosion", player, pos)
	end)
end

function Bomb.clientEquip(item)
end

function Bomb.serverEquip(player, item)
end

function Bomb.clientUnequip(item)
	-- item.Fuse.Attachment.Fire.Enabled = false
	-- item.Fuse.Attachment.PointLight.Enabled = false
	-- item.Fuse.Fuse:Stop()
end

function Bomb.serverUnequip(player, item)
end

return Bomb
