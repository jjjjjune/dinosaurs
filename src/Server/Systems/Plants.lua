local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local SeasonsData = import "Shared/Data/SeasonsData"
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local PlantPhases = import "ServerStorage/PlantPhases"
local ServerData = import "Server/Systems/ServerData"

local lastSeason = 1

local function random(min, max)
    local randomObj = Random.new()
    return randomObj:NextInteger(min, max)
end

local function colorGrass(grass)
    local seasonData = SeasonsData[lastSeason]
    grass.Color = seasonData.grassColor
end

local function onSeasonChanged(newSeason)
    lastSeason = newSeason
    local seasonData = SeasonsData[newSeason]
    for _, grass in pairs(CollectionService:GetTagged("Grass")) do
        local color = seasonData.grassColor
        local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
        if typeof(color) == "table" then
            color = color[random(1, #color)]
        end
        local properties = {Color = color}
        local tween = TweenService:Create(grass, tweenInfo, properties)
        tween:Play()
    end
    for _, grass in pairs(CollectionService:GetTagged("Leaf")) do
        local color = seasonData.leafColor
        --local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
        if typeof(color) == "table" then
            color = color[random(1, #color)] or color[1]
        end
        --local properties = {Color = color}
        grass.TextureID = color
    end
end

local function setPhase(plantModel, phaseNumber)
    local type = plantModel.Type.Value
    local phaseFolder = PlantPhases[type]
    local newModel = phaseFolder[phaseNumber..""]:Clone()
    newModel.PrimaryPart = newModel.Base
    local cf = plantModel.PrimaryPart.CFrame *  CFrame.new(0, -plantModel.PrimaryPart.Size.Y/2, 0)
    cf = cf * CFrame.new(0,newModel.PrimaryPart.Size.Y/2,0)
    newModel:SetPrimaryPartCFrame(cf)
    plantModel:Destroy()
    newModel.Parent = workspace
    local phase = Instance.new("IntValue", newModel)
    phase.Name = "Phase"
    phase.Value = phaseNumber
    CollectionService:AddTag(newModel, "Plant")
    return newModel
end

local function getMaxPhase(type)
    for i = 1, 100 do
        local folder = PlantPhases[type]
        if not folder:FindFirstChild((i+1).."") then
            return i
        end
    end
end

local function onPlantFinishedGrowing(plantModel)
    CollectionService:AddTag(plantModel, "Grown")
end

local function growPlant(plantModel)
    local currentPhase = ((tonumber(plantModel.Name) ~= 0) and tonumber(plantModel.Name)) or 1
    local maxPhase = getMaxPhase(plantModel.Type.Value)
    if currentPhase < maxPhase then
        setPhase(plantModel, math.min(maxPhase, currentPhase+1))
        if currentPhase+1 == maxPhase then
            onPlantFinishedGrowing(plantModel)
        end
    end
end

local function growAllPlants()
    for _, plant in pairs(CollectionService:GetTagged("Plant")) do
        if plant:IsDescendantOf(workspace) then
            growPlant(plant)
        end
    end
end

local function createPlant(plantName, posOrCF, phase, isUserPlanted)
    local plantModel = PlantPhases[plantName]["1"]:Clone()
    plantModel.PrimaryPart = plantModel.Base
    local ang = math.random(1, 360)
    ang = CFrame.Angles(0, math.rad(ang),0)
    if typeof(posOrCF) == "CFrame" then
        plantModel:SetPrimaryPartCFrame(posOrCF * CFrame.new(0, plantModel.PrimaryPart.Size.Y/2, 0) * ang)
    else
        plantModel:SetPrimaryPartCFrame(CFrame.new(posOrCF) * CFrame.new(0, plantModel.PrimaryPart.Size.Y/2, 0) * ang)
    end
    plantModel.Parent = workspace
    plantModel = setPhase(plantModel, phase)
    if isUserPlanted then
        plantModel.UserPlanted.Value = true
    end
    return plantModel
end

local function loadSavedPlants()
    local plants = ServerData:getValue("plants")
    if not plants then
        return
    end
    for _, plant in pairs(plants) do
        local plantModel = game.ServerStorage.PlantPhases[plant.type][plant.phase]:Clone()
        plantModel.Parent = workspace
        local pos = plant.position
        local orientation = plant.orientation
        local rotCF = CFrame.fromOrientation(orientation.x, orientation.y, orientation.z)
        local posCF = CFrame.new(Vector3.new(pos.x, pos.y, pos.z))
        plantModel:SetPrimaryPartCFrame(posCF*rotCF)
    end
end

local function round(n, mult)
    mult = mult or 1
    return math.floor((n + mult/2)/mult) * mult
end

local function backUpPlants()
    local plants = {}
    for _, plant in pairs(CollectionService:GetTagged("Plant")) do
        if plant:IsDescendantOf(workspace) then
			local primaryPart = plant.PrimaryPart
			if not primaryPart then
				-- todo: why does this happen
				--print(plant.Name, " does not have primaryPart")
			else
				local pos = primaryPart.Position
				local ox, oy, oz  = primaryPart.CFrame:toOrientation()

				local info = {}
				info.type = plant.Type.Value
				info.phase = plant.Name
				info.position = {x = round(pos.X, .15), y = round(pos.Y, .15), z = round(pos.Z, .15)}
				info.orientation = {x = ox, y = oy, z = oz}
				table.insert(plants, info)
			end
        end
    end
    ServerData:setValue("plants", plants)
end

local function preparePlants()
    local plantPhases = game.ServerStorage.PlantPhases
    for _, plantFolder in pairs(plantPhases:GetChildren()) do
        for _, phaseModel in pairs(plantFolder:GetChildren()) do
            local typeValue = Instance.new("StringValue", phaseModel)
            typeValue.Name = "Type"
            typeValue.Value = plantFolder.Name
        end
    end
    for _, plant in pairs(CollectionService:GetTagged("Plant")) do
        local UserPlanted = Instance.new("BoolValue", plant)
        UserPlanted.Name = "UserPlanted"
        local Biome = Instance.new("StringValue", plant)
        Biome.Name = "Biome"
    end
end

local Plants = {}

function Plants.createPlant(plantName, posOrCF, phase, isUserPlanted)
    return createPlant(plantName, posOrCF, phase, isUserPlanted)
end

function Plants:start()
    preparePlants()
    Messages:hook("SeasonSetTo",function(newSeason)
        onSeasonChanged(newSeason)
    end)
    CollectionService:GetInstanceAddedSignal("Grass"):connect(colorGrass)
    loadSavedPlants()
    Messages:hook("GrowAllPlants", growAllPlants)
    Messages:hook("CreatePlant", createPlant)
    spawn(function()
        while wait(5) do
            backUpPlants()
        end
    end)
    spawn(function()
        while wait(60) do
            growAllPlants()
        end
    end)
end

return Plants
