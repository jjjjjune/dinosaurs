local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"

local CollectionService = game:GetService("CollectionService")

local RideableComponent = {}

RideableComponent.__index = RideableComponent

function RideableComponent:canBeMounted(player)
    if player.Character then
        if not self.rider then
            return true
        end
    end
    return false
end

function RideableComponent:canBeRidden()
    if self.model.Health.Value <= 0 or CollectionService:HasTag(self.model, "Burning") then
        return false
    end
    return true
end

function RideableComponent:riderValid()
    local condition1 = self.rider.Parent and self.rider.PrimaryPart and self.rider:FindFirstChild("Humanoid") and self.rider.Humanoid.Health > 0
    return condition1
end

function RideableComponent:isMounted()
    return self.rider ~= nil
end

function RideableComponent:dismount()
    self.riderWeld:Destroy()
    local player = game:GetService("Players"):GetPlayerFromCharacter(self.rider)
    if player then
        Messages:sendClient(player, "Dismounted")
    end
    self.rider = nil
    self.model.PrimaryPart:SetNetworkOwnershipAuto()
end

function RideableComponent:mount(player)
    self.model.PrimaryPart:SetNetworkOwner(player)
    local character = player.Character
    character:SetPrimaryPartCFrame(self.model.MountPart.CFrame)
    self.rider = character
    self.riderWeld = Instance.new("WeldConstraint", self.model.PrimaryPart)
    self.riderWeld.Part0 = character.PrimaryPart
    self.riderWeld.Part1 = self.model.MountPart
    Messages:sendClient(player, "Mounted", self.model)
end

function RideableComponent:step(dt)
    if self:isMounted() and not self:canBeRidden() then
        self:dismount()
    elseif self:isMounted() and not self:riderValid() then
        self:dismount()
    elseif self:isMounted() then
        self.idleComponent.spawnPosition = self.model.PrimaryPart.Position
    end
end

function RideableComponent:init(model, props)
    self.model = model
    self.giveUpTargetTime = props.giveUpTargetTime
    self.mountRemote = Instance.new("RemoteEvent", model)
    self.mountRemote.Name = "Mount"
    self.mountRemote.OnServerEvent:connect(function(player)
        if self:canBeMounted(player) then
            self:mount(player)
        elseif self:isMounted() and self.rider == player.Character then
            self:dismount()
        end
    end)
    self.idleComponent = props.idleComponent
end

function RideableComponent.new()
    local class = {}
    class.state = {}
    class.nextSightCheck = tick()
    class.position = Vector3.new()
    return setmetatable(class, RideableComponent)
end

return RideableComponent