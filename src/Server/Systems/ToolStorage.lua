local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local ServerData = import "Server/Systems/ServerData"
local CollectionService = game:GetService("CollectionService")

local function storeTool(player, itemInstance, desiredSlotNumber)
    local storeData = ServerData:getPlayerValue(player, "storedTools")
    local slotData

    if storeData[desiredSlotNumber] then
        slotData = storeData[desiredSlotNumber]
    else
        for _, data in pairs(storeData) do
            if not data.item then
                slotData = data
                break
            end
        end
	end

	if not slotData then
		return
	end

    local prevItem = slotData.item
    Messages:send("DestroyItem", itemInstance)
    itemInstance:Destroy()
	if prevItem then
		print("we had prev item! force settine")
        local Items = import "Server/Systems/Items"
        local itemModel = Items.createItem(prevItem, Vector3.new(0,1000,0))
		itemModel.Parent = workspace
		Messages:sendClient(player, "ForceSetItem", itemModel)
    end
    slotData.item = itemInstance.Name
    ServerData:setPlayerValue(player, "storedTools", storeData)
end

local function equipStoredTool(player, slotName)
    local storeData = ServerData:getPlayerValue(player, "storedTools")
    local storedTool = storeData[slotName]
    local foundStoredTool
    if not storedTool or storedTool.item == nil then
        print("no stored tool")
        return
    end
    foundStoredTool = storedTool.item
    storedTool.item = nil
    ServerData:setPlayerValue(player, "storedTools", storeData)

    local totalStoredTools = 0
    for _, tool in pairs(storeData) do
        if tool.name then
            totalStoredTools = totalStoredTools + 1
        end
	end

    local foundStorableTool = false
    for _, possibleTool in pairs(player.Character:GetChildren()) do
        if possibleTool:IsA("Model") and CollectionService:HasTag(possibleTool, "Item") and totalStoredTools < #storeData then
            storeTool(player, possibleTool, slotName)
            foundStorableTool = true
        end
    end
    if not foundStorableTool then
        -- if we did find a storable tool, the storeTool method will handle the unequip/reequipping
        Messages:sendClient(player, "ForceThrowItems")
        local Items = import "Server/Systems/Items"
		local itemModel = Items.createItem(foundStoredTool, Vector3.new(0,1000,0))
		itemModel.Parent = workspace
        Messages:sendClient(player,"ForceSetItem", itemModel)
	end

	if foundStoredTool then
		local Items = import "Server/Systems/Items"
        local itemModel = Items.createItem(foundStoredTool, Vector3.new(0,1000,0))
		itemModel.Parent = workspace
		Messages:sendClient(player, "ForceSetItem", itemModel)
	end
end

local ToolStorage = {}

function ToolStorage:start()
    Messages:hook("StoreTool", storeTool)
    Messages:hook("EquipStoredTool", equipStoredTool)
end

return ToolStorage
