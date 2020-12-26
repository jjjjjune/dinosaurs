local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local ServerData = import "Server/Systems/ServerData"
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

local GetWorldPositionFromMapPosition = import "Shared/Utils/GetWorldPositionFromMapPosition"

local Ocean = {}

local OCEAN_LOWER_AMOUNT = 40

--600, 419.5, 600

function Ocean:updateSand()
    local newHeight = self.sandGenerationHeight
    for _, t in pairs(workspace.Tiles:GetChildren()) do
        for _, tileModel in pairs(t:GetChildren()) do
            if not tileModel:FindFirstChild("EffectSand") then
                local sand = game.ServerStorage.MapResources.EffectSand:Clone()

                sand.Parent = tileModel
                sand.Anchored = true
                sand.TopSurface = "Smooth"
                sand.Material = Enum.Material.SmoothPlastic
                sand.Color = workspace.Effects.Sand.Color
                sand.Size = Vector3.new(tileModel.PrimaryPart.Size.X *2.5, 14, tileModel.PrimaryPart.Size.Z *2.5)
                sand.CFrame = CFrame.new(tileModel.PrimaryPart.Position.X, (newHeight and newHeight - 4.001) or (workspace.Effects.Water.Position.Y - 4.001), tileModel.PrimaryPart.Position.Z)

                CollectionService:AddTag(sand, "Sand")
                CollectionService:AddTag(sand, "EffectSand")

                --[[if newHeight  then
                    CollectionService:AddTag(sand, "NoLowerFirstTime")
                end--]]

                local sand2 = Instance.new("Part", tileModel)

                sand2.CanCollide = false
                sand2.Anchored = true

                local finalSizeAdjustment = Vector3.new(1.0635,.91,1.0635)
                local modifier = Vector3.new(.185,.467,.185)

                sand2.CFrame = sand.CFrame
                sand2.Parent = sand.Parent

                CollectionService:AddTag(sand2, "EffectSand")
                CollectionService:AddTag(sand2, "RayIgnore")

                local skirtMesh = game.ServerStorage.MapResources.EffectSkirt:Clone()

                skirtMesh.Parent = sand2
                skirtMesh.Scale = sand.Size * modifier * finalSizeAdjustment

                CollectionService:AddTag(skirtMesh, "SkirtMesh")
            end
        end
    end
end

function Ocean:lowerOcean()
    local oceanHeight = ServerData:getValue("oceanHeight") or 500

    oceanHeight = oceanHeight - OCEAN_LOWER_AMOUNT

    local newPos = Vector3.new(600, oceanHeight, 600)

    workspace.Effects.Sky.Position = newPos

    local goals = {
        Position = newPos,
    }
    local sandGoals = {
        Position = newPos - Vector3.new(0,3,0)
    }

    local tweenInfo = TweenInfo.new(6, Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
    TweenService:Create(workspace.Effects.Water, tweenInfo, goals):Play()
    TweenService:Create(workspace.Effects.Sand, tweenInfo, sandGoals):Play()

    for _, s in pairs(CollectionService:GetTagged("EffectSand")) do
        if not CollectionService:HasTag(s, "NoLowerFirstTime") then
            local sandGoals = {
                Position = s.Position - Vector3.new(0, OCEAN_LOWER_AMOUNT, 0)
            }
            TweenService:Create(s, tweenInfo, sandGoals):Play()
        else
            CollectionService:RemoveTag(s, "NoLowerFirstTime")
        end
    end

    ServerData:setValue("oceanHeight", oceanHeight)

    delay(1, function()
        Messages:send("WaterPositionUpdated")
    end)

    self.sandGenerationHeight = oceanHeight

	for _, v in pairs(CollectionService:GetTagged("Item")) do
		if v:FindFirstChild("FreezeWeld") and (v.FreezeWeld.Part0 == workspace.Effects.Sand or v.FreezeWeld.Part1 == workspace.Effects.Sand) then
			local ConstraintManager = import "Server/Systems/ConstraintManager"
			print("unfreezing")
			ConstraintManager.unfreeze(v, true)
			v:SetPrimaryPartCFrame(v.PrimaryPart.CFrame + Vector3.new(0,1,0))
		end
	end
    --self:updateSand()
end

function Ocean:setOceanHeight(height)
    local newPos = Vector3.new(600, height, 600)

    ServerData:setValue("oceanHeight", height)

    workspace.Effects.Sky.Position = newPos

    workspace.Effects.Water.Position = newPos
    workspace.Effects.Sand.Position = newPos - Vector3.new(0,3,0)

    self.sandGenerationHeight = newPos.Y

    --self:updateSand()
end

function Ocean:onMapDoneGenerating()
    local oceanHeight = ServerData:getValue("oceanHeight")

    local newPos = Vector3.new(600, oceanHeight, 600)
    workspace.Effects.Sky.Position = newPos
    workspace.Effects.Water.Position = newPos
    workspace.Effects.Sand.Position = newPos - Vector3.new(0,3,0)

    self.sandGenerationHeight = newPos.Y

    Messages:send("WaterPositionUpdated")
end

function Ocean:start(mapTileObjects)
    self.mapTileObjects = mapTileObjects

    Messages:hook("LowerOcean", function()
        self:lowerOcean()
    end)

    Messages:hook("MapRerendered", function()
        --self:updateSand()
    end)

    local oceanHeight = ServerData:getValue("oceanHeight")

    if not oceanHeight then
        local highestTile = {y = -100000000}
        for _, mapTile in pairs(self.mapTileObjects) do
            if mapTile.y > highestTile.y and not string.find(mapTile.name:lower(), "sky") then
                highestTile = mapTile
            end
        end
        oceanHeight = GetWorldPositionFromMapPosition(highestTile.x, highestTile.y, highestTile.z).y - 90
        ServerData:setValue("oceanHeight", oceanHeight)
        self:onMapDoneGenerating()
    else
        self:setOceanHeight(oceanHeight)
        Messages:send("WaterPositionUpdated")
    end

end

return Ocean
