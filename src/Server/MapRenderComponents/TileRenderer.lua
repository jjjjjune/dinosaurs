local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"

local CollectionService = game:GetService("CollectionService")

local hasRendered = false

local TileRenderer = {}

TileRenderer.generatedTiles = {}

function TileRenderer:supplyMapTileObjects(mapTileObjects, tileNameToRotationMap)
    self.mapTileObjects = mapTileObjects
    self.tileNameToRotationMap = tileNameToRotationMap
    for i, tileInfo in pairs(self.mapTileObjects) do
        local cellName = tileInfo.name
        if cellName ~= "skyForward" and cellName ~= "skyRight" and cellName ~= "skyBackward" and cellName ~= "skyLeft" then
            local rotation = self.tileNameToRotationMap[cellName] or CFrame.Angles(0,0,0)

            cellName = string.gsub(cellName, "Forward", "")
            cellName = string.gsub(cellName, "Backward", "")
            cellName = string.gsub(cellName, "Left", "")
            cellName = string.gsub(cellName, "Right", "")

            local biome = tileInfo.biome
            local newTile = game.ServerStorage.MapTiles[biome][cellName]:Clone()
            local biomeValue = Instance.new("StringValue", newTile)

            biomeValue.Name = "Biome"
            biomeValue.Value = biome

            newTile:SetPrimaryPartCFrame(CFrame.new(tileInfo.x*120,tileInfo.y*120,tileInfo.z*120))
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