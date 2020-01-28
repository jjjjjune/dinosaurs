local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"

local ProcessFunctions = import "Shared/Data/ProcessFunctions"
local ReactionFunctions = import "Shared/Data/ReactionFunctions"

local ELEMENTS = import "Shared/Data/Elements"

local STATES = import "Shared/Data/States"

local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local events = {}
local activeElements = {} 

local function initializeMaterial(material)
    activeElements[material] = CollectionService:HasTag(material, "Active")
end

local function getElement(material)
    for _, element in pairs(ELEMENTS) do
        if CollectionService:HasTag(material, element) then
            return element
        end
    end
end

local function getState(material)
    for _, element in pairs(STATES) do
        if CollectionService:HasTag(material, element) then
            return element
        end
    end
end

local function tryProcess(material)
    local element = getElement(material)
    local processTable = ProcessFunctions[element]
    if processTable then
        for processType, processFunction in pairs(processTable) do
            if CollectionService:HasTag(material, processType) then
                processFunction(material)
            end
        end
    end
end

local function tryReact(material)
    local state = getState(material)
    local reactionsTable = ReactionFunctions[state]
    if reactionsTable then 
        if not events[material] then
            events[material] = material.Touched:connect(function() end) -- generates touch interest
        end
        local parts = material:GetTouchingParts()
        for _, p in pairs(parts) do
            local partElement = getElement(p)
            if reactionsTable[partElement] then
                reactionsTable[partElement](material, p)
            end
        end
    end
end

local function processActiveElements(dt)
    for material, _ in pairs(activeElements) do
        tryProcess(material)
        tryReact(material)
    end
end

local Chemistry = {}

function Chemistry:start()
    CollectionService:GetInstanceAddedSignal("Active"):connect(function(material)
        initializeMaterial(material)
    end)
    for _, materialName in pairs(ELEMENTS) do
        CollectionService:GetInstanceAddedSignal(materialName):connect(function(material)
            initializeMaterial(material)
        end)
    end
    for _, materialName in pairs(STATES) do
        CollectionService:GetInstanceAddedSignal(materialName):connect(function(material)
            initializeMaterial(material)
        end)
    end
    CollectionService:GetInstanceRemovedSignal("Active"):connect(function(material)
        activeElements[material] = nil
        if events[material] then
            events[material] = nil
        end
    end)
    for _, elementName in pairs(ELEMENTS) do 
        for _, existingMaterial in pairs(CollectionService:GetTagged(elementName)) do
            initializeMaterial(existingMaterial)
        end
    end
    for _, elementName in pairs(STATES) do 
        for _, existingMaterial in pairs(CollectionService:GetTagged(elementName)) do
            initializeMaterial(existingMaterial)
        end
    end
    RunService.Stepped:connect(function(dt)
        processActiveElements(dt)
    end)
    Messages:hook("DestroyMaterial", function(material)
        material:Destroy()
        activeElements[material] = nil
    end)
    workspace.Terrain.Touched:connect(function(hit)
        local reactions = ReactionFunctions.Water
        local hitElement = getElement(hit)
        if reactions[hitElement] then
            reactions[hitElement](workspace.Terrain, hit)
        end
        local state = getState(hit)
        if reactions[state] then
            reactions[state](workspace.Terrain, hit)
        end
    end)
end

return Chemistry