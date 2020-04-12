local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")

local function round(n, mult)
    mult = mult or 1
    return math.floor((n + mult/2)/mult) * mult
end

local function backupBuildings()
    local ServerData = import "Server/Systems/ServerData"
    local buildings = {}
    for _, building in pairs(CollectionService:GetTagged("Building")) do
        if building:IsDescendantOf(workspace) then
            local primaryPart = building.PrimaryPart
            local pos = primaryPart.Position
            local orientation = primaryPart.Orientation

            local info = {}
            info.name = building.Name
            info.position = {x = round(pos.X, .15), y = round(pos.Y, .15), z = round(pos.Z, .15)}
            info.orientation = {x = round(orientation.X, 1), y = round(orientation.Y, 1), z = round(orientation.Z, 1)}
            table.insert(buildings, info)
        end
    end
    for _, building in pairs(CollectionService:GetTagged("SaveableMapEntity")) do
        if building:IsDescendantOf(workspace) then
            local primaryPart = building.PrimaryPart
            local pos = primaryPart.Position
            local orientation = primaryPart.Orientation

            local info = {}
            info.name = building.Name
            info.position = {x = round(pos.X, .15), y = round(pos.Y, .15), z = round(pos.Z, .15)}
            info.orientation = {x = round(orientation.X, 1), y = round(orientation.Y, 1), z = round(orientation.Z, 1)}
            table.insert(buildings, info)
        end
    end
    ServerData:setValue("buildings", buildings)
end

local function loadBuildings()
    local ServerData = import "Server/Systems/ServerData"
    local buildings = ServerData:getValue("buildings")
    if buildings then
        print("loading serialized buildings")
        for _, building in pairs(buildings) do
            local model = game.ReplicatedStorage.Buildings[building.name]:Clone()
            model.Parent = workspace.Buildings
            local pos = building.position
            local orientation = building.orientation
            print(pos, orientation)
            print(orientation.x, orientation.y, orientation.z)
            local rotCF = CFrame.fromOrientation(Vector3.new(orientation.x, orientation.y, orientation.z))
            local posCF = CFrame.new(Vector3.new(pos.x, pos.y, pos.z))
            model:SetPrimaryPartCFrame(rotCF*posCF)
        end
    end
end

local Buildings = {}

function Buildings:start()
    Messages:hook("MapDoneGenerating", function(isFirstTime)
        print("MAP IS DONE GENERATING")
        if isFirstTime then
            print("IS FIRST TIME")
            local folder = game.ServerStorage.StartTileBuildings
            for _, building in pairs(folder:GetChildren()) do
                local x = building:Clone()
                x.Parent = workspace.Buildings
            end
        else
            print("IS NOT FIRST TIME")
        end
    end)
    spawn(function()
        while wait(5) do
            backupBuildings()
        end
    end)
    loadBuildings()
end

return Buildings