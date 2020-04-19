local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")
local CastRay = import "Shared/Utils/CastRay"

local RunService = game:GetService("RunService")

local BiomePlants = {
    Forest = {
        "Wood Tree",
        "Wood Tree",
        "Wood Tree",
        "Pine",
        "Tall Tree",
        "Tall Tree",
        "Tall Tree",
        "Tall Tree",
    }
}

local BiomeCavePlants = {
    Forest = {
        "Blue Mushroom",
    }
}

local TREE_LIMIT = 200 -- gonna have to do this dynamically somehow

local function randomPointOnPartSurface(part)
    local start = part.CFrame  * CFrame.new(0, part.Size.Y/2, 0)
    local xDist = math.random(-part.Size.X/2, part.Size.X/2)
    local zDist = math.random(-part.Size.Z/2, part.Size.Z/2)
    return (start * CFrame.new(xDist, 0, zDist)).p
end

local function getBiome(part)
    return "Forest"
end

local function canBePlacedOnPart(plantName, part)
    return CollectionService:HasTag(part, "Grass") and part.Name == "Grass" and part:IsDescendantOf(workspace.Tiles)
end

local function populateTrees()
    local grasses = {}
    local collection = CollectionService:GetTagged("Grass")

    for _, grass in pairs(collection) do
        if grass.Position.Y >= workspace.Effects.Water.Position.Y - 8 then
            local amount = math.min(1, math.floor((grass.Size.X + grass.Size.Z)/5))
            for i = 1, amount do
                table.insert(grasses, grass)
            end
        end
    end

    local treesNum = #CollectionService:GetTagged("Plant")
    if treesNum < #grasses then
        local grass = grasses[math.random(1, #grasses)]
        local biome = getBiome(grass)
        local plants = BiomePlants[biome]
        local myPlant = plants[math.random(1, #plants)]
        local myPos = randomPointOnPartSurface(grass)
        local tries = 0
        local hit, pos
        repeat 
            hit, pos = CastRay(myPos + Vector3.new(0,60,0), Vector3.new(0,-70,0))
            tries = tries + 1
            if not hit or (hit and not canBePlacedOnPart(myPlant, hit)) then
                grass = grasses[math.random(1, #grasses)]
                myPos = randomPointOnPartSurface(grass)
            else
                myPos = pos
            end
        until 
            tries > 20 or (hit and canBePlacedOnPart(myPlant, grass))
        if tries > 20 then
            return
        end
        Messages:send("CreatePlant", myPlant, myPos, math.random(1, 3))
    end
end

local function onCaveAdded(cave)
    if cave:IsDescendantOf(workspace) then 
        cave.Parent = nil
    end
end

local function isValidRockSpawn(part) 
    if part.Parent.Name == "Altar" or part.Anchored == false then
        return false
    end
    if not part:IsDescendantOf(workspace.Tiles) then
        return false  
    end
    return true
end

local function getCavePosition(cave)
    local length = cave.Size.X + cave.Size.Z + cave.Size.Y
    local angleDir = CFrame.new() * CFrame.Angles(math.rad(math.random(1, 360)), math.rad(math.random(1, 360)),math.rad(math.random(1, 360)))
    local hit, pos, normal = CastRay(cave.Position, (angleDir.lookVector * length))
    if hit and not CollectionService:HasTag(hit, "Grass") then
        local tHit, tPos = CastRay(pos, Vector3.new(0,40,0))
        if tHit then 
            return pos, normal
        end
    end
end

local function getRockPosition(cave)
    local length = cave.Size.X + cave.Size.Z + cave.Size.Y
    local angleDir = CFrame.new() * CFrame.Angles(math.rad(math.random(1, 360)), math.rad(math.random(1, 360)),math.rad(math.random(1, 360)))
    local hit, pos, normal = CastRay(cave.Position, (angleDir.lookVector * length))
    if hit and isValidRockSpawn(hit) then
        return pos, normal
    end
end

local function populateCaves()
    local caves = CollectionService:GetTagged("Cave")
    local cave = caves[math.random(1, #caves)]
    if cave:IsDescendantOf(workspace) then
        local limit = math.max(1, math.min(3, cave.Size.magnitude/80))
        for _, v in pairs(cave:GetChildren()) do
            if v:IsA("ObjectValue") and v.Value and v.Value.Parent == nil then
                v:Destroy()
            end
        end
        if #cave:GetChildren() < limit then
            local tries = 0
            local pos, normal
            repeat 
                pos, normal = getCavePosition(cave) 
                tries = tries + 1
            until
                (tries > 20) or (pos)
            if tries > 20 then
                return
            else
                local Plants = import "Server/Systems/Plants"
                local biome = getBiome(cave)
                local plant = BiomeCavePlants[biome][math.random(1, #BiomeCavePlants[biome])]
                plant = Plants.createPlant(plant,CFrame.new(pos, pos + normal) * CFrame.Angles(-math.pi/2,0,0), math.random(1, 3))
                local val = Instance.new("ObjectValue", cave)
                val.Value = plant
            end
        end
    end
end

local function populateSpawnZoneWithRocks(zone)
    local limit = math.max(1, math.min(4, zone.Size.magnitude/40))
    for i = 1, limit do
        local tries = 0
        local pos, normal
        repeat 
            pos, normal = getRockPosition(zone)
            tries = tries + 1
        until
            (pos) or tries > 30
        if tries > 30 then
            warn("something went wrong with zone: ", zone, " at ", zone.Position, " in ", zone.Parent)
        else
            local cf = CFrame.new(pos, pos + normal) * CFrame.Angles(-math.pi/2,0,0)
            local rock = game.ServerStorage.Rocks[zone.Rock.Value]:Clone()
            rock.Parent = workspace
            rock:SetPrimaryPartCFrame(cf * CFrame.new(0, rock.PrimaryPart.Size.Y/2, 0))
        end
    end
end

local function onZoneAdded(zone)
    if zone.Type.Value == "Rock" then
        populateSpawnZoneWithRocks(zone)
        zone.Parent = nil
    end
end

for _, zone in pairs(CollectionService:GetTagged("SpawnZone")) do
    if zone:IsDescendantOf(workspace) then
        onZoneAdded(zone)
    end
end

for _, cave in pairs(CollectionService:GetTagged("Cave")) do
    if cave:IsDescendantOf(workspace) then
        onCaveAdded(cave)
    end
end

local Ecosystem = {}

function Ecosystem:start()
   -- RunService.Stepped:connect(populateTrees)
   -- RunService.Stepped:connect(populateCaves)
    CollectionService:GetInstanceAddedSignal("SpawnZone"):connect(onZoneAdded)
    CollectionService:GetInstanceAddedSignal("Cave"):connect(onCaveAdded)
end

return Ecosystem