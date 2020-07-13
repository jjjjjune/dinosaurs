local import = require(game.ReplicatedStorage.Shared.Import)

local CollectionService = game:GetService("CollectionService")

local TameableComponent = {}

TameableComponent.__index = TameableComponent

function TameableComponent:updateName()

end

function TameableComponent:onTamed(player)
    if player then
        -- was tamed by a player
        self.model.Health.Value = self.model.Health.MaxValue
        self.model.OwnerId.Value = player.UserId
    else
        -- value was set by data loading script
    end
    CollectionService:AddTag(self.model, "Rideable")
    self.model.Tamed.Value = true
    self.model.PrimaryPart.NameBillboard.Enabled = true
    self.model.PrimaryPart.NameBillboard.NameLabel.Text = self.model.MonsterName.Value
    self.model.PrimaryPart.NameBillboard.NameLabelShadow.Text = self.model.MonsterName.Value
    self:updateName()
end

function TameableComponent:attemptTame(player)
    if not CollectionService:HasTag(self.model, "Rideable") then
        self:onTamed(player)
    end
end

function TameableComponent:init(model, props)
    self.model = model

    self.nameValue = Instance.new("StringValue", model)
    self.nameValue.Name = "MonsterName"
    self.nameValue.Value = model.Name
    self.nameValue.Changed:connect(function()
        self:updateName()
    end)

    self:updateName()

    self.ownerIdValue = Instance.new("IntValue", model)
    self.ownerIdValue.Name = "OwnerId"

    self.tameEvent = Instance.new("BindableEvent", model)
    self.tameEvent.Name = "Tame"
    self.tameEvent.Event:connect(function(player)
        self:attemptTame(player)
    end)

    self.isTamedValue = Instance.new("BoolValue", model)
    self.isTamedValue.Name = "Tamed"
    self.isTamedValue.Value = false
    self.isTamedValue.Changed:connect(function()
        if self.isTamedValue.Value == true then
            self:onTamed()
        end
    end)
end

function TameableComponent.new()
    local class = {}
    return setmetatable(class, TameableComponent)
end

return TameableComponent
