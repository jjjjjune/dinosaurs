local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Damage = import "Shared/Utils/Damage"

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local BURN_TIME_TO_DESTROY_OBJECT = 10

local PLAYER_BURN_DAMAGE = 20

local PLAYER_BURN_DEBOUNCE = 5

local burningObjects = {}

local lastPlayerDamages = {}

local function setOnFire(object)
    table.insert(burningObjects, {
        target = object,
        start = tick()
    })
end

local function putOutFire(object)
    local newBurningObjects = {}
    for _, obj in pairs(burningObjects) do
        if obj ~= object then
            table.insert(newBurningObjects, obj)
        end
    end
    if object:FindFirstChild("BurnHitbox") then
        object.BurnHitbox:Destroy()
    end
    burningObjects = newBurningObjects
end

local function manageBurnParticle(object)
    if not object:FindFirstChild("BurnHitbox") then
        local burnHitbox = Instance.new("Part")
        CollectionService:AddTag(burnHitbox, "RayIgnore")
        burnHitbox.Size = object:GetModelSize()
        burnHitbox.Transparency = 1
        burnHitbox.Name = "BurnHitbox"
        burnHitbox.Massless = true
        burnHitbox.CFrame = object:GetModelCFrame()
        burnHitbox.CanCollide = false
        burnHitbox.Parent = object
        local w = Instance.new("WeldConstraint", burnHitbox)
        w.Part0 = burnHitbox
        w.Part1 = object.PrimaryPart
        local particle = game.ReplicatedStorage.Particles.SystemFire:Clone()
        particle.Parent = burnHitbox
    end
end

local function manageSpread(object)
    local connect = object.BurnHitbox.Touched:connect(function() end)
    local parts = object.BurnHitbox:GetTouchingParts()
    connect:disconnect()
    for _, part in pairs(parts) do
        local potentialBurnable = part.Parent
        if CollectionService:HasTag(potentialBurnable, "Character") then
            if not potentialBurnable:FindFirstChild("BurnHitbox") then
                setOnFire(potentialBurnable)
            end
        end
        if CollectionService:HasTag(potentialBurnable, "Organic") then
            if not potentialBurnable:FindFirstChild("BurnHitbox") then
                setOnFire(potentialBurnable)
            end
        end
    end
end

local function manageBurningPlayer(character)
    if not lastPlayerDamages[character] then
        lastPlayerDamages[character] = tick() - 100
    end
    if tick() - lastPlayerDamages[character] > PLAYER_BURN_DEBOUNCE then
        print("DAMAGING PLAYER:)")
        lastPlayerDamages[character] = tick()
        Damage(character, {damage = PLAYER_BURN_DAMAGE, type = "fire", serverApplication = true})
    end
end

local function manageBurningItem(object)
end

local function manageBurningObject(object, elapsedTime)
    manageBurnParticle(object)
    local isCharacter = object:FindFirstChild("Humanoid")

    if elapsedTime > BURN_TIME_TO_DESTROY_OBJECT then
        if not isCharacter then
            object:Destroy()
            return false
        end
    end

    if isCharacter then
        manageBurningPlayer(object)
    else
        manageBurningItem(object)
    end

    manageSpread(object)
    return true
end

local function step(dt)
    local newBurningObjects = {}
    for i, burningObject in pairs(burningObjects) do
        local elapsedTime = tick() - burningObject.start
        local shouldContinueBurning = manageBurningObject(burningObject.target, elapsedTime)
        if shouldContinueBurning then
            table.insert(newBurningObjects, burningObject)
        end
    end
    burningObjects = newBurningObjects
end

local Fire = {}

function Fire:start()
    Messages:hook("SetOnFire", setOnFire)
    Messages:hook("PutOutFire", putOutFire)
    RunService.Stepped:connect(step)
end

return Fire