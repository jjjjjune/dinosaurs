local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local ToolsUi = game.Players.LocalPlayer.PlayerGui:WaitForChild("Tools")

local currentInventory = _G.Data.storedTools

local order = {
    "Weapon",
    "RangedWeapon",
    "Pickaxe",
    "Utility",
}

local function getOrder(inventorySlot)
    for i, v in pairs(order) do
        if v == inventorySlot then
            return i
        end
    end
end

local function skin(inventorySlot)
    local data = currentInventory[inventorySlot.Name]
    local newFrame = inventorySlot:Clone()
    newFrame.Parent = inventorySlot.Parent
    newFrame.Visible = true
    local newCam = Instance.new("Camera")
    newCam.Parent = newFrame.ViewportFrame
    newCam.FieldOfView = 30
    newFrame.LayoutOrder = getOrder(inventorySlot.Name)
    newFrame.Shadow.CurrentCamera = newCam
    newFrame.ViewportFrame.CurrentCamera = newCam
    newFrame.NumberLabel.Text = getOrder(inventorySlot.Name)..""
    newFrame.Button.Activated:connect(function()
        Messages:sendServer("EquipStoredTool", inventorySlot.Name)
    end)
    if data and data.item then
        local itemPreview = game.ReplicatedStorage.Items[data.item]:Clone()
        itemPreview.Parent = newFrame.ViewportFrame
        itemPreview:Clone().Parent = newFrame.Shadow
        local origin = itemPreview:GetModelCFrame().p
        local size = itemPreview:GetModelSize()
        newCam.CFrame = CFrame.new(origin + Vector3.new(size.x*2, size.y*2, size.z*2), origin)
    end
end

local function refreshTools()
    for _, t in pairs(ToolsUi.Frame:GetChildren()) do
        if t:IsA("ImageLabel") and t.Visible == true then
            t:Destroy()
        elseif t:IsA("ImageLabel") and t.Visible == false then
            skin(t)
        end
    end
end

local function onPlayerDataSet(data)
    for toolName, toolData in pairs(data.storedTools) do
        skin(ToolsUi.Frame[toolName])
    end
    currentInventory = data.storedTools
    refreshTools()
end

local function onHotkeyPressedForCategory(itemCategory)
    local data = currentInventory[itemCategory]
    if data and data.item ~= nil then
        print("doing equip storedf tool")
        Messages:sendServer("EquipStoredTool", itemCategory)
    else
        print("STORE ACTION!!")
        Messages:send("OnStoreAction")
    end
end

local Tools = {}

function Tools:start()
    refreshTools()
    Messages:hook("PlayerDataSet", onPlayerDataSet)
    local keys = {
        [Enum.KeyCode.One] = "Weapon",
        [Enum.KeyCode.Two] = "RangedWeapon",
        [Enum.KeyCode.Three] = "Pickaxe",
        [Enum.KeyCode.Four] = "Utility"
    }
    game:GetService("UserInputService").InputBegan:connect(function(inputObject, gameProcessed)
        if not gameProcessed then
            if keys[inputObject.KeyCode] then
                onHotkeyPressedForCategory(keys[inputObject.KeyCode])
            end
        end
    end)
end

return Tools