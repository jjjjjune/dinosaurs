local import = require(game.ReplicatedStorage.Shared.Import)
local GuiService = game:GetService("GuiService")
local InputData = import "Client/Data/InputData"
local ContextActionService = game:GetService("ContextActionService")

local Messages = import "Shared/Utils/Messages"
local Buttons = import "UI/Elements/Buttons"
local UiState= import "UI/UiState"
local InventoryItem = import "UI/Elements/InventoryItem"
local Styles = import "UI/Styles"



local Window = import "UI/Menus/Window"
local DoStats = import "UI/Elements/ItemStats"

local Inventory = {}

local tabOrder = {"Tools","Stickers"}
local loadedItems = {["Tools"]={},["Stickers"]={},["Pets"]={},["Titles"]={},}
local loadedPage = "Tools"
local gridSize = {["Tools"] = Vector2.new(0.25,0.21),["Stickers"] = Vector2.new(0.2,0.21)}

local sortToolsOrder = {"ALL","ROCKET","SWORD","BOMB","BALL","TROWEL"}
local sortTypeOrder = {"TIME","RARITY","NAME"}

local function isThisTopWindow()
	return UiState.openWindows[1] == "Inventory_Main"
end

Inventory.stickyButton = nil
local stickyButtonSelf = nil
local function updateStickyButton()
	if InputData.inputType == "Gamepad" and isThisTopWindow() then
		GuiService.SelectedObject = Inventory.stickyButton
		if stickyButtonSelf then
			stickyButtonSelf:hover()
		end
	end
end

--Set the height of the scrolling frame
local function UpdateCanvas()
	for _,iFrame in pairs(Inventory.ItemsFrames) do
		iFrame.CanvasSize = UDim2.new(0, 0, 0, iFrame.UIGridLayout.AbsoluteContentSize.Y)
		iFrame.UIGridLayout.CellSize = UDim2.new(0,(iFrame.AbsoluteWindowSize.X*gridSize[iFrame.Name].X),0,
			iFrame.AbsoluteWindowSize.X*gridSize[iFrame.Name].Y)
	end
end

function Inventory:clear(page)
	for i, item in pairs(loadedItems[page]) do
		item:destroy()
		loadedItems[page][i] = nil
	end
	loadedItems[page] = {}
end

local currentSortType = 1
local function SortType(sort)
	if sort == "TIME" then
		for _,page in pairs(loadedItems) do
			for _,item in pairs(page) do
				item.button.LayoutOrder = item.timeOrder
			end
		end
		for _,iFrame in pairs(Inventory.ItemsFrames) do
			iFrame.UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
		end
	end
	if sort == "NAME" then
		for _,iFrame in pairs(Inventory.ItemsFrames) do
			iFrame.UIGridLayout.SortOrder = Enum.SortOrder.Name
		end
	end
	if sort == "RARITY" then
		for _,page in pairs(loadedItems) do
			for _,item in pairs(page) do
				item.button.LayoutOrder = item.rarityOrder
			end
		end
		for _,iFrame in pairs(Inventory.ItemsFrames) do
			iFrame.UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
		end
	end
	local sortButtons = Inventory.Container.SortType:GetChildren()
	for _,b in pairs(sortButtons) do if b:IsA("ImageButton") then b.ImageColor3 = Color3.fromRGB(90,90,90) end end
	Inventory.Container.SortType[sort].ImageColor3 = Styles.colors.toolsColor
	for n,sorting in pairs(sortTypeOrder) do
		if sorting == sort then
			currentSortType = n
		end
	end
end

local currentSort = 1
local function SortTools(slot)
	local lastButton = nil
	for _,item in pairs(loadedItems["Tools"]) do
		if slot == "ALL" then
			item.button.Visible = true
			if lastButton == nil or lastButton.LayoutOrder > item.button.LayoutOrder then
				lastButton = item.button
				stickyButtonSelf = item
			end
		else
			item.button.Visible = item.data.slot == slot
			if item.button.Visible then
				if lastButton == nil or lastButton.LayoutOrder > item.button.LayoutOrder then
					lastButton = item.button
					stickyButtonSelf = item
				end
			end
		end
	end
	local toolButtons = Inventory.Container.SortTools:GetChildren()
	for _,b in pairs(toolButtons) do if b:IsA("ImageButton") then b.ImageColor3 = Color3.fromRGB(90,90,90) end end
	Inventory.Container.SortTools[slot].ImageColor3 = Styles.colors.toolsColor
	UpdateCanvas()
	for n,sorting in pairs(sortToolsOrder) do
		if sorting == slot then
			currentSort = n
		end
	end
	return lastButton
