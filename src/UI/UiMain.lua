local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"

local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local CollectionService = game:GetService("CollectionService")

local UiState = import "UI/UiState"

local Inventory = import "UI/Menus/Inventory"
local Shop = import "UI/Menus/Shop"
local Window = import "UI/Menus/Window"
local Sidebar = import "UI/Menus/Sidebar"
local BuyConfirm = import "UI/Menus/BuyConfirm"
local GetItem = import "UI/Menus/GetItem"
local Hud = import "UI/Menus/Hud"
local GetKO = import "UI/Elements/GetKO"
local EquipSlot = import "UI/Menus/EquipSlot"
local Notifications = import "UI/Elements/Notifications"
local NavBar = import "UI/Menus/NavBar"
local InputIcons = import "UI/Elements/InputIcons"
local ToolbarKeys = import "UI/Elements/ToolbarKeys"
local RoundStarting = import "UI/Elements/RoundStarting"
local Tasks = import "Client/Systems/Tasks"
local Settings = import "UI/Menus/Settings"
local Music = import "Client/Systems/Music"
local Vote = import "UI/Menus/Vote"
local Logbook = import "UI/Menus/Logbook"
local Tips = import "UI/Elements/Tips"
local Reticles = import "UI/Elements/Reticles"

local FastSpawn = import "Shared/Utils/FastSpawn"

local UiMain = {}

function UiMain:GetElement(name)
	local element = game.Players.LocalPlayer.PlayerGui:FindFirstChild(name,true)
	if not element then
		repeat
			wait()
			element = game.Players.LocalPlayer.PlayerGui:FindFirstChild(name,true)
		until element
	end
	return element
end

function UiMain:start()
	local player = game.Players.LocalPlayer
	--game.StarterGui:SetCoreGuiEnabled("Backpack",false)
	--game.StarterGui:SetCoreGuiEnabled("PlayerList",false)
	FastSpawn(function()
		UiState:start()
		Notifications:start()
		Hud:start()
		Inventory:start()
		Shop:start()
		BuyConfirm:start()
		Window:start()
		Sidebar:start()
		GetItem:start()
		GetKO:start()
		EquipSlot:start()
		NavBar:start()
		InputIcons:start()
		ToolbarKeys:start()
		RoundStarting:start()
		Tasks:start()
		Settings:start()
		Music:start()
		Vote:start()
		Logbook:start()
		Tips:start()
		Reticles:start()
	end)
	GuiService.AutoSelectGuiEnabled = false
	GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(function(obj)
		if obj == nil then return end
		UiState.Sounds.Select:Play()
	end)

	FastSpawn(function()
		local resetBindable = Instance.new("BindableEvent")
		resetBindable.Event:connect(function()
			if player.Character then
				if player.Character:FindFirstChildOfClass("Humanoid") then
					Messages:sendServer("IDied")
					player.Character.Humanoid.Health = 0
					--player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
				end
			end
			repeat
				Messages:sendServer("IDied")
				wait(1)
			until player.Character and player.Character:FindFirstChildOfClass("Humanoid") and player.Character.Humanoid.Health>0
		end)

		local coreCall do
			local MAX_RETRIES = 8

			local StarterGui = game:GetService('StarterGui')
			local RunService = game:GetService('RunService')

			function coreCall(method, ...)
				local result = {}
				for retries = 1, MAX_RETRIES do
					result = {pcall(StarterGui[method], StarterGui, ...)}
					if result[1] then
						break
					end
					RunService.Stepped:Wait()
				end
				return unpack(result)
			end
		end

		coreCall('SetCore', 'ResetButtonCallback', false)
		StarterGui:SetCore("ResetButtonCallback", resetBindable)

		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
		game.Players.LocalPlayer.PlayerGui:SetTopbarTransparency(1)
		StarterGui:SetCoreGuiEnabled("Health",false)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, true)
	end)
end

return UiMain
