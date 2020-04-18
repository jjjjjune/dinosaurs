
local import = require(game.ReplicatedStorage.Shared.Import)
local CollectionService = game:GetService("CollectionService")
local CastRay = import "Shared/Utils/CastRay"

local function randomPointOnPartSurface(part)
    local start = part.CFrame  * CFrame.new(0, part.Size.Y/2, 0)
    local xDist = math.random(-part.Size.X/2, part.Size.X/2)
    local zDist = math.random(-part.Size.Z/2, part.Size.Z/2)
    return (start * CFrame.new(xDist, 0, zDist)).p
end

local function canPlantGoOn(hit, tile)
    return (CollectionService:HasTag(hit, "Grass") and hit.Transparency == 0 and hit.Anchored) or CollectionService:HasTag(hit, "Sand") and hit:IsDescendantOf(tile)
end

local function isDotValid(dot)
    print(dot)
    return dot > .5 and dot < 1.5
end

local function isAreaGood(position, size)
    -- in every corner of this direction, we check if a downwards ray will hit a valid point
    local isGood = true

    local start1 = position + Vector3.new(size,0,size)
    local start2 = position + Vector3.new(-size, 0, size)
    local start3 = position + Vector3.new(-size, 0, -size)
    local start4 = position + Vector3.new(size, 0,- size)

    local dir = Vector3.new(0,-1,0)

    local hit, pos, normal = CastRay(start1, dir)
    local dot = Vector3.new(0,1,0):Dot(normal)

    if not hit then
        isGood = false
    else
        if isDotValid(dot) then
            isGood = false
        else
            if not canPlantGoOn(hit) then
                isGood = false
            end
        end
    end

    hit, pos, normal = CastRay(start2, dir)
    dot = Vector3.new(0,1,0):Dot(normal)

    if not hit then
        isGood = false
    else
        if isDotValid(dot) then
            isGood = false
        else
            if not canPlantGoOn(hit) then
                isGood = false
            end
        end
    end

    hit, pos, normal = CastRay(start3, dir)
    dot = Vector3.new(0,1,0):Dot(normal)

    if not hit then
        isGood = false
    else
        if isDotValid(dot)then
            isGood = false
        else
            if not canPlantGoOn(hit) then
                isGood = false
            end
        end
    end

    hit, pos, normal = CastRay(start4, dir)
    dot = Vector3.new(0,1,0):Dot(normal)

    if not hit then
        isGood = false
    else
        if isDotValid(dot) then
            isGood = false
        else
            if not canPlantGoOn(hit) then
                isGood = false
            end
        end
    end

    return isGood
end

return function(tile, plantName)
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

    local plantFolder = game.ServerStorage.PlantPhases[plantName]
    local numChildren = #plantFolder:GetChildren()
    local model = plantFolder[numChildren..""]
    local size = (model).PrimaryPart.Size.X
    -- roughly the base size of dis

    local grass = grasses[math.random(1, #grasses)]
    local rayStartPos = randomPointOnPartSurface(grass)
    local tries = 0
    local hit, pos, normal
    local dot
    repeat
        hit, pos, normal = CastRay(rayStartPos + Vector3.new(0,100,0), Vector3.new(0,-200,0))
        dot = Vector3.new(0,1,0):Dot(normal)
        tries = tries + 1
        if (not hit) or (hit and not canPlantGoOn(hit, tile)) or (not isDotValid(dot)) then
            grass = grasses[math.random(1, #grasses)]
            rayStartPos = randomPointOnPartSurface(grass)
            hit = nil
        end
    until 
        tries > 20 or (hit)
    if tries > 20 then
        return
    end

    if dot ~= 1 then
        if size > 8 then
            pos = pos - Vector3.new(0,8,0) -- this is just a visual thing for larger trees spawning inside funny wedges
        end
    end

    return pos
end