local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")

local ServerData = import "Server/Systems/ServerData"

local SaveableObjectManager = import "Server/Systems/SaveableObjectManager"

local function backupBuildings()
	SaveableObjectManager.saveTag("Building")
	SaveableObjectManager.saveTag("SaveableMapEntity")
end

local function loadBuildings()
	SaveableObjectManager.loadTag("Building")
	SaveableObjectManager.loadTag("SaveableMapEntity")
end

local function destroyBuilding(object)
	local ConstraintManager = import "Server/Systems/ConstraintManager"
	ConstraintManager.removeAllRelevantConstraints(object)
	object:Destroy()
end

local Buildings = {}

function Buildings.createBuilding(name, pos, presumedId)
	local buildingModel = game.ReplicatedStorage.Buildings[name]:Clone()
	if presumedId then
		local ID = Instance.new("StringValue", buildingModel)
		ID.Name = "ID"
		ID.Value = presumedId
	end
	return buildingModel
end

function Buildings:start()
	Messages:hook("DestroyBuilding", destroyBuilding)
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
	CollectionService:GetInstanceAddedSignal("Building"):connect(function(building)
		if building:IsDescendantOf(workspace) then
			ServerData:generateIdForInstanceOfType(building, "B")
		end
	end)
	for _, building in pairs(CollectionService:GetTagged("Building")) do
		if building:IsDescendantOf(workspace) then
			ServerData:generateIdForInstanceOfType(building, "B")
		end
	end
end

return Buildings
