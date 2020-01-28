local import = require(game.ReplicatedStorage.Shared.Import)
local GuiService = game:GetService("GuiService")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Messages = import "Shared/Utils/Messages"
local Buttons = import "UI/Elements/Buttons"
local UiState= import "UI/UiState"
local Styles = import "UI/Styles"
local InputData = import "Client/Data/InputData"

local ContextActionService = game:GetService("ContextActionService")

local Window = {}
local Windows = import "UI/Elements/Windows"

Window.windows = {}

local player = game.Players.LocalPlayer

local function SetupWindow(window)
	if not window:isDescendantOf(player.PlayerGui) then return end
	if Window.windows[window.Name] then return end
	local newWindow = Windows.new(window)
	newWindow:spawn()
	Window.windows[newWindow.name] = newWindow
	--table.insert(Window.Windows,window.Name,newWindow)
end

local noClutterWindows = {["Inventory_Main"]=true,["Shop_Main"]=true,["TasksWindow"]=true,
							["Settings_Main"]=true,["VoteFrame"]=true,["Log_Main"]=true,}
local ShowTopBar = {["Inventory_Main"]=true,["Shop_Main"]=true,["Shop_YesNo"]=true,
							["GotItemFrame"]=true,["TasksWindow"]=true,["Settings_Main"]=true,["Log_Main"]=true,}
local ShowChat = {["VoteFrame"]=true}
local ShowSidebar = {["VoteFrame"]=true}
local function updateWindows()
	local noClutter = false
	local showTopBar = false
	local showChat = true
	local showSidebar = true
	for _,window in pairs(UiState.openWindows) do
		if noClutterWindows[window] then
			noClutter = true
			showSidebar = false
			showChat = false
		end
		if ShowTopBar[window] then
			showTopBar = true
		end
	end
	for _,window in pairs(UiState.openWindows) do
		if ShowChat[window] then
			showChat = true
		end
		if ShowSidebar[window] then
			showSidebar = true
		end
	end
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, not noClutter)
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, showChat)
	game.Lighting.MenuCC.Enabled = noClutter
	game.Lighting.MenuBlur.Enabled = noClutter
	UiState.Hud.Enabled = not noClutter
	UiState.Toolbar.Enabled = not noClutter
	UiState.Sidebar.Parent.Enabled = showSidebar
	if showTopBar then
		if UiState.topbarOn then return end
		UiState.topbarOn = true
		UiState.TopBar.Visible = true
	else
		if not UiState.topbarOn then return end
		UiState.topbarOn = false
		UiState.TopBar.Visible = false
	end
	if #UiState.openWindows == 0 then
		if InputData.inputType == "Gamepad" then
			GuiService.SelectedObject = nil
			UserInputService.MouseIconEnabled = true
		end
		ContextActionService:BindActivate(Enum.UserInputType.Gamepad1,Enum.KeyCode.ButtonR2)
	else
		if InputData.inputType == "Gamepad" then
			UserInputService.MouseIconEnabled = false
		end
		ContextActionService:BindActivate(Enum.UserInputType.Gamepad1,Enum.KeyCode.Comma)
	end
	Messages:send("WindowsChanged")
end

function Window:back()
	if UiState.openWindows[1] then
		Messages:send("CloseWindow",UiState.openWindows[1])
	end
	if not UiState.openWindows[1] then
		if InputData.inputType == "Gamepad" then
			UserInputService.MouseIconEnabled = true
		end
	end
end

function Window:start()
	for _,i in pairs(CollectionService:GetTagged("UiWindow")) do
		SetupWindow(i)
	end
	CollectionService:GetInstanceAddedSignal("UiWindow"):Connect(SetupWindow)
	Messages:hook("OnWindowOpenedInitial",function(name,openUnder)
		for n,window in pairs(UiState.openWindows) do
			if name == window then
				table.remove(UiState.openWindows,n)
			end
		end
		for _,window in pairs(Window.windows) do
			if window.name == name then
				table.insert(UiState.openWindows,openUnder and #UiState.openWindows+1 or 1,window.name)
			end
		end
		updateWindows()
		Messages:send("OnWindowOpened",name)
	end)
	Messages:hook("OnWindowClosedInitial",function(name)
		for n,window in pairs(UiState.openWindows) do
			if name == window then
				table.remove(UiState.openWindows,n)
			end
		end
		updateWindows()
		Messages:send("OnWindowClosed",name)
	end)
	Messages:hook("OpenCloseWindow",function(name)
		for _,w in pairs(Window.windows) do
			if name == w.name then
				if w.opened == false then
					w:open()
				else
					w:close()
				end
			end
		end
	end)
	Messages:hook("OpenWindow",function(name)
		for _,w in pairs(Window.windows) do
			if name == w.name then
				w:open()
			end
		end
	end)
	Messages:hook("OpenWindowUnder",function(name)
		for _,w in pairs(Window.windows) do
			if name == w.name then
				w:open(true)
			end
		end
	end)
	Messages:hook("CloseWindow",function(name)
		for _,w in pairs(Window.windows) do
			if name == w.name then
				w:close()
			end
		end
	end)
	Messages:hook("CloseAllWindows",function(name)
		for _,w in pairs(Window.windows) do
			if w.opened == true then
				w:close()
			end
		end
	end)

	Messages:hook("ChangeMenuBG",function(color)
		local tweenInfo = TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
		local tween = TweenService:Create(game.Lighting.MenuCC,tweenInfo,{TintColor = color})
		tween:Play()
	end)

	ContextActionService:BindAction("BACK",function(actionName, inputState, inputObject)
		if inputState ~= Enum.UserInputState.Begin then return end
		Window:back()
	end, false, Enum.KeyCode.Backspace, Enum.KeyCode.ButtonB)
end

return Window
