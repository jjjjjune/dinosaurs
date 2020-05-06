local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Damage = import "Shared/Utils/Damage"
local Water = import "Server/Systems/Water"

local FastSpawn = import "Shared/Utils/FastSpawn"

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local BURN_TIME_TO_DESTROY_OBJECT = 60

local PLAYER_BURN_DAMAGE = 20

local PLAYER_BURN_DEBOUNCE = 5

local burningObjects = {}

local lastPlayerDamages = {}

local lastPartColors = {}
local lastPartTextures = {}

local function setFireSkin(object)
    for _, part in pairs(object:GetDescendants()) do
        if part:IsA("BasePart") then
            lastPartColors[part] = part.Color
            part.Color = Color3.fromRGB(255,50,20)
        end
        if part:IsA("MeshPart") then
            lastPartTextures[part] = part.TextureID
            part.TextureID = ""
        end
    end
end

local function unsetFireSkin(object)
    for _, part in pairs(object:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Color = lastPartColors[part]
        end
        if part:IsA("MeshPart") then
            part.TextureID = lastPartTextures[part]
        end
    end
end

local function setOnFire(object, t)
    CollectionService:AddTag(object, "Burning")
    Messages:send("PlaySound", "Ignite", object.PrimaryPart.Position)
    if not CollectionService:HasTag(object, "Character") then
        setFireSkin(object)
    end
    table.insert(burningObjects, {
        target = object,
        start = tick(),
        expire = t and (tick() + t) or (tick() + 1000000)
    })
end

local function putOutFire(object)
    CollectionService:RemoveTag(object, "Burning")
    Messages:send("PlaySound", "Fireputout", object.BurnHitbox.Position)
    Messages:send("PlayParticle", "Extinguish", 10, object.BurnHitbox.Position)
    if object:FindFirstChild("BurnHitbox") then
        object.BurnHitbox:Destroy()
    end
    if not CollectionService:HasTag(object, "Character") then
        unsetFireSkin(object)
    end
end

local function manageBurnParticle(object)
    if CollectionService:HasTag(object, "Burning") then
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
            particle:Emit(20)
        end
    end
end

local function canSpreadTo(fromObject, toObject)
    if toObject:FindFirstChild("BurnHitbox") then
        return false
    end
    if CollectionService:HasTag(toObject, "Burning") then
        return false
    end
    if CollectionService:HasTag(toObject, "Fireproof") then
        return false
    end
    if CollectionService:HasTag(toObject, "Character") then
        if fromObject then
            if not CollectionService:HasTag(fromObject, "Item") then -- no spreading from an item to a player
                return true
            end
        end
    end
    if CollectionService:HasTag(toObject, "Organic") then
        return true
    end
    if CollectionService:HasTag(toObject, "Plant") then
        return true
    end
    return false
end

local function manageSpread(object)
    local connect = object.BurnHitbox.Touched:connect(function() end)
    local parts = object.BurnHitbox:GetTouchingParts()
    connect:disconnect()
    for _, part in pairs(parts) do
        local potentialBurnable = part.Parent
        if potentialBurnable ~= object then
            if canSpreadTo(object, potentialBurnable) then
                print(object, "can spread fire to ", potentialBurnable)
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
        lastPlayerDamages[character] = tick()
        Damage(character, {damage = PLAYER_BURN_DAMAGE, type = "fire", serverApplication = true})
    end
    local position = character.PrimaryPart.Position - Vector3.new(0,1,0)
    if Water.isPositionWithinWater(position) then
        return false
    else
        return true
    end
end

local function manageBurningItem(object)
    local position = object.PrimaryPart.Position
    if Water.isPositionWithinWater(position) then
        return false
    else
        return true
    end
end

local function manageBurningObject(tableObject, elapsedTime)
    local object = tableObject.target

    if not object.PrimaryPart then
        return false
    end

    manageBurnParticle(object)

    if not tableObject.lastSpread then
        tableObject.lastSpread = tick()
    end

    if tick() - tableObject.lastSpread > 1 then
        tableObject.lastSpread = tick()
        manageSpread(object)
    end

    local isCharacter = object:FindFirstChild("Humanoid")

    if elapsedTime > BURN_TIME_TO_DESTROY_OBJECT then
        if not isCharacter then
            if CollectionService:HasTag(object, "Item") then
                Messages:send("DestroyItem", object)
            else
                -- plant or building
                object:Destroy()
            end
            return false
        end
    end

    if isCharacter then
        if not manageBurningPlayer(object) then
            return false
        end
    else
        if not manageBurningItem(object) then
            return false
        end
    end

    if object.Parent == nil then
        return false
    end

    local bottom = object.BurnHitbox.Position - Vector3.new(0, object.BurnHitbox.Size.Y/2, 0)
    if bottom.Y <= workspace.Effects.Water.Position.Y then
        return false
    end

    return true
end

local function step(dt)
    local newBurningObjects = {}
    for i, burningObject in pairs(burningObjects) do
        local elapsedTime = tick() - burningObject.start
        local shouldContinueBurning = manageBurningObject(burningObject, elapsedTime)
        if shouldContinueBurning and burningObject.expire > tick() then
            table.insert(newBurningObjects, burningObject)
        else
            if burningObject.target.PrimaryPart then
                putOutFire(burningObject.target)
            end
        end
    end
    burningObjects = newBurningObjects
end

local Fire = {}

function Fire:start()
    Messages:hook("SetOnFire", function(object)
        if canSpreadTo(nil, object) then
            setOnFire(object)
        end
    end)
    Messages:hook("PutOutFire", putOutFire)
    Messages:hook("Report")
    FastSpawn(function()
        while wait() do
            step()
        end
    end)
end

return Fire