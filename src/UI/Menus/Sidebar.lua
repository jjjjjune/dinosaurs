local import = require(game.ReplicatedStorage.Shared.Import)
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")

local Messages = import "Shared/Utils/Messages"
local Buttons = import "UI/Elements/Buttons"
local UiState= import "UI/UiState"
local Styles = import "UI/Styles"
local StickerData = import "Shared/Data/StickerData"

local StickerMenu = import "UI/Menus/StickerMenu"


local Sidebar = {}

function Sidebar:start()
	local player = game.Players.LocalPlayer
	local inventoryButton = UiState:GetElement("InventorySidebar")
	local shopButton = UiState:GetElement("ShopSidebar")
	local tasksButton = UiState:GetElement("TasksSidebar")
	local settingsButton = UiState:GetElement("SettingsSidebar")

	local spectateButton = UiState:GetElement("SpectateSidebar")
	Buttons:IconShrinkButton(inventoryButton)
	Buttons:IconShrinkButton(shopButton)
	Buttons:IconShrinkButton(tasksButton)
	Buttons:IconShrinkButton(settingsButton)

	inventoryButton.MouseButton1Click:connect(function()
		UiState.Sounds.MenuOpen:Play()
		Messages:send("OpenWindow","Inventory_Main")
		inventoryButton.icon.Size = UDim2.new(0.6,0,0.6,0)
	end)
	shopButton.MouseButton1Click:connect(function()
		UiState.Sounds.MenuOpen:Play()
		Messages:send("OpenWindow","Shop_Main")
		shopButton.icon.Size = UDim2.new(0.6,0,0.6,0)
	end)
	tasksButton.MouseButton1Click:connect(function()
		UiState.Sounds.MenuOpen:Play()
		Messages:send("OpenWindow","TasksWindow")
		tasksButton.icon.Size = UDim2.new(0.7,0,0.7,0)
	end)
	settingsButton.MouseButton1Click:connect(function()
		UiState.Sounds.MenuOpen:Play()
		Messages:send("OpenWindow","Settings_Main")
		settingsButton.icon.Size = UDim2.new(0.7,0,0.7,0)
	end)

	player.CharacterAdded:Connect(function(char)
		if player.Team == game.Teams.Spectators then
			spectateButton.Visible = true
		else
			spectateButton.Visible = false
		end
	end)
	StickerMenu:start()
end

return Sidebar