end

function Inventory:loadItems(page)
	Inventory:clear(page)
	loadedPage = page
	Inventory.Container.SortTools.Visible = false
	for _,frame in pairs(Inventory.ItemsFrames) do frame.Visible = false end

	local lastButton

	if page == "Tools" then
		Inventory.Container.SortTools.Visible = true
		for k,t in pairs(_G.Data.weapons) do
			local newItem = InventoryItem.new(k,t)
			newItem:spawn("Tools")
			if newItem and newItem.button then
				newItem.button.Parent = Inventory.ItemsFrame[page]
				table.insert(loadedItems[page],newItem)
			end
		end
		lastButton = SortTools("ALL")
	end
	if page == "Stickers" then
		for k,t in pairs(_G.Data.stickers) do
			local newItem = InventoryItem.new(k,t)
			newItem:spawn("Stickers")
			if newItem and newItem.button and not newItem.data.deleteThis then
				newItem.button.Parent = Inventory.ItemsFrame[page]
				table.insert(loadedItems[page],newItem)
				if lastButton == nil or lastButton.LayoutOrder > newItem.button.LayoutOrder then
					lastButton = newItem.button
					stickyButtonSelf = newItem
				end
			end
		end
	end
	SortType(sortTypeOrder[currentSortType])

	Inventory.stickyButton = lastButton
	updateStickyButton()

	Inventory.ItemsFrame[page].Visible = true
end

local function showEquipped(item,isEquipped)
	if isEquipped then
		if item.button.Equipped.Visible == false then
			item.button.Equipped.Size = UDim2.new(0.3,0,0.3,0)
			item.button.Equipped:TweenSize(UDim2.new(0.15,0,0.15,0),
			Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.25,true)
		end
		item.button.Button.ImageColor3 = Color3.fromRGB(50,50,50)
		item.button.Equipped.Visible = true
		item.button.ItemType.circle.ImageColor3 = Styles.colors.toolsColor
	else
		item.button.Equipped.Visible = false
		item.button.Button.ImageColor3 = Color3.fromRGB(255,255,255)
		item.button.ItemType.circle.ImageColor3 = Color3.fromRGB(144,144,144)
	end
end

local function UpdateItems(page)

	if page == "Tools" then
		for _,item in pairs(loadedItems["Tools"]) do
			local isEquipped = _G.Data["equippedWeapons"][item.data.slot] == item.item
			showEquipped(item,isEquipped)
		end
	end

	if page == "Stickers" then
		local equipped = {}
		for slot,sticker in pairs(_G.Data["equippedStickers"]) do
			for _,item in pairs(loadedItems["Stickers"]) do
				if (sticker == item.item) then table.insert(equipped,slot,item) end
				if slot == 1 then showEquipped(item,false) end
			end
		end
		for ii,i in pairs(equipped) do
			showEquipped(i,true)
		end
	end

end

function Inventory:setTab(tab)
	local tabs = Inventory.Tabs:GetChildren()
	Inventory:loadItems(tab)
	UpdateCanvas()
	for _,t in pairs(tabs) do
		if t:IsA("ImageButton") then
			if t.Name == tab then
				t.ImageColor3 = t.Arrow.ImageColor3
				t.icon.ImageColor3 = Color3.new(1,1,1)
				t.name.TextColor3 = t.icon.ImageColor3
				t.Arrow.Visible = true
				t.name.Font = Enum.Font.GothamBlack
				t.Arrow.Size = UDim2.new(1.6,0,1.6,0)
				t.Arrow:TweenSize(UDim2.new(1,0,1,0),Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.4,true)
				Inventory.Window.CategoryTitle.TextLabel.Text = t.name.Text
				Inventory.Window.CategoryTitle.icon.ImageRectOffset = t.icon.ImageRectOffset
			else
				t.Arrow.Visible = false
				t.ImageColor3 = t.Arrow.BackgroundColor3
				t.name.TextColor3 = Color3.fromRGB(36, 36, 36)
				t.icon.ImageColor3 = t.name.TextColor3
				t.name.Font = Enum.Font.GothamSemibold
			end
		end
	end
	Inventory.ItemsFrame[tab].CanvasPosition = Vector2.new(0,0)
	UpdateItems(tab)
