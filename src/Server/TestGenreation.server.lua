-- local directions = {"Left","Right","Forward","Backward", "Up", "Down"}
-- local permutationDirections = {"Left", "Right", "Forward", "Backward"}

-- local allTiles = {}

-- -- when rotating a corner to the right, flip the value of the right side
-- -- when rotating a corner to the left, flip the value of the left side

-- local function updateDirectionalValues(moduleModel, direction)
-- 	if not string.find(moduleModel.Name, "Corner") and not string.find(moduleModel.Name, "CornerIn") and not string.find(moduleModel.Name, "ToFlat") then 
-- 		for _, val in pairs(moduleModel:GetChildren()) do
-- 			if val:IsA("StringValue") then 
-- 				if (direction == "Backward" or direction == "Left") then
-- 					if val.Value == "TriangleNormal" then
-- 						val.Value = "TriangleFlipped"
-- 					elseif val.Value == "TriangleFlipped" then
-- 						val.Value = "TriangleNormal"
-- 					end
-- 				end
-- 			end
-- 		end
-- 	else
-- 		if direction == "Right" then
-- 			if moduleModel[direction].Value == "TriangleNormal" then
-- 				moduleModel[direction].Value = "TriangleFlipped"
-- 			elseif moduleModel[direction].Value == "TriangleFlipped" then
-- 				moduleModel[direction].Value = "TriangleNormal"
-- 			end
-- 		elseif direction == "Backward" or direction == "Forward" then
-- 			for _, val in pairs(moduleModel:GetChildren()) do
-- 				if val:IsA("StringValue") then 
-- 					if val.Value == "TriangleNormal" then
-- 						val.Value = "TriangleFlipped"
-- 					elseif val.Value == "TriangleFlipped" then
-- 						val.Value = "TriangleNormal"
-- 					end
-- 				end
-- 			end
-- 		elseif direction == "Left" then
-- 			moduleModel.Front.Value = "TriangleFlipped"
-- 		end
-- 	end
-- end

-- --[[
-- 	notes for tomorrow: investigate by looking at the example some more
-- ]]

-- local function getPermutation(model, direction)
--     if direction == "Forward" then
--         local new = model:Clone()
-- 		local cfVal = Instance.new("CFrameValue", new)
-- 		cfVal.Name = "CFrameValue"
-- 		cfVal.Value = new.PrimaryPart.CFrame - new.PrimaryPart.CFrame.p
--         --new.Base.Transparency = .99
--         --new.Base.FrontSurface = Enum.SurfaceType.Hinge
--         return new
--     else
--         local new = model:Clone()
--         local prevValues = {	
                
--         }
--         for _, x in pairs(new:GetChildren()) do
--             if x:IsA("StringValue") then
--                 prevValues[x.Name] = x.Value
--             end
--         end
--         if direction == "Left" then
--             new.Front.Value = prevValues.Right
--             new.Left.Value = prevValues.Front
--             new.Back.Value = prevValues.Left
--             new.Right.Value = prevValues.Back
-- 			new:SetPrimaryPartCFrame(new.PrimaryPart.CFrame * CFrame.Angles(0, math.pi/2, 0))
-- 			local cfVal = Instance.new("CFrameValue", new)
-- 			cfVal.Name = "CFrameValue"
-- 			cfVal.Value = new.PrimaryPart.CFrame- new.PrimaryPart.CFrame.p
--             new.Base.Orientation = Vector3.new(0, 180,0)
--         elseif direction == "Right" then
--             new.Front.Value = prevValues.Left
--             new.Right.Value = prevValues.Front
--             new.Back.Value = prevValues.Right
--             new.Left.Value = prevValues.Back
--             new:SetPrimaryPartCFrame(new.PrimaryPart.CFrame * CFrame.Angles(0, -math.pi/2, 0))
-- 			local cfVal = Instance.new("CFrameValue", new)
-- 			cfVal.Name = "CFrameValue"
-- 			cfVal.Value = new.PrimaryPart.CFrame- new.PrimaryPart.CFrame.p
--             new.Base.Orientation = Vector3.new(0, 180,0)
--         elseif direction == "Backward" then
--             new.Back.Value = prevValues.Front
--             new.Front.Value = prevValues.Back
--             new.Left.Value = prevValues.Right
--             new.Right.Value = prevValues.Left
--             new:SetPrimaryPartCFrame(new.PrimaryPart.CFrame * CFrame.Angles(0, math.pi, 0))
-- 			local cfVal = Instance.new("CFrameValue", new)
-- 			cfVal.Name = "CFrameValue"
-- 			cfVal.Value = new.PrimaryPart.CFrame - new.PrimaryPart.CFrame.p
--             new.Base.Orientation = Vector3.new(0, 180,0)
--         end
-- 		updateDirectionalValues(new, direction)
--         --new.Base.Transparency = .99
--         new.Base.FrontSurface = Enum.SurfaceType.Hinge
--         return new
--     end
-- end

