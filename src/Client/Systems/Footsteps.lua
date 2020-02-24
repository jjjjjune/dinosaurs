local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local FastSpawn = import "Shared/Utils/FastSpawn"
local CastRay = import "Shared/Utils/CastRay"
local CollectionService = game:GetService("CollectionService")

local FootstepsFolder = import "ReplicatedStorage/Footsteps"

local RunService = game:GetService("RunService")

local FOOT_STEP_DISTANCE = 4
local oldBind
local hum, rFoot, lFoot, lastLeftPosition, lastRightPosition

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
    if CollectionService:HasTag(part, "Grass") then
        material = "grass"
        if part.Color.r > .6 and part.Color.g > .6 and part.Color.b > .6 then
            material = "snow"
        end
        return material
    end
    if part.BrickColor.Name == "Flint" then
        return "stone"
    end
    if part.BrickColor.Name == "Pine Cone" then
        return "dirt"
    end
    if part.BrickColor.Name == "Dark taupe" then
        return "wood"
    end
    if part.Name == "Water" then
        return "hi"
    end
    if CollectionService:HasTag(part, "Sand") then
        return "sand"
    end
    return material
end

local function onFootstep(part, foot, resultPosition)
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
        footstepPart.CFrame = CFrame.new(resultPosition) * CFrame.new(0, (-(footstepPart.Size.X/2)) + .01,0) * CFrame.Angles(0,0,math.pi/2)
        footstepPart.Color = Color3.new(part.Color.r * .9, part.Color.g * .9, part.Color.b * .9)
        footstepPart.Material = Enum.Material.SmoothPlastic
        local x = Instance.new("SpecialMesh", footstepPart)
        x.MeshType = "Cylinder"
        footstepPart.Parent = workspace
        CollectionService:AddTag(x, "RayIgnore")
        game:GetService("Debris"):AddItem(footstepPart, 5)
    end
end

local function onFrameChange()
    local rayDir = Vector3.new(0,-1,0)
    local didHitLeft, currentLeftPosition = CastRay(lFoot.Position, rayDir, {hum.Parent})
    local didHitRight, currentRightPosition = CastRay(rFoot.Position, rayDir, {hum.Parent})
    if didHitLeft then
        if ((currentLeftPosition) - lastLeftPosition).magnitude > FOOT_STEP_DISTANCE then
            onFootstep(didHitLeft, lFoot, currentLeftPosition)
            lastLeftPosition = currentLeftPosition
        end
    end
    if didHitRight then
        if (currentRightPosition - lastRightPosition).magnitude > FOOT_STEP_DISTANCE then
            onFootstep(didHitRight, rFoot, currentRightPosition)
            lastRightPosition = currentRightPosition
        end
    end
end

local function bindFootsteps(character)
    if oldBind then
        oldBind:disconnect()
        oldBind = nil
    end
    FastSpawn(function()
        hum = character:WaitForChild("Humanoid")
        rFoot = character:WaitForChild("RightFoot")
        lFoot = character:WaitForChild("LeftFoot")
        lastLeftPosition = Vector3.new()
        lastRightPosition = Vector3.new()

        oldBind = RunService.Stepped:connect(function(dt)
            onFrameChange()
        end)
    end)
end

local Footsteps = {}

function Footsteps:start()
    FastSpawn(function()
        initializeMaterialToSoundMap()
    end)
    Messages:hook("CharacterAddedClient", function(character)
        bindFootsteps(character)
        character:WaitForChild("HumanoidRootPart"):WaitForChild("Running"):Destroy()
    end)
end

return Footsteps