end

local function setupTabButtons()
	local tabs = Inventory.Tabs:GetChildren()
	for _,t in pairs(tabs) do
		if t:IsA("ImageButton") then
			t.name.TextColor3 = Color3.fromRGB(36, 36, 36)
			t.icon.ImageColor3 = t.name.TextColor3
			local baseColor = t.ImageColor3
			local onColor = t.Arrow.ImageColor3
			t.MouseEnter:Connect(function()
				if not isThisTopWindow() then return end
				if loadedPage == t.Name then t.ImageColor3 = onColor return end
				UiState.Sounds.Select:Play()
				t.ImageColor3 = Color3.new(baseColor.r*0.8,baseColor.g*0.8,baseColor.b*0.8)
			end)
			t.MouseLeave:Connect(function()
				if loadedPage == t.Name then t.ImageColor3 = onColor return end
				t.ImageColor3 = baseColor
			end)
			t.MouseButton1Click:Connect(function()
				if not isThisTopWindow() then return end
				UiState.Sounds.Click:Play()
				Inventory:setTab(t.Name)
				Inventory.Window.CategoryTitle.icon.Size = UDim2.new(1,0,1,0)
				Inventory.Window.CategoryTitle.TextLabel.Position = UDim2.new(0.4,0,0.5,0)
				Inventory.Window.CategoryTitle.TextLabel:TweenPosition(UDim2.new(0.3,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.3,true)
				Inventory.Window.CategoryTitle.icon:TweenSize(UDim2.new(0.8,0,0.8,0),Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.3,true)
			end)
		end
	end
end

local function setupSortButtons(frame)
	local toolButtons = Inventory.Container.SortTools:GetChildren()
	local sortButtons = Inventory.Container.SortType:GetChildren()
	for _,button in pairs(toolButtons) do
		if button:IsA("ImageButton") then
			local function hover()
				if button.ImageColor3 == Styles.colors.toolsColor then return end
				button.icon:TweenSize(UDim2.new(0.75,0,0.75,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.2,true)
				UiState.Sounds.Select:Play()
			end
			local function unhover()
				button.icon:TweenSize(UDim2.new(0.9,0,0.9,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.2,true)
			end
			button.MouseEnter:connect(hover)
			button.MouseLeave:connect(unhover)
			button.MouseButton1Click:connect(function()
				if not isThisTopWindow() then return end
				if button.ImageColor3 == Styles.colors.toolsColor then return end
				UiState.Sounds.Click:Play()
				SortTools(button.Name)
			end)
		end
	end
	for _,button in pairs(sortButtons) do
		if button:IsA("ImageButton") then
			local function hover()
				if button.ImageColor3 == Styles.colors.toolsColor then return end
				button.icon:TweenSize(UDim2.new(0.75,0,0.75,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.2,true)
				UiState.Sounds.Select:Play()
			end
			local function unhover()
				button.icon:TweenSize(UDim2.new(0.9,0,0.9,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.2,true)
			end
			button.MouseEnter:connect(hover)
			button.MouseLeave:connect(unhover)
			button.MouseButton1Click:connect(function()
				if not isThisTopWindow() then return end
				if button.ImageColor3 == Styles.colors.toolsColor then return end
				UiState.Sounds.Click:Play()
				SortType(button.Name)
			end)
		end
	end
end

local function clearDescription()
	DoStats(nil,Inventory.Description.ItemDesc.ItemStats)
	Inventory.Description.BrickCost.Visible = false
	Inventory.Description.ItemDesc.TextLabel.Text = ""
	Inventory.Description.ItemDesc.extraInfo.Text = ""
	Inventory.Description.ItemRarity.Visible = false
	Inventory.Description.ItemName.Visible = false
	Inventory.Description.ItemName.TextLabel.Text = ""
	Inventory.Description.ItemDate.Text = ""
	Inventory.Description.ItemIcon.Visible = false
	Inventory.Description.ItemType.Visible = false
	Inventory.Description.ItemDesc.by.Visible = false
	Inventory.Description.ItemDesc.extraInfo.Visible = false
end

function Inventory:start()
	Inventory.Window = UiState:GetElement("Inventory_Main")
	Inventory.Tabs = UiState:GetElement("InventoryCategories")
	Inventory.Container = UiState:GetElement("InventoryContainer")
	Inventory.ItemsFrame = UiState:GetElement("InventoryItems")
	Inventory.ItemsFrames = {Inventory.ItemsFrame:WaitForChild("Tools"),
							Inventory.ItemsFrame:WaitForChild("Stickers"),}
	Inventory.Description = UiState:GetElement("InventoryDescription")

	for _,w in pairs(Inventory.ItemsFrames) do
		GuiService:AddSelectionParent("Inventory"..w.Name,w)
	end

	setupTabButtons()
	Inventory:setTab("Tools")

	Messages:hook("OnToolGiven", function(tool)
		UpdateItems("Tools")
	end)
	Messages:hook("UpdatedTools", function(tool)
		UpdateItems("Tools")
	end)
	Messages:hook("UpdatedStickers", function(slot)
		UpdateItems("Stickers")
	end)
	Messages:hook("OnWindowOpened",function(name)
		if name == "Inventory_Main" then
			clearDescription()
			Inventory:loadItems(loadedPage)
			UpdateItems(loadedPage)
			UpdateCanvas()
			UiState.Sidebar.InventorySidebar.Visible = false
			Inventory.ItemsFrame[loadedPage].CanvasPosition = Vector2.new(0,0)
			updateStickyButton()
			Messages:send("ChangeMenuBG",Color3.fromRGB(255, 145, 0))
			ContextActionService:BindActionAtPriority("TabInventory",function(actionName, inputState, inputObject)
				if inputState ~= Enum.UserInputState.Begin then return end
				if not isThisTopWindow() then return end
				--print(inputObject.KeyCode)
				local thisTabNumber = 1
				for n,t in pairs(tabOrder) do
					if t == loadedPage then
						thisTabNumber = n
					end
				end
				if inputObject.KeyCode == Enum.KeyCode.ButtonL1 or inputObject.KeyCode == Enum.KeyCode.Q then
					--left
					Inventory:setTab(tabOrder[thisTabNumber-1] or tabOrder[#tabOrder])
				elseif inputObject.KeyCode == Enum.KeyCode.ButtonR1 or inputObject.KeyCode == Enum.KeyCode.E then
					--right
					Inventory:setTab(tabOrder[thisTabNumber+1] or tabOrder[1])
				end
				UiState.Sounds.Click:Play()
			end, false, 500, Enum.KeyCode.ButtonR1, Enum.KeyCode.ButtonL1, Enum.KeyCode.Q, Enum.KeyCode.E)
			ContextActionService:BindAction("SortInventoryTools",function(actionName, inputState, inputObject)
				if inputState ~= Enum.UserInputState.Begin then return end
				if not isThisTopWindow() then return end
				Inventory.stickyButton = SortTools(sortToolsOrder[currentSort+1] or sortToolsOrder[1])
				UiState.Sounds.Click:Play()
				updateStickyButton()
			end, false, Enum.KeyCode.ButtonY)
			ContextActionService:BindAction("SortInventory",function(actionName, inputState, inputObject)
				if inputState ~= Enum.UserInputState.Begin then return end
				if not isThisTopWindow() then return end
				SortType(sortTypeOrder[currentSortType+1] or sortTypeOrder[1])
				UiState.Sounds.Click:Play()
			end, false, Enum.KeyCode.ButtonSelect)
		end
	end)
	Messages:hook("OnWindowClosed",function(name)
		if name == "Inventory_Main" then
			ContextActionService:UnbindAction("TabInventory")
			ContextActionService:UnbindAction("SortInventory")
			ContextActionService:UnbindAction("SortInventoryTools")
			UiState.Sidebar.InventorySidebar.Visible = true
		end
		if isThisTopWindow() then
			updateStickyButton()
		end
	end)

	for _,iFrame in pairs(Inventory.ItemsFrames) do
		iFrame:GetPropertyChangedSignal("AbsoluteWindowSize"):connect(function()
			UpdateCanvas()
		end)
	end

	setupSortButtons()
	SortType("TIME")

	ContextActionService:BindAction("OpenItems",function(actionName, inputState, inputObject)
		if inputState ~= Enum.UserInputState.Begin then return end
		if not Inventory.Window.Visible and UiState.Sidebar.Parent.Enabled then
			UiState.Sounds.MenuOpen:Play()
			Messages:send("OpenWindow","Inventory_Main")
		end
	end, false, Enum.KeyCode.ButtonSelect)
end

return Inventory
