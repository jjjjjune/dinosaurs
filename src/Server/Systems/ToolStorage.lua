local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local Data = import "Shared/Systems/Data"
local CollectionService = game:GetService("CollectionService")

local function storeTool(player, itemInstance)
    local storeData = Data:get(player, "storedTools")
    local slotData
    for category, data in pairs(storeData) do
        if CollectionService:HasTag(itemInstance, category) then
            slotData = data
        end
    end
    local prevItem = slotData.item
    Messages:send("DestroyItem", itemInstance)
    itemInstance:Destroy()
    if prevItem then
        local Items = import "Server/Systems/Items"
        local itemModel = Items.createItem(prevItem, Vector3.new(0,1000,0))
        Messages:sendClient(player, "ForceSetItem", itemModel)
    end
    slotData.item = itemInstance.Name
    Data:set(player, "storedTools", storeData)
end

local function equipStoredTool(player, slotName)
    local storeData = Data:get(player, "storedTools")
    local storedTool = storeData[slotName]
    local foundStoredTool
    if not storedTool or storedTool.item == nil then
        return
    end
    foundStoredTool = storedTool.item
    storedTool.item = nil
    Data:set(player, "storedTools", storeData)
    local foundStorableTool = false
    for _, possibleTool in pairs(player.Character:GetChildren()) do
        if possibleTool:IsA("Model") and CollectionService:HasTag(possibleTool, slotName) then
            storeTool(player, possibleTool)
            foundStorableTool = true
        end
    end
    if not foundStorableTool then
        -- if we did find a storable tool, the storeTool method will handle the unequip/reequipping
        Messages:sendClient(player, "ForceThrowItems")
        local Items = import "Server/Systems/Items"
        local itemModel = Items.createItem(foundStoredTool, Vector3.new(0,1000,0))
        Messages:sendClient(player,"ForceSetItem", itemModel)
    end
end

local ToolStorage = {}

function ToolStorage:start()
    Messages:hook("StoreTool", storeTool)
    Messages:hook("EquipStoredTool", equipStoredTool)
end

return ToolStorage