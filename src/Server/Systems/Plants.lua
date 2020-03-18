local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local SeasonsData = import "Shared/Data/SeasonsData"
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local PlantPhases = import "ServerStorage/PlantPhases"

local function random(min, max)
    local randomObj = Random.new()
    return randomObj:NextInteger(min, max)
end

local function onSeasonChanged(newSeason)
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
    setPhase(plantModel, math.min(maxPhase, currentPhase+1))
    if currentPhase+1 == maxPhase then
        onPlantFinishedGrowing(plantModel)
    end
end

local function growAllPlants()
    for _, plant in pairs(CollectionService:GetTagged("Plant")) do
        if plant:IsDescendantOf(workspace) then
            growPlant(plant)
        end
    end
end

local function createPlant(plantName, pos, phase)
    local plantModel = PlantPhases[plantName]["1"]:Clone()
    plantModel.PrimaryPart = plantModel.Base
    plantModel:SetPrimaryPartCFrame(CFrame.new(pos) * CFrame.new(0, plantModel.PrimaryPart.Size.Y/2, 0))
    plantModel.Parent = workspace
    setPhase(plantModel, phase)
end

local Plants = {}

function Plants:start()
    Messages:hook("SeasonSetTo",function(newSeason)
        growAllPlants()
        onSeasonChanged(newSeason)
    end)
    Messages:hook("GrowAllPlants", growAllPlants)
    Messages:hook("CreatePlant", createPlant)
    growAllPlants()
end

return Plants