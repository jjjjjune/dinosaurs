local import = require(game.ReplicatedStorage.Shared.Import)

local CollectionService = game:GetService("CollectionService")

local Messages = import "Shared/Utils/Messages"

local TouchComponent = {}
TouchComponent.__index = TouchComponent

function TouchComponent:_onHitboxContact(part)
    if CollectionService:HasTag(part.Parent, "FreshWater") then
        Messages:send("ReportCollision", self.model, part.Parent)
	end
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
