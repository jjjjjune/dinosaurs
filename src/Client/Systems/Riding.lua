local import = require(game.ReplicatedStorage.Shared.Import)

local GetCharacter = import "Shared/Utils/GetCharacter"
local Messages = import "Shared/Utils/Messages"
local Binds = import "Client/Systems/Binds"
local CastRay = import "Shared/Utils/CastRay"

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local lastNormal = Vector3.new()

local JUMP_TIME = .2
local JUMP_FORCE = 7000

local lastJump = 0

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

        --print(math.deg(tilt), math.deg(yGoal), math.deg(roll))
    end
end

local function move(dt, mountModel, dir)
    local floorHit, pos = CastRay(mountModel.PrimaryPart.Position, Vector3.new(0, -3, 0), {mountModel, GetCharacter()})
    local isOnFloor = floorHit ~= nil
    if dir.magnitude == 0 then
        mountModel.PrimaryPart.BodyVelocity.Velocity  = Vector3.new()
        mountModel.PrimaryPart.BodyVelocity.MaxForce = Vector3.new(1,0,1)*1000000
    else
        if isOnFloor then
            mountModel.PrimaryPart.BodyVelocity.MaxForce = Vector3.new(1,1,1)*1000000
        else
            mountModel.PrimaryPart.BodyVelocity.MaxForce = Vector3.new(1,0,1)*1000000
        end
        local x, y, z = mountModel.PrimaryPart.CFrame:toEulerAnglesXYZ()
        x = math.deg(x)
        y = math.deg(y)
        z = math.deg(z)
        local isOnFlatGround = (math.abs(x) <= 1) and (math.abs(z) <= 1)
        if isOnFlatGround then
            mountModel.PrimaryPart.BodyVelocity.Velocity = dir * mountModel.Speed.Value
        else
            mountModel.PrimaryPart.BodyVelocity.Velocity = mountModel.PrimaryPart.CFrame.lookVector * mountModel.Speed.Value
        end
    end
    if tick() - lastJump < JUMP_TIME then
        mountModel.PrimaryPart.BodyVelocity.MaxForce = Vector3.new(1,1,1)*1000000
        mountModel.PrimaryPart.BodyVelocity.Velocity = mountModel.PrimaryPart.BodyVelocity.Velocity + Vector3.new(0, JUMP_FORCE, 0)
    end
end

local function rideStep(dt)
    local character = GetCharacter()
    if character then
        local dir = character.Humanoid.MoveDirection
        align(dt, mountModel, dir)
        move(dt, mountModel, dir)
    end
end

local function jump()
    lastJump = tick()
end

local jumpEvent

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
        model.HumanoidRootPart.NameBillboard.Enabled = false
        jumpEvent = UserInputService.JumpRequest:connect(function()
            if tick() - lastJump > 1 then
                jump()
            end
        end)
    end)
    Messages:hook("Dismounted", function()
        GetCharacter().Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        Messages:send("StopAnimationClient", "Ride")
        if rideConnection then
            rideConnection:disconnect()
            rideConnection = nil
        end
        mountModel.HumanoidRootPart.NameBillboard.Enabled = true
        mountModel = nil
        jumpEvent:disconnect()
    end)
end

return Riding