local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Perlin = import "Shared/Utils/Perlin"
local ServerData = import "Server/Systems/ServerData"

local directions = {"Left","Right","Forward","Backward", "Up", "Down"}
local permutationDirections = {"Left", "Right", "Forward", "Backward"}

local allTiles = {}
local tileNameToRotationMap = {}

local function random(min, max)
    local randomObj = Random.new()
    return randomObj:NextInteger(min, max)
end

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
	new.Base.CFrame = originalCF
	new:SetPrimaryPartCFrame(CFrame.new(0,0,0))
	new.Name = model.Name..direction
    new.Parent = workspace -- sadly this is required for da raycast
    tileNameToRotationMap[new.Name] = cf
	local skin = import "Shared/Utils/ConfigureWfcTile"
	skin(new)
	new.Parent = nil
	return new
end

local function populatePermutations()
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
end

populatePermutations()

local allPossibilities do
    allPossibilities = {}
    for _, x in pairs(game.ServerStorage.Example:GetChildren()) do
        if not string.find(x.Name, "starttile") then
            table.insert(allPossibilities, x.Name)
        end
    end
end

local finalTiles = {}
local tiles = {}
local weights = {}

local function newTile(x, y, z)
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

local possibilitiesMap do
    possibilitiesMap = {}
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

local function getLeastEntropicTileToCollapse()
    local lowestEntropy = 1000000
    local leastEntropicTile = nil
	local entropies = {}
    for _, tile in pairs(allTiles) do
        local thisEntropy = #tile.possibilities--shannonEntropyForTile(tile)
		entropies[tile] = thisEntropy
        if (thisEntropy < lowestEntropy) and not tile.collapseResult then -- let's not include collapsed tiles
            lowestEntropy = thisEntropy
			leastEntropicTile = tile
        end
    end
    return leastEntropicTile
end


local weightCache = {}

