local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local ServerData = import "Server/Systems/ServerData"

local tileNameToRotationMap = {}

local directions = {"Left","Right","Forward","Backward", "Up", "Down"}
local permutationDirections = {"Left", "Right", "Forward", "Backward"}

local allTiles = {}
local generatedMapTiles = {}

local function getPermutation(model, direction)
	local new = model:Clone()
    local originalCF = new.PrimaryPart.CFrame
    local cf = new.PrimaryPart.CFrame - new.PrimaryPart.CFrame.p
    if direction == "Left" then
        new:SetPrimaryPartCFrame(new.PrimaryPart.CFrame * CFrame.Angles(0, math.pi/2, 0))
        cf = new.PrimaryPart.CFrame - new.PrimaryPart.CFrame.p
    elseif direction == "Right" then
        new:SetPrimaryPartCFrame(new.PrimaryPart.CFrame * CFrame.Angles(0, -math.pi/2, 0))
        cf = new.PrimaryPart.CFrame - new.PrimaryPart.CFrame.p
    elseif direction == "Backward" then
        new:SetPrimaryPartCFrame(new.PrimaryPart.CFrame * CFrame.Angles(0, math.pi, 0))
        cf = new.PrimaryPart.CFrame - new.PrimaryPart.CFrame.p
    end
    tileNameToRotationMap[new.Name..direction] = cf
	new.Base.CFrame = originalCF
	new:SetPrimaryPartCFrame(CFrame.new(0,0,0))
	new.Name = model.Name..direction
	new.Parent = workspace -- sadly this is required for da raycast
	local skin = import "Shared/Utils/ConfigureWfcTile"
	skin(new)
	new.Parent = nil
	return new
end

for _, tileTemplate in pairs(game.ServerStorage.BaseTiles:GetChildren()) do
    for _, dir in pairs(permutationDirections) do
		if not tileTemplate:FindFirstChild("NoPermutations") then
			local newModel = getPermutation(tileTemplate, dir)
            newModel.Parent = game.ServerStorage.Example
		else
			local newModel = getPermutation(tileTemplate, "Forward")
            newModel.Parent = game.ServerStorage.Example
		end
    end
end

local allPossibilities = {}

for _, x in pairs(game.ServerStorage.Example:GetChildren()) do
    if not string.find(x.Name, "starttile") then 
        table.insert(allPossibilities, x.Name)
    end
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
    if direction == "Backward" then
		local nx = baseTile.x
		local ny = baseTile.y
		local nz = baseTile.z + 1
		if tiles[nx] and tiles[nx][ny] and tiles[nx][ny][nz] then
			return tiles[nx][ny][nz]
		end
    end
    if direction == "Forward" then
		local nx = baseTile.x
		local ny = baseTile.y
		local nz = baseTile.z - 1
		if tiles[nx] and tiles[nx][ny] and tiles[nx][ny][nz] then
			return tiles[nx][ny][nz]
		end
    end
    if direction == "Left" then
        local nx = baseTile.x - 1
		local ny = baseTile.y
		local nz = baseTile.z
		if tiles[nx] and tiles[nx][ny] and tiles[nx][ny][nz] then
			return tiles[nx][ny][nz]
		end
    end
    if direction == "Right" then
        local nx = baseTile.x + 1
		local ny = baseTile.y
		local nz = baseTile.z
		if tiles[nx] and tiles[nx][ny] and tiles[nx][ny][nz] then
			return tiles[nx][ny][nz]
		end
    end
    if direction == "Up" then
        local nx = baseTile.x
		local ny = baseTile.y + 1
		local nz = baseTile.z
		if tiles[nx] and tiles[nx][ny] and tiles[nx][ny][nz] then
			return tiles[nx][ny][nz]
		end
    end
    if direction == "Down" then
        local nx = baseTile.x
		local ny = baseTile.y - 1
		local nz = baseTile.z
		if tiles[nx] and tiles[nx][ny] and tiles[nx][ny][nz] then
			return tiles[nx][ny][nz]
		end
    end
end

local possibilitiesMap = {}

for _, exModel in pairs(game.ServerStorage.Example:GetChildren()) do
    if not possibilitiesMap[exModel.Name] then
        possibilitiesMap[exModel.Name] = {}
    end
    for _, x in pairs(exModel:GetChildren()) do
        if x:IsA("StringValue") then
            possibilitiesMap[exModel.Name][x.Name] = x.Value
        end
    end
