local tilePossibilitiesMap = {}

local size = 100

local directions = {"Left","Right","Forward","Backward", "Up", "Down"}
local permutationDirections = {"Left", "Right", "Forward", "Backward"}

local function getPermutation(model, direction)
    if direction == "Forward" then
        local new = model:Clone()
        new.Base.Transparency = .99
        new.Base.FrontSurface = Enum.SurfaceType.Hinge
        return new
    else
        local new = model:Clone()
        local prevValues = {
                
        }
        for _, x in pairs(new:GetChildren()) do
            if x:IsA("StringValue") then
                prevValues[x.Name] = x.Value
            end
        end
        if direction == "Left" then
            new.Front.Value = prevValues.Right
            new.Left.Value = prevValues.Front
            new.Back.Value = prevValues.Left
            new.Right.Value = prevValues.Back
            for _, v in pairs(new:GetChildren()) do
                if v.Name ~= "Base" and v:IsA("BasePart") then
                    v.CFrame = v.CFrame * CFrame.Angles(0, -math.pi/2, 0)
                end
            end
        elseif direction == "Right" then
            new.Front.Value = prevValues.Left
            new.Right.Value = prevValues.Front
            new.Back.Value = prevValues.Right
            new.Left.Value = prevValues.Back
            for _, v in pairs(new:GetChildren()) do
                if v.Name ~= "Base"and v:IsA("BasePart") then
                    v.CFrame = v.CFrame * CFrame.Angles(0, math.pi/2, 0)
                end
            end
        elseif direction == "Backward" then
            new.Back.Value = prevValues.Front
            new.Front.Value = prevValues.Back
            new.Left.Value = prevValues.Right
            new.Right.Value = prevValues.Left
            for _, v in pairs(new:GetChildren()) do
                if v.Name ~= "Base"and v:IsA("BasePart") then
                    v.CFrame = v.CFrame * CFrame.Angles(0, math.pi, 0)
                end
            end
        end
        new.Base.Transparency = .99
        new.Base.FrontSurface = Enum.SurfaceType.Hinge
        return new
    end
end

workspace.Example:ClearAllChildren()

for _, tileTemplate in pairs(workspace.BaseTiles:GetChildren()) do
    for _, dir in pairs(permutationDirections) do
        if dir == "Forward" then 
            local newModel = getPermutation(tileTemplate, dir)
            newModel.Name = newModel.Name..dir
            newModel.Parent = workspace.Example
        end
    end
end

local allPossibilities = {}

for _, x in pairs(workspace.Example:GetChildren()) do
    table.insert(allPossibilities, x.Name)
end

-- ok, now we have a map of [tileName] = {direction = thing that can be here or nil}
local finalTiles = {}
local tiles = {}

local function newTile(x, y, z) -- holds the possibilities for the tile and the collapsed result
    local tile = {}
    tile.x = x
    tile.y = y
    tile.z = z
    tile.possibilities = allPossibilities
    tile.collapseResult = nil
    return tile
end

local function getTileInDirection(baseTile, direction)
    for _, tile in pairs(tiles) do
        if direction == "Backward" then
            if tile.x == baseTile.x and tile.z == baseTile.z + 1 and tile.y == baseTile.y then
                return tile
            end
        end
        if direction == "Forward" then
            if tile.x == baseTile.x and tile.z == baseTile.z - 1 and tile.y == baseTile.y then
                return tile
            end
        end
        if direction == "Left" then
            if tile.x == baseTile.x - 1 and tile.z == baseTile.z and tile.y == baseTile.y then
                return tile
            end
        end
        if direction == "Right" then
            if tile.x == baseTile.x + 1 and tile.z == baseTile.z and tile.y == baseTile.y then
                return tile
            end
        end
        if direction == "Up" then
            if tile.x == baseTile.x and tile.z == baseTile.z and tile.y == baseTile.y + 1 then
                return tile
            end
        end
        if direction == "Down" then
            if tile.x == baseTile.x and tile.z == baseTile.z and tile.y == baseTile.y - 1 then
                return tile
            end
        end
    end
end

local possibilitiesMap = {}

for _, exModel in pairs(workspace.Example:GetChildren()) do
    if not possibilitiesMap[exModel.Name] then
        possibilitiesMap[exModel.Name] = {}
    end
    for _, x in pairs(exModel:GetChildren()) do
        if x:IsA("StringValue") then
            possibilitiesMap[exModel.Name][x.Name] = x.Value
        end
    end
