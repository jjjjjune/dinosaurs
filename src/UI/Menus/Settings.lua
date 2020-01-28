local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local Buttons = import "UI/Elements/Buttons"
local UiState= import "UI/UiState"
local InventoryItem = import "UI/Elements/InventoryItem"
local Styles = import "UI/Styles"
local InputData = import "Client/Data/InputData"
local Window = import "UI/Menus/Window"

local FastSpawn = import "Shared/Utils/FastSpawn"

local GuiService = game:GetService("GuiService")
local CollectionService = game:GetService("CollectionService")

local Settings = {}

local player = game.Players.LocalPlayer

local onColor = Color3.fromRGB(134,140,255)
local offColor = Color3.fromRGB(118,118,118)

local function isThisTopWindow()
	return UiState.openWindows[1] == "Settings_Main"
end

local Selection = nil
local function setupTools()
	local slots = Settings.tools.Slots:GetChildren()
	for _,slot in pairs(slots) do
		if slot:IsA("Frame") then
			local button = slot.Image.Button
			button.MouseEnter:Connect(function()
				UiState.Sounds.Select:Play()
				slot.Image.SlotIcon:TweenSize(UDim2.new(0.6,0,0.6,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.2,true)
			end)
			button.MouseLeave:Connect(function()
				slot.Image.SlotIcon:TweenSize(UDim2.new(0.7,0,0.7,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.2,true)
			end)
			button.MouseButton1Down:Connect(function()
				UiState.Sounds.Click:Play()
				slot.Image.SlotIcon:TweenSize(UDim2.new(0.5,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.2,true)
			end)
			button.MouseButton1Up:Connect(function()
				slot.Image.SlotIcon:TweenSize(UDim2.new(0.6,0,0.6,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.2,true)
			end)
			button.Activated:Connect(function()
				if Selection == slot then
					Selection = nil
					slot.Image:TweenSize(UDim2.new(1,0,1,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.2,true)
					slot.Image.SlotIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
					Settings.tools.titleBar.TextLabel.Text = "Select a slot to swap."
				else
					if Selection then
						Selection.Image:TweenSize(UDim2.new(1,0,1,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.2,true)
						Selection.Image.SlotIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
						--print("Swap "..Selection.Name.." with "..slot.Name)
						Messages:sendServer("ChangeToolOrder",Selection.Name,slot.Name)
						Selection = nil
						Settings.tools.titleBar.TextLabel.Text = "Select a slot to swap."
					else
						Selection = slot
						slot.Image.SlotIcon.ImageColor3 = Color3.fromRGB(255, 240, 0)
						slot.Image:TweenSize(UDim2.new(0.8,0,0.8,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true)
						Settings.tools.titleBar.TextLabel.Text = "Move "..slot.slotName.Text.." where?"
					end
				end
			end)
		end
	end
end

local function updateTools()
	local order = _G.Data.settings.toolOrder
	local slots = Settings.tools.Slots:GetChildren()
	for _,slot in pairs(slots) do
		if slot:IsA("Frame") then
			for n,dslot in pairs(order) do
				if dslot == slot.Name then
					slot.LayoutOrder = n
					slot.Image.ImageLabel.TextLabel.Text = n
				end
			end
		end
	end
end

local function updateButtonSettings(f)
	local val = _G.Data.settings[f.Name]
	for _,button in pairs(f.Frame:GetChildren()) do
		if button:IsA("ImageButton") then
			--print(f.Name..": "..tostring(val).." = "..tostring(button.Value.Value))
			if button.Name == "afkOn" then
				if CollectionService:HasTag(player,"Afk") then
					button.ImageColor3 = onColor
					button.TextLabel.Font = Enum.Font.GothamBlack
					button.TextLabel.TextColor3 = Color3.new(0,0,0)
					button.icon.ImageColor3 = Color3.new(0,0,0)
				else
					button.ImageColor3 = offColor
					button.TextLabel.Font = Enum.Font.GothamBlack
					button.TextLabel.TextColor3 = Color3.new(1,1,1)
					button.icon.ImageColor3 = Color3.new(1,1,1)
				end
			end
			if button.Name == "afkOff" then
				if not CollectionService:HasTag(player,"Afk") then
					button.ImageColor3 = onColor
					button.TextLabel.Font = Enum.Font.GothamBlack
					button.TextLabel.TextColor3 = Color3.new(0,0,0)
					button.icon.ImageColor3 = Color3.new(0,0,0)
				else
					button.ImageColor3 = offColor
					button.TextLabel.Font = Enum.Font.GothamBlack
					button.TextLabel.TextColor3 = Color3.new(1,1,1)
					button.icon.ImageColor3 = Color3.new(1,1,1)
				end
			end
			if button:FindFirstChild("Value") then
				if val == button.Value.Value then
					button.ImageColor3 = onColor
					if button:FindFirstChild("TextLabel") then
						button.TextLabel.Font = Enum.Font.GothamBlack
						button.TextLabel.TextColor3 = Color3.new(0,0,0)
					elseif button:FindFirstChild("ImageLabel") then
						button.ImageLabel.ImageColor3 = Color3.new(0,0,0)
					end
				else
					button.ImageColor3 = offColor
					if button:FindFirstChild("TextLabel") then
						button.TextLabel.Font = Enum.Font.GothamSemibold
						button.TextLabel.TextColor3 = Color3.new(1,1,1)
					elseif button:FindFirstChild("ImageLabel") then
						button.ImageLabel.ImageColor3 = Color3.new(1,1,1)
					end
				end
			end
		end
	end
end

local function updateSettings()
	for _,s in pairs(CollectionService:GetTagged("HudScale")) do
		s.Scale = 1-(_G.Data.settings.hudSize*0.2)
	end
	Messages:send("MusicVolume",_G.Data.settings.musicVolume)
	UiState.Hotkeys.Visible = _G.Data.settings.inputTips == 1
	if InputData.inputType == "Touch" then UiState.Hotkeys.Visible = false end
	for _,f in pairs(Settings.window.settings1:GetChildren()) do
		if f:IsA("Frame") and f.Name ~= "toolorder" then
			updateButtonSettings(f)
		end
	end
	for _,f in pairs(Settings.window.settings2:GetChildren()) do
		if f:IsA("Frame") then
			updateButtonSettings(f)
		end
	end
	updateTools()
end

local function setupButtons()
	Settings.window:WaitForChild("settings1"):WaitForChild("toolorder"):WaitForChild("Frame"):WaitForChild("edit")
	local toolbutton = Settings.window.settings1.toolorder.Frame.edit
	toolbutton.MouseEnter:Connect(function()
		UiState.Sounds.Select:Play()
		toolbutton.TextLabel.TextTransparency = 0.4
	end)
	toolbutton.MouseLeave:Connect(function()
		toolbutton.TextLabel.TextTransparency = 0
	end)
	toolbutton.MouseButton1Down:Connect(function()
		UiState.Sounds.Click:Play()
		toolbutton.TextLabel.TextTransparency = 0
	end)
	toolbutton.MouseButton1Up:Connect(function()
		toolbutton.TextLabel.TextTransparency = 0.4
	end)
	toolbutton.Activated:Connect(function()
		Messages:send("OpenWindow","ToolSlotWindow")
	end)
	for _,f in pairs(Settings.window.settings1:GetChildren()) do
		if f:IsA("Frame") and f.Name ~= "toolorder" then
			for _,b in pairs(f.Frame:GetChildren()) do
				if b:IsA("ImageButton") then
					b.MouseEnter:Connect(function()
						UiState.Sounds.Select:Play()
						if b:FindFirstChild("TextLabel") then b.TextLabel.TextTransparency = 0.4 end
					end)
					b.MouseLeave:Connect(function()
						if b:FindFirstChild("TextLabel") then b.TextLabel.TextTransparency = 0 end
					end)
					b.MouseButton1Down:Connect(function()
						UiState.Sounds.Click:Play()
						if b:FindFirstChild("TextLabel") then b.TextLabel.TextTransparency = 0 end
					end)
					b.MouseButton1Up:Connect(function()
						if b:FindFirstChild("TextLabel") then b.TextLabel.TextTransparency = 0.4 end
					end)
					b.Activated:Connect(function()
						if b:FindFirstChild("Value") then
							Messages:sendServer("ChangeSetting",b.Parent.Parent.Name,b.Value.Value)
						end
						if b.Name == "afkOn" then
							Messages:sendServer("SetAfk",true)
						end
						if b.Name == "afkOff" then
							Messages:sendServer("SetAfk",false)
						end
					end)
				end
			end
		end
	end
	for _,f in pairs(Settings.window.settings2:GetChildren()) do
		if f:IsA("Frame") then
			for _,b in pairs(f.Frame:GetChildren()) do
				if b:IsA("ImageButton") then
					b.MouseEnter:Connect(function()
						UiState.Sounds.Select:Play()
						b.TextLabel.TextTransparency = 0.4
					end)
					b.MouseLeave:Connect(function()
						b.TextLabel.TextTransparency = 0
					end)
					b.MouseButton1Down:Connect(function()
						UiState.Sounds.Click:Play()
						b.TextLabel.TextTransparency = 0
					end)
					b.MouseButton1Up:Connect(function()
						b.TextLabel.TextTransparency = 0.4
					end)
					b.Activated:Connect(function()
						if b:FindFirstChild("Value") then
							Messages:sendServer("ChangeSetting",b.Parent.Parent.Name,b.Value.Value)
						end
					end)
				end
			end
		end
	end
end

function Settings:start()
	Settings.window = UiState:GetElement("Settings_Main")
	Settings.window:WaitForChild("settings2")
	Settings.window:WaitForChild("settings1"):WaitForChild("toolorder"):WaitForChild("Frame"):WaitForChild("edit")
	Settings.tools = UiState:GetElement("ToolSlotWindow")
	Settings.ErrorMsg = UiState:GetElement("SettingsError")
	repeat wait() until _G.Data

	setupButtons()
	setupTools()
	updateSettings()

	Messages:hook("SettingsChanged",function()
		updateSettings()
		updateTools()
	end)

	Messages:hook("OpenWindow",function(name)
		if name == Settings.window.Name then
			updateSettings()
			if InputData.inputType == "Gamepad" then
				GuiService.SelectedObject = Settings.window.settings1.toolorder.Frame.edit
			else
				GuiService.SelectedObject = nil
			end
			Messages:send("ChangeMenuBG",Color3.fromRGB(103, 75, 155))
		end
		if name == Settings.tools.Name then
			if InputData.inputType == "Gamepad" then
				GuiService.SelectedObject = Settings.tools.Slots.ROCKET.Image.Button
			else
				GuiService.SelectedObject = nil
			end
		end
	end)

	Messages:hook("OnWindowClosed",function(name)
		if isThisTopWindow() then
			if InputData.inputType == "Gamepad" then
				GuiService.SelectedObject = Settings.window.settings1.toolorder.Frame.edit
			else
				GuiService.SelectedObject = nil
			end
		end
	end)

	Messages:hook("SettingsError",function(message)
		Settings.ErrorMsg.TextLabel.Text = message
		Settings.ErrorMsg.Visible = true
		FastSpawn(function()
			wait(3)
			Settings.ErrorMsg.Visible = false
		end)
		if isThisTopWindow() then
			UiState.Sounds.Error:Play()
		end
	end)

	GuiService:AddSelectionParent("Settings",Settings.window)
	GuiService:AddSelectionParent("ToolSlots",Settings.tools:WaitForChild("Slots"))

	Messages:hook("CharacterAdded",function()
		updateSettings()
		Messages:send("MusicVolume",_G.Data.settings.musicVolume)
	end)

	if _G.Data.settings["musicVolume"] == nil then
		Messages:sendServer("ChangeSetting","musicVolume",35)
		Messages:send("MusicVolume",_G.Data.settings.musicVolume)
	end

end

return Settings
