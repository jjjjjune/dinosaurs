local import = require(game.ReplicatedStorage.Shared.Import)

local AnimationComponent = {}

AnimationComponent.__index = AnimationComponent

function AnimationComponent:playTrack(trackName, speed, weight)
    if not self.tracks[trackName].IsPlaying then
        self.tracks[trackName]:Play(.25)
    end
    if speed then
        self.tracks[trackName]:AdjustSpeed(speed)
    end
    if weight then
        self.tracks[trackName]:AdjustWeight(weight)
    end
end

function AnimationComponent:stopTrack(trackName)
    if self.tracks[trackName].IsPlaying then
        self.tracks[trackName]:Stop(.25)
    end
end

function AnimationComponent:init(model, animations)
    self.model = model
    self.animationInstances = {}
    self.tracks = {}
    for animationName, id in pairs(animations) do
        local instance = Instance.new("Animation", model)
        instance.Name = animationName
        instance.AnimationId = id
        self.animationInstances[animationName] = instance
        self.tracks[animationName] = self.model.AnimationController:LoadAnimation(instance)
    end
    self:playTrack("Idle")
end

function AnimationComponent.new()
    local class = {}
    return setmetatable(class, AnimationComponent)
end

return AnimationComponent