end

local function getWeight(possibility)
    return 1
end

local function shannonEntropyForTile(tile)
    --# Sums are over the weights of each remaining allowed tile type for the square whose entropy we are calculating.
    local sum_of_weights = 0
    local sum_of_weight_log_weights = 0
    for _, opt in pairs (tile.possibilities) do
        local weight = getWeight(opt)
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

local function tableContains(t, v)
    for i, x in pairs(t) do
        if x == v then
            return true
        end
    end
    return false
end

local function collapse(tile, lastTile)
    if #tile.possibilities < 1 then
        tile.possibilities = lastTile.possibilities -- if a tile ends in an error state lets just grab the last tile's stuff
        warn("Tile possibilities dropped to less than one (should not happen, system is over constrained)")
    end
    tile.collapseResult = tile.possibilities[math.random(1, #tile.possibilities)]
    print("collapsing ", tile.x,tile.y,tile.z, " to ", tile.collapseResult)
    tile.possibilities = {tile.collapseResult}
    table.insert(finalTiles, tile)
end

local function visualizeTiles(goldX, goldY, goldZ)
    for _, tile in pairs(tiles) do
        if not tile.collapseResult then 
            local str = tile.x.." "..tile.y.." "..tile.z.." "
            if not workspace.Tiles:FindFirstChild(str) then
                local folder = Instance.new("Folder", workspace.Tiles)
                folder.Name = str
            end
            local folder = workspace.Tiles[str]
            for _, possibility in pairs(tile.possibilities) do
                local newModel
                if not folder:FindFirstChild(possibility) then
                    newModel = workspace.Example[possibility]:Clone()
                    newModel:SetPrimaryPartCFrame(CFrame.new(tile.x*8, tile.y*8, tile.z*8))
                    newModel.Parent = folder
                else
                    newModel = folder[possibility]
                end
                if tile.x == goldX and tile.y == goldY and tile.z == goldZ then
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
        local str = tile.x.." "..tile.y.." "..tile.z.." "
        if not workspace.Tiles:FindFirstChild(str) then
            local folder = Instance.new("Folder", workspace.Tiles)
            folder.Name = str
        end
        local folder = workspace.Tiles[str]
        if #folder:GetChildren() > 1 then
            folder:ClearAllChildren()
        end
        if not folder:FindFirstChild(tile.collapseResult) then
            local newModel
            newModel = workspace.Example[tile.collapseResult]:Clone()
            newModel:SetPrimaryPartCFrame(CFrame.new(tile.x*8, tile.y*8, tile.z*8))
            newModel.Parent = folder
        else
            for _, ch in pairs(folder[tile.collapseResult]:GetChildren()) do
                if ch.Name == "Render" and not string.find(tile.collapseResult, "Sky") then
                    ch.Transparency = 0
                end
            end
        end
    end
end

local function getDirectionalRelationship(from, to) -- returns a face, not a direction
    if from.x == to.x and from.y == to.y and from.z ==to.z - 1 then
        return "Front", "Back" -- from is is front of tile 2
    elseif from.x == to.x and from.y == to.y and from.z ==to.z + 1 then
        return "Back", "Front" -- to is behing from
    elseif from.x == to.x and from.y == to.y + 1 and from.z ==to.z  then
        return "Top", "Bottom"
    elseif from.x == to.x and from.y == to.y - 1 and from.z ==to.z  then
        return "Bottom", "Top"
    elseif from.x == to.x + 1 and from.y == to.y and from.z ==to.z  then
        return "Right", "Left"
    elseif from.x == to.x - 1 and from.y == to.y and from.z ==to.z  then
        return "Left", "Right"
    end
end

local function getUpdatedPossibilities(toTile, fromTile)
    assert(toTile)
    assert(fromTile and #fromTile.possibilities >= 1)
    
    local fromDirection, toDirection = getDirectionalRelationship(fromTile, toTile)

    local allowedModuleNames = {}

    for _, moduleName in pairs(fromTile.possibilities) do
        local module = possibilitiesMap[moduleName] or error("No module found")
        allowedModuleNames[module[fromDirection]] = true
    end

    -- Module possibilities not allowed from prev tile, but exist
    local newPossibilities = {}
    local removed = false

    for _, moduleName in pairs(toTile.possibilities) do
        local module = possibilitiesMap[moduleName] or error("No module found (2)")
        local requiredNext = module[toDirection]
        if allowedModuleNames[requiredNext] then
            table.insert(newPossibilities, moduleName)
        else
            removed = true
        end
    end

    return newPossibilities, removed
end

    --[[
    local newPossibleModules = {}

    local removedPossibility = false

    local direction, opposite = getDirectionalRelationship(tile, prevTile)

    print(tile.x, tile.y, tile.z, " is to the ", direction, " of ", prevTile.x, prevTile.y, prevTile.z)

    local prevTileModule = prevTile.possibilities[1] --or "SkyForward"

    print("prevTile has : ", #prevTile.possibilities)

    -- for each of the previous tile's possibilities, check if that possibility would accept THIS possibility in 
    -- a direction, so long as one of them does, we can keep our possibility

    if prevTileModule then 
        for _, possibleModule in pairs(tile.possibilities) do
            local possibilityInDirection = possibilitiesMap[possibleModule][opposite] -- check MY possibility in opposite direction
            local prevTilePossibilityInOpposite = possibilitiesMap[prevTileModule][direction] -- check THEIR possibility in direction
            if possibilityInDirection ~= prevTilePossibilityInOpposite then
                print("removing: ", possibleModule)
                print("this is because ",possibleModule,"would need ", possibilityInDirection, " in the direction ", opposite)
                print("but the tile other tile, ", prevTile.x,prevTile.y,prevTile.z, prevTileModule, " has ", prevTilePossibilityInOpposite, " in ", direction)
                removedPossibility = true
            else
                table.insert(newPossibleModules, possibleModule)
            end
        end
    end

    return newPossibleModules, removedPossibility
end--]]

local function updateTileNeighborsRecursive(tile)
    print("updating recursive for: ", tile.x, tile.y, tile.z)
    for _, direction in pairs(directions) do -- propogate if CHANGED
        local neighbor = getTileInDirection(tile, direction)
        if neighbor then
            local newPossibilities, removedPossibility = getUpdatedPossibilities(neighbor, tile)
            if removedPossibility then
                neighbor.possibilities = newPossibilities
                -- Now we've changed this neighbor, all its neighbors need to update
                print("updating neighbor in direction", direction)
                wait()
                updateTileNeighborsRecursive(neighbor)
            end
            visualizeTiles(neighbor.x, neighbor.y, neighbor.z)
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
        print("collapse", unsolved.x, unsolved.y, unsolved.z)
        visualizeTiles(unsolved.x, unsolved.y, unsolved.z)

        -- This function propogates changes from the JUST collapsed
        -- file. Once we do this, all neighbors
        updateTileNeighborsRecursive(unsolved)

        unsolved = getLeastEntropicTile()
        wait()
    end
end

local function getWfcGridOfSize(size)
    tiles = {}
    finalTiles = {}

    for x = 1, size do
        for y = 1,size do
            for z = 1, size do
                local tile = newTile(x,y, z)
                table.insert(tiles, tile)
                -- if y == 1 then
                --     local unsolved = tile
                --     tile.possibilities = {"FlatForward"}
                --     collapse(unsolved)
                --     visualizeTiles(unsolved.x, unsolved.y, unsolved.z)
                --     updateTileNeighborsRecursive(unsolved)
                -- elseif y == size then
                --     local unsolved = tile
                --     tile.possibilities = {"SkyForward"}
                --     collapse(unsolved)
                --     visualizeTiles(unsolved.x, unsolved.y, unsolved.z)
                --     updateTileNeighborsRecursive(unsolved)
                -- end
            end
        end
    end

    local tile
    for i, v in pairs(tiles) do
        if v.x == 2 and v.y == 2 and v.z == 2 then
            tile = v
        end
    end
    assert(tile)
    local unsolved = tile
    tile.possibilities = {"GrassForward"}
    --collapse(unsolved)
    visualizeTiles(unsolved.x, unsolved.y, unsolved.z)
    updateTileNeighborsRecursive(unsolved)

    --run(tiles)

    return tiles
end

--local grid = getWfcGridOfSize(3)

--visualizeTiles()