-- game.ServerStorage.Example:ClearAllChildren()

-- for _, tileTemplate in pairs(game.ServerStorage.BaseTiles:GetChildren()) do
--     for _, dir in pairs(permutationDirections) do
-- 		if not tileTemplate:FindFirstChild("NoPermutations") then
-- 			local newModel = getPermutation(tileTemplate, dir)
-- 			newModel.Name = newModel.Name..dir
-- 			newModel.Parent = game.ServerStorage.Example
-- 		else
-- 			if dir == "Forward" then 
-- 				local newModel = getPermutation(tileTemplate, dir)
-- 	            newModel.Name = newModel.Name..dir
-- 	            newModel.Parent = game.ServerStorage.Example
-- 			end
-- 		end
--     end
-- end

-- local allPossibilities = {}

-- for _, x in pairs(game.ServerStorage.Example:GetChildren()) do
--     table.insert(allPossibilities, x.Name)
-- end

-- -- ok, now we have a map of [tileName] = {direction = thing that can be here or nil}
-- local finalTiles = {}
-- local tiles = {}

-- local function newTile(x, y, z) -- holds the possibilities for the tile and the collapsed result
--     local tile = {}
--     tile.x = x
--     tile.y = y
--     tile.z = z
--     tile.possibilities = allPossibilities
--     tile.collapseResult = nil
--     return tile
-- end

-- local function getTileInDirection(baseTile, direction)
--     if direction == "Backward" then
-- 		local nx = baseTile.x
-- 		local ny = baseTile.y
-- 		local nz = baseTile.z + 1
-- 		if tiles[nx] and tiles[nx][ny] and tiles[nx][ny][nz] then
-- 			return tiles[nx][ny][nz]
-- 		end
--     end
--     if direction == "Forward" then
-- 		local nx = baseTile.x
-- 		local ny = baseTile.y
-- 		local nz = baseTile.z - 1
-- 		if tiles[nx] and tiles[nx][ny] and tiles[nx][ny][nz] then
-- 			return tiles[nx][ny][nz]
-- 		end
--     end
--     if direction == "Left" then
--         local nx = baseTile.x - 1
-- 		local ny = baseTile.y
-- 		local nz = baseTile.z
-- 		if tiles[nx] and tiles[nx][ny] and tiles[nx][ny][nz] then
-- 			return tiles[nx][ny][nz]
-- 		end
--     end
--     if direction == "Right" then
--         local nx = baseTile.x + 1
-- 		local ny = baseTile.y
-- 		local nz = baseTile.z
-- 		if tiles[nx] and tiles[nx][ny] and tiles[nx][ny][nz] then
-- 			return tiles[nx][ny][nz]
-- 		end
--     end
--     if direction == "Up" then
--         local nx = baseTile.x
-- 		local ny = baseTile.y + 1
-- 		local nz = baseTile.z
-- 		if tiles[nx] and tiles[nx][ny] and tiles[nx][ny][nz] then
-- 			return tiles[nx][ny][nz]
-- 		end
--     end
--     if direction == "Down" then
--         local nx = baseTile.x
-- 		local ny = baseTile.y - 1
-- 		local nz = baseTile.z
-- 		if tiles[nx] and tiles[nx][ny] and tiles[nx][ny][nz] then
-- 			return tiles[nx][ny][nz]
-- 		end
--     end
-- end

-- local possibilitiesMap = {}

-- for _, exModel in pairs(game.ServerStorage.Example:GetChildren()) do
--     if not possibilitiesMap[exModel.Name] then
--         possibilitiesMap[exModel.Name] = {}
--     end
--     for _, x in pairs(exModel:GetChildren()) do
--         if x:IsA("StringValue") then
--             possibilitiesMap[exModel.Name][x.Name] = x.Value
--         end
--     end
-- end

