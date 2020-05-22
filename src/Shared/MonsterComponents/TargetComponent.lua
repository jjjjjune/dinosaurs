local import = require(game.ReplicatedStorage.Shared.Import)

local CollectionService = game:GetService("CollectionService")

local CastRay = import "Shared/Utils/CastRay"

local MIN_FIND_DISTANCE = 300

local function isValid(item)
    return not item.Parent:FindFirstChild("Humanoid")
end

local function getClosestItemOfName(position, name)
    local closestDistance = MIN_FIND_DISTANCE
    local closestItem
    for _, item in pairs(CollectionService:GetTagged("Item")) do
        if item.Name == name and isValid(item) then 
            local itemPos = item.PrimaryPart and item.PrimaryPart.Position
            if itemPos then
                local dist = (position - itemPos).magnitude
                if (dist < closestDistance) then
                    closestDistance = dist
                    closestItem = item
                end
            end
        end
    end
    return closestItem
end

local function getClosestEnemyOfSet(position, set)
    local closestDistance = MIN_FIND_DISTANCE
    local closestItem
    for _, character in pairs(set) do
        local isValid do
            if CollectionService:HasTag(character, "Character") then
                isValid = character.Humanoid.Health > 0
            else
                isValid = not CollectionService:HasTag(character, "Corpse")
            end
        end
        if isValid then 
            local itemPos = character.PrimaryPart and character.PrimaryPart.Position
            if itemPos then
                local dist = (position - itemPos).magnitude
                if (dist < closestDistance) then
                    closestDistance = dist
                    closestItem = character
                end
            end
        end
    end
    return closestItem
end


local TargetComponent = {}

TargetComponent.__index = TargetComponent

--[[
    - last thing we saw that we want
    - last position we saw the thing at
    - can that thing currently be seen
    - is that thing more than give_up_distance away

    -- if we can currently see the thing (and is within radius), return the thing, record position (spotted)
    -- if we can't currently see it, but we know its last position, return last position (investigating)
    -- if the thing has moved too far away, it is no longer a valid target (give up)

    {
        lastValidTargetPosition
        lastValidTarget
        isTargetVisible
        distanceFromTarget
    }

    give up method resets all target state info
]]

function TargetComponent:getCanSeePosition(position)
    if tick() > self.nextSightCheck then
        self.nextSightCheck = tick() + .5
        local hit, pos = CastRay(self.position, (position - self.position).unit * 200, {self.model})
        return hit and hit:IsDescendantOf(self.state.lastValidTarget)
    else
        return self.state.isTargetVisible
    end
end

function TargetComponent:getTarget()
    return ((self.state.lastValidTarget and self.state.lastValidTarget.Parent ~= nil) and self.state.lastValidTarget) or nil
end

function TargetComponent:getValidEnemy()
    local allEnemies = {}
    for _, enemyTag in pairs(self.wantedEnemyTags) do
        for _, enemy in pairs(CollectionService:GetTagged(enemyTag)) do
            if enemy ~= self.model then
                table.insert(allEnemies, enemy)
            end
        end
    end
    return getClosestEnemyOfSet(self.position, allEnemies)
end

function TargetComponent:step()
    self.position = (self.model.PrimaryPart and self.model.PrimaryPart.Position) or Vector3.new()
    local wantedItem = self.wantItem
    local item do
        item = getClosestItemOfName(self.position, wantedItem) or self:getValidEnemy()
    end
    if item and self:getCanSeePosition(item.PrimaryPart.Position) then
        self.state.lastValidTarget = item
    end
    if self.state.lastValidTarget and self.state.lastValidTarget.PrimaryPart and self.state.lastValidTarget.Parent ~= nil then
        self.state.lastValidTargetPosition = self.state.lastValidTarget.PrimaryPart.Position
        self.state.distanceFromTarget = (self.state.lastValidTargetPosition - self.position).magnitude
        self.isTargetVisible = self:getCanSeePosition(self.state.lastValidTargetPosition)
    else
        self.state.lastValidTarget = nil
        self.state.lastValidTargetPosition = nil
        self.state.isTargetVisible = false
        self.state.distanceFromTarget = 100000
    end
end

function TargetComponent:init(model)
    self.model = model
end

function TargetComponent.new()
    local class = {}
    class.state = {}
    class.nextSightCheck = tick()
    class.position = Vector3.new()
    return setmetatable(class, TargetComponent)
end

return TargetComponent