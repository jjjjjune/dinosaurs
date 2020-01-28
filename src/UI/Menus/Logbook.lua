local import = require(game.ReplicatedStorage.Shared.Import)
local GuiService = game:GetService("GuiService")
local InputData = import "Client/Data/InputData"
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")

local Messages = import "Shared/Utils/Messages"
local Buttons = import "UI/Elements/Buttons"
local UiState= import "UI/UiState"
local Styles = import "UI/Styles"

local Window = import "UI/Menus/Window"

local ToolData = import "Shared/Data/ToolData"
local StickerData = import "Shared/Data/StickerData"
local RenderItem = import "UI/Elements/RenderItem"
local ToolCosmetics = import "Shared/Data/ToolCosmetics"

local StickerSoundsFolder = import "Assets/StickerSounds"

local player = game.Players.LocalPlayer

local Logbook = {}

local tabOrder = {"Stats","Tools","Stickers"}
local loadedItems = {["Stats"]={},["Tools"]={},["Stickers"]={},["Pets"]={},["Titles"]={},}
local loadedPage = "Stats"
local customFrames = {["Tools"]={},["Stickers"]={},["Pets"]={},["Titles"]={},}

local cycleTeams = {"Red","Yellow","Green","Blue","Spectators"}
local teamNums = {["Red"]=1,["Yellow"]=2,["Green"]=3,["Blue"]=4,["Spectators"]=5}

local SpinConnect = nil

local function isThisTopWindow()
	return UiState.openWindows[1] == "Log_Main"
end

Logbook.stickyButton = nil
local function updateStickyButton()
	if InputData.inputType == "Gamepad" and isThisTopWindow() then
		GuiService.SelectedObject = Logbook.stickyButton
	end
end

--Set the height of the scrolling frame
local function UpdateCanvas()
	for _,iFrame in pairs(Logbook.ItemsFrames) do
		if iFrame:IsA("ScrollingFrame") then
			iFrame.CanvasSize = UDim2.new(0, 0, 0, iFrame.UIGridLayout.AbsoluteContentSize.Y)
			iFrame.UIGridLayout.CellSize = UDim2.new(0,(iFrame.AbsoluteWindowSize.X*0.12),0,
				iFrame.AbsoluteWindowSize.X*0.12)
		end
	end
end

function Logbook:clear(page)
	for i, item in pairs(loadedItems[page]) do
		item:Destroy()
		loadedItems[page][i] = nil
	end
	if customFrames[page] then
		for i, frame in pairs(customFrames[page]) do
			frame:Destroy()
			customFrames[page][i] = nil
		end
	end

	loadedItems[page] = {}
end

local function newStat(statName,stat)
	if not Logbook.statBase then
		Logbook.statBase = Logbook.Window.StatTracked
	end
	local new = Logbook.statBase:Clone()
	--new.Name = statName
	new.TextLabel.Text = statName
	new.Count.TextLabel.Text = stat
	new.Parent = Logbook.ItemsFrame.Stats
	new.Visible = true
	return new
end