-- local function getTotalAppearancesOfConnector(connectionType)
-- 	local total = 0
-- 	for _, ex in pairs(game.ServerStorage.Example:GetChildren()) do
-- 		for _, side in pairs(ex:GetChildren()) do
-- 			if side:IsA("StringValue") then
-- 				if side.Value == connectionType then
-- 					total = total + 1
-- 				end
-- 			end
-- 		end
-- 	end
-- 	assert(total > 0)
-- 	return total
-- end

-- local weights = {}

-- local function getWeight(possibility)
-- 	if weights[possibility] then
-- 		return weights[possibility]
-- 	end
-- 	local weightScore = 6
-- 	local counted = {}
-- 	local refModel = game.ServerStorage.Example[possibility]
-- 	for _, side in pairs(refModel:GetChildren()) do
-- 		if side:IsA("StringValue") then
-- 			if not counted[side.Value] then
-- 				counted[side.Value] = true
-- 				weightScore = weightScore - 1
-- 			end
-- 		end
-- 	end
-- 	-- multiply by the sum of (total number of times each option appears across all tiles)
-- 	local weightMultiplier = 1
-- 	for connectionType, _ in pairs(counted) do
-- 		local totalNumberOfAppearances = getTotalAppearancesOfConnector(connectionType)
-- 		weightMultiplier = weightMultiplier + totalNumberOfAppearances
-- 	end
-- 	weights[possibility] = weightScore*weightMultiplier
-- 	print("weight for: ", possibility, " is ", weights[possibility])
--     return 1--weightScore
-- end

-- local function shannonEntropyForTile(tile)
--     --# Sums are over the weights of each remaining allowed tile type for the square whose entropy we are calculating.
--    local sum_of_weights = 0
--     local sum_of_weight_log_weights = 0
--     for _, opt in pairs (tile.possibilities) do
--         local weight = getWeight(opt)
--         sum_of_weights = sum_of_weights + weight
--         sum_of_weight_log_weights = sum_of_weight_log_weights + weight * math.log(weight)
--     end

-- 	return math.log(sum_of_weights) - (sum_of_weight_log_weights / sum_of_weights)
-- end

