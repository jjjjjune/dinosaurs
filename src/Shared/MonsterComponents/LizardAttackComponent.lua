local import = require(game.ReplicatedStorage.Shared.Import)

local LizardAttackComponent = {}

LizardAttackComponent.__index = LizardAttackComponent

function LizardAttackComponent:init(model, animationComponent, targetComponent)
    self.model = model
    self.animationComponent = animationComponent
    self.targetComponent = targetComponent
    self.rope = self.model.TongueStart.RopeConstraint
    self.rope.Length = 0
end

function LizardAttackComponent:canAttack()
    return tick() > self.nextAttack
end

function LizardAttackComponent:initializeAttack(target)
    self.attacking = true
    self.attackStart = tick()
    self.nextAttack = tick() + 8
    self.chargeEnd = tick() + 2
    self.attackEnd = self.chargeEnd + .25
    self.attackTarget = target
end

function LizardAttackComponent:attack(target)
    local len = (target.PrimaryPart.Position - self.model.TongueStart.Position).magnitude
    self.maxRopeLength = len
    self.rope.Length = len
    self.model.TongueEnd.CFrame = target.PrimaryPart.CFrame
    self.tongueWeld = Instance.new("WeldConstraint", self.model.TongueEnd)
    self.tongueWeld.Part0 = self.model.TongueEnd
    self.tongueWeld.Part1 = target.PrimaryPart
end

function LizardAttackComponent:stepAttack()
    if tick() < self.chargeEnd then
        self.hasLaunched = false
        self.animationComponent:playTrack("ChargeAttack")
    elseif tick() < self.attackEnd then
        self.animationComponent:stopTrack("ChargeAttack")
        if not self.hasLaunched then
            self.animationComponent:playTrack("Attack")
            self.hasLaunched = true
            self:attack(self.attackTarget)
        else
            local maxTime = .25
            local timeUntilEnd = (self.attackEnd - tick())/maxTime
            self.rope.Length = self.maxRopeLength*timeUntilEnd
        end
    else
        self.tongueWeld:Destroy()
        self.attackTarget:Destroy()
        self.animationComponent:stopTrack("ChargeAttack")
        self.animationComponent:stopTrack("Attack")
        self.attacking = false
    end
end

function LizardAttackComponent:step(dt)
    if self.attacking then
        self:stepAttack()
    else
        local target = self.targetComponent:getTarget()
        if target then
            local distance = self.targetComponent.state.distanceFromTarget
            local attackDistance = 50
            print("distance is: ", distance)
            if distance < attackDistance then
                if self:canAttack() then
                    self:initializeAttack(target)
                end
            end
        end
    end
end

function LizardAttackComponent.new()
    local class = {}
    class.nextAttack = tick()
    return setmetatable(class, LizardAttackComponent)
end

return LizardAttackComponent