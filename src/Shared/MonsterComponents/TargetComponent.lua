local import = require(game.ReplicatedStorage.Shared.Import)

local TargetComponent = {}

TargetComponent.__index = TargetComponent

function TargetComponent:getTarget()

end

function TargetComponent:step()

end

function TargetComponent:init(model)
    self.model = model
end

function TargetComponent.new()
    local class = {}
    return setmetatable(class, TargetComponent)
end

return TargetComponent