local import = require(game.ReplicatedStorage.Shared.Import)

local AnimationComponent = {}

AnimationComponent.__index = AnimationComponent

function AnimationComponent:playTrack(trackName)
    if not self.tracks[trackName].IsPlaying then
        self.tracks[trackName]:Play()
    end
end

function AnimationComponent:stopTrack(trackName)
    self.tracks[trackName]:Stop(.5)
end

function AnimationComponent:init(model, animations)
    self.model = model
    self.humanoid = model.Humanoid
    self.animationInstances = {}
    self.tracks = {}
    for animationName, id in pairs(animations) do
        local instance = Instance.new("Animation", model)
        instance.Name = animationName
        instance.AnimationId = id
        self.animationInstances[animationName] = instance
        self.tracks[animationName] = self.humanoid:LoadAnimation(instance)
    end
    self:playTrack("Idle")
    self.humanoid.Running:connect(function(speed)
        if speed > 1 then
            self:playTrack("Walking")
        else
            self:stopTrack("Walking")
        end
    end)
end

function AnimationComponent.new()
    local class = {}
    return setmetatable(class, AnimationComponent)
end

return AnimationComponent