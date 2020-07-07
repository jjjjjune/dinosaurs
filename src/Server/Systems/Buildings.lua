local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")

local ServerData = import "Server/Systems/ServerData"

local function round(n, mult)
    mult = mult or 1
    return math.floor((n + mult/2)/mult) * mult
end

local function backupBuildings()
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

            for _, v in pairs(building:GetChildren()) do
                if v:IsA("ValueBase") then
                    info[v.Name] = v.Value
                end
            end

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

            for _, v in pairs(building:GetChildren()) do
                if v:IsA("ValueBase") then
                    info[v.Name] = v.Value
                end
            end

            table.insert(buildings, info)
        end
    end
    ServerData:setValue("buildings", buildings)
end

local function loadBuildings()
    local ServerData = import "Server/Systems/ServerData"
    local buildings = ServerData:getValue("buildings")
    if buildings then
        for _, building in pairs(buildings) do
            local model = game.ReplicatedStorage.Buildings[building.name]:Clone()
            local pos = building.position
            local orientation = building.orientation
            local rotCF = CFrame.fromOrientation(orientation.x, orientation.y, orientation.z)
            local posCF = CFrame.new(Vector3.new(pos.x, pos.y, pos.z))
            model:SetPrimaryPartCFrame(posCF*rotCF)

			if building.ID then
				local ID = Instance.new("StringValue", model)
				ID.Name = "ID"
				ID.Value = building.ID
			end


            for propName, value in pairs(building) do
                if model:FindFirstChild(propName) then
                    if model[propName]:IsA("ValueBase") then
                        model[propName].Value = value
                    end
                end
            end

            model.Parent = workspace.Buildings
        end
    end
end

local Buildings = {}

function Buildings:start()
    Messages:hook("MapDoneGenerating", function(isFirstTime)
        if isFirstTime then
            local folder = game.ServerStorage.StartTileBuildings
            local starttile = CollectionService:GetTagged("StartTile")[1]:Clone()
            folder:SetPrimaryPartCFrame(starttile.PrimaryPart.CFrame)
            for _, v in pairs(folder:GetChildren()) do
                v.Parent = workspace.Buildings
            end
            folder:Destroy()
            for _, v in pairs(game.Players:GetPlayers()) do
                if v.Character then
                    v.Character:MoveTo(workspace:FindFirstChild("Altar", true).Base.Position)
                end
            end
        end
    end)
    spawn(function()
        while wait(5) do
            backupBuildings()
        end
    end)
	loadBuildings()
	CollectionService:GetInstanceAddedSignal("Building"):connect(function(building)
		ServerData:generateIdForInstanceOfType(building, "B")
	end)
	for _, building in pairs(CollectionService:GetTagged("Building")) do
		ServerData:generateIdForInstanceOfType(building, "B")
	end
end

return Buildings
