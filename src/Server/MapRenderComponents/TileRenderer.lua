local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"

local CollectionService = game:GetService("CollectionService")

local cellSize = 120

local hasRendered = false

local highestY = 0

local TileRenderer = {}

TileRenderer.generatedTiles = {}

function TileRenderer.getCellYLevelOfPosition(pos)
	return math.floor(pos.Y/cellSize)
end

function TileRenderer:supplyMapTileObjects(mapTileObjects, tileNameToRotationMap, firstGen)
    self.mapTileObjects = mapTileObjects
    self.tileNameToRotationMap = tileNameToRotationMap
    for i, tileInfo in pairs(self.mapTileObjects) do
        local cellName = tileInfo.name
        if cellName ~= "skyForward" and cellName ~= "skyRight" and cellName ~= "skyBackward" and cellName ~= "skyLeft" then
            local rotation = self.tileNameToRotationMap[cellName] or CFrame.Angles(0,0,0)

            local oldName = cellName

            cellName = string.gsub(cellName, "Forward", "")
            cellName = string.gsub(cellName, "Backward", "")
            cellName = string.gsub(cellName, "Left", "")
            cellName = string.gsub(cellName, "Right", "")

            local biome = tileInfo.biome
            local newTile = game.ServerStorage.MapTiles[biome][cellName]:Clone()

            if not firstGen then
                for _, possibleWater in pairs(newTile:GetDescendants()) do
                    if CollectionService:HasTag(possibleWater, "FreshWater") then
                        print("destroying water source from not first loaded map")
                        possibleWater:Destroy()
                    end
                end
            end

            local biomeValue = Instance.new("StringValue", newTile)

            biomeValue.Name = "Biome"
			biomeValue.Value = biome

			if string.find(string.lower(cellName), "cave") then
				local cave = Instance.new("BoolValue", newTile)
				cave.Name = "Cave"
				cave.Value = true
			end

            local x = Instance.new("StringValue", newTile)
            x.Name = oldName

			CollectionService:AddTag(newTile, "Tile")

			if tileInfo.y > highestY then
				highestY = tileInfo.y -- sorry
			end

            newTile:SetPrimaryPartCFrame(CFrame.new(tileInfo.x*cellSize,tileInfo.y*cellSize,tileInfo.z*cellSize))
            newTile:SetPrimaryPartCFrame(newTile.PrimaryPart.CFrame * rotation)

            if newTile.Name == "starttile" then
                CollectionService:AddTag(newTile, "StartTile")
                if not workspace.Tiles:FindFirstChild(i.."") then
                    local folder = Instance.new("Folder", workspace.Tiles)
                    folder.Name = i..""
                end
                local folder = workspace.Tiles:FindFirstChild(i.."")
                newTile.Parent = folder
            end

            newTile.Name = "X"..tileInfo.x.."Y"..tileInfo.y.."Z"..tileInfo.z..""

            table.insert(self.generatedTiles, newTile)
        end
    end
end

function TileRenderer:reRender()
    local water = workspace.Effects.Water
    local yPos = water.Position.Y - 20
    for i, tile in pairs(self.generatedTiles) do
        if not workspace.Tiles:FindFirstChild(i.."") then
            local folder = Instance.new("Folder", workspace.Tiles)
            folder.Name = i..""
        end
        local folder = workspace.Tiles:FindFirstChild(i.."")
        if tile.PrimaryPart and tile.PrimaryPart.Position.Y >= yPos - 70 then
            tile.Parent = folder
        end
    end
    Messages:send("MapRerendered")
    if not hasRendered then
        hasRendered = true
        Messages:send("FirstMapRenderComplete")
    end
end

function TileRenderer:onWaterUpdated()
    self:reRender()
end

function TileRenderer:start()
    Messages:hook("WaterPositionUpdated", function() self:onWaterUpdated() end)
end

return TileRenderer
