local import = require(game.ReplicatedStorage.Shared.Import)

local PathfindingService = game:GetService("PathfindingService")
local CollectionService = game:GetService("CollectionService")

local FastSpawn = import "Shared/Utils/FastSpawn"

local MovementComponent = {}

MovementComponent.__index = MovementComponent

function MovementComponent:pathfindToGoal()
    self.isPathfinding = true
    local goal = self.goal
    if self.lastPathfindGoal ~= goal then
        self.waypoints = nil
        self.currentWaypointIndex = 1
        FastSpawn(function()
            self.path:ComputeAsync(self.model.PrimaryPart.Position, goal)
            self.waypoints = self.path:GetWaypoints()
            for _, point in pairs(self.waypoints) do
                local debugPart = Instance.new("Part", workspace)
                CollectionService:AddTag(debugPart, "RayIgnore")
                debugPart.CanCollide = false
                debugPart.Color = Color3.new(1,0,0)
                debugPart.Anchored = true
                debugPart.Name = "Debug"
                debugPart.CFrame = CFrame.new(point.Position)
                debugPart.Size = Vector3.new(1,1,1)
            end
        end)
        self.lastPathfindGoal = goal
    end
    if self.waypoints and #self.waypoints > 0 then
        print("ok waypoints")
        local waypoint = self.waypoints[self.currentWaypointIndex]
        local action = waypoint.Action
        if action == 0 then
            print("moving to way point")
            self.humanoid.WalkToPoint = (waypoint.Position)
            --self:walkToGoal(waypoint.Position)
        else
            print("jump waypoint")
            self.humanoid.WalkToPoint = (waypoint.Position)
            self:jump()
        end
        local distance = (self.model.PrimaryPart.Position - waypoint.Position).magnitude
        if distance < 10 then
            self.currentWaypointIndex = math.min(#self.waypoints, self.currentWaypointIndex + 1)
        end
    else
        print("no waypoints rip")
        self:walkToGoal()
    end
end

function MovementComponent:getDistanceToGoal()
    local f = Vector3.new(1,1,1)
    return (self.model.PrimaryPart.Position*f - self.goal*f).magnitude
end

function MovementComponent:onNewGoalSet()
    self.walking = false
end

function MovementComponent:setGoal(goal)
    if goal ~= self.goal then
        self:onNewGoalSet()
    end
    self.goal = goal
end

function MovementComponent:walkToGoal(goal)
    if goal then
        self.walking = false
    end
    if not self.walking then
        self.walking = true
        self.humanoid.WalkToPoint = (goal or self.goal)
    end
end

function MovementComponent:stop()
    print("stop called no funny auth")
    if self.walking then
        self.walking = false
        print("stop being called and funny auth")
        --self.humanoid:MoveTo(self.model.PrimaryPart.Position)
    end
end

function MovementComponent:jump()
    if tick() > self.nextJump then
        self.humanoid.Jump = true
        self.nextJump = tick() + 2
    end
end

function MovementComponent:goToGoal(dt)
    if not self.lastGoal then
        self.lastGoal = self.goal
        self.isPathfinding = false
        self.stuckTime = 0
    else
        if self.goal ~= self.lastGoal then
            self.lastGoal = self.goal
            self.isPathfinding = false
            self.stuckTime = 0
        end
    end
    if self.walking and self.isPathfinding then
        self:pathfindToGoal()
        return
    end
    if self.stuckTime > 1 and self.stuckTime < 5 then
        self:jump()
        self:walkToGoal()
    elseif self.stuckTime >= 5 then
        self:pathfindToGoal()
    else
        self:walkToGoal()
    end
    if self.walking then
        if (self.model.PrimaryPart.Velocity*Vector3.new(1,0,1)).magnitude < 20 then
            self.stuckTime = self.stuckTime + dt
        else
            self.stuckTime = 0
        end
    else
        self.stuckTime = 0
    end
end

function MovementComponent:step(dt)
    if self.goal then
        local distance = self:getDistanceToGoal()
        if distance > 10 then
            self:goToGoal(dt)
        else
            self:stop()
            self.stuckTime = 0
            self.isPathfinding = false
        end
    end
end

function MovementComponent:init(model)
    self.model = model
    self.humanoid = model.Humanoid
    self.path = PathfindingService:CreatePath({
        AgentHeight = 7,
        AgentRadius = 7,
        CanJump = true
    })
end

function MovementComponent.new()
    local class = {}
    class.stuckTime = 0
    class.nextJump = 0
    class.computingPath = false
    return setmetatable(class, MovementComponent)
end

return MovementComponent