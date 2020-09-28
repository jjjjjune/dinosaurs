
local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"

local FastSpawn = import "Shared/Utils/FastSpawn"

local Damage = import "Shared/Utils/Damage"

local CollectionService = game:GetService("CollectionService")

local function onExplosionHit(hit, dist, damaged, player)
	local victim = hit.Parent
	if victim:FindFirstChild("Health") or CollectionService:HasTag(victim, "Character") then
		Messages:send("Knockback", hit.Parent, hit.Parent.PrimaryPart.CFrame.lookVector * -(1000/(dist/2)), .4)
		Messages:send("PlaySound", "BoneBreak", hit.Position)
		Damage(victim, {damage = math.max(0, 200 - (dist*8)), type = "fire", serverApplication = true})
	end
	damaged[hit.Parent] = true
	Messages:send("SetOnFire", hit.Parent, 4)
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
		onExplosionHit(hit, dist, damaged, player)
	end)
	ex.Parent = workspace
end

local Explosions = {}

function Explosions:start()
	Messages:hook("CreateExplosion", createExplosion)
end

return Explosions
