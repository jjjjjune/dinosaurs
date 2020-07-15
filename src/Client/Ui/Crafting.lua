local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local Recipes = import "Shared/Data/CraftingRecipes"
local BoundMenu = import "Shared/Utils/BoundMenu"
local ContextActionService = game:GetService("ContextActionService")
local GetDevice = import "Shared/Utils/GetDevice"
local CraftingUi = game.Players.LocalPlayer.PlayerGui:WaitForChild("Crafting"):WaitForChild("Background")

local craftBoundMenu
local selectedButton

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

local function closeCrafting()
	if craftBoundMenu then
		craftBoundMenu:Destroy()
		craftBoundMenu = nil
	end

	Messages:send("PlaySoundOnClient",{
		instance = game.ReplicatedStorage.Sounds.NewUITwoPartClick,
	})

	game:GetService("GuiService").SelectedObject = nil

	CraftingUi.Visible = false

	ContextActionService:UnbindAction("close menu")
	ContextActionService:UnbindAction("select button")
end

local function selectButton()
	if selectedButton then
		Messages:send("PressButton", selectedButton)
	end
end

local function openCrafting(stationType, station)
	ContextActionService:BindAction("close menu", function(contextActionName, inputState, inputObject)
		if inputState == Enum.UserInputState.Begin then
			closeCrafting()
		end
	end, false, Enum.KeyCode.ButtonB)

	ContextActionService:BindAction("select button", function(contextActionName, inputState, inputObject)
		if inputState == Enum.UserInputState.Begin then
			selectButton()
		end
	end, false, Enum.KeyCode.ButtonA)

	local frame = CraftingUi.ScrollFrameContainer.ScrollingFrame
	local typeRecipes = Recipes[stationType]

	CraftingUi.Visible = true
	frame.CanvasSize = UDim2.new(0,0,0,0)

	for _, f in pairs(frame:GetChildren()) do
		if f:IsA("ImageLabel") and f.Visible == true then
			f:Destroy()
		end
	end

	local function getBuildValue(a)
		local avalue = 1
		if a.building then
			avalue = 1000
		end
		avalue = avalue * string.len(a.product)
		return avalue
	end

	local buttons = {}

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

		frame.CanvasSize = frame.CanvasSize + UDim2.new(0,0,0,craftFrame.AbsoluteSize.Y + 10)

		craftFrame.Parent = frame
		craftFrame.LayoutOrder = getBuildValue(recipe)
		craftFrame.Visible = true

		if not game.Players.LocalPlayer.Character:FindFirstChild(recipe.ingredient) then
			craftFrame.Craft.ImageColor3 = Color3.fromRGB(200,200,200)
		else
			Messages:send("RegisterButton", craftFrame.Craft, craftFrame.CraftShadow, function()
				Messages:sendServer("CraftItem", station, stationType, index)
				closeCrafting()
			end)
		end

		table.insert(buttons, craftFrame.Craft)

		skin(craftFrame.IngredientFrame, recipe.ingredient, "Items")
		skin(craftFrame.IngredientShadow, recipe.ingredient, "Items")
		skin(craftFrame.ProductFrame, recipe.product, folderName)
		skin(craftFrame.ProductShadow, recipe.product, folderName)

		craftFrame.ItemName.Text = recipe.product
	end

	local device = GetDevice()
	if device == "Gamepad" then
		craftBoundMenu = BoundMenu.new(buttons)
		craftBoundMenu.SelectionChanged:connect(function(oldButton,newButton)
			game:GetService("GuiService").SelectedObject = newButton
			selectedButton = newButton
			if oldButton ~= newButton then
				Messages:send("PlaySoundOnClient",{
					instance = game.ReplicatedStorage.Sounds.NewUIScroll1,
				})
			else
				Messages:send("PlaySoundOnClient",{
					instance = game.ReplicatedStorage.Sounds.NewUIScroll2,
				})
			end
		end)
		craftBoundMenu:SetSelection(buttons[1])
	end

	Messages:send("PlaySoundOnClient",{
		instance = game.ReplicatedStorage.Sounds.NewUIClickHigh,
	})
end

local RadialProgress = {}

function RadialProgress:start()
	Messages:hook("OpenCrafting", openCrafting)
	Messages:send("RegisterButton", CraftingUi.CloseButton, CraftingUi.CloseButtonShadow, closeCrafting)
end

return RadialProgress
