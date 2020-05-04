local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"

local ParticlesFolder = import "ReplicatedStorage/Particles"

local CollectionService = game:GetService("CollectionService")

local Debris = game:GetService("Debris")

local Particles ={}

function Particles:start()

	CollectionService:GetInstanceAddedSignal("Particle"):Connect(function(instance)
		if instance:IsA("Attachment") or instance:IsA("BasePart") then
			delay(2,function()
				if instance then instance:Destroy() end
			end)
		end
	end)

	Messages:hook("PlayParticleSet", function(particleName, subFolder, position)
		local attach = Instance.new("Attachment")
		if typeof(position) ~= "Instance" then
			attach.Position = position
			attach.Parent = workspace.Terrain
		else
			attach.Parent = position
		end
		attach.Name = "Particle"
		CollectionService:AddTag(attach,"Particle")

		local particlePart = ParticlesFolder[particleName][subFolder]:Clone()
		for _,particle in pairs(particlePart:GetChildren()) do
			particle.Parent = attach
			particle:Emit(particle.Rate)
		end
	end)

	Messages:hook("PlayParticle", function(particleName, amount, position)
		local attach = Instance.new("Attachment")
		if typeof(position) ~= "Instance" then
			attach.Position = position
			attach.Parent = workspace.Terrain
		else
			attach.Parent = position
		end

		attach.Name = "Particle"
		CollectionService:AddTag(attach,"Particle")

		local particleInstance = ParticlesFolder[particleName]:Clone()
		particleInstance.Parent = attach
		particleInstance:Emit(amount)
	end)
	Messages:hook("PlayParticleServer", function(player, particleName, amount, position)
		local attach = Instance.new("Attachment")
		attach.Position = position
		attach.Name = "Particle"
		attach.Parent = workspace.Terrain
		CollectionService:AddTag(attach,"Particle")
		local particleInstance = ParticlesFolder[particleName]:Clone()
		particleInstance.Parent = attach
		particleInstance:Emit(amount)
	end)
	Messages:hook("PlayParticleColor", function(particleName, color, amount, position)
		local attach = Instance.new("Attachment")
		if typeof(position) ~= "Instance" then
			attach.Position = position
			attach.Parent = workspace.Terrain
		else
			attach.Parent = position
		end
		attach.Name = "Particle"
		CollectionService:AddTag(attach,"Particle")

		local particleInstance = ParticlesFolder[particleName]:Clone()
		particleInstance.Color = ColorSequence.new(color)
		particleInstance.Parent = attach
		particleInstance:Emit(amount)
	end)
end

return Particles
