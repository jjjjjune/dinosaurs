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
		wait(5)
		local pos = item.PrimaryPart.Position
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
