local import = require(game.ReplicatedStorage.Shared.Import)

local CollectionService = game:GetService("CollectionService")

local Messages = import "Shared/Utils/Messages"

local MovementComponent = import "Shared/MonsterComponents/MovementComponent"
local AnimationComponent = import "Shared/MonsterComponents/AnimationComponent"
local IdleComponent = import "Shared/MonsterComponents/IdleComponent"
local TargetComponent = import "Shared/MonsterComponents/TurtleTargetComponent"
local TouchComponent = import "Shared/MonsterComponents/TurtleTouchComponent"
local RideableComponent = import "Shared/MonsterComponents/RideableComponent"
local TameableComponent = import "Shared/MonsterComponents/TameableComponent"

local RedTurtle = {}

RedTurtle.__index = RedTurtle

function RedTurtle:step()
	if not self.model.PrimaryPart then
		self.mainThread:disconnect()
		self.model:Destroy()
		return
	end
    local target = self.targetComponent:getTarget()
    local closeEnemy = self.targetComponent:hasCloseEnemy()
	if closeEnemy and not target then -- if we have a close enemy, and do not have an item nearby
		self.movementComponent:setStopped(true)
		self.animationComponent:playTrack("Hide", 1, 1, 0.05)
		self.animationComponent:playTrack("SpikesOut")
		self.animationComponent:stopTrack("Idle")
		self.touchComponent.damageOnTouch = true
		self.movementComponent:setLookAtGoal(closeEnemy.PrimaryPart.Position)
		CollectionService:AddTag(self.model, "Spiky")
	else
		self.movementComponent:setStopped(false)
		self.animationComponent:stopTrack("Hide")
		self.animationComponent:stopTrack("SpikesOut")
		self.animationComponent:playTrack("SpikesIn")
		self.animationComponent:playTrack("Idle")
		self.touchComponent.damageOnTouch = false
        if target and target.PrimaryPart then
            self.movementComponent:setGoal(target.PrimaryPart.Position)
        else
            self.movementComponent:setGoal(self.idleComponent:getIdlePosition())
		end
		CollectionService:RemoveTag(self.model, "Spiky")
	end
	if target and (CollectionService:HasTag(target, "Item") or CollectionService:HasTag(target, "Plant")) then
		local distance = self.targetComponent.state.distanceFromTarget
		if distance < 12 then
			self:eat(target)
		else
			self:stopEating()
		end
	else
		self:stopEating()
	end
end

function RedTurtle:eat(target)
	if target.Parent == nil then
		return
	end
	if not self.eatBeginTime then
		self.eatBeginTime = tick()
	end
	if self.lastFood ~= target then
		self.lastFood = target
		self.eatBeginTime = tick()
		Messages:send("PlaySound", "Lick"..math.random(1,4).."", self.model.Head.Position)
	end
	self.animationComponent:playTrack("Eat")
	if tick() - self.eatBeginTime > 4 then
		if CollectionService:HasTag(target, "Plant") then
			local cf = target.PrimaryPart.CFrame
			local Plants = import "Server/Systems/Plants"
			Plants.chopPlant(target)
			Plants.createPlant(target.Type.Value, cf.p, 1, false)
		else
			Messages:send("DestroyItem", target)
		end
		Messages:send("PlaySound", "Lick"..math.random(1,4).."", self.model.Head.Position)
	end
end

function RedTurtle:stopEating()
	self.eatBeginTime = tick()
	self.animationComponent:stopTrack("Eat")
end