local function newItem(itemName,itemType)
	if not Logbook.itemBase then
		Logbook.itemBase = UiState:GetElement("LogItem")
	end
	local data
	local CustomFrame = nil
	local new = Logbook.itemBase:Clone()

	local has = false
	if itemType == "Tools" then
		data = ToolData[itemName]
		has = _G.Data.weapons[itemName]~=nil
		CustomFrame = RenderItem:icon(new.ItemIcon,itemType,data)
		CustomFrame.Parent = new.ItemIcon
		customFrames[itemType][new] = CustomFrame
		if not has then
			CustomFrame.Frame.ImageColor3 = Color3.new(0,0,0)
		end
	end
	if itemType == "Stickers" then
		data = StickerData[itemName]
		has = _G.Data.stickers[itemName]~=nil
		CustomFrame = RenderItem:icon(new.ItemIcon,itemType,data)
		CustomFrame.Parent = new.ItemIcon
		customFrames[itemType][new] = CustomFrame
		if not has then
			CustomFrame.ImageColor3 = Color3.new(0,0,0)
		end
		if data.sound then
			local sound = StickerSoundsFolder[data.sound]:Clone()
			sound.Name = "Sound"
			sound.Parent = new
		end
	end
	if data.deleteThis then return nil end
	if data.taskReward then
		new.task.Visible = true
	end

	new.rarity.ImageColor3 = Styles.colors["rare"..data.rarity.."color"]
	new.LayoutOrder = data.rarity
	new.notfound.ImageColor3 = Styles.colors["rare"..data.rarity.."color"]

	if has then
		new.notfound.Visible = false
		Logbook.has = Logbook.has + 1
		new.ImageColor3 = Color3.new(0.9,0.9,0.9)
	elseif not data.notAvailable then
		--new.ItemIcon.Visible = false
		new.task.ImageTransparency = 0.66
		Logbook.notHas = Logbook.notHas + 1
	end

	new.Name = itemName
	new.Parent = Logbook.ItemsFrame[itemType]

	local teamNum = teamNums[player.Team.Name]

	local function hover()
		if has then
			new.ImageColor3 = Color3.new(0.8,0.8,0.8)
		end
		new.ItemIcon:TweenSize(UDim2.new(1.1,0,1.1,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.2,true)
		new.notfound:TweenSize(UDim2.new(0.8,0,0.8,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.2,true)
		Logbook.Info.TextLabel.Text = has and itemName or "???"
		Logbook.Info.TextLabel.TextColor3 = Styles.colors["rare"..data.rarity.."color"]
		Logbook.Info.TextLabel.Visible = true
		Logbook.Info.ItemRarity.Visible = true
		RenderItem:rarityStars(Logbook.Info.ItemRarity,data.rarity)
		RenderItem:rarityText(Logbook.Info.ItemRarity.TextLabel,data.rarity)
		if has and data.price and data.price > 0 then
			Logbook.Info.price.Visible = true
			Logbook.Info.priceNum.Visible = true
			Logbook.Info.priceNum.Text = Styles.addComma(data.price)
		else
			Logbook.Info.price.Visible = false
			Logbook.Info.priceNum.Visible = false
		end
	end

	local function unhover()
		if has then
			new.ImageColor3 = Color3.new(0.9,0.9,0.9)
		end
		new.notfound:TweenSize(UDim2.new(1,0,1,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.33,true)
		new.ItemIcon:TweenSize(UDim2.new(0.9,0,0.9,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.33,true)
	end

	new.MouseEnter:connect(function()
		hover()
		if InputData.inputType ~= "Gamepad" then
			UiState.Sounds.Select:Play()
		end
	end)
	new.SelectionGained:connect(function()
		hover()
		UiState.Sounds.Select:Play()
	end)
	new.Activated:connect(function()
		if has then
			if customFrames[itemType][new] and itemType == "Tools" then
				teamNum = teamNum >= 5 and 1 or teamNum + 1
				ToolCosmetics:skin(game.Teams[cycleTeams[teamNum]],customFrames[itemType][new].Model,itemName)
			end
			if new:FindFirstChild("Sound") then
				new.Sound:Play()
			else
				UiState.Sounds.Click:Play()
			end
			new.ItemIcon.Size = UDim2.new(1.3,0,1.3,0)
			new.ItemIcon:TweenSize(UDim2.new(1.1,0,1.1,0),Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.25,true)
		else
			UiState.Sounds.Click:Play()
		end
	end)
	new.MouseLeave:connect(unhover)
	new.SelectionLost:connect(unhover)

	if not has and data.notAvailable then
		new.Visible = false
	end

	return new
end

function Logbook:loadItems(page)
	Logbook:clear(page)
	loadedPage = page
	for _,frame in pairs(Logbook.ItemsFrames) do frame.Visible = false end

	local lastButton

	Logbook.has = 0
	Logbook.notHas = 0

	Logbook.Info.Visible = true
	Logbook.Count.Visible = true

	if page == "Tools" then
		for k,t in pairs(ToolData) do
			local new = newItem(t.name,"Tools")
			if new then
				table.insert(loadedItems[page],new)
				if lastButton == nil or lastButton.LayoutOrder > new.LayoutOrder then
					lastButton = new
				end
			end
		end
	end
	if page == "Stickers" then
		for k,t in pairs(StickerData) do
			local new = newItem(t.name,"Stickers")
			if new then
				table.insert(loadedItems[page],new)
				if lastButton == nil or lastButton.LayoutOrder > new.LayoutOrder then
					lastButton = new
				end
			end
		end
	end
	if page == "Stats" then
		Logbook.Info.Visible = false
		Logbook.Count.Visible = false
		local stats = {
			["KOs"] = {_G.Data.lifetimeKills,1},
			["Victories"] = {_G.Data.lifetimeWins,2},
			["Highest KDR"] = {_G.Data.highestKDRInRound,3},
			["Total Bricks"] = {_G.Data.lifetimeBricks,4},
			["Spawns Knocked Off"] = {_G.Data.spawnsDestroyed,5},
			["Fallout KOs"] = {_G.Data.enemiesDeplatformed,6},
			["KOs While Burning"] = {_G.Data.killsWhileOnFire,7},
			["Projectiles Reflected"] = {_G.Data.reflects,8},
			["Highest Reflect"] = {_G.Data.maxReflects,9},
			["Reflect KOs"] = {_G.Data.reflectKills,10},
		}
		for name,stat in pairs(stats) do
			local new = newStat(name,Styles.addComma(stat[1]))
			new.LayoutOrder = stat[2]
			table.insert(loadedItems[page],new)
		end
	end

	Logbook.Count.owned.TextLabel.Text = Logbook.has
	Logbook.Count.notowned.TextLabel.Text = Logbook.notHas

	Logbook.stickyButton = lastButton
	updateStickyButton()

	Logbook.ItemsFrame[page].Visible = true
end

function Logbook:setTab(tab)
	local tabs = Logbook.Tabs:GetChildren()
	Logbook:loadItems(tab)
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
				Logbook.Window.CategoryTitle.TextLabel.Text = t.name.Text
				Logbook.Window.CategoryTitle.icon.ImageRectOffset = t.icon.ImageRectOffset
			else
				t.Arrow.Visible = false
				t.ImageColor3 = t.Arrow.BackgroundColor3
				t.name.TextColor3 = Color3.fromRGB(36, 36, 36)
				t.icon.ImageColor3 = t.name.TextColor3
				t.name.Font = Enum.Font.GothamSemibold
			end
		end
	end
	if Logbook.ItemsFrame[tab]:IsA("ScrollingFrame") then
		Logbook.ItemsFrame[tab].CanvasPosition = Vector2.new(0,0)
	end
end

local function setupTabButtons()
	local tabs = Logbook.Tabs:GetChildren()
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
				Logbook:setTab(t.Name)
				Logbook.Window.CategoryTitle.icon.Size = UDim2.new(1,0,1,0)
				Logbook.Window.CategoryTitle.TextLabel.Position = UDim2.new(0.4,0,0.5,0)
				Logbook.Window.CategoryTitle.TextLabel:TweenPosition(UDim2.new(0.3,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.3,true)
				Logbook.Window.CategoryTitle.icon:TweenSize(UDim2.new(0.8,0,0.8,0),Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.3,true)
			end)
		end
	end
end

local function clearDescription()
	Logbook.Info.price.Visible = false
	Logbook.Info.priceNum.Visible = false
	Logbook.Info.TextLabel.Visible = false
	Logbook.Info.ItemRarity.Visible = false
end

function Logbook:start()
	Logbook.Window = UiState:GetElement("Log_Main")
	Logbook.Tabs = UiState:GetElement("LogCategories")
	Logbook.ItemsFrame = UiState:GetElement("LogItems")
	Logbook.Info = UiState:GetElement("LogInfo")
	Logbook.Count = UiState:GetElement("LogCount")
	Logbook.ItemsFrames = {Logbook.ItemsFrame:WaitForChild("Stats"),
							Logbook.ItemsFrame:WaitForChild("Tools"),
							Logbook.ItemsFrame:WaitForChild("Stickers"),}

	for _,w in pairs(Logbook.ItemsFrames) do
		GuiService:AddSelectionParent("Logbook"..w.Name,w)
	end

	setupTabButtons()

	Messages:hook("OnWindowOpened",function(name)
		if name == "Log_Main" then
			clearDescription()
			Logbook:setTab(loadedPage)
			Logbook:loadItems(loadedPage)
			UpdateCanvas()
			if Logbook.ItemsFrame[loadedPage]:IsA("ScrollingFrame") then
				Logbook.ItemsFrame[loadedPage].CanvasPosition = Vector2.new(0,0)
			end
			updateStickyButton()
			Messages:send("ChangeMenuBG",Color3.fromRGB(146, 126, 158))
			ContextActionService:BindActionAtPriority("TabLogbook",function(actionName, inputState, inputObject)
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
					Logbook:setTab(tabOrder[thisTabNumber-1] or tabOrder[#tabOrder])
				elseif inputObject.KeyCode == Enum.KeyCode.ButtonR1 or inputObject.KeyCode == Enum.KeyCode.E then
					--right
					Logbook:setTab(tabOrder[thisTabNumber+1] or tabOrder[1])
				end
				UiState.Sounds.Click:Play()
			end, false, 500, Enum.KeyCode.ButtonR1, Enum.KeyCode.ButtonL1, Enum.KeyCode.Q, Enum.KeyCode.E)
		end
	end)
	Messages:hook("OnWindowClosed",function(name)
		if name == "Log_Main" then
			ContextActionService:UnbindAction("TabLogbook")
		end
		if isThisTopWindow() then
			updateStickyButton()
		end
	end)

	for _,iFrame in pairs(Logbook.ItemsFrames) do
		if iFrame:IsA("ScrollingFrame") then
			iFrame:GetPropertyChangedSignal("AbsoluteWindowSize"):connect(function()
				UpdateCanvas()
			end)
		end
	end
end

return Logbook
