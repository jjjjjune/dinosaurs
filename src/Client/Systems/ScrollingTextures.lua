local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local GetCharacterPosition = import "Shared/Utils/GetCharacterPosition"

local LOD_INTERVAL = 5
local LOD_RANGE = 120

local FACES = {
	Enum.NormalId.Left,
	Enum.NormalId.Right,
	Enum.NormalId.Front,
	Enum.NormalId.Back,
	Enum.NormalId.Top,
	Enum.NormalId.Bottom,
}

local textureFunctions = {
	Wave = function(instance)
		instance.OffsetStudsV = instance.OffsetStudsV - .05
	end,
}

local nextLODCheck = tick()
local allTextureParts = {}

local function prepareTexture(part, type)
	for i = 1, 6 do
		local tex = game.ReplicatedStorage.ScrollingTextures[type]:Clone()
		tex.Face = FACES[i]
		tex.Parent = part
	end
end

local function checkLOD()
	local myPosition = GetCharacterPosition()

	local textures = {}

	if myPosition then
		for _, part in pairs(CollectionService:GetTagged("TexturePart")) do
			if (part.Position - myPosition).magnitude < LOD_RANGE then
				local foundTextures = {}

				for _, v in pairs(part:GetChildren()) do
					if v:IsA("Texture") then
						table.insert(foundTextures, v)
					end
				end

				if #foundTextures == 0 then
					prepareTexture(part, part.Type.Value)
					for _, v in pairs(part:GetChildren()) do
						if v:IsA("Texture") then
							table.insert(foundTextures, v)
						end
					end
				end

				table.insert(textures, {
					type = part.Type.Value,
					textures = foundTextures,
				})
			end
		end
	end

	return textures
end

local function tickTextures()
	for _, texturePartTab in pairs(allTextureParts) do
		for _, texture in pairs(texturePartTab.textures) do
			textureFunctions[texturePartTab.type](texture)
		end
	end
end

local ScrollingTextures = {}

function ScrollingTextures:start()
	RunService.Heartbeat:connect(function(dt)
		if tick() > nextLODCheck then
			nextLODCheck = tick() + LOD_INTERVAL
			allTextureParts = checkLOD()
		end
		tickTextures(allTextureParts)
	end)
	CollectionService:GetInstanceAddedSignal("TexturePart"):connect(function()
		wait(.1)
		checkLOD()
	end)
end

return ScrollingTextures
