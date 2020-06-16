local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local FastSpawn = import "Shared/Utils/FastSpawn"
local CastRay = import "Shared/Utils/CastRay"
local CollectionService = game:GetService("CollectionService")

local GetCharacterPosition = import "Shared/Utils/GetCharacterPosition"

local FootstepsFolder = import "ReplicatedStorage/Footsteps"

local RunService = game:GetService("RunService")

local FOOTSTEP_RADIUS = 300
local FOOT_STEP_DISTANCE = 5
local soundDebounce = .2
local lastSound = time()

local footstepConnections = {}

local materialTypes = {
    "sand","snow","planks","metal", "ice","grass","floor","carpet","dirt", "basic","stone","wood", "hi"
}

local materialToSoundMap = {}

local function initializeMaterialToSoundMap()
    for _, materialName in pairs(materialTypes) do
        if not materialToSoundMap[materialName] then
            materialToSoundMap[materialName] = {}
        end
    end
    for _, child in pairs(FootstepsFolder:GetChildren()) do
        for _, materialName in pairs(materialTypes) do
            if string.find(string.lower(child.Name), materialName) then
                table.insert(materialToSoundMap[materialName], child)
            end
        end
    end
end

local function getMaterial(part)
    local material = "basic"
    if CollectionService:HasTag(part, "Grass") and part.Transparency == 0 then
        material = "grass"
        if part.Color.r > .6 and part.Color.g > .6 and part.Color.b > .6 and part.Material ~= Enum.Material.Neon then
            material = "snow"
        end
        return material
    end
    if part.BrickColor.Name == "Flint" or CollectionService:HasTag(part, "Stone") then
        return "stone"
    end
    if part.BrickColor.Name == "Pine Cone" then
        return "dirt"
    end
    if part.BrickColor.Name == "Dark taupe" then
        return "wood"
    end
    if part.Name == "Water" or part.Material == Enum.Material.Neon then
        return "hi"
    end
    if CollectionService:HasTag(part, "Sand") then
        return "sand"
    end
    return material
end

local function onFootstep(part, foot, resultPosition, normal)
    if time() - lastSound < soundDebounce then
        return
    else
        lastSound = time()
    end
    local material = getMaterial(part)
    local sounds = materialToSoundMap[material]
    local chosenSoundInstance = sounds[math.random(1, #sounds)]
    Messages:send("PlaySoundOnClient",{
        instance = chosenSoundInstance,
        part = foot
    })
    if material == "snow" or material == "sand" or material == "dirt" then 
        local footstepPart = Instance.new("Part")
        footstepPart.Size = Vector3.new(0, .5 + math.random(), .5 + math.random())
        footstepPart.Anchored = true
        footstepPart.CanCollide = false
        footstepPart.CFrame = CFrame.new(resultPosition) * CFrame.Angles(0,0,math.pi/2)
        footstepPart.CFrame = CFrame.new(footstepPart.Position, footstepPart.Position + normal)
        footstepPart.CFrame = footstepPart.CFrame * CFrame.Angles(0,math.pi/2,0)
        footstepPart.Color = Color3.new(part.Color.r * .9, part.Color.g * .9, part.Color.b * .9)
        footstepPart.Material = Enum.Material.SmoothPlastic
        local x = Instance.new("SpecialMesh", footstepPart)
        x.MeshType = "Cylinder"
        footstepPart.Parent = workspace
        CollectionService:AddTag(x, "RayIgnore")
        game:GetService("Debris"):AddItem(footstepPart, 5)
    end
end

local function onFrameChange(character, rFoot, lFoot, lastLeftPosition, lastRightPosition)
    local leftDir = Vector3.new(0,-1,0) * ((lFoot.Size.Y/2)+1)
    local rightDir = Vector3.new(0,-1,0)  * ((rFoot.Size.Y/2)+1)
    local didHitLeft, currentLeftPosition, normal2 = CastRay(lFoot.Position, leftDir, {character})
    local didHitRight, currentRightPosition, normal = CastRay(rFoot.Position, rightDir, {character})
    if character:FindFirstChild("Humanoid") then
        if character.Humanoid:GetState() == Enum.HumanoidStateType.Physics then
            return lastLeftPosition, lastRightPosition
        end
    end
    if didHitLeft then
        if ((currentLeftPosition) - lastLeftPosition).magnitude > FOOT_STEP_DISTANCE then
            onFootstep(didHitLeft, lFoot, currentLeftPosition, normal)
            lastLeftPosition = currentLeftPosition
        end
    end
    if didHitRight then
        if (currentRightPosition - lastRightPosition).magnitude > FOOT_STEP_DISTANCE then
            onFootstep(didHitRight, rFoot, currentRightPosition, normal2)
            lastRightPosition = currentRightPosition
        end
    end

    return lastLeftPosition, lastRightPosition
end

local function bindFootsteps(character)
    local rFoot, lFoot
    if character:FindFirstChild("Humanoid") then
        rFoot = character:WaitForChild("RightFoot")
        lFoot = character:WaitForChild("LeftFoot")
    else
        rFoot = character:WaitForChild("BackLeft")
        lFoot = character:WaitForChild("BackRight")
    end
    local lastLeftPosition = Vector3.new()
    local lastRightPosition = Vector3.new()

    local bind = RunService.Stepped:connect(function(dt)
        lastLeftPosition, lastRightPosition = onFrameChange(character, rFoot, lFoot, lastLeftPosition, lastRightPosition)
    end)

    return bind
end

local function handleFootsteps()
    local position = GetCharacterPosition()
    for instance, connection in pairs(footstepConnections) do
        if instance.Parent == nil then
            connection:disconnect()
            footstepConnections[instance] = nil
        else
            local pos = instance.PrimaryPart and instance.PrimaryPart.Position
            if (pos and position) and (pos - position).magnitude < FOOTSTEP_RADIUS then

            else
                connection:disconnect()
                footstepConnections[instance] = nil
            end
        end
    end
    for _, monster in pairs(CollectionService:GetTagged("Monster")) do
        if not footstepConnections[monster] then
            local pos = monster.PrimaryPart and monster.PrimaryPart.Position
            if (pos and position) and (pos - position).magnitude < FOOTSTEP_RADIUS then
                footstepConnections[monster] = bindFootsteps(monster)
            end
        end
    end
end

local Footsteps = {}

function Footsteps:start()
    FastSpawn(function()
        initializeMaterialToSoundMap()
        while wait(5) do
            handleFootsteps()
        end
    end)
    Messages:hook("CharacterAddedClient", function(character)
        footstepConnections[character] = bindFootsteps(character)
        character:WaitForChild("HumanoidRootPart"):WaitForChild("Running"):Destroy()
    end)
    Messages:hook("PlayerDied", function ()
        handleFootsteps()
    end)
end

return Footsteps