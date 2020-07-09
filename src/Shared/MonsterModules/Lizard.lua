local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local MovementComponent = import "Shared/MonsterComponents/MovementComponent"
local AnimationComponent = import "Shared/MonsterComponents/AnimationComponent"
local IdleComponent = import "Shared/MonsterComponents/IdleComponent"
local TargetComponent = import "Shared/MonsterComponents/TargetComponent"
local LizardAttackComponent = import "Shared/MonsterComponents/LizardAttackComponent"
local TouchComponent = import "Shared/MonsterComponents/TouchComponent"
local RideableComponent = import "Shared/MonsterComponents/RideableComponent"
local TameableComponent = import "Shared/MonsterComponents/TameableComponent"

local Lizard = {}

Lizard.__index = Lizard

function Lizard:step()
	if not self.model.PrimaryPart then
		self.mainThread:disconnect()
		self.model:Destroy()
		return
	end
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

    self.idleComponent = IdleComponent.new()
    self.idleComponent:init(self.model)

    self.rideableComponent = RideableComponent.new()
    self.rideableComponent:init(self.model, {idleComponent = self.idleComponent})

    self.animationComponent = AnimationComponent.new()
    self.animationComponent:init(self.model, {
        Walking = "rbxassetid://5009072693",
        Attack = "rbxassetid://5009197262",
        ChargeAttack = "rbxassetid://5009187418",
        Falling = "rbxassetid://5009163593",
        Idle = "rbxassetid://5009118786",
        Speak = "rbxassetid://5037809602",
        Dead = "rbxassetid://5079811280"
    })

    self.movementComponent = MovementComponent.new()
    self.movementComponent:init(self.model, {
        jumpDebounce = 2,
        speed = 20,
        closenessThreshold = 11,
        jumpLength = .5,
        rideableComponent = self.rideableComponent,
        animationComponent = self.animationComponent,
        jumpVelocity = 800000
    })

    self.targetComponent = TargetComponent.new()
    self.targetComponent.wantItem = "Banana"
    self.targetComponent.wantedEnemyTags = {"Character", "Alpaca"}
    self.targetComponent:init(self.model, {
        giveUpTargetTime = 10,
    })

    self.attackComponent = LizardAttackComponent.new()
    self.attackComponent:init(self.model, {
        animationComponent = self.animationComponent,
        targetComponent = self.targetComponent,
        attackDistance = 45,
        damage = 15,
        damageType = "poison",
        reloadTime = 4,
        chargeTime = 2,
        spawnAttackDebounce = 4,
        rideableComponent = self.rideableComponent,
    })

    self.touchComponent = TouchComponent.new()
    self.touchComponent:init(self.model)

    self.tameableComponent = TameableComponent.new()
    self.tameableComponent:init(self.model)

    self.drops = {
		{name = "Skull", min = 1, max = 2, chance = 45},
		{name = "Bone", min = 1, max = 2, chance = 45},
		{name = "Raw Meat", min = 1, max = 2, chance = 35},
    }

    self.hitNoises = {
        "Hiss1",
        "Hiss2",
        "Hiss3",
        "Hiss4",
        "Hiss5",
        "Hiss6"
    }

    self.lastHealth = self.model.Health.Value

    self.model.Health.Changed:connect(function()

        if self.model.Health.Value < self.lastHealth then
            Messages:send("PlaySound", self.hitNoises[math.random(1, #self.hitNoises)], self.model.PrimaryPart.Position)
        end

        self.lastHealth = self.model.Health.Value

        if self.model.Health.Value <= 0 then
            self:die()
        else
            self.attackComponent:onDamaged()
        end

    end)

    self.mainThread = game:GetService("RunService").Stepped:connect(function(t, dt)

		self:step(dt)

		self.movementComponent:step(dt)
        self.targetComponent:step(dt)
        self.idleComponent:step(dt)
        self.attackComponent:step(dt)
        self.touchComponent:step(dt)
        self.rideableComponent:step(dt)

		if not self.model.PrimaryPart then
			return
		end

        local speed = (self.model.PrimaryPart.Velocity*Vector3.new(1,0,1)).magnitude
        local speedPercent = math.max(.01, speed/self.animationScaledWalkspeed)
        local weightPercent = math.max(.01, speed/2)

        self.animationComponent:playTrack("Walking", speedPercent, weightPercent)
    end)

    self.model.PrimaryPart:SetNetworkOwner()
end

function Lizard:makeDropItems()
    local Items = import "Server/Systems/Items"

    local dropTable = self.drops
    local itemsToMake = {}

    local function random(min, max)
        local randomObj = Random.new()
        return randomObj:NextInteger(min, max)
    end

    for _, itemTable in pairs(dropTable) do
        if itemTable.min > 0 then
            for _ = 1, itemTable.min do
                table.insert(itemsToMake, itemTable.name)
            end
        end
        local remaining = math.random(0, itemTable.max - itemTable.min)
        if remaining > 0 then
            for _ = 1, remaining do
                local n = random(1, 100)
                if n < itemTable.chance then
                    table.insert(itemsToMake, itemTable.name)
                end
            end
        end
    end

    for _, itemName in pairs(itemsToMake) do
        local newPos = self.model.PrimaryPart.Position + Vector3.new(random(-5,5), 0, random(-5,5))
        Items.createItem(itemName, newPos)
        Messages:send("PlayParticle", "DeathSmoke",  10, newPos)
    end
end

function Lizard:die()

    self.mainThread:disconnect()

    self.rideableComponent:dismount()

    if not self.isDead then
        self.isDead = true
        self.model.Torso.TextureID = "rbxassetid://5079825969"
        self.animationComponent:stopTrack("Idle")
        self.animationComponent:playTrack("Dead")
        self.model.Head.RotVelocity = Vector3.new(math.random(), math.random(), math.random())*10
        self.model.HumanoidRootPart.BodyGyro:Destroy()
        self.model.HumanoidRootPart.BodyVelocity:Destroy()
		self.model.Torso.CanCollide = true

		for _, v in pairs(self.model:GetChildren()) do
            if v:IsA("BasePart") then
				v.Massless = false
				v.CustomPhysicalProperties = PhysicalProperties.new(Enum.Material.Metal)
            end
        end
    else
		local ConstraintManager = import "Server/Systems/ConstraintManager"
		ConstraintManager.removeAllRelevantConstraints(self.model)
		self:makeDropItems()
        self.model:Destroy()
    end
end

function Lizard.new()
    local class = {}
    return setmetatable(class, Lizard)
end

return Lizard
