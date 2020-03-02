local tilePossibilitiesMap = {}

local size = 4

local directions = {"Left","Right","Top","Bottom"}
local oppositeDirections = {"Right", "Left", "Bottom", "Top"}

tilePossibilitiesMap.Grass = {
    "JungleGrass", "Grass", "DryGrass"
}

tilePossibilitiesMap.DryGrass = {
    "Grass", "DryGrass", "Sand"
}

tilePossibilitiesMap.Sand = {
    "DryGrass", "Sand"
}

tilePossibilitiesMap.JungleGrass = {
    "Grass", "JungleGrass"
}

-- ok, now we have a map of [tileName] = {direction = thing that can be here or nil}
local tiles = {}

local function newTile(x, y) -- holds the possibilities for the tile and the collapsed result
    local tile = {}
    tile.x = x
    tile.y = y
    tile.possibilities = {"Sand", "Grass", "JungleGrass", "DryGrass"}
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
    end
end

for x = 1, size do
    for y = 1, size do
        table.insert(tiles, newTile(x,y))
    end
end

local finalTiles = {}

local function getLeastEntropicTile()
    local lowestEntropy = 10000
    local leastEntropicTile
    for _, tile in pairs(tiles) do
        local thisEntropy = (#tile.possibilities)
        if (thisEntropy < lowestEntropy) and tile.collapseResult == nil then -- let's not include collapsed tiles
            lowestEntropy = thisEntropy
            leastEntropicTile = tile
        end
    end
    return leastEntropicTile
end

local function collapse(tile)
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

local function tileHasPossibility(tile, possibility)
    for _, p in pairs(tile.possibilities) do
        if p == possibility then
            return true
        end
    end
    return false
end

--[[ -- local found = false
            for _, checkPossibility in pairs(validPossibilities) do
                if checkPossibility == assumedPossibilityName then
                    found = true
                end
            end
            if found == false then
                return false
            end
            local oppositeDirections = {"Right","Left","Bottom","Top"}]]

local function visualizeTiles(goldX, goldY)
    for _, tile in pairs(tiles) do
        if not tile.collapseResult then 
            if not workspace:FindFirstChild(tile.x.."X"..tile.y.."Y") then
                local folder = Instance.new("Folder", workspace)
                folder.Name = tile.x.."X"..tile.y.."Y"
            end
            local folder = workspace[tile.x.."X"..tile.y.."Y"]
            folder:ClearAllChildren()
            for _, possibility in pairs(tile.possibilities) do
                if not folder:FindFirstChild(possibility) then
                    local newModel = workspace.Example[possibility]:Clone()
                    newModel:SetPrimaryPartCFrame(CFrame.new(tile.x*8, 0, tile.y*8))
                    newModel.Parent = folder
                    if tile.x == goldX and tile.y == goldY then
                        newModel.Render.BrickColor = BrickColor.new("Bright red")
                    end
                    newModel.Render.Transparency = .3
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
        if #folder:GetChildren() > 1 then
            for i, v in pairs(folder:GetChildren()) do
                if i > 1 then
                    v:Destroy()
                end
            end
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

    print("my last tile had: ", #prevTile.possibilities)

    for _, possibleModule in pairs(tile.possibilities) do
        if doesPossibilityWorkBeside(possibleModule, prevTile) then
            table.insert(newPossibileModules, possibleModule)
        end
    end

    return newPossibileModules
end

local function solveTile(tile ,lastTile)
    visualizeTiles(tile.x, tile.y)
    wait()
    local newPossibilities = getUpdatedPossibilities(tile, lastTile)
    if #newPossibilities ~= #tile.possibilities then -- we updated our number of possibilities
        tile.possibilities = newPossibilities
    else
        tile.possibilities = newPossibilities
        collapse(tile)
        for _, direction in pairs(directions) do -- propogate if collapsed
            local t = getTileInDirection(tile, direction)
            if t and not t.collapseResult then
                solveTile(t, tile)
            end
        end
    end
end

collapse(tiles[1])
local lastUnsolved = tiles[1]

local unsolved = getLeastEntropicTile()
while unsolved do
    solveTile(unsolved, lastUnsolved)
    lastUnsolved = unsolved
    unsolved = getLeastEntropicTile()
end
