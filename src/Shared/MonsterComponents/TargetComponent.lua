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

local function getPositionOnEdgeOfCirlceAwayFrom(position, distance)
    local deg = math.random(1, 360)
    local rad = math.rad(deg)
    local cf = CFrame.new(position) * CFrame.Angles(0, rad, 0)
    cf = cf * CFrame.new(0, 0, -distance)
    return cf.p
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
    local condition1 = (self.state.lastValidTarget and self.state.lastValidTarget.Parent ~= nil)
    local condition2 = (self.state.cantSeeTargetCounter or 0) < self.giveUpTargetTime
    return condition1 and condition2 and self.state.lastValidTarget
end

function TargetComponent:getValidEnemy()
    if self.model.Tamed.Value == false then
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
end

function TargetComponent:getFleeing(forceRecalc)
    self.lastFleeCalculation = self.lastFleeCalculation or tick()
    self.lastFleeing = self.lastFleeing or false
    local timeSinceLastFleeCalculation = tick() - self.lastFleeCalculation
    if timeSinceLastFleeCalculation > 1 or forceRecalc then
        self.lastFleeCalculation = tick()
        local fleeFrom = {}
        for _, enemyTag in pairs(self.fleeFromTags) do
            for _, enemy in pairs(CollectionService:GetTagged(enemyTag)) do
                if enemy ~= self.model then
                    table.insert(fleeFrom, enemy)
                end
            end
        end
        local targetToFleeFrom = getClosestEnemyOfSet(self.position, fleeFrom)
        if targetToFleeFrom and self:getCanSeePosition(targetToFleeFrom.PrimaryPart.Position) then
            self.lastFleeTargetReset = self.lastFleeTargetReset or 0
            if tick() - self.lastFleeTargetReset > 5 then
                self.fleePosition = getPositionOnEdgeOfCirlceAwayFrom(targetToFleeFrom.PrimaryPart.Position, 100)
                self.lastFleeTargetReset = tick()
            end
            self.lastFleeing = true
            return true
        end
    else
        return self.lastFleeing
    end
    self.lastFleeing = false
    return false
end

function TargetComponent:getFleePosition()
    if (self.position - self.fleePosition).magnitude < 20 then
        self:getFleeing(true)
    end
    return self.fleePosition
end

function TargetComponent:step(dt)
    self.position = (self.model.PrimaryPart and self.model.PrimaryPart.Position) or Vector3.new()
    local wantedItem = self.wantItem
    local item do
        item = getClosestItemOfName(self.position, wantedItem) or self:getValidEnemy()
    end
    if item and self:getCanSeePosition(item.PrimaryPart.Position) then
        self.state.cantSeeTargetCounter = nil
        self.state.lastValidTarget = item
    end
    if self.state.lastValidTarget and self.state.lastValidTarget.PrimaryPart and self.state.lastValidTarget.Parent ~= nil then
        self.state.lastValidTargetPosition = self.state.lastValidTarget.PrimaryPart.Position
        self.state.distanceFromTarget = (self.state.lastValidTargetPosition - self.position).magnitude
        self.state.isTargetVisible = self:getCanSeePosition(self.state.lastValidTargetPosition)
    else
        self.state.lastValidTarget = nil
        self.state.lastValidTargetPosition = nil
        self.state.isTargetVisible = false
        self.state.distanceFromTarget = 100000
    end
    if not self.state.isTargetVisible then
        if not self.state.cantSeeTargetCounter then
            self.state.cantSeeTargetCounter = 0
        else
            self.state.cantSeeTargetCounter = self.state.cantSeeTargetCounter + dt
        end
    else
        self.state.cantSeeTargetCounter = nil
    end
end

function TargetComponent:init(model, props)
    self.model = model
    self.giveUpTargetTime = props.giveUpTargetTime
end

function TargetComponent.new()
    local class = {}
    class.state = {}
    class.nextSightCheck = tick()
    class.position = Vector3.new()
    return setmetatable(class, TargetComponent)
end

return TargetComponent
