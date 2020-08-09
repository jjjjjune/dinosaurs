local import = require(game.ReplicatedStorage.Shared.Import)

local CollectionService = game:GetService("CollectionService")

local Messages = import "Shared/Utils/Messages"

local Damage = import "Shared/Utils/Damage"

local CastRay = import "Shared/Utils/CastRay"

local LizardAttackComponent = {}

LizardAttackComponent.__index = LizardAttackComponent

function LizardAttackComponent:doDamage(target)
    if CollectionService:HasTag(target, "Item") then
        Messages:send("PlayParticle", "PinkWater", 15, target.PrimaryPart.Position)
    else
        Damage(target, {damage = self.damage, type = self.damageType, serverApplication = true})
        --Messages:send("Knockback", target, self.model.PrimaryPart.CFrame.lookVector * 100)
	end
	print("doing damge')")
	if self.damageType == "fire" then
		print("set on fire")
		Messages:send("SetOnFire", target, 5)
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
    self.model.Head.Hiss.PlaybackSpeed = 1 + math.random(0,20)/100
    self.model.Head.Hiss:Play()
end

function LizardAttackComponent:isValidHitTarget(target)
    local condition1 = target:FindFirstChild("Health")
    local condition2 = target:FindFirstChild("Humanoid")
    local condition3 = CollectionService:HasTag(target, "Item") and target.Name == self.targetComponent.wantItem
    return target ~= self.model and (condition1 or condition2 or condition3)
end

function LizardAttackComponent:attack(target)
    --Messages:send("PlayParticle", "Water", 10, self.model.TongueStart.Position)
    local dir = (CFrame.new(self.model.Head.Position, self.attackTarget.PrimaryPart.Position).lookVector) * self.attackDistance
    local hit, pos = CastRay(self.model.Head.Position, dir, {self.model})
    if hit and hit:IsDescendantOf(self.attackTarget) then
        self.attackFailed = false
    else
        if self:isValidHitTarget(hit.Parent) then -- if the attack hits the wrong thing, but the thing it hits is a valid target also
            print("we hit funny thing")
            self.attackFailed = false
            self.attackTarget = hit.Parent
            target = hit.Parent
        else
            self.attackFailed = true
        end
    end
    local len = (target.PrimaryPart.Position - self.model.TongueStart.Position).magnitude
    self.maxRopeLength = len
    self.rope.Length = len
    self.model.TongueEnd.CFrame = target.PrimaryPart.CFrame
    if not self.attackFailed then
        self.tongueWeld = Instance.new("SpringConstraint", self.model.TongueEnd)
        self.springAttach1= Instance.new("Attachment", self.model.TongueEnd)
        self.springAttach2 = Instance.new("Attachment", target.PrimaryPart)
        self.tongueWeld.FreeLength = 1
        self.tongueWeld.LimitsEnabled = true
        if target:FindFirstChild("Humanoid") then
            self.tongueWeld.MaxLength = 14
        else
            self.tongueWeld.MaxLength = 2
        end
        self.tongueWeld.Attachment0 = self.springAttach1
        self.tongueWeld.Attachment1 = self.springAttach2
        self:doDamage(self.attackTarget)
    end
    Messages:send("PlaySound", "PaintballFireLight", self.model.Head.Position)
end

function LizardAttackComponent:onDamaged()
    self.nextCharge = tick() + .25
    self.cancelAttack = true
end

function LizardAttackComponent:onFinishedEating(target)
    Messages:send("PlaySound", "Lick"..math.random(1,4).."", self.model.Head.Position)
    if CollectionService:HasTag(target, "Item") then
        target:Destroy()
    end
end

function LizardAttackComponent:stopAttack(didComplete)
    self.rope.Length = 0
    if self.tongueWeld then
        self.tongueWeld:Destroy()
    end
    if self.springAttach1 then
        self.springAttach1:Destroy()
        self.springAttach2:Destroy()
        self.springAttach1 = nil
        self.springAttach2 = nil
    end
    if didComplete and (not self.attackFailed) then
        self:onFinishedEating(self.attackTarget)
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
    if self.cancelAttack then
        self.cancelAttack = nil
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
            self.rope.Length = math.max(1, self.maxRopeLength*timeUntilEnd)
        end
    else
        self:stopAttack(true)
    end
end

function LizardAttackComponent:step(dt)
    if self.attacking then
        self:stepAttack()
    else
        if not self.rideableComponent:isMounted() then
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
    self.rideableComponent = properties.rideableComponent
    self.nextAttack = tick() + properties.spawnAttackDebounce

    self.rope = self.model.TongueStart.RopeConstraint
    self.rope.Length = 0
end

function LizardAttackComponent.new()
    local class = {}
    class.nextAttack = tick()
    return setmetatable(class, LizardAttackComponent)
end

return LizardAttackComponent
