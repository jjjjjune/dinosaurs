local function configure(subject)
	
	
	local size = 10
	local origin = subject.PrimaryPart.Position
	
	local topFaceHash, bottomFaceHash, leftFaceHash, rightFaceHash, frontFaceHash, backFaceHash
	
	--- top
	
	local direction = Vector3.new(0,-1,0)
	
	local faceHash = ""
	
	for x = -1, 1 do
		for z = -1, 1 do
			local start = origin + Vector3.new(x*size, size*2, z*size)
			-- size*2 puts us size/2 units outside of the tile
			local r = Ray.new(start, direction*(size/2)*1.01)
			local hit, pos = workspace:FindPartOnRayWithWhitelist(r, {subject})
			if hit and hit.Transparency == 0 and hit.Name ~= "SKY" then
				faceHash = faceHash.." "..hit.BrickColor.Name.." "
			else
				faceHash = faceHash.." ".."SKY".." "
			end
		end
	end
	
	topFaceHash = faceHash
	
	-- bottom
	
	local direction = Vector3.new(0,1,0)
	
	faceHash = ""
	
	for x = -1, 1 do
		for z = -1, 1 do
			local start = origin + Vector3.new(x*size, -size*2, z*size)
			local r = Ray.new(start, direction*(size/2)*1.01)
			local hit, pos = workspace:FindPartOnRayWithWhitelist(r, {subject})
			if hit and hit.Transparency == 0 and hit.Name ~= "SKY" then
				faceHash = faceHash.." "..hit.BrickColor.Name.." "
			else
				faceHash = faceHash.." ".."SKY".." "
			end
		end
	end
	
	bottomFaceHash = faceHash
	
	
	-- left
	
	local direction = Vector3.new(-1,0,0)
	
	faceHash = ""
	
	for y = -1, 1 do
		for z = -1, 1 do
			local start = origin + Vector3.new(size*2, y*size, z*size)
			local r = Ray.new(start - Vector3.new(0,.05,0), direction*(size/2)*1.01)
			--draw.ray(r)
			local hit, pos = workspace:FindPartOnRayWithWhitelist(r, {subject})
			if hit and hit.Transparency == 0 and hit.Name ~= "SKY" then
				faceHash = faceHash.." "..hit.BrickColor.Name.." "
			else
				faceHash = faceHash.." ".."SKY".." "
			end
		end
	end
	
	leftFaceHash = faceHash
	
	-- right 
	
	local direction = Vector3.new(1,0,0)
	
	faceHash = ""
	
	for y = -1, 1 do
		for z = -1, 1 do
			local start = origin + Vector3.new(-size*2, y*size, z*size)
			local r = Ray.new(start - Vector3.new(0,.05,0), direction*(size/2)*1.01)
			--draw.ray(r)
			local hit, pos = workspace:FindPartOnRayWithWhitelist(r, {subject})
			if hit and hit.Transparency == 0 and hit.Name ~= "SKY" then
				faceHash = faceHash.." "..hit.BrickColor.Name.." "
			else
				faceHash = faceHash.." ".."SKY".." "
			end
		end
	end
	
	rightFaceHash = faceHash
	
	-- front 
	
	local direction = Vector3.new(0,0,-1)
	
	faceHash = ""
	
	for y = -1, 1 do
		for x = -1, 1 do
			local start = origin + Vector3.new(x*size, y*size, size*2)
			local r = Ray.new(start- Vector3.new(0,.05,0), direction*(size/2)*1.01)
			local hit, pos = workspace:FindPartOnRayWithWhitelist(r, {subject})
			if hit and hit.Transparency == 0 and hit.Name ~= "SKY" then
				faceHash = faceHash.." "..hit.BrickColor.Name.." "
			else
				faceHash = faceHash.." ".."SKY".." "
			end
		end
	end
	
	frontFaceHash = faceHash
	
	-- back
	
	local direction = Vector3.new(0,0,1)
	
	faceHash = ""
	
	for y = -1, 1 do
		for x = -1, 1 do
			local start = origin + Vector3.new(x*size, y*size, -size*2)
			local r = Ray.new(start - Vector3.new(0,.05,0), direction*(size/2)*1.01)
			local hit, pos = workspace:FindPartOnRayWithWhitelist(r, {subject})
			if hit and hit.Transparency == 0 and hit.Name ~= "SKY" then
				faceHash = faceHash.." "..hit.BrickColor.Name.." "
			else
				faceHash = faceHash.." ".."SKY".." "
			end
		end
	end
	
	backFaceHash = faceHash
	
	--- direction hashes 
	
	local directionToHashes = {
		Top = topFaceHash,
		Bottom = bottomFaceHash,
		Left = leftFaceHash,
		Right = rightFaceHash,
		Front = frontFaceHash,
		Back = backFaceHash,
	}
	
	for _, v in pairs(subject:GetChildren()) do
		if directionToHashes[v.Name] then
			v:Destroy()
		end
	end
	
	for face, hash in pairs(directionToHashes) do
		local val = Instance.new("StringValue", subject)
		val.Name = face
		val.Value = hash
	end
end

return configure