local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local MovementComponent = import "Shared/MonsterComponents/MovementComponent"
local AnimationComponent = import "Shared/MonsterComponents/AnimationComponent"
local IdleComponent = import "Shared/MonsterComponents/IdleComponent"
local TargetComponent = import "Shared/MonsterComponents/TargetComponent"

local Lizard = {}

Lizard.__index = Lizard

function Lizard:step()
    local target = self.targetComponent:getTarget()
    if target then
        self.movementComponent:setGoal(target.PrimaryPart.Position)
    else
        self.movementComponent:setGoal(self.idleComponent:getIdlePosition())
    end
end

function Lizard:init(model)
    self.model = model

    self.movementComponent = MovementComponent.new()
    self.movementComponent:init(self.model)

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
    self.targetComponent.wantedItems = {"Banana"}
    self.targetComponent.wantedEnemyTags = {}
    self.targetComponent:init(self.model)

    self.mainThread = game:GetService("RunService").Stepped:connect(function(t, dt)
        self.movementComponent:step(dt)
        self.targetComponent:step(dt)
        self.idleComponent:step(dt)
        self:step(dt)
    end)

end

function Lizard.new()
    local class = {}
    return setmetatable(class, Lizard)
end

return Lizard