local import = require(game.ReplicatedStorage.Shared.Import)

local CollectionService = game:GetService("CollectionService")

local Messages = import "Shared/Utils/Messages"

local TouchComponent = {}
TouchComponent.__index = TouchComponent

local HIT_DEBOUNCE = .75

function TouchComponent:_onHitSpikyThing(part)

    Messages:send("ReportCollision", self.model, part.Parent)

    local dir = CFrame.new(self.model.PrimaryPart.Position, part.Position).lookVector
    dir = dir + Vector3.new(0,-1,0)

    Messages:send("Knockback", self.model, -dir*40, .2)

end

function TouchComponent:_onHitFastItem(part)
	local dir = CFrame.new(self.model.PrimaryPart.Position, part.Position).lookVector
    dir = dir + Vector3.new(0,-1,0)

    Messages:send("Knockback", self.model, -dir*40, .2)
end

function TouchComponent:_onHitboxContact(part)
    if CollectionService:HasTag(part.Parent, "FreshWater") then
        Messages:send("ReportCollision", self.model, part.Parent)
	end
	if not self._immunities.Spiky then
		if CollectionService:HasTag(part.Parent, "Spiky") then
			if tick() - self._lastContact > HIT_DEBOUNCE then
				self:_onHitSpikyThing(part)
				self._lastContact = tick()
			end
		end
	end
	-- if CollectionService:hasTag(part.Parent, "Item") and not part.Parent:FindFirstChild("ObjectWeld", true) then
	-- 	if part.Velocity.magnitude > 10 then
	-- 		self:_onHitFastItem(part)
	-- 	end
	-- end
end

function TouchComponent:init(model, props)
    self.model = model
	self._lastContact = tick()
	self._nextCanTouchDamage = {}
    model.Hitbox.Touched:connect(function(hit)
        self:_onHitboxContact(hit)
	end)
	self._shouldDamageOnTouch = props.shouldDamageOnTouch
	self._damageTypeOnTouch = props.damageTypeOnTouch
	self._damageValueOnTouch = props.damageValueOnTouch
	self._immunities = props.immunities or {}
end

function TouchComponent:step(dt)
    if not self._nextCollide then
        self._nextCollide = tick() + .5
    else
        if tick() > self._nextCollide then
            self._nextCollide = tick() + .5
            local parts = self.model.Hitbox:GetTouchingParts()
            for _, p in pairs(parts) do
                if p.Parent ~= self.model then
                    self:_onHitboxContact(p)
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
