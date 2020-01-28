local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local Buttons = import "UI/Elements/Buttons"
local UiState= import "UI/UiState"

local InputData = import "Client/Data/InputData"
local ContextActionService = game:GetService("ContextActionService")
local CollectionService = game:GetService("CollectionService")

local NavBar = {}

local function isThisTopWindow(w)
	return UiState.openWindows[1] == w
end

local function mouseEvents(b)
	local color = b.ImageColor3
	b.MouseEnter:Connect(function()
		b.ImageColor3 = Color3.new(color.r*0.8,color.g*0.8,color.b*0.8)
		UiState.Sounds.Select:Play()
		b.icon:TweenSize(UDim2.new(0.8,0,0.8,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quint,0.5,true)
	end)
	b.MouseLeave:Connect(function()
		b.ImageColor3 = color
		b.icon:TweenSize(UDim2.new(0.9,0,0.9,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quint,0.25,true)
	end)
	b.MouseButton1Down:Connect(function()
		b.ImageColor3 = Color3.new(color.r*0.6,color.g*0.6,color.b*0.6)
		UiState.Sounds.Click:Play()
	end)
	b.MouseButton1Up:Connect(function()
		b.ImageColor3 = Color3.new(color.r*0.8,color.g*0.8,color.b*0.8)
	end)
end

local function setupBar(navbar)
	local bar = NavBar.newBar:Clone()
	local toInventory = bar:FindFirstChild("ToInventory")
	local toShop = bar:FindFirstChild("ToShop")
	local toOptions = bar:FindFirstChild("ToSettings")
	local toTasks = bar:FindFirstChild("ToTasks")
	local toLog = bar:FindFirstChild("ToLog")
	local parent = navbar.Parent.Name

	if toInventory then
		if parent == "Inventory_Main" then
			toInventory.ImageColor3 = Color3.new(0.5,0.5,0.5)
			toInventory.TextLabel.TextColor3 = Color3.new(0.6,0.6,0.6)
			toInventory.icon.ImageColor3 = Color3.new(0.6,0.6,0.6)
		else
			mouseEvents(toInventory)
			toInventory.Activated:Connect(function()
				Messages:send("OpenWindow","Inventory_Main")
				Messages:send("CloseWindow",parent)
			end)
		end
	end
	if toShop then
		if parent == "Shop_Main" then
			toShop.ImageColor3 = Color3.new(0.5,0.5,0.5)
			toShop.TextLabel.TextColor3 = Color3.new(0.8,0.8,0.8)
			toShop.icon.ImageColor3 = Color3.new(0.6,0.6,0.6)
		else
			mouseEvents(toShop)
			toShop.Activated:Connect(function()
				Messages:send("OpenWindow","Shop_Main")
				Messages:send("CloseWindow",parent)
			end)
		end
	end
	if toOptions then
		if parent == "Settings_Main" then
			toOptions.ImageColor3 = Color3.new(0.5,0.5,0.5)
			toOptions.TextLabel.TextColor3 = Color3.new(0.8,0.8,0.8)
			toOptions.icon.ImageColor3 = Color3.new(0.6,0.6,0.6)
		else
			mouseEvents(toOptions)
			toOptions.Activated:Connect(function()
				Messages:send("OpenWindow","Settings_Main")
				Messages:send("CloseWindow",parent)
			end)
		end
	end
	if toTasks then
		if parent == "TasksWindow" then
			toTasks.ImageColor3 = Color3.new(0.5,0.5,0.5)
			toTasks.TextLabel.TextColor3 = Color3.new(0.8,0.8,0.8)
			toTasks.icon.ImageColor3 = Color3.new(0.6,0.6,0.6)
		else
			mouseEvents(toTasks)
			toTasks.Activated:Connect(function()
				Messages:send("OpenWindow","TasksWindow")
				Messages:send("CloseWindow",parent)
			end)
		end
	end
	if toLog then
		if parent == "Log_Main" then
			toLog.ImageColor3 = Color3.new(0.5,0.5,0.5)
			toLog.TextLabel.TextColor3 = Color3.new(0.8,0.8,0.8)
			toLog.icon.ImageColor3 = Color3.new(0.6,0.6,0.6)
		else
			mouseEvents(toLog)
			toLog.Activated:Connect(function()
				Messages:send("OpenWindow","Log_Main")
				Messages:send("CloseWindow",parent)
			end)
		end
	end
	bar.Parent = navbar
end

local navWindows = {"Shop_Main","Inventory_Main","TasksWindow","Settings_Main","Log_Main"}

function NavBar:start()
	NavBar.newBar = UiState:GetElement("NavBarButtons")
	for _,bar in pairs(CollectionService:GetTagged("UiNavBar")) do
		setupBar(bar)
	end
	CollectionService:GetInstanceAddedSignal("UiNavBar"):connect(setupBar)

	ContextActionService:BindActionAtPriority("Navbar",function(actionName, inputState, inputObject)
		if inputState ~= Enum.UserInputState.Begin then return end
		local currentWindow = nil
		local currentNum = nil
		for n,w in pairs(navWindows) do
		if isThisTopWindow(w) then
				currentWindow = w
				currentNum = n
			end
		end
		if not currentWindow then return Enum.ContextActionResult.Pass end
		if inputObject.KeyCode == Enum.KeyCode.ButtonL2 then
			--left
			Messages:send("CloseWindow",currentWindow)
			Messages:send("OpenWindow",navWindows[currentNum-1] or navWindows[#navWindows])
			UiState.Sounds.Click:Play()
		elseif inputObject.KeyCode == Enum.KeyCode.ButtonR2 then
			--right
			Messages:send("CloseWindow",currentWindow)
			Messages:send("OpenWindow",navWindows[currentNum+1] or navWindows[1])
			UiState.Sounds.Click:Play()
		end
	end, false, 2000, Enum.KeyCode.ButtonR2, Enum.KeyCode.ButtonL2)
end

return NavBar
