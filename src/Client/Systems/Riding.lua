local import = require(game.ReplicatedStorage.Shared.Import)

local GetCharacter = import "Shared/Utils/GetCharacter"

local Messages = import "Shared/Utils/Messages"

local Binds = import "Client/Systems/Binds"

local CastRay = import "Shared/Utils/CastRay"

local RunService = game:GetService("RunService")

local lastNormal = Vector3.new()

local mountModel
local rideConnection

local function align(dt, mount, dir)
    if dir.magnitude > 0 then
        local goalOffset = ((mount.PrimaryPart.Position  + dir )*Vector3.new(1,0,1)) - ((mount.PrimaryPart.Position)*Vector3.new(1,0,1))
        local yGoal = math.atan2(goalOffset.Z, -goalOffset.X) + math.pi / 2

        local goalGyroCF
        local start = mount.PrimaryPart.Position + (mount.PrimaryPart.Velocity*dt)

        local hit, _, normal = CastRay(start, Vector3.new(0,-8,0), {mount})
        if hit then
            lastNormal = normal
        end
        local lookVector = Vector3.new(0, 0, -1)
        local rightVector = Vector3.new(1, 0, 0)

        local tilt = math.asin(lookVector:Dot(lastNormal))
        local roll = math.asin(rightVector:Dot(lastNormal))
        local floorCF = CFrame.Angles(-tilt, 0, -roll)

        goalGyroCF = CFrame.new(mount.PrimaryPart.Position) * floorCF * CFrame.Angles(0, yGoal, 0)

        mount.PrimaryPart.BodyGyro.CFrame = goalGyroCF
    end
end

local function move(dt, mountModel, dir)
    mountModel.PrimaryPart.BodyVelocity.Velocity = dir * mountModel.Speed.Value
end

local function rideStep(dt)
    local character = GetCharacter()
    if character then
        local dir = character.Humanoid.MoveDirection
        align(dt, mountModel, dir)
        move(dt, mountModel, dir)
    end
end

local Riding = {}

function Riding:start()
    Binds.bindTagToAction("Rideable", "INTERACT", function(rideableEntity)
        rideableEntity.Mount:FireServer()
    end)
    Messages:hook("Mounted", function(model)
        GetCharacter().Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        Messages:send("PlayAnimationClient", "Ride")
        mountModel = model
        rideConnection = RunService.Heartbeat:connect(function(dt)
            rideStep(dt)
        end)
    end)
    Messages:hook("Dismounted", function()
        GetCharacter().Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        Messages:send("StopAnimationClient", "Ride")
        if rideConnection then
            rideConnection:disconnect()
            rideConnection = nil
        end
    end)
end

return Riding