local function getCollapseResult(possibilities)
	local newPossibilities = {}
	for _, poss in pairs(possibilities) do
		local multiplier = 1
		if weightCache[poss] then
			multiplier = weightCache[poss]
		else
			if game.ServerStorage.Example:FindFirstChild(poss) then
				if game.ServerStorage.Example[poss]:FindFirstChild("Weight") then
					multiplier = game.ServerStorage.Example[poss]["Weight"].Value
					weightCache[poss] = multiplier
				end
			end
		end
		for i = 1, math.max(1, multiplier*100) do
			table.insert(newPossibilities, poss)
		end
	end
	return newPossibilities[random(1, #newPossibilities)]
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
        local module = possibilitiesMap[moduleName]
        if not module then
            print(moduleName)
            error("No module found")
        end
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

local function conditionsMet(tiles)
	local totalCaveEntrances = 0
	local caveEntranceTiles = {}
	for x = 1, #tiles do
		for y = 1, #tiles[x] do
			for z = 1, #tiles[x][y] do
				local tile = tiles[x][y][z]
				if string.find(string.lower(tile.collapseResult), "caveintoslope") then
					totalCaveEntrances = totalCaveEntrances + 1
					table.insert(caveEntranceTiles, tile)
				end
			end
		end
	end
	local checks = {
		[0] = false,
		[1] = false,
		[2] = false,
		[3] = false,
		[4] = false,
		[5] = false,
		[6] = false,
		[7] = false,
	}
	for level, _ in pairs(checks) do
		for _, t in pairs(caveEntranceTiles) do
			if t.y == level then
				checks[level] = true
				print("found cave at level: ", level)
			end
		end
	end
	print("total cave entrances: ", totalCaveEntrances)

	return totalCaveEntrances > 6 and checks[2] and checks[3] and checks[4] and checks[5]
end

local function getWfcGridOfSize(xsize, ysize, zsize)
    tiles = {}
    finalTiles = {}

	local randZ = random(1, zsize)

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
    local slopeString = slopeTypes[random(1, #slopeTypes)]
    local poss = slopeString.."Backward"
    tile.possibilities = {poss}
	updateTileNeighborsRecursive(tile)

	local tile = tiles[halfx-1][ysize-2][halfz]
    local slopeString = slopeTypes[random(1, #slopeTypes)]
    local poss = slopeString.."Forward"
    tile.possibilities = {poss}
	updateTileNeighborsRecursive(tile)

	local tile = tiles[halfx][ysize-2][halfz-1]
    local slopeString = slopeTypes[random(1, #slopeTypes)]
    local poss = slopeString.."Right"
    tile.possibilities = {poss}
	updateTileNeighborsRecursive(tile)

	local tile = tiles[halfx][ysize-2][halfz+1]
    local slopeString = slopeTypes[random(1, #slopeTypes)]
    local poss = slopeString.."Left"
    tile.possibilities = {poss}
	updateTileNeighborsRecursive(tile)

	for z1 = 2, zsize-1 do
		local tile = tiles[1][1][z1]
		local slopeString = slopeTypes[random(1, #slopeTypes)]
		local poss = slopeString.."Forward"
		tile.possibilities = {poss}
		updateTileNeighborsRecursive(tile)
	end

	for z1 = 2, zsize-1 do
		local tile = tiles[xsize][1][z1]
		local slopeString = slopeTypes[random(1, #slopeTypes)]
		local poss = slopeString.."Backward"
		tile.possibilities = {poss}
		updateTileNeighborsRecursive(tile)
	end

	for x1 = 2, xsize-1 do
		local tile = tiles[x1][1][1]
		local slopeString = slopeTypes[random(1, #slopeTypes)]
		local poss = slopeString.."Right"
		tile.possibilities = {poss}
		updateTileNeighborsRecursive(tile)
	end

	for x1 = 2, xsize-1 do
		local tile = tiles[x1][1][zsize]
		local slopeString = slopeTypes[random(1, #slopeTypes)]
		local poss = slopeString.."Left"
		tile.possibilities = {poss}
		updateTileNeighborsRecursive(tile)
	end

	for x1 = 2, xsize - 2 do
		for z1 = 2, zsize - 2 do
			local tile = tiles[x1][1][z1]
			tile.possibilities = {"groundForward"}
			updateTileNeighborsRecursive(tile)
		end
	end

    run(tiles)

    tiles[halfx][ysize-1][halfz].collapseResult = "starttileForward"
	tiles[halfx][ysize-1][halfz].possibilities = {"starttileForward"}

	assert(conditionsMet(tiles), "conditions not met")

    return tiles
end

local function backUpMap(allTiles)
    local ServerData = import "Server/Systems/ServerData"
    local map = {}
    for _, tile in pairs(allTiles) do
		local noise = Perlin(tile.x/9,tile.z/9)
		local tileData = {
            name = tile.possibilities[1],
            x = tile.x,
            y = tile.y,
            z = tile.z,
            biome = "Desert", -- (noise > .55 and  "Desert") or
		}
        table.insert(map, tileData)
    end
    ServerData:setValue("tileMap", map)
end

local MapGeneration = {}

function MapGeneration:loadFromSerializedMap(map, isFirstTime)
    workspace.Tiles:ClearAllChildren()

    self.TileRenderer = import "Server/MapRenderComponents/TileRenderer"
    self.TileRenderer:supplyMapTileObjects(map, tileNameToRotationMap, isFirstTime)
    self.TileRenderer:start()

    self.Ocean = import "Server/MapRenderComponents/Ocean"
    self.Ocean:start(map)
end

function MapGeneration:generateInitialMap()
    local xsize = 16
    local ysize = 8
    local zsize = 16

    local grid
    repeat
		local status, error = pcall(function()
			allTiles = {}
            grid = getWfcGridOfSize(xsize,ysize,zsize)
        end)
        if error then
            warn(error)
            print("retry")
        end
        wait()
    until grid

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

    self:loadFromSerializedMap(ServerData:getValue("tileMap"), true) -- displays the map

    Messages:send("MapDoneGenerating", true)
end

function MapGeneration:start()
    local savedTileMap = ServerData:getValue("tileMap")
    if savedTileMap then
        self:loadFromSerializedMap(savedTileMap, false)
        Messages:send("MapDoneGenerating", false)
        return
    else
        self:generateInitialMap()
    end
end

return MapGeneration
