
local import = require(game.ReplicatedStorage.Shared.Import)
local CollectionService = game:GetService("CollectionService")
local CastRay = import "Shared/Utils/CastRay"

local biomeChecks = {
    ["Rainforest"] = function(hit)
        return CollectionService:HasTag(hit, "Grass")
    end,
    ["Desert"] = function(hit)
        return CollectionService:HasTag(hit, "Sand") or CollectionService:HasTag(hit, "Grass")
	end,
	["RainforestCave"] = function(hit)
		return CollectionService:HasTag(hit, "CaveGrowable")
	end,
}

local function randomPointOnPartSurface(part)
    local start = part.CFrame  * CFrame.new(0, part.Size.Y/2, 0)
    local xDist = math.random(-part.Size.X/2, part.Size.X/2)
    local zDist = math.random(-part.Size.Z/2, part.Size.Z/2)
    return (start * CFrame.new(xDist, 0, zDist)).p
end

local function canPlantGoOn(hit, tile, biome)
    local basicCheck1 = hit and hit.Transparency == 0 and hit.Anchored
    if tile and not hit:IsDescendantOf(tile) then
		basicCheck1 = false
    end
	local basicCheck2 = basicCheck1 and (not CollectionService:HasTag(hit, "EffectSand"))
	local basicCheck3 = basicCheck2 and biomeChecks[biome](hit)
    return basicCheck3
end

local grassesCache = {}

local function getValidSurfacesFor(tile, biome)
	if grassesCache[tile] and grassesCache[tile][biome] then
		local grasses = {}
		for grass, _ in pairs(grassesCache[tile][biome]) do
			table.insert(grasses, grass)
		end
		return grasses
	end
	local grasses = {}
	for _, v in pairs(tile:GetDescendants()) do
		if v:IsA("BasePart") and biomeChecks[biome](v) then
			if not grassesCache[tile] then
				grassesCache[tile] = {}
			end
			if not grassesCache[tile][biome] then
				grassesCache[tile][biome] = {}
			end
			grassesCache[tile][biome][v] = true
			table.insert(grasses, v)
		end
	end
	return grasses
end

return function(tile, plantName, biome)
	local surfaces = getValidSurfacesFor(tile, biome)

	if #surfaces == 0 then
		return
	end

    local plantFolder = game.ServerStorage.PlantPhases[plantName]
    local numChildren = #plantFolder:GetChildren()
    local model = plantFolder[numChildren..""]
    local size = (model).PrimaryPart.Size.X
    local ysize = model:GetModelSize().Y

    local grass = surfaces[math.random(1, #surfaces)]
	local rayStartPos = randomPointOnPartSurface(grass)
    local tries = 0
    local hit, pos, normal
    local dot
    repeat
        hit, pos, normal = CastRay(rayStartPos + Vector3.new(0,ysize,0), Vector3.new(0,(-ysize) - 4,0))
        dot = Vector3.new(0,1,0):Dot(normal)
        tries = tries + 1

		local condition1 = hit
		local condition2 = hit and canPlantGoOn(hit, tile, biome)

		if not (condition1 and condition2) then
            grass = surfaces[math.random(1, #surfaces)]
            rayStartPos = randomPointOnPartSurface(grass)
            hit = nil
        end

        if tries%5 == 0 then
            wait()
        end
    until
        tries > 40 or (hit)
    if tries > 40 then
        return
    end

    if dot ~= 1 then
        if size > 10 then
            local amount = math.min(8, math.abs(size - 10))
            pos = pos - Vector3.new(0,amount,0) -- this is just a visual thing for larger trees spawning inside funny wedges
        end
    end

    return pos, normal
end
