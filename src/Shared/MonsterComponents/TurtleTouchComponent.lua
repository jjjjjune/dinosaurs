local import = require(game.ReplicatedStorage.Shared.Import)

local CollectionService = game:GetService("CollectionService")

local Messages = import "Shared/Utils/Messages"

local Damage = import "Shared/Utils/Damage"

local HIT_DEBOUNCE = .75

local TouchComponent = {}
TouchComponent.__index = TouchComponent

function TouchComponent:onHitSpikyThing(part)

    Messages:send("ReportCollision", self.model, part.Parent)

    local dir = CFrame.new(self.model.PrimaryPart.Position, part.Position).lookVector
    dir = dir + Vector3.new(0,-1,0)

    Messages:send("Knockback", self.model, -dir*40, .2)

end

function TouchComponent:passiveDamage(victim)
	if self.shouldDamageOnTouch then
		if not self.nextCanTouchDamage[victim] then
			self.nextCanTouchDamage[victim] = 0
		end
		if tick() > self.nextCanTouchDamage[victim] then
			local dir = CFrame.new(victim.PrimaryPart.Position, self.model.PrimaryPart.Position).lookVector
			Messages:send("Knockback", victim, dir*-100, .3)
			Damage(victim, {damage = self.damageValueOnTouch, type = self.damageTypeOnTouch, serverApplication = true})
			self.nextCanTouchDamage[victim] = tick() + 1
		end
	end
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

	-- if self.shouldDamageOnTouch then
	-- 	if CollectionService:HasTag(part.Parent, "Monster") or CollectionService:HasTag(part.Parent, "Character") then
	-- 		if self.model.Name ~= part.Parent.Name then
	-- 			self:passiveDamage(part.Parent)
	-- 		end
	-- 	end
	-- end
end

function TouchComponent:init(model, props)
    self.model = model
	self.lastContact = tick()
	self.nextCanTouchDamage = {}
    model.Hitbox.Touched:connect(function(hit)
        self:onHitboxContact(hit)
	end)
	self.shouldDamageOnTouch = props.shouldDamageOnTouch
	self.damageTypeOnTouch = props.damageTypeOnTouch
	self.damageValueOnTouch = props.damageValueOnTouch
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
