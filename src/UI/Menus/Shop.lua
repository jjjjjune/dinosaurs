local import = require(game.ReplicatedStorage.Shared.Import)
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")

local Messages = import "Shared/Utils/Messages"
local Buttons = import "UI/Elements/Buttons"
local UiState= import "UI/UiState"
local InputData = import "Client/Data/InputData"
local ShopItem = import "UI/Elements/ShopItem"
local Styles = import "UI/Styles"
local BuyConfirm = import "UI/Menus/BuyConfirm"
local GetShopItems = import "Shared/Utils/GetShopItems"

local FastSpawn = import "Shared/Utils/FastSpawn"

local ToolData = import "Shared/Data/ToolData"
local StickerData = import "Shared/Data/StickerData"
local CrownShopData = import "Shared/Data/CrownShopData"

local MarketplaceService = game:GetService("MarketplaceService")

local Shop= {}

local isVipServer = false

local itemPool = {}

local tabOrder = {"Frontpage","Tools","Stickers","Crowns","Codes"}
local loadedItems = {["Tools"]={},["Stickers"]={},["Pets"]={},["Titles"]={}}
local loadedPage = nil

local itemsPerPage = {["Frontpage"] = 8,["Tools"] = 8,["Stickers"] = 12,["Pets"] = 8, ["Titles"] = 8,}
local pageSizes = { [4]=UDim2.new(0.5,0,0.5,0),[6]=UDim2.new(0.33,0,0.5,0),
					[8]=UDim2.new(0.25,0,0.5,0),[10]=UDim2.new(0.2,0,0.5,0),
					[12]=UDim2.new(0.165,0,0.5,0),}

local function isThisTopWindow()
	return UiState.openWindows[1] == "Shop_Main"
end

Shop.stickyButton = nil
local function updateStickyButton()
	if InputData.inputType == "Gamepad" and isThisTopWindow() then
		GuiService.SelectedObject = Shop.stickyButton
	end
end

function Shop:clear()
	for i, itemType in pairs(loadedItems) do
		for ii,item in pairs(loadedItems[i]) do
			item:destroy()
			loadedItems[ii] = nil
		end
	end
	loadedItems = {["Frontpage"]={},["Tools"]={},["Stickers"]={},["Pets"]={},["Titles"]={}}
end

local function UpdateTools()
	for _,item in pairs(loadedItems["Tools"]) do
		for owned,_ in pairs(_G.Data["weapons"]) do
			if owned == item.item then
				item.button.Owned.Visible = true
				item.button.OwnedCheck.Visible = true
				item.button.Price.Visible = false
				item.button.Button.ImageColor3 = Color3.fromRGB(120, 120, 120)
				item.button.ItemRarity.Visible = false
				item.button.ItemType.Visible = false
				if item.CustomFrame then
					item.CustomFrame.ImageColor3 = Color3.new(0.2,0.2,0.2)
				end
			end
		end
	end
end
local function UpdateStickers()
	for _,item in pairs(loadedItems["Stickers"]) do
		for owned,_ in pairs(_G.Data["stickers"]) do
			if owned == item.item then
				item.button.Owned.Visible = true
				item.button.OwnedCheck.Visible = true
				item.button.Price.Visible = false
				item.button.Button.ImageColor3 = Color3.fromRGB(120, 120, 120)
				item.button.ItemRarity.Visible = false
				item.button.ItemType.Visible = false
				if item.CustomFrame then
					item.CustomFrame.ImageColor3 = Color3.new(0.2,0.2,0.2)
				end
			end
		end
	end
end
local function UpdateFrontpage()
	for _,item in pairs(loadedItems["Frontpage"]) do
		if item.itemType == "Tools" then
			for owned,_ in pairs(_G.Data["weapons"]) do
				if owned == item.item then
					item.button.Owned.Visible = true
					item.button.OwnedCheck.Visible = true
					item.button.Price.Visible = false
					item.button.Button.ImageColor3 = Color3.fromRGB(120, 120, 120)
					item.button.ItemRarity.Visible = false
					item.button.ItemType.Visible = false
					if item.CustomFrame then
						item.CustomFrame.ImageColor3 = Color3.new(0.2,0.2,0.2)
					end
				end
			end
		end
		if item.itemType == "Stickers" then
			for owned,_ in pairs(_G.Data["stickers"]) do
				if owned == item.item then
					item.button.Owned.Visible = true
					item.button.OwnedCheck.Visible = true
					item.button.Price.Visible = false
					item.button.Button.ImageColor3 = Color3.fromRGB(120, 120, 120)
					item.button.ItemRarity.Visible = false
					item.button.ItemType.Visible = false
					if item.CustomFrame then
						item.CustomFrame.ImageColor3 = Color3.new(0.2,0.2,0.2)
					end
				end
			end
		end
	end
