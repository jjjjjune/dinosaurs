local tilePossibilitiesMap = {}

local size = 100

local directions = {"Left","Right","Top","Bottom"}--, "TopRight", "TopLeft", "BottomRight", "BottomLeft"}

tilePossibilitiesMap.Grass = {
    "JungleGrass", "Grass", "DryGrass"--, "Swamp",
}

tilePossibilitiesMap.DryGrass = {
    "Grass", "DryGrass", "Sand"
}

tilePossibilitiesMap.Sand = {
    "DryGrass", "Sand"
}

tilePossibilitiesMap.Water = {
    "Swamp", "Water"--, "JungleGrass",
}

tilePossibilitiesMap.Swamp = {
    "Swamp","JungleGrass","Water", "Grass",
}

tilePossibilitiesMap.JungleGrass = {
    "Grass", "JungleGrass"
}



-- ok, now we have a map of [tileName] = {direction = thing that can be here or nil}
local finalTiles = {}
local tiles = {}

local function newTile(x, y) -- holds the possibilities for the tile and the collapsed result
    local tile = {}
    tile.x = x
    tile.y = y
    tile.possibilities = {"Sand", "Grass", "DryGrass",  "JungleGrass"}--, "Water", "Swamp"}
    tile.collapseResult = nil
    return tile
end

local function getTileInDirection(baseTile, direction)
    for _, tile in pairs(tiles) do
        if direction == "Top" then
            if tile.x == baseTile.x and tile.y == baseTile.y + 1 then
                return tile
            end
        end
        if direction == "Bottom" then
            if tile.x == baseTile.x and tile.y == baseTile.y - 1 then
                return tile
            end
        end
        if direction == "Left" then
            if tile.x == baseTile.x - 1 and tile.y == baseTile.y then
                return tile
            end
        end
        if direction == "Right" then
            if tile.x == baseTile.x + 1 and tile.y == baseTile.y then
                return tile
            end
        end
        if direction == "TopRight" then
            if tile.x == baseTile.x + 1 and tile.y == baseTile.y + 1 then
                return tile
            end
        end
        if direction == "BottomRight" then
            if tile.x == baseTile.x + 1 and tile.y == baseTile.y - 1 then
                return tile
            end
        end
        if direction == "TopLeft" then
            if tile.x == baseTile.x - 1 and tile.y == baseTile.y + 1 then
                return tile
            end
        end
        if direction == "BottomRight" then
            if tile.x == baseTile.x + 1 and tile.y == baseTile.y - 1 then
                return tile
            end
        end
    end
end

local weights = {}

local function getWeight(possibility)
    if not weights[possibility] then
        local totalWeight = 0
        local occurances = {}
        for materialName, possibleMaterials in pairs(tilePossibilitiesMap) do
            for _, material in pairs(possibleMaterials) do
                if not occurances[material] then
                    occurances[material] = 1
                else
                    occurances[material] = occurances[material] + 1
                end
                totalWeight = totalWeight + 1
            end
        end
        weights[possibility] = occurances[possibility]/totalWeight
    end
    return weights[possibility]
end

local function shannonEntropyForTile(tile)
    --# Sums are over the weights of each remaining allowed tile type for the square whose entropy we are calculating.
    sum_of_weights = 0
    sum_of_weight_log_weights = 0
    for _, opt in pairs (tile.possibilities) do
        weight = getWeight(opt)
        sum_of_weights = sum_of_weights + weight
        sum_of_weight_log_weights = sum_of_weight_log_weights + weight * math.log(weight)
    end

    return math.log(sum_of_weights) - (sum_of_weight_log_weights / sum_of_weights)
end

local function getLeastEntropicTile()
    local lowestEntropy = 10000
    local leastEntropicTile
    for _, tile in pairs(tiles) do
        local thisEntropy = shannonEntropyForTile(tile)
        if (thisEntropy < lowestEntropy) and tile.collapseResult == nil then -- let's not include collapsed tiles
            lowestEntropy = thisEntropy
            leastEntropicTile = tile
        end
    end
    return leastEntropicTile
end

