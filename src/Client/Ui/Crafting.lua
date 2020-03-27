local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local Recipes = import "Shared/Data/CraftingRecipes"
local CraftingUi = game.Players.LocalPlayer.PlayerGui:WaitForChild("Crafting"):WaitForChild("Background")

local function skin(inventorySlot, item, folder)
    local newFrame = inventorySlot:Clone()
    newFrame.Parent = inventorySlot.Parent
    newFrame.Visible = true
    local newCam = Instance.new("Camera")
    newCam.Parent = newFrame
    newCam.FieldOfView = 30
    newFrame.CurrentCamera = newCam
    local itemPreview = game.ReplicatedStorage[folder][item]:Clone()
    itemPreview.Parent = newFrame
    local origin = itemPreview:GetModelCFrame().p
    local size = itemPreview:GetModelSize()
    newCam.CFrame = CFrame.new(origin + Vector3.new(size.x*2, size.y*2, size.z*2), origin)
end

local function openCrafting(stationType)
    CraftingUi.Visible = true
    local frame = CraftingUi.ScrollFrameContainer.ScrollingFrame
    local typeRecipes = Recipes[stationType]
    frame.CanvasSize = UDim2.new(0,0,0,0)
    for _, f in pairs(frame:GetChildren()) do
        if f:IsA("ImageLabel") and f.Visible == true then
            f:Destroy()
        end
    end
    for index, recipe in pairs(typeRecipes) do
        local craftFrame do
            if recipe.building then
                craftFrame = frame.BuildingCraftFrame:Clone()
            else
                craftFrame = frame.CraftFrame:Clone()
            end
        end
        local folderName do
            if recipe.building then
                folderName = "Buildings"
            else
                folderName = "Items"
            end
        end
        craftFrame.Parent = frame
        frame.CanvasSize = frame.CanvasSize + UDim2.new(0,0,0,craftFrame.AbsoluteSize.Y + 10)
        craftFrame.LayoutOrder = string.byte(recipe.product)
        craftFrame.Visible = true
        skin(craftFrame.IngredientFrame, recipe.ingredient, "Items")
        skin(craftFrame.IngredientShadow, recipe.ingredient, "Items")
        skin(craftFrame.ProductFrame, recipe.product, folderName)
        skin(craftFrame.ProductShadow, recipe.product, folderName)
        craftFrame.ItemName.Text = recipe.product
        Messages:send("RegisterButton", craftFrame.Craft, craftFrame.CraftShadow, function()
            Messages:sendServer("CraftItem", stationType, index)
        end)
    end
end

local RadialProgress = {}

function RadialProgress:start()
    Messages:hook("OpenCrafting", openCrafting)
    Messages:send("RegisterButton", CraftingUi.CloseButton, CraftingUi.CloseButtonShadow, function()
        CraftingUi.Visible = false
    end)
end

return RadialProgress