end

local codesSetup = false
local function setupCodes()
	local textBox = Shop.ItemsFrame.Codes.TextBox
	local frame = Shop.ItemsFrame.Codes
	local function onlyUppercase(text)
		text = text:upper()
		return text:gsub("%U+", "")
	end
	textBox:GetPropertyChangedSignal("Text"):Connect(function()
		-- Replace the text with the formatted text:
		textBox.Text = onlyUppercase(textBox.Text)
	end)
	textBox.ReturnPressedFromOnScreenKeyboard:Connect(function()
		Messages:sendServer("EnterCode",textBox.Text)
	end)
	local color = frame.Button.ImageColor3
	frame.Button.MouseEnter:connect(function()
		if not isThisTopWindow() then return end
		UiState.Sounds.Select:Play()
		frame.Button.ImageColor3 = Color3.new(color.r*0.8,color.g*0.8,color.b*0.8)
	end)
	frame.Button.MouseLeave:connect(function()
		frame.Button.ImageColor3 = color
	end)
	frame.Button.SelectionGained:connect(function()
		UiState.Sounds.Select:Play()
	end)
	frame.Button.MouseButton1Down:connect(function()
		UiState.Sounds.Click:Play()
		frame.Button.ImageColor3 = Color3.new(color.r*0.6,color.g*0.6,color.b*0.6)
	end)
	frame.Button.MouseButton1Up:connect(function()
		frame.Button.ImageColor3 = Color3.new(color.r*0.8,color.g*0.8,color.b*0.8)
	end)
	frame.Button.Activated:connect(function()
		if not isThisTopWindow() then return end
		Messages:sendServer("EnterCode",textBox.Text)
	end)
end

