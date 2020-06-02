local import = require(game.ReplicatedStorage.Shared.Import)

local CollectionService = game:GetService("CollectionService")

local CastRay = import "Shared/Utils/CastRay"

local IdleComponent = {}

IdleComponent.__index = IdleComponent

function IdleComponent:getIdleMoveDuration()
    return 15
end

function IdleComponent:getIdleOffset()
    return Vector3.new(math.random(-50,50), 0, math.random(-50,50))
end

function IdleComponent:getIdlePosition()
    if tick() > self.nextIdleMovement then
        self.nextIdleMovement = tick() + self:getIdleMoveDuration()
        self.idlePosition = self.spawnPosition + self:getIdleOffset()
        local hit, pos = CastRay(self.idlePosition, Vector3.new(0,-100,0))
        self.idlePosition = pos
    end
    --[[local debugPart = Instance.new("Part", workspace)
    CollectionService:AddTag(debugPart, "RayIgnore")
    debugPart.CanCollide = false
    debugPart.Color = Color3.new(0,0,1)
    debugPart.Anchored = true
    debugPart.CFrame = CFrame.new(self.idlePosition)
    debugPart.Size = Vector3.new(1,1,1)--]]
    return self.idlePosition
end

function IdleComponent:init(model)
    self.model = model
    self.spawnPosition = self.model.PrimaryPart.Position
end

function IdleComponent:step(dt)

end

function IdleComponent.new()
    local class = {}
    class.nextIdleMovement = 0
    return setmetatable(class, IdleComponent)
end

return IdleComponent