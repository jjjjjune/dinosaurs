local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"
local CastRay = import "Shared/Utils/CastRay"

local MovementComponent = {}

MovementComponent.__index = MovementComponent

function MovementComponent:setGoal(goal)
    self._goal = goal
end

function MovementComponent:setStopped(isStopped)
	self._stopOverride = isStopped
	self._stuckTime = 0
end

function MovementComponent:setLookAtGoal(goal)
	self._lookAtGoal = goal
end

function MovementComponent:_walkToGoal()
    self._walking = true
    self._lookAtGoal = (self._goal)
    self._moveToGoal = (self._goal)
end

function MovementComponent:_getDistanceToGoal()
    local f = Vector3.new(1,1,1)
    return (self.model.Head.Position*f - self._goal*f).magnitude
end

function MovementComponent:_stop()
    self._walking = false
    self._moveToGoal = nil
end

function MovementComponent:_jump()
	if self._stopOverride then
		return
	end

    if not self._jumpEnd then
        self._jumpEnd = tick()
	end

    if tick() > self._nextJump then
        Messages:send("PlaySound", "AnimalJump", self.model.PrimaryPart.Position)
        Messages:send("PlayParticle", "JumpParticle", 10, self.model.PrimaryPart.Position)
        self._jumpEnd = tick() + self._jumpLength
        self._nextJump = tick() + self._jumpDebounce
    end
end

function MovementComponent:_goToGoal(dt)
    if not self._lastGoal then
        self._lastGoal = self._goal
        self._stuckTime = 0
    end
	if self._stuckTime > .5 then
        self:_jump()
        self:_walkToGoal()
    else
        self:_walkToGoal()
    end
    self:_evaluateStuckness(dt)
end

function MovementComponent:_evaluateStuckness(dt)
    if self._walking then
        if (self.model.PrimaryPart.Velocity*Vector3.new(1,0,1)).magnitude < self._speed*.5 then
            self._stuckTime = self._stuckTime + dt
        else
            self._stuckTime = 0
        end
    else
        self._stuckTime = 0
    end
end

function MovementComponent:_floorRay(dt)
    local start = self.model.HumanoidRootPart.Position + (self.model.HumanoidRootPart.Velocity*dt)
    local hit, pos, normal = CastRay(start, Vector3.new(0,-8,0), {self.model})

    if hit then
        self._lastNormal = normal
    end

    return hit
end

function MovementComponent:_move(hit)
    if self._moveToGoal then
        self.model.HumanoidRootPart.BodyVelocity.Velocity = self.model.HumanoidRootPart.CFrame.lookVector * self._speed
        if self._jumping and hit then
            self.model.HumanoidRootPart.BodyVelocity.Velocity = self.model.HumanoidRootPart.BodyVelocity.Velocity + Vector3.new(0,2000,0)
		end
		self.model.HumanoidRootPart.BodyVelocity.Velocity = self.model.HumanoidRootPart.BodyVelocity.Velocity
    else
        self.model.HumanoidRootPart.BodyVelocity.Velocity = Vector3.new()
	end
	if self._stopOverride then
		self.model.HumanoidRootPart.BodyVelocity.Velocity = Vector3.new()
	end
end

function MovementComponent:_checkIfShouldBeMoving(dt)
    if self._goal then
        local distance = self:_getDistanceToGoal()
        if distance > self._closenessThreshold then
            self:_goToGoal(dt)
        else
            self:_stop()
            self._stuckTime = 0
        end
    else
        self:_stop()
    end
end

function MovementComponent:_alignToNormal()
    local goalGyroCF =  self.model.HumanoidRootPart.BodyGyro.CFrame

    if self._lookAtGoal then
        goalGyroCF = CFrame.new(self.model.HumanoidRootPart.Position*Vector3.new(1,0,1), self._lookAtGoal*Vector3.new(1,0,1))
    end

    if self._lastNormal and self._lookAtGoal then

        local goalOffset = (self._lookAtGoal*Vector3.new(1,0,1)) - (self.model.HumanoidRootPart.Position*Vector3.new(1,0,1))
        local yGoal = math.atan2(goalOffset.Z, -goalOffset.X) + math.pi / 2

        local normal = self._lastNormal
        local lookVector = Vector3.new(0, 0, -1)
        local rightVector = Vector3.new(1, 0, 0)

        local tilt = math.asin(lookVector:Dot(normal))
        local roll = math.asin(rightVector:Dot(normal))
        local floorCF = CFrame.Angles(-tilt, 0, -roll)

        goalGyroCF = CFrame.new(self.model.HumanoidRootPart.Position) * floorCF * CFrame.Angles(0, yGoal, 0)
    end

    self.model.HumanoidRootPart.BodyGyro.CFrame = goalGyroCF
end

function MovementComponent:_handleJumpForces()
    if self._jumpEnd and tick() < self._jumpEnd then
        self._maxYVelocity = self._jumpVelocity
        self._jumping = true
    else
        self._jumping = false
        self._maxYVelocity = 0
    end

    if self._jumping then
        self._animationComponent:playTrack("Falling")
    else
        self._animationComponent:stopTrack("Falling")
	end

	if self._stopOverride then
		self._maxYVelocity = 0
	end

    self.model.HumanoidRootPart.BodyVelocity.MaxForce = Vector3.new(1000000,self._maxYVelocity or 0,1000000)
end

function MovementComponent:step(dt)
    if self._rideableComponent:isMounted() then

    else
        local hit = self:_floorRay(dt)

        self:_alignToNormal()
        self:_handleJumpForces()
        self:_move(hit)
        self:_checkIfShouldBeMoving(dt)
    end
end

function MovementComponent:init(model, movementProperties)
    self.model = model
    self._speed = movementProperties.speed
    self._jumpDebounce = movementProperties.jumpDebounce
    self._closenessThreshold = movementProperties.closenessThreshold
    self._jumpLength = movementProperties.jumpLength
    self._rideableComponent = movementProperties.rideableComponent
    self._animationComponent = movementProperties.animationComponent
	self._jumpVelocity = movementProperties.jumpVelocity

    local speedValue = Instance.new("IntValue", model)
    speedValue.Name = "Speed"
    speedValue.Value = movementProperties.speed
end

function MovementComponent.new()
    local class = {}
    class._stuckTime = 0
    class._nextJump = 0
    return setmetatable(class, MovementComponent)
end

return MovementComponent