local crownsSetup = false
local function setupCrowns()
	for buttonName,crownData in pairs(CrownShopData) do
		local frame = Shop.ItemsFrame.Crowns[buttonName]
		local color = frame.Button.ImageColor3
		frame.Button.MouseEnter:connect(function()
			UiState.Sounds.Select:Play()
			frame.Button.ImageColor3 = Color3.new(color.r*0.8,color.g*0.8,color.b*0.8)
			frame.Icon:TweenSize(UDim2.new(0.8,0,0.8,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quint,0.5,true)
			Messages:send("MakeSparkles",{amount=1,delay=0,size=UDim2.new(0.5,0,0.5,0),
				center=UDim2.new(0.5,0,0.5,0),spread=UDim2.new(0.25,0,0.25,0),parent=frame})
		end)
		frame.Button.MouseLeave:connect(function()
			frame.Button.ImageColor3 = color
			frame.Icon:TweenSize(UDim2.new(0.7,0,0.7,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quint,0.25,true)
		end)
		frame.Button.SelectionGained:connect(function()
			UiState.Sounds.Select:Play()
			frame.Icon:TweenSize(UDim2.new(0.8,0,0.8,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quint,0.5,true)
		end)
		frame.Button.SelectionLost:connect(function()
			frame.Icon:TweenSize(UDim2.new(0.7,0,0.7,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quint,0.25,true)
		end)
		frame.Button.MouseButton1Down:connect(function()
			UiState.Sounds.Click:Play()
			frame.Button.ImageColor3 = Color3.new(color.r*0.6,color.g*0.6,color.b*0.6)
			Messages:send("MakeSparkles",{amount=2,delay=0,size=UDim2.new(0.5,0,0.5,0),
				center=UDim2.new(0.5,0,0.5,0),spread=UDim2.new(0.25,0,0.25,0),parent=frame})
		end)
		frame.Button.MouseButton1Up:connect(function()
			frame.Button.ImageColor3 = Color3.new(color.r*0.8,color.g*0.8,color.b*0.8)
		end)
		frame.Button.Activated:connect(function()
			MarketplaceService:PromptProductPurchase(game.Players.LocalPlayer, crownData.id)
		end)
	end
	crownsSetup = true
end

function Shop:loadItems(page)
	Shop:clear()
	loadedPage = page
	for _,frame in pairs(Shop.ItemsFrames) do frame.Visible = false end
	Shop.ItemsFrame.CrownTip.Visible = false

	if Shop.ItemsFrame[page]:FindFirstChild("UIGridLayout") and itemsPerPage[page] then
		Shop.ItemsFrame[page].UIGridLayout.CellSize = pageSizes[itemsPerPage[page]]
	end

	Shop.ItemsFrame.Codes.TextBox:ReleaseFocus()
	if page == "Frontpage" then
		for n,t in pairs(itemPool["Featured"]["Tools"]) do
			local newItem = ShopItem.new(t,ToolData[t])
			newItem:spawn("Tools")
			newItem.button.Parent = Shop.ItemsFrame.Frontpage
			table.insert(loadedItems["Frontpage"],#loadedItems["Frontpage"]+1,newItem)
		end
		for n,t in pairs(itemPool["Featured"]["Stickers"]) do
			local newItem = ShopItem.new(t,StickerData[t])
			newItem:spawn("Stickers")
			newItem.button.Parent = Shop.ItemsFrame.Frontpage
			table.insert(loadedItems["Frontpage"],#loadedItems["Frontpage"]+1,newItem)
		end
		Shop.stickyButton = loadedItems[page][1].button.Button
		UpdateFrontpage()
	end
	if page == "Tools" then
		for n,t in pairs(itemPool["Tools"]) do
			local newItem = ShopItem.new(t,ToolData[t])
			newItem:spawn("Tools")
			newItem.button.Parent = Shop.ItemsFrame.Tools
			table.insert(loadedItems["Tools"],#loadedItems["Tools"]+1,newItem)
		end
		UpdateTools()
		Shop.stickyButton = loadedItems[page][1].button.Button
	end
	if page == "Stickers" then
		for n,t in pairs(itemPool["Stickers"]) do
			local newItem = ShopItem.new(t,StickerData[t])
			newItem:spawn("Stickers")
			newItem.button.Parent = Shop.ItemsFrame.Stickers
			table.insert(loadedItems["Stickers"],#loadedItems["Stickers"]+1,newItem)
		end
		UpdateStickers()
		Shop.stickyButton = loadedItems[page][1].button.Button
	end
	if page == "Crowns" then
		if not crownsSetup then setupCrowns() end
		Shop.ItemsFrame.CrownTip.Visible = true
		Shop.stickyButton = Shop.ItemsFrame.Crowns.buy1.Button
	end
	if page == "Codes" then
		if not codesSetup then setupCodes() end
		Shop.stickyButton = Shop.ItemsFrame.Codes.TextBox
		Shop.ItemsFrame.Codes.TextBox.Text = ""
	end
	Shop.ItemsFrame[page].Visible = true
	updateStickyButton()
end

local timerCache = {h = -1, m = 0, s = 0}
local timerConnection = nil
local timerTween1,timerTween2 = nil
local function updateTimer()
	if timerCache.h ~= _G.dateTable.mhour then
		itemPool = GetShopItems:get(itemsPerPage)
	end
	timerCache.h = _G.dateTable.mhour
	timerCache.m = 60-_G.dateTable.minute
	timerCache.s = 60-_G.dateTable.second
	timerCache.lastSecond = timerCache.s
end

local function countTimer(step)
	timerCache.s = timerCache.s - step
	if math.floor(timerCache.s) ~= timerCache.lastSecond then
		timerCache.lastSecond = math.floor(timerCache.s)
		if not timerTween1 then
			local tweenInfo = TweenInfo.new(0.9,Enum.EasingStyle.Linear,Enum.EasingDirection.Out)
			timerTween1 = TweenService:Create(Shop.Window.SalesTimer.TextLabel,tweenInfo,{TextColor3 = Color3.fromRGB(120,120,120)})
			timerTween2 = TweenService:Create(Shop.Window.SalesTimer.icon,tweenInfo,{ImageColor3 = Color3.fromRGB(120,120,120)})
		end
		Shop.Window.SalesTimer.TextLabel.TextColor3 = Color3.fromRGB(80,80,80)
		Shop.Window.SalesTimer.icon.ImageColor3 = Color3.fromRGB(80,80,80)
		timerTween1:Play()
		timerTween2:Play()
	end
	if timerCache.s < 0 then
		timerCache.s = 60
		timerCache.m = timerCache.m - 1
	end
	local m = timerCache.m
	if timerCache.m<10 then m = "0"..tostring(m) end
	Shop.Window.SalesTimer.TextLabel.Text = m..":"..(timerCache.s<10 and "0" or "")..math.floor(timerCache.s)
end

local function updateTopbar()
	UiState.TopBar.CrownCount.TextLabel.Text = Styles.addComma(_G.Data["cash"])
	local bounds = UiState.TopBar.CrownCount.TextLabel.TextBounds
	UiState.TopBar.CrownCount.icon.Position = UDim2.new(0.5,-bounds.X*0.5,0.5,0)
end

function Shop:setTab(tab)
	local tabs = Shop.Tabs:GetChildren()
	Shop:loadItems(tab)
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
				Shop.Window.CategoryTitle.TextLabel.Text = t.name.Text
				Shop.Window.CategoryTitle.icon.Image = t.icon.Image
				Shop.Window.CategoryTitle.icon.ImageRectSize = t.icon.ImageRectSize
				Shop.Window.CategoryTitle.icon.ImageRectOffset = t.icon.ImageRectOffset
			else
				t.Arrow.Visible = false
				t.ImageColor3 = t.Arrow.BackgroundColor3
				t.name.TextColor3 = Color3.fromRGB(36, 36, 36)
				t.icon.ImageColor3 = t.name.TextColor3
				t.name.Font = Enum.Font.GothamSemibold
			end
		end
	end
end

local function setupTabButtons()
	local tabs = Shop.Tabs:GetChildren()
	for _,t in pairs(tabs) do
		if t:IsA("ImageButton") then
			t.name.TextColor3 = Color3.fromRGB(36, 36, 36)
			t.icon.ImageColor3 = t.name.TextColor3
			local baseColor = t.ImageColor3
			local onColor = t.Arrow.ImageColor3
			t.MouseEnter:Connect(function()
				if loadedPage == t.Name then t.ImageColor3 = onColor return end
				UiState.Sounds.Select:Play()
				t.ImageColor3 = Color3.new(baseColor.r*0.8,baseColor.g*0.8,baseColor.b*0.8)
			end)
			t.MouseLeave:Connect(function()
				if loadedPage == t.Name then t.ImageColor3 = onColor return end
				t.ImageColor3 = baseColor
			end)
			t.MouseButton1Click:Connect(function()
				UiState.Sounds.Click:Play()
				Shop:setTab(t.Name)
				Shop.Window.CategoryTitle.icon.Size = UDim2.new(1,0,1,0)
				Shop.Window.CategoryTitle.TextLabel.Position = UDim2.new(0.4,0,0.5,0)
				Shop.Window.CategoryTitle.TextLabel:TweenPosition(UDim2.new(0.3,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.3,true)
				Shop.Window.CategoryTitle.icon:TweenSize(UDim2.new(0.8,0,0.8,0),Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.3,true)
			end)
		end
	end
end

local function updateFeatured()
	if itemPool["Featured"] then
		Shop.Tabs.Frontpage.Visible = true
		tabOrder = {"Frontpage","Tools","Stickers","Crowns","Codes"}
	else
		Shop.Tabs.Frontpage.Visible = false
		tabOrder = {"Tools","Stickers","Crowns","Codes"}
	end
end

function Shop:start()
	--[[Messages:hook("SetServerType", function(serverType) -- not vip server for now
		if serverType == "VIPServer" then
			isVipServer = true
		end
	end)--]]
	Shop.Window = UiState:GetElement("Shop_Main")
	Shop.ErrorMsg = UiState:GetElement("ShopError")
	Shop.ItemsFrame = Shop.Window:WaitForChild("Items")
	Shop.ItemsFrames = {
		Shop.ItemsFrame:WaitForChild("Frontpage"),
		Shop.ItemsFrame:WaitForChild("Tools"),
		Shop.ItemsFrame:WaitForChild("Pets"),
		Shop.ItemsFrame:WaitForChild("Stickers"),
		Shop.ItemsFrame:WaitForChild("Titles"),
		Shop.ItemsFrame:WaitForChild("Crowns"),
		Shop.ItemsFrame:WaitForChild("Codes"),
	}
	for _,w in pairs(Shop.ItemsFrames) do
		GuiService:AddSelectionParent("Shop"..w.Name,w)
	end
	Shop.Tabs = Shop.Window:WaitForChild("Categories")
	updateTopbar()
	Messages:hook("PlayerDataSet", function(stat, value)
		updateTopbar()
	end)
	Messages:hook("OnWindowOpened",function(name)
		if name == "Shop_Main" then
			itemPool = GetShopItems:get(itemsPerPage)
			updateFeatured()
			if loadedPage == nil then
				loadedPage = tabOrder[1]
				Shop:setTab(tabOrder[1])
			else
				Shop:loadItems(loadedPage)
			end
			updateTimer()
			Messages:sendServer("GetDate")
			if timerConnection then timerConnection:Disconnect() timerConnection = nil end
			timerConnection = RunService.Stepped:Connect(function(time,step)
				countTimer(step)
			end)
			Messages:send("CloseWindow","Inventory_Main")
			Messages:send("PlayShopMusic",true)
			Messages:send("ChangeMenuBG",Color3.fromRGB(0, 255, 136))
			UiState.Sidebar.ShopSidebar.Visible = false
			UiState.Sidebar.ShopSidebar.NEW.Visible = false
			Shop.ItemsFrame.Visible = true
			ContextActionService:BindActionAtPriority("TabShop",function(actionName, inputState, inputObject)
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
					Shop:setTab(tabOrder[thisTabNumber-1] or tabOrder[#tabOrder])
				elseif inputObject.KeyCode == Enum.KeyCode.ButtonR1 or inputObject.KeyCode == Enum.KeyCode.E then
					--right
					Shop:setTab(tabOrder[thisTabNumber+1] or tabOrder[1])
				end
				UiState.Sounds.Click:Play()
			end, false, 500, Enum.KeyCode.ButtonR1, Enum.KeyCode.ButtonL1, Enum.KeyCode.Q, Enum.KeyCode.E)
		end
	end)
	Messages:hook("OpenShopTab",function(name)
		Shop:setTab(name)
		Messages:send("OpenWindow","Shop_Main")
	end)
	Messages:hook("OnWindowClosed",function(name)
		if name == "Shop_Main" then
			UiState.Sidebar.ShopSidebar.Visible = true
			Shop.ItemsFrame.Visible = false
			UiState.Sidebar.ShopSidebar.NEW.Visible = false
			ContextActionService:UnbindAction("TabShop")
			Messages:send("PlayShopMusic",false)
		end
		if isThisTopWindow() then
			updateStickyButton()
		end
	end)
	Messages:hook("ReceiveDate",function(dateget)
		if timerCache.h ~= -1 and _G.dateTable.mhour ~= timerCache.h then
			UiState.Sidebar.ShopSidebar.NEW.Visible = true
		end
		updateTimer()
	end)
	Messages:hook("ShopTransaction",function(success)
		if success == true and Shop.Window.Visible == true then
			if loadedPage == "Tools" then
				UpdateTools()
			elseif loadedPage == "Stickers" then
				UpdateStickers()
			elseif loadedPage == "Frontpage" then
				UpdateFrontpage()
			end
		end
	end)
	Messages:hook("ShopError",function(message,action)
		Shop.ErrorMsg.TextLabel.Text = message
		Shop.ErrorMsg.Visible = true
		FastSpawn(function()
			wait(3)
			Shop.ErrorMsg.Visible = false
		end)
		if action == "crowns" then
			Shop:setTab("Crowns")
		end
		if action == "code" then
			Shop.ItemsFrame.Codes.TextBox.Text = ""
		end
		if isThisTopWindow() then
			UiState.Sounds.Error:Play()
		end
	end)
	setupTabButtons()

	ContextActionService:BindAction("OpenShop",function(actionName, inputState, inputObject)
		if inputState ~= Enum.UserInputState.Begin then return end
		if not Shop.Window.Visible and UiState.Sidebar.Parent.Enabled then
			UiState.Sounds.MenuOpen:Play()
			Messages:send("OpenWindow","Shop_Main")
		end
	end, false, Enum.KeyCode.ButtonY)

	Messages:sendServer("GetDate")
end

return Shop
