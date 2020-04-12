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
            local ox, oy, oz  = primaryPart.CFrame:toOrientation()

            local info = {}
            info.name = building.Name
            info.position = {x = round(pos.X, .15), y = round(pos.Y, .15), z = round(pos.Z, .15)}
            info.orientation = {x = ox, y = oy, z = oz}
            table.insert(buildings, info)
        end
    end
    for _, building in pairs(CollectionService:GetTagged("SaveableMapEntity")) do
        if building:IsDescendantOf(workspace) then
            local primaryPart = building.PrimaryPart
            local pos = primaryPart.Position
            local ox, oy, oz  = primaryPart.CFrame:toOrientation()

            local info = {}
            info.name = building.Name
            info.position = {x = round(pos.X, .15), y = round(pos.Y, .15), z = round(pos.Z, .15)}
            info.orientation = {x = ox, y = oy, z = oz}
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
            local rotCF = CFrame.fromOrientation(orientation.x, orientation.y, orientation.z)
            local posCF = CFrame.new(Vector3.new(pos.x, pos.y, pos.z))
            model:SetPrimaryPartCFrame(posCF*rotCF)
        end
    end
end

local Buildings = {}

function Buildings:start()
    Messages:hook("MapDoneGenerating", function(isFirstTime)
        if isFirstTime then
            local folder = game.ServerStorage.StartTileBuildings
            for _, building in pairs(folder:GetChildren()) do
                local x = building:Clone()
                x.Parent = workspace.Buildings
            end
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