end

local function getTotalAppearancesOfConnector(connectionType)
	local total = 0
	for _, ex in pairs(game.ServerStorage.Example:GetChildren()) do
		for _, side in pairs(ex:GetChildren()) do
			if side:IsA("StringValue") then
				if side.Value == connectionType then
					total = total + 1
				end
			end
		end
	end
	assert(total > 0)
	return total
end

local weights = {}

local function getWeight(possibility)
	if weights[possibility] then
		return weights[possibility]
	end
	local weightScore = 7
	local counted = {}
	local refModel = game.ServerStorage.Example[possibility]
	for _, side in pairs(refModel:GetChildren()) do
		if side:IsA("StringValue") then
			if not counted[side.Value] then
				counted[side.Value] = true
				weightScore = weightScore - 1
			end
		end
	end
	-- multiply by the sum of (total number of times each option appears across all tiles)
	local weightMultiplier = 1
	for connectionType, _ in pairs(counted) do
		local totalNumberOfAppearances = getTotalAppearancesOfConnector(connectionType)
		weightMultiplier = weightMultiplier + totalNumberOfAppearances
	end
	weights[possibility] = weightScore*weightMultiplier
	--print("weight for: ", possibility, " is ", weights[possibility])
    return weightScore
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

local function getLeastEntropicTileToCollapse()
    local lowestEntropy = 1000000
    local leastEntropicTile = nil
	local entropies = {}
    for _, tile in pairs(allTiles) do
        local thisEntropy = shannonEntropyForTile(tile)
		entropies[tile] = thisEntropy
        if (thisEntropy < lowestEntropy) and not tile.collapseResult then -- let's not include collapsed tiles
            lowestEntropy = thisEntropy
			leastEntropicTile = tile
        end
    end
	local leastEntropies = {}
	for tile, entropy in pairs(entropies) do
		if entropy == lowestEntropy then
			table.insert(leastEntropies, tile)
		end
	end
    return (#leastEntropies > 0 and leastEntropies[math.random(1, #leastEntropies)]) or leastEntropicTile
end

local function getCollapseResult(possibilities)
	local newPossibilities = {}
	for _, poss in pairs(possibilities) do
		local multiplier = 1
		if game.ServerStorage.Example:FindFirstChild(poss) then
			if game.ServerStorage.Example[poss]:FindFirstChild("Weight") then
				multiplier = game.ServerStorage.Example[poss]["Weight"].Value
			end
		end
		for i = 1, math.max(1, multiplier*100) do 
			table.insert(newPossibilities, poss)
		end
	end
	return newPossibilities[math.random(1, #newPossibilities)]
end

local function collapse(tile, lastTile)
    if #tile.possibilities < 1 then
        tile.possibilities = lastTile.possibilities -- if a tile ends in an error state lets just grab the last tile's stuff
        warn("Tile possibilities dropped to less than one (should not happen, system is over constrained)")
    end
    tile.collapseResult = getCollapseResult(tile.possibilities)
    tile.possibilities = {tile.collapseResult}
    table.insert(finalTiles, tile)
end

local function visualizeTiles()
    for _, tile in pairs(allTiles) do
        local str = tile.x.." "..tile.y.." "..tile.z.." "
        if not workspace.Tiles:FindFirstChild(str) then
            local folder = Instance.new("Folder", workspace.Tiles)
            folder.Name = str
        end
        local folder = workspace.Tiles[str]
        if #folder:GetChildren() > 1 then
            folder:ClearAllChildren()
        end
		local result = tile.possibilities[1]
        if not folder:FindFirstChild(result) then
            local newModel
            newModel = game.ServerStorage.Example[result]:Clone()
            newModel:SetPrimaryPartCFrame(CFrame.new(tile.x*30, (tile.y*30) - 13, tile.z*30))
            newModel.Parent = folder
        end
    end
end

local function getDirectionalRelationship(from, to) -- returns a face, not a direction
    if from.x == to.x and from.y == to.y and from.z ==to.z - 1 then
        return "Front", "Back" -- from is is front of tile 2
    elseif from.x == to.x and from.y == to.y and from.z ==to.z + 1 then
        return "Back", "Front" -- to is behing from
    elseif from.x == to.x and from.y == to.y + 1 and from.z ==to.z  then
        return "Bottom", "Top"
    elseif from.x == to.x and from.y == to.y - 1 and from.z ==to.z  then
        return "Top", "Bottom"
    elseif from.x == to.x + 1 and from.y == to.y and from.z ==to.z  then
        return "Right", "Left"
    elseif from.x == to.x - 1 and from.y == to.y and from.z ==to.z  then
        return "Left", "Right"
    end
end

local function getUpdatedPossibilities(toTile, fromTile)
    assert(toTile)
    assert(fromTile and #fromTile.possibilities >= 1, " no possibilities!")
    
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

local x = 1

local function updateTileNeighborsRecursive(tile)
	x = x +1
	if x%256 == 0 then
		game:GetService("RunService").Stepped:Wait()
	end
    for _, direction in pairs(directions) do -- propogate if CHANGED
        local neighbor = getTileInDirection(tile, direction)
        if neighbor then
            local newPossibilities, removedPossibility = getUpdatedPossibilities(neighbor, tile)
            if removedPossibility then
                neighbor.possibilities = newPossibilities
                -- Now we've changed this neighbor, all its neighbors need to update              
				updateTileNeighborsRecursive(neighbor)
				--visualizeTiles(tile.x, tile.y, tile.z)
            end
        end
    end
end

local function run(tiles)
	local i = 1
    local unsolved = getLeastEntropicTileToCollapse()
	
    while unsolved do
        -- Big difference: only need to collapse 1 tile, then we need to force
        -- constraints on whole system.
        collapse(unsolved)

        -- This function propogates changes from the JUST collapsed
        -- file. Once we do this, all neighbors
        updateTileNeighborsRecursive(unsolved)

        unsolved = getLeastEntropicTileToCollapse()
		i = i + 1
		
		if i % 16  == 0 and unsolved then
			--game:GetService("RunService").Stepped:Wait()
		end
        
    end
end

local function getWfcGridOfSize(xsize, ysize, zsize)
    tiles = {}
    finalTiles = {}

	local randZ = math.random(1, zsize)

    for x = 1, xsize do
		tiles[x] = {}
        for y = 1,ysize do
			tiles[x][y] = {}
            for z = 1, zsize do
                local tile = newTile(x,y, z)
                tiles[x][y][z] = tile
				table.insert(allTiles, tile)
            end
        end
    end

	local halfx = math.ceil(xsize/2)
	local halfz = math.ceil(zsize/2)
	
	-- start tile
	
	local centerTile = tiles[halfx][ysize-1][halfz]
	centerTile.possibilities = {"groundtoskyForward"}
	updateTileNeighborsRecursive(centerTile)
	collapse(centerTile)
	
    -- tiles around start tile
    
    local slopeTypes = {"slope", "slopealt1", "slopealt2"}
	
	local tile = tiles[halfx+1][ysize-2][halfz]
    local slopeString = slopeTypes[math.random(1, #slopeTypes)]
    local poss = slopeString.."Backward"
    tile.possibilities = {poss}
	updateTileNeighborsRecursive(tile)
	
	local tile = tiles[halfx-1][ysize-2][halfz]
    local slopeString = slopeTypes[math.random(1, #slopeTypes)]
    local poss = slopeString.."Forward"
    tile.possibilities = {poss}
	updateTileNeighborsRecursive(tile)
	
	local tile = tiles[halfx][ysize-2][halfz-1]
    local slopeString = slopeTypes[math.random(1, #slopeTypes)]
    local poss = slopeString.."Right"
    tile.possibilities = {poss}
	updateTileNeighborsRecursive(tile)
	
	local tile = tiles[halfx][ysize-2][halfz+1]
    local slopeString = slopeTypes[math.random(1, #slopeTypes)]
    local poss = slopeString.."Left"
    tile.possibilities = {poss}
	updateTileNeighborsRecursive(tile)
	
	-- corners

	local tile = tiles[xsize][1][1]
	tile.possibilities = {"cornerBackward"}
	updateTileNeighborsRecursive(tile)

	local tile = tiles[xsize][1][zsize]
	tile.possibilities = {"cornerLeft"}
	updateTileNeighborsRecursive(tile)

	local tile = tiles[1][1][1]
	tile.possibilities = {"cornerRight"}
	updateTileNeighborsRecursive(tile)

	local tile = tiles[1][1][zsize]
	tile.possibilities = {"cornerForward"}
	updateTileNeighborsRecursive(tile)

    run(tiles)

    visualizeTiles()
    
    tiles[halfx][ysize-1][halfz].collapseResult = {"starttileForward"}
    tiles[halfx][ysize-1][halfz].possibilities = {"starttileForward"}

    return tiles
end

local function onWaterUpdated()
    local water = workspace.Effects.Water
    local yPos = water.Position.Y - 20
    for i, tile in pairs(generatedMapTiles) do
        if not workspace.Tiles:FindFirstChild(i.."") then
            local folder = Instance.new("Folder", workspace.Tiles)
            folder.Name = i..""
        end
        local folder = workspace.Tiles:FindFirstChild(i.."")
        if tile.PrimaryPart and tile.PrimaryPart.Position.Y >= yPos then
            tile.Parent = folder
        end
    end
end

local function backUpMap(allTiles)
    local ServerData = import "Server/Systems/ServerData"
    local map = {}
    for _, tile in pairs(allTiles) do
        table.insert(map, {
            name = tile.possibilities[1],
            x = tile.x,
            y = tile.y,
            z = tile.z,
            biome = "Rainforest",
        })
    end
    ServerData:setValue("tileMap", map)
end

local function setInitialOceanHeight()
    local highest = -1000
    for _, t in pairs(generatedMapTiles) do
        if t.PrimaryPart.Position.Y > highest then
            highest = t.PrimaryPart.Position.Y
        end
    end

    Messages:send("SetOceanHeight", highest - 100)
end

local MapGeneration = {}

function MapGeneration:loadFromSerializedMap(map)
    workspace.Tiles:ClearAllChildren()
    self.tileModelsToTileInfoMap = {}
    for i, tileInfo in pairs(map) do
        local cellName = tileInfo.name
        if cellName ~= "skyForward" and cellName ~= "skyRight" and cellName ~= "skyBackward" and cellName ~= "skyLeft" then 
            local rotation = tileNameToRotationMap[cellName] or CFrame.Angles(0,0,0)
            cellName = string.gsub(cellName, "Forward", "")
            cellName = string.gsub(cellName, "Backward", "")
            cellName = string.gsub(cellName, "Left", "")
            cellName = string.gsub(cellName, "Right", "")
            local biome = tileInfo.biome
            local newTile = game.ServerStorage.MapTiles[biome][cellName]:Clone()
            newTile:SetPrimaryPartCFrame(CFrame.new(tileInfo.x*120,tileInfo.y*120,tileInfo.z*120))
            newTile:SetPrimaryPartCFrame(newTile.PrimaryPart.CFrame * rotation)
            if newTile.Name ~= "starttile" then
                newTile.Name = "X"..tileInfo.x.."Y"..tileInfo.y.."Z"..tileInfo.z..""
            end
            table.insert(generatedMapTiles, newTile)
            self.tileModelsToTileInfoMap[newTile] = tileInfo
            --newTile.Parent = workspace.Tiles
        end
    end
end

function MapGeneration:generateInitialMap()
    local xsize = 9
    local ysize = 5
    local zsize = 9

    local grid
    repeat
        local status, error = pcall(function()
            grid = getWfcGridOfSize(xsize,ysize,zsize)
        end)
        if error then
            warn(error)
            print("retry")
        end
        wait()
    until grid
    Messages:hook("WaterPositionUpdated", onWaterUpdated)

    local halfx = math.ceil(xsize/2)
    local halfz = math.ceil(zsize/2)
    local centerY = ysize - 1

    for _, v in pairs(allTiles) do
        if v.x == halfx and v.y == centerY and v.z == halfz then
            v.possibilities[1] = "starttile"
            break
        end
    end

    backUpMap(allTiles)
    self:loadFromSerializedMap(ServerData:getValue("tileMap")) -- displays the map

    setInitialOceanHeight()

    onWaterUpdated()

    Messages:send("MapDoneGenerating", true)
end

function MapGeneration:start()
    local savedTileMap = ServerData:getValue("tileMap")
    if savedTileMap then
        self:loadFromSerializedMap(savedTileMap)
        onWaterUpdated()
        Messages:send("MapDoneGenerating", false)
        return
    else
        self:generateInitialMap()
    end
end

return MapGeneration