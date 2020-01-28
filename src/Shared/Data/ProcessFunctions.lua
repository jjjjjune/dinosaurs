local import = require(game.ReplicatedStorage.Shared.Import)
local GetTimer = import "Shared/Utils/GetTimer"
local Messages = import "Shared/Utils/Messages"

local ProcessParticlesFolder = game.ServerStorage.ProcessParticles

local function addProcessParticle(material, processName)
    local particle = ProcessParticlesFolder:FindFirstChild(processName)
    if particle then
        local found = false 
        local children = material:GetChildren()
        for _, child in pairs(children) do
            if child:IsA("ParticleEmitter") and child.Name == processName then
                found = true
            end
        end
        if not found then
            local newParticle = particle:Clone()
            newParticle.Parent = material
        end
    end
end

local ProcessFunctions = {}

ProcessFunctions.Wood = {}
ProcessFunctions.Wood.Fire = function(material)
    local timer = GetTimer(material, "FireTick")
    if timer.hasBeen(10) then
        timer.advance()
        local amount = .2
        local threshold = .3
        material.Size = material.Size - Vector3.new(math.max(amount, material.Size.X*.15), math.max(amount, material.Size.Y*.15),math.max(amount, material.Size.Z*.15))
        if material.Size.Y < threshold or material.Size.Z < threshold or material.Size.X < threshold then
            Messages:send("DestroyMaterial", material)
        end
    end
    addProcessParticle(material, "Fire")
end
ProcessFunctions.Metal = {}
ProcessFunctions.Metal.Fire = function(material)
    addProcessParticle(material, "Fire")
end

ProcessFunctions.Coal = {}
ProcessFunctions.Coal.Fire = function(material)
    addProcessParticle(material, "Fire")
end

return ProcessFunctions