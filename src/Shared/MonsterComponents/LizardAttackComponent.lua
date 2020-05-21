local import = require(game.ReplicatedStorage.Shared.Import)

local CollectionService = game:GetService("CollectionService")

local Messages = import "Shared/Utils/Messages"

local Damage = import "Shared/Utils/Damage"

local LizardAttackComponent = {}

LizardAttackComponent.__index = LizardAttackComponent

function LizardAttackComponent:doDamage(target)
    if CollectionService:HasTag(target, "Item") then
        self.attackTarget:Destroy()
    else
        Damage(target, {damage = self.damage, type = self.damageType, serverApplication = true})
        --Messages:send("Knockback", target, self.model.PrimaryPart.CFrame.lookVector * 100)
    end
end

function LizardAttackComponent:canAttack(target)
    return (tick() > self.nextAttack) and (not self.attacking)
end

function LizardAttackComponent:initializeAttack(target)
    self.attacking = true
    self.attackStart = tick()
    self.nextAttack = tick() + self.reloadTime
    self.chargeEnd = tick() + self.chargeTime
    self.attackEnd = self.chargeEnd + .25
    self.attackTarget = target
    self.model.Head.Hiss:Play()
end

function LizardAttackComponent:attack(target)
    --Messages:send("PlayParticle", "Water", 10, self.model.TongueStart.Position)
    local len = (target.PrimaryPart.Position - self.model.TongueStart.Position).magnitude
    self.maxRopeLength = len
    self.rope.Length = len
    self.model.TongueEnd.CFrame = target.PrimaryPart.CFrame
    self.tongueWeld = Instance.new("WeldConstraint", self.model.TongueEnd)
    self.tongueWeld.Part0 = self.model.TongueEnd
    self.tongueWeld.Part1 = target.PrimaryPart
    Messages:send("PlaySound", "PaintballFireLight", self.model.Head.Position)
end

function LizardAttackComponent:stopAttack(didComplete)
    self.rope.Length = 0
    if self.tongueWeld then
        self.tongueWeld:Destroy()
    end
    if didComplete then
        self:doDamage(self.attackTarget)
        self.attackTarget = nil
    else
        self.attackTarget = nil
    end
    self.animationComponent:stopTrack("ChargeAttack")
    self.animationComponent:stopTrack("Attack")
    self.attacking = false
    self.model.Head.Hiss:Stop()
end

function LizardAttackComponent:attackIsStillValid()
    local distance = self.targetComponent.state.distanceFromTarget
    if not self.attackTarget.Parent then
        return false
    end
    return not (self.attackTarget.Parent:FindFirstChild("Humanoid")) and distance <= self.attackDistance
end

function LizardAttackComponent:stepAttack()
    if not self:attackIsStillValid() then
        Messages:send("PlaySound", "Hiss"..math.random(1,4).."", self.model.Head.Position)
        self.animationComponent:playTrack("Speak")
        self:stopAttack(false)
        self.nextAttack = tick() + 2
        return
    end
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
        Messages:send("PlaySound", "Lick"..math.random(1,4).."", self.model.Head.Position)
        self:stopAttack(true)
    end
end

function LizardAttackComponent:step(dt)
    if self.attacking then
        self:stepAttack()
    else
        local target = self.targetComponent:getTarget()
        if target then
            local distance = self.targetComponent.state.distanceFromTarget
            local attackDistance = self.attackDistance
            if distance < attackDistance then
                if self:canAttack(target) then
                    self:initializeAttack(target)
                end
            end
        end
    end
end

function LizardAttackComponent:init(model, properties)
    self.model = model
    self.animationComponent = properties.animationComponent
    self.targetComponent = properties.targetComponent
    self.attackDistance = properties.attackDistance
    self.reloadTime = properties.reloadTime
    self.damageType = properties.damageType
    self.chargeTime = properties.chargeTime
    self.damage = properties.damage
    self.rope = self.model.TongueStart.RopeConstraint
    self.rope.Length = 0
    self.nextAttack = tick() + 8
end

function LizardAttackComponent.new()
    local class = {}
    class.nextAttack = tick()
    return setmetatable(class, LizardAttackComponent)
end

return LizardAttackComponent