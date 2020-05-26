local import = require(game.ReplicatedStorage.Shared.Import)

local TameableComponent = {}

TameableComponent.__index = TameableComponent

function TameableComponent:init(model, props)
    self.model = model
    self.setNameRemote = Instance.new("RemoteEvent", model)
    self.setNameRemote.Name = "Set Name"
    self.rideRemote = Instance.new("RemoteEvent", model)
    self.rideRemote.Name = "Ride"
    self.followRemote = Instance.new("RemoteEvent", model)
    self.followRemote.Name = "Toggle Follow"
end

function TameableComponent.new()
    local class = {}
    return setmetatable(class, TameableComponent)
end