function RedTurtle:init(model)
    self.model = model

    self.animationScaledWalkspeed = 10 -- this is about the speed at which the animation expects the animal to travel

    self.idleComponent = IdleComponent.new()
    self.idleComponent:init(self.model)

    self.rideableComponent = RideableComponent.new()
    self.rideableComponent:init(self.model, {idleComponent = self.idleComponent})

    self.animationComponent = AnimationComponent.new()
    self.animationComponent:init(self.model, {
        Walking = "rbxassetid://5704116230",
        Falling = "rbxassetid://5704119019",
        Idle = "rbxassetid://5706614653",
        Speak = "rbxassetid://5037809602",
		Dead = "rbxassetid://5706618821",
		SpikesIn = "rbxassetid://5704133423",
		SpikesOut = "rbxassetid://5704133131",
		Hide = "rbxassetid://5704143833",
		Eat = "rbxassetid://5711177087"
    })

    self.movementComponent = MovementComponent.new()
    self.movementComponent:init(self.model, {
        jumpDebounce = 2,
        speed = 10,
        closenessThreshold = 5,
        jumpLength = .5,
        rideableComponent = self.rideableComponent,
        animationComponent = self.animationComponent,
        jumpVelocity = 1050000
    })

    self.targetComponent = TargetComponent.new()
    self.targetComponent.fleeFromTags = {"Lizard", "Character"}
	self.targetComponent.wantItem = "None"
	self.targetComponent.wantPlant = "Cactus"
    self.targetComponent.wantedEnemyTags = {}
    self.targetComponent:init(self.model, {
		giveUpTargetTime = 10,
		rideableComponent = self.rideableComponent,
    })

    self.touchComponent = TouchComponent.new()
    self.touchComponent:init(self.model, {
		shouldDamageOnTouch = true,
		damageTypeOnTouch = "normal",
		damageValueOnTouch = 15,
	})

    self.tameableComponent = TameableComponent.new()
    self.tameableComponent:init(self.model)

    self.drops = {
		{name = "Skull", min = 1, max = 2, chance = 45},
		{name = "Bone", min = 1, max = 2, chance = 45},
		{name = "Raw Meat", min = 1, max = 2, chance = 35},
    }

    self.hitNoises = {
        "RedTurtle1",
        "RedTurtle2",
        "RedTurtle3",
    }

    self.lastHealth = self.model.Health.Value

    self.model.Health.Changed:connect(function()

        if self.model.Health.Value < self.lastHealth then
            Messages:send("PlaySound", self.hitNoises[math.random(1, #self.hitNoises)], self.model.PrimaryPart.Position)
        end

        self.lastHealth = self.model.Health.Value

        if self.model.Health.Value <= 0 then
            self:die()
        end

    end)

    self.mainThread = game:GetService("RunService").Stepped:connect(function(t, dt)
		self:step(dt)

        self.movementComponent:step(dt)
        self.targetComponent:step(dt)
        self.idleComponent:step(dt)
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

function RedTurtle:makeDropItems()
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
		local item = Items.createItem(itemName, newPos)
		item.Parent = workspace
        Messages:send("PlayParticle", "DeathSmoke",  10, newPos)
    end
end

function RedTurtle:die()

    self.mainThread:disconnect()

    self.rideableComponent:dismount()

    if not self.isDead then
        self.isDead = true
        self.animationComponent:stopTrack("Idle")
        self.animationComponent:playTrack("Dead")
        self.model.Head.RotVelocity = Vector3.new(math.random(), math.random(), math.random())*1
        for _, v in pairs(self.model:GetChildren()) do
            if v:IsA("BasePart") then
				v.Massless = false
				v.CustomPhysicalProperties = PhysicalProperties.new(Enum.Material.Metal)
            end
        end
        self.model.HumanoidRootPart.BodyGyro:Destroy()
        self.model.HumanoidRootPart.BodyVelocity:Destroy()
		self.model.Torso.CanCollide = true
		self.model.Collider.CanCollide = false
	else
		local ConstraintManager = import "Server/Systems/ConstraintManager"
		ConstraintManager.removeAllRelevantConstraints(self.model)
        self:makeDropItems()
        self.model:Destroy()
    end
end

function RedTurtle.new()
    local class = {}
    return setmetatable(class, RedTurtle)
end

return RedTurtle
