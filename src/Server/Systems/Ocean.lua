local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local ServerData = import "Server/Systems/ServerData"
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

local OCEAN_LOWER_AMOUNT = 20--200

--600, 419.5, 600

local function updateSand(newHeight)
    print("updating sand yea")
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

                if newHeight  then
                    CollectionService:AddTag(sand, "NoLowerFirstTime")
                end

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

local function lowerOcean()
    local oceanHeight = ServerData:getValue("oceanHeight") or 500

    oceanHeight = oceanHeight - OCEAN_LOWER_AMOUNT

    updateSand(oceanHeight)

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
        print("sending water height updated")
        Messages:send("WaterPositionUpdated")
    end)
end

local function setOceanHeight(height)
    local newPos = Vector3.new(600, height, 600)

    ServerData:setValue("oceanHeight", height)

    workspace.Effects.Sky.Position = newPos

    workspace.Effects.Water.Position = newPos
    workspace.Effects.Sand.Position = newPos - Vector3.new(0,3,0)

    updateSand(newPos.Y)
end

local function onMapDoneGenerating()
    print("MAP DONE GENERATING")
    local oceanHeight = ServerData:getValue("oceanHeight") or 400
    local newPos = Vector3.new(600, oceanHeight, 600)
    workspace.Effects.Sky.Position = newPos
    workspace.Effects.Water.Position = newPos
    workspace.Effects.Sand.Position = newPos - Vector3.new(0,3,0)

    Messages:send("WaterPositionUpdated")

    spawn(function()
        wait()
        updateSand(newPos.Y)
    end)
end

local Ocean = {}

function Ocean:start()
    Messages:hook("MapDoneGenerating", onMapDoneGenerating)
    Messages:hook("LowerOcean", lowerOcean)
    Messages:hook("SetOceanHeight", setOceanHeight)

end

return Ocean