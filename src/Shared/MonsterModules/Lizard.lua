local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local MovementComponent = import "Shared/MonsterComponents/MovementComponent"
local AnimationComponent = import "Shared/MonsterComponents/AnimationComponent"
local IdleComponent = import "Shared/MonsterComponents/IdleComponent"
local TargetComponent = import "Shared/MonsterComponents/TargetComponent"
local LizardAttackComponent = import "Shared/MonsterComponents/LizardAttackComponent"

local Lizard = {}

Lizard.__index = Lizard

function Lizard:step()
    if not self.attackComponent.attacking then 
        local target = self.targetComponent:getTarget()
        if target and target.PrimaryPart then
            self.movementComponent:setGoal(target.PrimaryPart.Position)
        else
            self.movementComponent:setGoal(self.idleComponent:getIdlePosition())
        end
    else
        self.movementComponent:setGoal(nil)
    end
end

function Lizard:init(model)
    self.model = model

    self.animationScaledWalkspeed = 22 -- this is about the speed at which the animation expects the lizzy to travel

    self.movementComponent = MovementComponent.new()
    self.movementComponent:init(self.model, {
        jumpDebounce = 2,
        speed = 16,
        closenessThreshold = 11,
        jumpLength = .5,
    })

    self.animationComponent = AnimationComponent.new()
    self.animationComponent:init(self.model, {
        Walking = "rbxassetid://5009072693",
        Attack = "rbxassetid://5009197262",
        ChargeAttack = "rbxassetid://5009187418",
        Falling = "rbxassetid://5009163593",
        Idle = "rbxassetid://5009118786",
    })

    self.idleComponent = IdleComponent.new()
    self.idleComponent:init(self.model)

    self.targetComponent = TargetComponent.new()
    self.targetComponent.wantedItems = {"Log"}
    self.targetComponent.wantedEnemyTags = {}
    self.targetComponent:init(self.model)

    self.attackComponent = LizardAttackComponent.new()
    self.attackComponent:init(self.model, self.animationComponent, self.targetComponent)

    self.mainThread = game:GetService("RunService").Stepped:connect(function(t, dt)
        self.movementComponent:step(dt)
        self.targetComponent:step(dt)
        self.idleComponent:step(dt)
        self.attackComponent:step(dt)
        self:step(dt)
        local speed = (self.model.PrimaryPart.Velocity*Vector3.new(1,0,1)).magnitude
        local speedPercent = speed/self.animationScaledWalkspeed
        local weightPercent = speed/2
        self.animationComponent:playTrack("Walking", speedPercent, weightPercent)
        --[[if self.movementComponent.walking then
            
        else
            self.animationComponent:stopTrack("Walking")
        end--]]
    end)

    self.model.PrimaryPart:SetNetworkOwner()
end

function Lizard.new()
    local class = {}
    return setmetatable(class, Lizard)
end

return Lizard