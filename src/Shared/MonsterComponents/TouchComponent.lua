local import = require(game.ReplicatedStorage.Shared.Import)

local CollectionService = game:GetService("CollectionService")

local Messages = import "Shared/Utils/Messages"

local HIT_DEBOUNCE = .75

local TouchComponent = {}
TouchComponent.__index = TouchComponent

function TouchComponent:onHitSpikyThing(part)

    Messages:send("ReportCollision", self.model, part.Parent)

    local dir = CFrame.new(self.model.PrimaryPart.Position, part.Position).lookVector
    dir = dir + Vector3.new(0,-1,0)

    Messages:send("Knockback", self.model, -dir*40, .2)

end

function TouchComponent:onHitboxContact(part)
    if CollectionService:HasTag(part.Parent, "Spiky") then
        if tick() - self.lastContact > HIT_DEBOUNCE then
            self:onHitSpikyThing(part)
            self.lastContact = tick()
        end
    end
    if CollectionService:HasTag(part.Parent, "FreshWater") then
        Messages:send("ReportCollision", self.model, part.Parent)
    end
end

function TouchComponent:init(model)
    self.model = model
    self.lastContact = tick()
    model.Hitbox.Touched:connect(function(hit)
        self:onHitboxContact(hit)
    end)
end

function TouchComponent:step(dt)
    if not self.nextCollide then
        self.nextCollide = tick() + .5
    else
        if tick() > self.nextCollide then
            self.nextCollide = tick() + .5
            local parts = self.model.Hitbox:GetTouchingParts()
            for _, p in pairs(parts) do
                if p.Parent ~= self.model then
                    self:onHitboxContact(p)
                end
            end
        end
    end
end

function TouchComponent.new()
    local class = {}
    return setmetatable(class, TouchComponent)
end

return TouchComponent