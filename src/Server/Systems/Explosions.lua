
local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"

local FastSpawn = import "Shared/Utils/FastSpawn"

local Damage = import "Shared/Utils/Damage"

local CollectionService = game:GetService("CollectionService")

local function onExplosionHit(hit, dist, damaged, player, startPos)
	if damaged[hit.Parent] then
		return
	end
	local shouldDamage = false
	local victim = hit.Parent
	if victim:FindFirstChild("Health") or CollectionService:HasTag(victim, "Character") then
		local dir = CFrame.new(hit.Position, startPos)
		Messages:send("Knockback", hit.Parent, dir.lookVector * (1000/(dist/2)), .4)
		shouldDamage = true
	end

	Messages:send("SetOnFire", hit.Parent, 4)

	damaged[hit.Parent] = true

	if shouldDamage then
		Damage(victim, {damage = math.max(0, math.floor(200 - (dist*8))), type = "fire", serverApplication = true})
	end
end

local function createExplosion(player, pos)
	Messages:send("PlayParticleSystem", "Explosion", pos)
	Messages:send("PlaySound", "ExplosionRocket1", pos)
	local ex = Instance.new("Explosion")
	ex.Position = pos
	ex.Visible = false
	ex.BlastRadius = 20
	ex.DestroyJointRadiusPercent = 0
	ex.BlastPressure = 10000
	local damaged = {}
	ex.Hit:connect(function(hit, dist)
		onExplosionHit(hit, dist, damaged, player, pos)
	end)
	ex.Parent = workspace
end

local Explosions = {}

function Explosions:start()
	Messages:hook("CreateExplosion", createExplosion)
end

return Explosions