local function collapse(tile, lastTile)
    if #tile.possibilities < 1 then
        tile.possibilities = lastTile.possibilities -- if a tile ends in an error state lets just grab the last tile's stuff
        warn("Tile possibilities dropped to less than one (should not happen, system is over constrained)")
    end
    --[[if lastTile and tableContains(tile.possibilities, lastTile.possibilities[1]) then
        if math.random(1, 10) < 9 then
            tile.possibilities = {lastTile.possibilities[1]}
        end
    end--]]
    tile.collapseResult = tile.possibilities[math.random(1, #tile.possibilities)]
    tile.possibilities = {tile.collapseResult}
    table.insert(finalTiles, tile)
end

local function tableContains(t, v)
    for i, x in pairs(t) do
        if x == v then
            return true
        end
    end
    return false
end

local function visualizeTiles(goldX, goldY)
    for _, tile in pairs(tiles) do
        if not tile.collapseResult then 
            if not workspace:FindFirstChild(tile.x.."X"..tile.y.."Y") then
                local folder = Instance.new("Folder", workspace)
                folder.Name = tile.x.."X"..tile.y.."Y"
            end
            local folder = workspace[tile.x.."X"..tile.y.."Y"]
            for _, possibility in pairs(tile.possibilities) do
                local newModel
                if not folder:FindFirstChild(possibility) then
                    newModel = workspace.Example[possibility]:Clone()
                    newModel:SetPrimaryPartCFrame(CFrame.new(tile.x*8, 0, tile.y*8))
                    newModel.Parent = folder
                else
                    newModel = folder[possibility]
                end
                if tile.x == goldX and tile.y == goldY then
                    newModel.Render.BrickColor = BrickColor.new("Bright red")
                    newModel.Render.Transparency = 0
                else
                    newModel.Render.Transparency = .7
                    newModel.Render.BrickColor = workspace.Example[newModel.Name].Render.BrickColor
                end
            end
            for i, v in pairs(folder:GetChildren()) do
                if not tableContains(tile.possibilities, v.Name) then
                    v:Destroy()
                end
            end
       end
    end
    for _, tile in pairs(finalTiles) do
        if not workspace:FindFirstChild(tile.x.."X"..tile.y.."Y") then
            local folder = Instance.new("Folder", workspace)
            folder.Name = tile.x.."X"..tile.y.."Y"
        end
        local folder = workspace[tile.x.."X"..tile.y.."Y"]
        if not folder:FindFirstChild(tile.collapseResult) and #folder:GetChildren() == 0 then
            local newModel
            newModel = workspace.Example[tile.collapseResult]:Clone()
            newModel:SetPrimaryPartCFrame(CFrame.new(tile.x*8, 0, tile.y*8))
            newModel.Parent = folder
        end
        for _, v in pairs(folder:GetChildren()) do
            if v.Name ~= tile.collapseResult then
                v.Name = tile.collapseResult
                v:FindFirstChild("Render").BrickColor = workspace.Example[tile.collapseResult]:FindFirstChild("Render").BrickColor
            else
                v.Render.Transparency = 0
                v.Base.Transparency = 1
                v:FindFirstChild("Render").BrickColor = workspace.Example[tile.collapseResult]:FindFirstChild("Render").BrickColor
            end
        end
    end
end

local function doesPossibilityWorkBeside(possibleModule, tile)
    local allowedPossibilities ={}
    for _, moduleName in pairs(tile.possibilities) do
        local allowedForModule = tilePossibilitiesMap[moduleName]
        for _,x  in pairs(allowedForModule) do
            table.insert(allowedPossibilities, x)
        end
    end
    return tableContains(allowedPossibilities, possibleModule)
end

local function getUpdatedPossibilities(tile, prevTile)
    local newPossibileModules = {}

    local removedPossibility = false

    for _, possibleModule in pairs(tile.possibilities) do
        if doesPossibilityWorkBeside(possibleModule, prevTile)
            and doesPossibilityWorkBeside(possibleModule, tile) then
            table.insert(newPossibileModules, possibleModule)
        else
            removedPossibility = true
        end
    end

    return newPossibileModules, removedPossibility
end

local function updateTileNeighborsRecursive(tile)
    for _, direction in pairs(directions) do -- propogate if CHANGED
        local neighbor = getTileInDirection(tile, direction)
        if neighbor then
            local newPossibilities, removedPossibility = getUpdatedPossibilities(neighbor, tile)
            if removedPossibility then
                neighbor.possibilities = newPossibilities

                -- Now we've changed this neighbor, all its neighbors need to update
                updateTileNeighborsRecursive(neighbor)
                --game:GetService("RunService").RenderStepped:Wait()
                visualizeTiles(tile.x, tile.y)
            end
        end
    end
end

local function run(tiles)
    --[[for _, possibility in pairs(tiles[1].possibilities) do
        local t = tiles[math.random(1, #tiles)]
        t.possibilities = {possibility}
        collapse(t)
    end--]]
    local unsolved = getLeastEntropicTile()
    --unsolved.possibilities = {"Sand"}
    while unsolved and #unsolved.possibilities > 0 do
        -- Big difference: only need to collapse 1 tile, then we need to force
        -- constraints on whole system.
        collapse(unsolved)
        visualizeTiles()

        -- This function propogates changes from the JUST collapsed
        -- file. Once we do this, all neighbors
        updateTileNeighborsRecursive(unsolved)

        unsolved = getLeastEntropicTile()
        --wait()
    end
end

local function getWfcGridOfSize(size)
    tiles = {}
    finalTiles = {}

    for x = 1, size do
        for y = 1, size do
            table.insert(tiles, newTile(x,y))
        end
    end

    run(tiles)

    return tiles
end

local grid = getWfcGridOfSize(10)

visualizeTiles()



local newMath = {}
local floor = math.floor
local perm = {}

for i = 1,512 do
    perm[i] = math.random(1,256)
end

local function grad( hash, x, y )
local h = hash%8; -- Convert low 3 bits of hash code
local u = h<4 and x or y; -- into 8 simple gradient directions,
local v = h<4 and y or x; -- and compute the dot product with (x,y).
return ((h%2==1) and -u or u) + ((floor(h/2)%2==1) and -2.0*v or 2.0*v);
end

function noise(x,y)
local ix0, iy0, ix1, iy1;
local fx0, fy0, fx1, fy1;
local s, t, nx0, nx1, n0, n1;
ix0 = floor(x); -- Integer part of x
iy0 = floor(y); -- Integer part of y
fx0 = x - ix0; -- Fractional part of x
fy0 = y - iy0; -- Fractional part of y
fx1 = fx0 - 1.0;
fy1 = fy0 - 1.0;
ix1 = (ix0 + 1) % 255; -- Wrap to 0..255
iy1 = (iy0 + 1) % 255;
ix0 = ix0 % 255;
iy0 = iy0 % 255;
    t = (fy0*fy0*fy0*(fy0*(fy0*6-15)+10));
    s = (fx0*fx0*fx0*(fx0*(fx0*6-15)+10));
nx0 = grad(perm[ix0 + perm[iy0+1]+1], fx0, fy0);
nx1 = grad(perm[ix0 + perm[iy1+1]+1], fx0, fy1);
n0 = nx0 + t*(nx1-nx0);
nx0 = grad(perm[ix1 + perm[iy0+1]+1], fx1, fy0);
nx1 = grad(perm[ix1 + perm[iy1+1]+1], fx1, fy1);
n1 = nx0 + t*(nx1-nx0);
return 0.5*(1 + (0.507 * (n0 + s*(n1-n0))))
end



local areaSize = 100

local tileSize = 32

local lip = 0
local roundNum = 20
local octaves = 10

local mountainScale = .05

local heightScale = 600

local tiles = {}
local useColors = {}
local alreadyTaken = {}
local useBiomes = {}

function round(n, mult)
    mult = mult or 1
    return math.floor((n + mult/2)/mult) * mult
end

for x = 1, areaSize do
    tiles[x] = {}
    useColors[x] = {}
    alreadyTaken[x] = {}
    useBiomes[x] = {}
    for y = 1, areaSize do
        tiles[x][y] = round(noise(x/areaSize, y/areaSize, octaves) * heightScale, roundNum)
    end
end

local centerX = math.floor(areaSize/2)
local centerY = math.floor(areaSize/2)

local maxDist = (Vector2.new(1,1) - Vector2.new(areaSize, areaSize)).magnitude

for x = 1, areaSize do
    for y = 1, areaSize do
        local dist = (Vector2.new(x,y) - Vector2.new(centerX, centerY)).magnitude
        tiles[x][y] = round(tiles[x][y] * (maxDist - dist)*mountainScale, roundNum)
    end
end

local highest = 0
for x = 1, areaSize do
    for y = 1, areaSize do
        if tiles[x][y] > highest then 
            highest = tiles[x][y]
        end
    end
end

print("CENTER X Y IS", centerX, centerY)

for x = 1, areaSize do
    for y = 1, areaSize do
        local dist = (Vector2.new(x,y) - Vector2.new(centerX, centerY)).magnitude
        local maxDist = areaSize
        local mountainScale = .1
        if dist < areaSize/10 then
            tiles[x][y] = highest
        end
    end
end

local heights = {}

for x = 1, areaSize do
    for y = 1, areaSize do
        table.insert(heights, tiles[x][y])
    end
end

table.sort(heights, function(a,b) return a > b end)

local biomes = {
    BrickColor.new("Shamrock"),
    BrickColor.new("Dark green"),
    BrickColor.new("Brick yellow"),
    BrickColor.new("Br. yellowish green")
}

--[[
    1, 2, 3
    1, 2
]]

local function getTileAtPosition(x,y)
    for _, t in pairs(grid) do
        if t.x == x and t.y == y then
            return t
        end
    end
end


local gridSize = 10

for x = 1, areaSize do
    for y = 1, areaSize do
        local multiplier = gridSize / areaSize
        local checkX = math.clamp(math.floor(x*multiplier), 1,gridSize)
        local checkY  = math.clamp(math.floor(y*multiplier), 1,gridSize)
        local t = getTileAtPosition(checkX, checkY)
        useColors[x][y] = ((#t.possibilities > 0) and t.possibilities[1]) or "Grass"
        useBiomes[x][y] = useColors[x][y]
        useColors[x][y] = workspace.Example[useColors[x][y]].Render.Color
    end
end

-- devide this grid into Shapes

for x = 1, areaSize do
    for y = 1, areaSize do
        if not alreadyTaken[x][y] then 
            local startHeight = tiles[x][y]
            local shapeChance = 999
            local startX = x
            local startY = y
            repeat
                local areaX = math.random(math.ceil(areaSize*.08), math.ceil(areaSize*.22))
                local areaY = math.random(math.ceil(areaSize*.08), math.ceil(areaSize*.22))
                local areaSize = Vector2.new(areaX, areaY)
                if math.random(1, 2) == 1 then
                    areaSize = Vector2.new(areaSize.X * -1, areaSize.Y)
                end
                if math.random(1, 2) == 1 then
                    areaSize = Vector2.new(areaSize.X , areaSize.Y* -1)
                end
                for areaX = 1, areaSize.X do
                    for areaY = 1, areaSize.Y do
                        local tileX = startX + areaX
                        local tileY = startY + areaY
                        if (tiles[tileX] and tiles[tileX][tileY]) and not alreadyTaken[tileX][tileY] then
                            shapeChance = shapeChance - .01
                            tiles[tileX][tileY] = startHeight
                            alreadyTaken[tileX][tileY] = true
                        else
                            shapeChance = shapeChance - .005
                        end
                    end
                end 
                startX = x + areaSize.X
                startY = y + areaSize.Y
            until
            math.random(1, 1000) > shapeChance
        end
    end
end

local function interpolateBySurrounding(color, x, y)
    local allColor = color
    local totalCols = 0
    local interpSize = 3
    for x2 = -interpSize, interpSize do
        for y2 = -interpSize, interpSize do 
            local tColor = useColors[x + x2] and useColors[x + x2][y + y2]
            if tColor then
                allColor = Color3.new(allColor.r + tColor.r, allColor.g + tColor.g, allColor.b + tColor.b)
                totalCols = totalCols + 1 
            end
        end
    end
    return Color3.new(allColor.r/totalCols, allColor.g/totalCols, allColor.b/totalCols)
end

workspace.Tiles:ClearAllChildren()


local function renderTiles()
    for x = 1, areaSize do
        wait()
        for y = 1, areaSize do
            useColors[x][y] = interpolateBySurrounding(useColors[x][y],x,y)
            local height = tiles[x][y]
            local part = Instance.new("Part")
            part.Size = Vector3.new(tileSize, height, tileSize)
            part.Anchored = true
            local cfDiff = 0
            if height < 0 then
                height = 10
                cfDiff = -height
            end
            part.CFrame = CFrame.new(x*tileSize, 0 + (height/2) + (cfDiff), y*tileSize)
            part.BrickColor = workspace.Example[useBiomes[x][y]].Base.BrickColor
            local grass = part:Clone()
            grass.Size = Vector3.new(grass.Size.X + lip, 4, grass.Size.Z + lip)
            grass.CFrame = part.CFrame * CFrame.new(0, part.Size.Y/2 + grass.Size.Y/2, 0)
            grass.BrickColor = BrickColor.new("Shamrock")
            grass.TopSurface = "Smooth"
            grass.BottomSurface = "Smooth"
            part.Parent = workspace.Tiles
            grass.Parent = workspace.Tiles
            grass.Color = useColors[x][y]
        end
    end
end

renderTiles()