-- local function getLeastEntropicTileToCollapse()
--     local lowestEntropy = 1000000
--     local leastEntropicTile = nil
-- 	local entropies = {}
--     for _, tile in pairs(allTiles) do
--         local thisEntropy = shannonEntropyForTile(tile)
-- 		entropies[tile] = thisEntropy
--         if (thisEntropy < lowestEntropy) and (#tile.possibilities > 1) then -- let's not include collapsed tiles
--             lowestEntropy = thisEntropy
-- 			leastEntropicTile = tile
--         end
--     end
-- 	local leastEntropies = {}
-- 	for tile, entropy in pairs(entropies) do
-- 		if entropy == lowestEntropy then
-- 			table.insert(leastEntropies, tile)
-- 		end
-- 	end
--     return (#leastEntropies > 0 and leastEntropies[math.random(1, #leastEntropies)]) or leastEntropicTile
-- end

-- local function tableContains(t, v)
--     for i, x in pairs(t) do
--         if x == v then
--             return true
--         end
--     end
--     return false
-- end

-- local function getCollapseResult(possibilities)
-- 	local newPossibilities = {}
-- 	for _, poss in pairs(possibilities) do
-- 		local multiplier = 1
-- 		if game.ServerStorage.Example:FindFirstChild(poss) then
-- 			if game.ServerStorage.Example[poss]:FindFirstChild("Weight") then
-- 				multiplier = game.ServerStorage.Example[poss]["Weight"].Value
-- 			end
-- 		end
-- 		for i = 1, math.max(1, multiplier*100) do 
-- 			table.insert(newPossibilities, poss)
-- 		end
-- 	end
-- 	return newPossibilities[math.random(1, #newPossibilities)]
-- end

-- local function collapse(tile, lastTile)
--     tile.collapseResult = getCollapseResult(tile.possibilities)
--     tile.possibilities = {tile.collapseResult}
--     table.insert(finalTiles, tile)
-- end

-- local function visualizeTiles(goldX, goldY, goldZ)
--     for _, tile in pairs(allTiles) do
--         if not tile.collapseResult then 
--             local str = tile.x.." "..tile.y.." "..tile.z.." "
--             if not workspace.Tiles:FindFirstChild(str) then
--                 local folder = Instance.new("Folder", workspace.Tiles)
--                 folder.Name = str
--             end
--             local folder = workspace.Tiles[str]
--             for _, possibility in pairs(tile.possibilities) do
--                 local newModel
--                 if not folder:FindFirstChild(possibility) then
--                     newModel = game.ServerStorage.Example[possibility]:Clone()
--                     newModel:SetPrimaryPartCFrame(CFrame.new(tile.x*8, tile.y*8, tile.z*8))
--                     newModel.Parent = folder
--                 else
--                     newModel = folder[possibility]
--                 end
--                 if tile.x == goldX and tile.y == goldY and tile.z == goldZ then
--                     newModel.Render.BrickColor = BrickColor.new("Bright red")
--                     newModel.Render.Transparency = 0
--                 else
--                     --newModel.Render.Transparency = .7
--                     newModel.Render.BrickColor = game.ServerStorage.Example[newModel.Name].Render.BrickColor
--                 end
--             end
--             for i, v in pairs(folder:GetChildren()) do
--                 if not tableContains(tile.possibilities, v.Name) then
--                     v:Destroy()
--                 end
--             end
--        end
--     end
--     for _, tile in pairs(finalTiles) do
--         local str = tile.x.." "..tile.y.." "..tile.z.." "
--         if not workspace.Tiles:FindFirstChild(str) then
--             local folder = Instance.new("Folder", workspace.Tiles)
--             folder.Name = str
--         end
--         local folder = workspace.Tiles[str]
--         if #folder:GetChildren() > 1 then
--             folder:ClearAllChildren()
--         end
--         if not folder:FindFirstChild(tile.collapseResult) then
--             local newModel
--             newModel = game.ServerStorage.Example[tile.collapseResult]:Clone()
--             newModel:SetPrimaryPartCFrame(CFrame.new(tile.x*8, tile.y*8, tile.z*8))
--             newModel.Parent = folder
--         end
--     end
-- end

-- local function getDirectionalRelationship(from, to) -- returns a face, not a direction
--     if from.x == to.x and from.y == to.y and from.z ==to.z - 1 then
--         return "Front", "Back" -- from is is front of tile 2
--     elseif from.x == to.x and from.y == to.y and from.z ==to.z + 1 then
--         return "Back", "Front" -- to is behing from
--     elseif from.x == to.x and from.y == to.y + 1 and from.z ==to.z  then
--         return "Bottom", "Top"
--     elseif from.x == to.x and from.y == to.y - 1 and from.z ==to.z  then
--         return "Top", "Bottom"
--     elseif from.x == to.x + 1 and from.y == to.y and from.z ==to.z  then
--         return "Right", "Left"
--     elseif from.x == to.x - 1 and from.y == to.y and from.z ==to.z  then
--         return "Left", "Right"
--     end
-- end

-- local function getUpdatedPossibilities(toTile, fromTile)
--     assert(toTile)

--     assert(fromTile and #fromTile.possibilities >= 1, " no possibilities!")
    
--     local fromDirection, toDirection = getDirectionalRelationship(fromTile, toTile)

--     local allowedModuleNames = {}

--     for _, moduleName in pairs(fromTile.possibilities) do
--         local module = possibilitiesMap[moduleName] or error("No module found")
--         allowedModuleNames[module[fromDirection]] = true
--     end

--     -- Module possibilities not allowed from prev tile, but exist
--     local newPossibilities = {}
--     local removed = false

--     for _, moduleName in pairs(toTile.possibilities) do
--         local module = possibilitiesMap[moduleName] or error("No module found (2)")
--         local requiredNext = module[toDirection]
--         if allowedModuleNames[requiredNext] then
--             table.insert(newPossibilities, moduleName)
--         else
-- 			--print("removing", moduleName, " from ", toTile.x, toTile.y, toTile.z)
--             removed = true
--         end
--     end

--     return newPossibilities, removed
-- end

-- local x = 1

-- local function updateTileNeighborsRecursive(tile)
-- 	x = x +1
-- 	if x%256 == 0 then
-- 		game:GetService("RunService").Stepped:Wait()
-- 	end
--     for _, direction in pairs(directions) do -- propogate if CHANGED
--         local neighbor = getTileInDirection(tile, direction)
--         if neighbor then
--             local newPossibilities, removedPossibility = getUpdatedPossibilities(neighbor, tile)
--             if removedPossibility then
--                 neighbor.possibilities = newPossibilities
--                 -- Now we've changed this neighbor, all its neighbors need to update              
-- 				updateTileNeighborsRecursive(neighbor)
-- 				--visualizeTiles(tile.x, tile.y, tile.z)
--             end
--         end
--     end
-- end

-- local function run(tiles)
-- 	local i = 1
-- 	local unsolved = getLeastEntropicTileToCollapse()
	
--     while unsolved do
--         -- Big difference: only need to collapse 1 tile, then we need to force
-- 		-- constraints on whole system.
-- 		collapse(unsolved)
--         -- This function propogates changes from the JUST collapsed
--         -- file. Once we do this, all neighbors
--         updateTileNeighborsRecursive(unsolved)

--         unsolved = getLeastEntropicTileToCollapse()
-- 		i = i + 1
		
-- 		if i % 16 == 0 and unsolved then
-- 			game:GetService("RunService").Stepped:Wait()
-- 		end
        
--     end
-- end

-- local function getWfcGridOfSize(xsize, ysize, zsize)
--     tiles = {}
--     finalTiles = {}

--     for x = 1, xsize do
-- 		tiles[x] = {}
--         for y = 1,ysize do
-- 			tiles[x][y] = {}
--             for z = 1, zsize do
--                 local tile = newTile(x,y, z)
--                 tiles[x][y][z] = tile
-- 				table.insert(allTiles, tile)
--             end
--         end
--     end

-- 	local halfx = math.ceil(xsize/2)
-- 	local halfz = math.ceil(zsize/2)
	
-- 	local centerTile = tiles[halfx][ysize-1][halfz]
-- 	centerTile.possibilities = {"GroundAirForward"}
-- 	updateTileNeighborsRecursive(centerTile)

-- 	local tile = tiles[xsize][1][zsize]
-- 	tile.possibilities = {"SlopeCornerRight"}
-- 	updateTileNeighborsRecursive(tile)

-- 	local tile = tiles[1][1][1]
-- 	tile.possibilities = {"SlopeCornerLeft"}
-- 	updateTileNeighborsRecursive(tile)

-- 	local tile = tiles[1][1][zsize]
-- 	tile.possibilities = {"SlopeCornerBackward"}
-- 	updateTileNeighborsRecursive(tile)

-- 	local tile = tiles[xsize][1][1]
-- 	tile.possibilities = {"SlopeCornerForward"}
-- 	updateTileNeighborsRecursive(tile)

--     run(tiles)

-- 	visualizeTiles()

-- 	for x = 1, xsize do
-- 	    for y = 1,ysize do
-- 	        for z = 1, zsize do
-- 	            local tile = tiles[x][y][z]
-- 				local cellName = tile.possibilities[1]
-- 				cellName = string.gsub(cellName, "Forward", "")
-- 				cellName = string.gsub(cellName, "Backward", "")
-- 				cellName = string.gsub(cellName, "Left", "")
-- 				cellName = string.gsub(cellName, "Right", "")
-- 				if cellName ~= "Sky" then 
-- 					local str = tile.x.." "..tile.y.." "..tile.z.." "
-- 					local referenceCell = workspace.Tiles[str]:GetChildren()[1]
-- 					local newTile = game.ServerStorage.MapTiles[cellName]:Clone()
-- 					print(newTile.Name)
-- 					newTile:SetPrimaryPartCFrame(CFrame.new(x*256,y*128,z*256))
-- 					newTile:SetPrimaryPartCFrame(newTile.PrimaryPart.CFrame * referenceCell.CFrameValue.Value)
-- 					newTile.Parent = workspace
-- 				end
-- 	        end
-- 	    end
-- 	end

--     return tiles
-- end

-- local grid
-- repeat
-- 	local status, error = pcall(function()
-- 		grid = getWfcGridOfSize(9,5,9)
-- 	end)
-- 	if error then
-- 		warn(error)
-- 		print("retry")
-- 	end
-- 	wait()
-- until grid
