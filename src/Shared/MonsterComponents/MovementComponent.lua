local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"
local CastRay = import "Shared/Utils/CastRay"

local MovementComponent = {}

MovementComponent.__index = MovementComponent


function MovementComponent:getDistanceToGoal()
    local f = Vector3.new(1,1,1)
    return (self.model.Head.Position*f - self.goal*f).magnitude
end

function MovementComponent:setGoal(goal)
    self.goal = goal
end

function MovementComponent:walkToGoal()
    self.walking = true
    self.lookAtGoal = (self.goal)
    self.moveToGoal = (self.goal)
end

function MovementComponent:stop()
    self.walking = false
    self.moveToGoal = nil
end

function MovementComponent:setStopped(isStopped)
	self.stopOverride = isStopped
end

function MovementComponent:jump()

	if self.stopOverride then
		return
	end

    if not self.jumpEnd then
        self.jumpEnd = tick()
	end

    if tick() > self.nextJump then
        Messages:send("PlaySound", "AnimalJump", self.model.PrimaryPart.Position)
        Messages:send("PlayParticle", "JumpParticle", 10, self.model.PrimaryPart.Position)
        self.jumpEnd = tick() + self.jumpLength
        self.nextJump = tick() + self.jumpDebounce
    end
end

function MovementComponent:goToGoal(dt)
    if not self.lastGoal then
        self.lastGoal = self.goal
        self.stuckTime = 0
    end
	if self.stuckTime > .5 then
        self:jump()
        self:walkToGoal()
    else
        self:walkToGoal()
    end
    self:evaluateStuckness(dt)
end

function MovementComponent:evaluateStuckness(dt)
    if self.walking then
        if (self.model.PrimaryPart.Velocity*Vector3.new(1,0,1)).magnitude < self.speed*.5 then
            self.stuckTime = self.stuckTime + dt
        else
            self.stuckTime = 0
        end
    else
        self.stuckTime = 0
    end
end

function MovementComponent:floorRay(dt)
    local start = self.model.HumanoidRootPart.Position + (self.model.HumanoidRootPart.Velocity*dt)
    local hit, pos, normal = CastRay(start, Vector3.new(0,-8,0), {self.model})

    if hit then
        self.lastNormal = normal
    end

    return hit
end

function MovementComponent:move(hit)
    if self.moveToGoal then
        self.model.HumanoidRootPart.BodyVelocity.Velocity = self.model.HumanoidRootPart.CFrame.lookVector * self.speed
        if self.jumping and hit then
            self.model.HumanoidRootPart.BodyVelocity.Velocity = self.model.HumanoidRootPart.BodyVelocity.Velocity + Vector3.new(0,2000,0)
		end
		self.model.HumanoidRootPart.BodyVelocity.Velocity = self.model.HumanoidRootPart.BodyVelocity.Velocity
    else
        self.model.HumanoidRootPart.BodyVelocity.Velocity = Vector3.new()
	end
	if self.stopOverride then
		self.model.HumanoidRootPart.BodyVelocity.Velocity = Vector3.new()
	end
end

function MovementComponent:checkIfShouldBeMoving(dt)
    if self.goal then
        local distance = self:getDistanceToGoal()
        if distance > self.closenessThreshold then
            self:goToGoal(dt)
        else
            self:stop()
            self.stuckTime = 0
        end
    else
        self:stop()
    end
end

function MovementComponent:alignToNormal()
    local goalGyroCF =  self.model.HumanoidRootPart.BodyGyro.CFrame

    if self.lookAtGoal then
        goalGyroCF = CFrame.new(self.model.HumanoidRootPart.Position*Vector3.new(1,0,1), self.lookAtGoal*Vector3.new(1,0,1))
    end

    if self.lastNormal and self.lookAtGoal then

        local goalOffset = (self.lookAtGoal*Vector3.new(1,0,1)) - (self.model.HumanoidRootPart.Position*Vector3.new(1,0,1))
        local yGoal = math.atan2(goalOffset.Z, -goalOffset.X) + math.pi / 2

        local normal = self.lastNormal
        local lookVector = Vector3.new(0, 0, -1)
        local rightVector = Vector3.new(1, 0, 0)

        local tilt = math.asin(lookVector:Dot(normal))
        local roll = math.asin(rightVector:Dot(normal))
        local floorCF = CFrame.Angles(-tilt, 0, -roll)

        goalGyroCF = CFrame.new(self.model.HumanoidRootPart.Position) * floorCF * CFrame.Angles(0, yGoal, 0)

    end

    self.model.HumanoidRootPart.BodyGyro.CFrame = goalGyroCF
end

function MovementComponent:handleJumpForces()
    if self.jumpEnd and tick() < self.jumpEnd then
        self.maxYVelocity = self.jumpVelocity
        self.jumping = true
    else
        self.jumping = false
        self.maxYVelocity = 0
    end

    if self.jumping then
        self.animationComponent:playTrack("Falling")
    else
        self.animationComponent:stopTrack("Falling")
	end

	if self.stopOverride then
		self.maxYVelocity = 0
	end

    self.model.HumanoidRootPart.BodyVelocity.MaxForce = Vector3.new(1000000,self.maxYVelocity or 0,1000000)
end

function MovementComponent:step(dt)
    if self.rideableComponent:isMounted() then

    else

        local hit = self:floorRay(dt)

        self:alignToNormal()

        self:handleJumpForces()

        self:move(hit)

        self:checkIfShouldBeMoving(dt)

    end
end

function MovementComponent:setSpeedMultiplier(n)
	self.speedMultiplier = n
end

function MovementComponent:init(model, movementProperties)
    self.model = model
    self.speed = movementProperties.speed
    self.jumpDebounce = movementProperties.jumpDebounce
    self.closenessThreshold = movementProperties.closenessThreshold
    self.jumpLength = movementProperties.jumpLength
    self.rideableComponent = movementProperties.rideableComponent
    self.animationComponent = movementProperties.animationComponent
	self.jumpVelocity = movementProperties.jumpVelocity

	self.speedMultiplier = 1

    local speedValue = Instance.new("IntValue", model)
    speedValue.Name = "Speed"
    speedValue.Value = movementProperties.speed
end

function MovementComponent.new()
    local class = {}
    class.stuckTime = 0
    class.nextJump = 0
    class.computingPath = false
    return setmetatable(class, MovementComponent)
end

return MovementComponent
