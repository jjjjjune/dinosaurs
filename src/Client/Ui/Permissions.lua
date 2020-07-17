local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local GetDevice = import "Shared/Utils/GetDevice"
local BoundMenu = import "Shared/Utils/BoundMenu"

local ContextActionService = game:GetService("ContextActionService")

local PermissionsConstants = import "Shared/Data/PermissionsConstants"

local PermissionsUi = game.Players.LocalPlayer.PlayerGui:WaitForChild("Permissions"):WaitForChild("Background")

local permissionsBoundMenu
local selectedButton

local buttons = {}

local selectedRank = "Guest"
local section = "Players"

local function setPermissionValue(rank, permission, value)
	local rankPermissions = _G.replicatedServerData.permissions
	rankPermissions[rank][permission] = value
end

local function getRankIndex(rank)
	local index
	for i, v in pairs(PermissionsConstants.RANKS) do
		if v == rank then
			index = i
			break
		end
	end
	return index
end

local function canPromoteToRank(rank)
	local rankPermissions = _G.replicatedServerData.permissions
	local ranks = _G.replicatedServerData.ranks
	local myRank = ranks[tostring(game.Players.LocalPlayer.UserId)] or PermissionsConstants.RANKS[1]
	local myPermissions = rankPermissions[myRank]
	if myPermissions["can promote lower ranks"] then
		local myRankIndex = getRankIndex(myRank)
		local theirRankIndex = getRankIndex(rank)
		if myRankIndex > theirRankIndex then
			return true
		end
	end
	return false
end

local function setPlayerRank(player, rank)
	local ranks = _G.replicatedServerData.ranks
	ranks[tostring(player.UserId)] = rank
end

local function destroyAllFrames()
	for _, v in pairs(PermissionsUi.ScrollFrameContainer.ScrollingFrame:GetChildren()) do
		if v:IsA("Frame") then
			if v.Visible == true then
				v:Destroy()
			end
		end
	end
end

local function openPlayersSection()
	destroyAllFrames()

	PermissionsUi.PlayersButton.ImageColor3 = Color3.fromRGB(189, 128, 63)
	PermissionsUi.SettingsButton.ImageColor3 = Color3.fromRGB(255, 174, 85)

	section = "Players"

	buttons = {}

	local totalSizeY = 0

	local ranks = _G.replicatedServerData.ranks

	for _, player in pairs(game.Players:GetPlayers()) do

		local label = PermissionsUi.ScrollFrameContainer.ScrollingFrame.LabelMultipleOptionFrame:Clone()
		label.Parent = PermissionsUi.ScrollFrameContainer.ScrollingFrame
		label.Visible = true
		label.TextBG.TextFG.Title.Text = player.Name
		label.TextBG.TextFG.TitleShadow.Text = player.Name

		table.insert(buttons, label.OptionFrameBG.LabelFG.Left.Button)

		table.insert(buttons, label.OptionFrameBG.LabelFG.Right.Button)

		totalSizeY = totalSizeY + label.AbsoluteSize.Y * 1.2

		local currentRank = PermissionsConstants.RANKS[1]

		if ranks[tostring(player.UserId)] then
			currentRank = ranks[tostring(player.UserId)]
		end

		Messages:send("RegisterMultipleOption", label.OptionFrameBG, PermissionsConstants.RANKS, function(rank)
			if player == game.Players.LocalPlayer then
				return false
			end
			if canPromoteToRank(rank) then
				setPlayerRank(player, rank)
				return true
			else
				return false
			end
		end, currentRank)
	end
	PermissionsUi.ScrollFrameContainer.ScrollingFrame.CanvasSize = UDim2.new(0,0,0,totalSizeY)

	if permissionsBoundMenu then
		permissionsBoundMenu:LoadObjects(buttons)
		permissionsBoundMenu:SetSelection(buttons[1])
	end
end

local function openSettingsSection()
	destroyAllFrames()

	PermissionsUi.SettingsButton.ImageColor3 = Color3.fromRGB(189, 128, 63)
	PermissionsUi.PlayersButton.ImageColor3 = Color3.fromRGB(255, 174, 85)

	section = "Settings"

	buttons = {}

	local rankChoice = PermissionsUi.ScrollFrameContainer.ScrollingFrame.MultipleOptionFrame:Clone()
	rankChoice.OptionFrameBG.LabelFG.Title.Text = selectedRank
	rankChoice.Parent = PermissionsUi.ScrollFrameContainer.ScrollingFrame
	rankChoice.Visible = true

	table.insert(buttons, rankChoice.OptionFrameBG.LabelFG.Left.Button)
	table.insert(buttons, rankChoice.OptionFrameBG.LabelFG.Right.Button)

	local previousRankStuff = {}

	local ranks = _G.replicatedServerData.ranks
	local myRank = ranks[tostring(game.Players.LocalPlayer.UserId)] or PermissionsConstants.RANKS[1]

	local readOnly = false

	if myRank ~= PermissionsConstants.RANKS[#PermissionsConstants.RANKS] then
		readOnly = true
	end

	local function displaySettings(rank)
		local totalSizeY = rankChoice.AbsoluteSize.Y * 1.2
		selectedRank = rank

		local rankPermissions = _G.replicatedServerData.permissions

		for permissionName, permissionValue in pairs(rankPermissions[selectedRank]) do
			if type(permissionValue) == "boolean" then

				local permissionFrame = PermissionsUi.ScrollFrameContainer.ScrollingFrame.CheckboxOptionFrame:Clone()
				permissionFrame.Visible = true
				permissionFrame.Parent = PermissionsUi.ScrollFrameContainer.ScrollingFrame
				permissionFrame.LabelBG.LabelFG.Title.Text = permissionName

				if permissionValue == true then
					permissionFrame.CheckboxBG.CheckboxFG.Checkmark.Visible = true
				else
					permissionFrame.CheckboxBG.CheckboxFG.Checkmark.Visible = false
				end

				Messages:send("RegisterCheckbox", permissionFrame.CheckboxBG, function(value)
					setPermissionValue(selectedRank, permissionName, value)
				end, permissionValue, readOnly)

				table.insert(previousRankStuff, permissionFrame)

				table.insert(buttons, permissionFrame.CheckboxBG.CheckboxFG.Button)

				totalSizeY = totalSizeY + permissionFrame.AbsoluteSize.Y * 1.2
			elseif type(permissionValue) == "number" then
				local permissionFrame = PermissionsUi.ScrollFrameContainer.ScrollingFrame.LabelOptionFrame:Clone()
				permissionFrame.Visible = true
				permissionFrame.Parent = PermissionsUi.ScrollFrameContainer.ScrollingFrame
				permissionFrame.LabelBG.LabelFG.Title.Text = permissionName
				permissionFrame.BoxBG.BoxFG.TextBox.Text = tostring(permissionValue)

				Messages:send("RegisterLabel", permissionFrame.BoxBG.BoxFG.TextBox, function(value)
					setPermissionValue(selectedRank, permissionName, tonumber(value))
				end, permissionValue, readOnly)

				table.insert(previousRankStuff, permissionFrame)

				table.insert(buttons, permissionFrame.BoxBG.BoxFG.TextBox)

				totalSizeY = totalSizeY + permissionFrame.AbsoluteSize.Y * 1.2
			end
		end
		PermissionsUi.ScrollFrameContainer.ScrollingFrame.CanvasSize = UDim2.new(0,0,0,totalSizeY)


	end

	displaySettings(selectedRank)

	Messages:send("RegisterMultipleOption", rankChoice.OptionFrameBG, PermissionsConstants.RANKS, function(rank)
		for i, v in pairs(previousRankStuff) do
			v:Destroy()
			previousRankStuff[i] = nil
		end
		displaySettings(rank)
		return true
	end, selectedRank)

	if permissionsBoundMenu then
		permissionsBoundMenu:LoadObjects(buttons)
		permissionsBoundMenu:SetSelection(buttons[1])
	end
end

local function closePermissions()
	if permissionsBoundMenu then
		permissionsBoundMenu:Destroy()
		permissionsBoundMenu = nil
	end

	Messages:send("PlaySoundOnClient",{
		instance = game.ReplicatedStorage.Sounds.NewUITwoPartClick,
	})

	game:GetService("GuiService").SelectedObject = nil

	PermissionsUi.Visible = false

	ContextActionService:UnbindAction("close menu")
	ContextActionService:UnbindAction("select button")
	ContextActionService:UnbindAction("navigate menu left")
	ContextActionService:UnbindAction("navigate menu right")

	destroyAllFrames()
end

local function selectButton()
	if selectedButton then
		if selectedButton:IsA("ImageButton") or selectedButton:IsA("TextButton") then
			Messages:send("PressButton", selectedButton)
		elseif selectedButton:IsA("TextBox") then
			selectedButton:CaptureFocus()
		end
	end
end

local function openPermissions(section)
	local device = GetDevice()
	if device == "Gamepad" then
		permissionsBoundMenu = BoundMenu.new(buttons)
		permissionsBoundMenu.DirectionThreshold = .9
		permissionsBoundMenu.SelectionChanged:connect(function(oldButton,newButton)
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
	end

	local tabsArray = {
		PermissionsUi.PlayersButton,
		PermissionsUi.SettingsButton,
	}

	local categories = {
		"Players",
		"Settings"
	}

	local tabsArrayIndex = 1

	ContextActionService:BindAction("navigate menu right", function(contextActionName, inputState, inputObject)
		if inputState == Enum.UserInputState.Begin then
			tabsArrayIndex = tabsArrayIndex + 1
			if tabsArrayIndex > #tabsArray then
				tabsArrayIndex = 1
			end
			local category = categories[tabsArrayIndex]
			if category == "Players" then
				openPlayersSection()
			elseif category == "Settings" then
				openSettingsSection()
			end
		end
	end, false, Enum.KeyCode.ButtonR1)

	ContextActionService:BindAction("navigate menu left", function(contextActionName, inputState, inputObject)
		if inputState == Enum.UserInputState.Begin then
			tabsArrayIndex = tabsArrayIndex - 1
			if tabsArrayIndex < 1 then
				tabsArrayIndex = #tabsArray
			end
			local category = categories[tabsArrayIndex]
			if category == "Players" then
				openPlayersSection()
			elseif category == "Settings" then
				openSettingsSection()
			end
		end
	end, false, Enum.KeyCode.ButtonL1)

	ContextActionService:BindAction("close menu", function(contextActionName, inputState, inputObject)
		if inputState == Enum.UserInputState.Begin then
			closePermissions()
		end
	end, false, Enum.KeyCode.ButtonB)

	ContextActionService:BindAction("select button", function(contextActionName, inputState, inputObject)
		if inputState == Enum.UserInputState.Begin then
			selectButton()
		end
	end, false, Enum.KeyCode.ButtonA)

	PermissionsUi.Visible = true

	Messages:send("PlaySoundOnClient",{
		instance = game.ReplicatedStorage.Sounds.NewUIClickHigh,
	})

	if section == "Players" then
		openPlayersSection()
	else
		openSettingsSection()
	end
end

local Permissions = {}

function Permissions:start()
	Messages:hook("OpenPermissions", openPermissions)
	Messages:send("RegisterButton", PermissionsUi.CloseButton, PermissionsUi.CloseButtonShadow, closePermissions)
	Messages:send("RegisterButton", PermissionsUi.PlayersButton, PermissionsUi.PlayersButtonBG, function()
		openPermissions("Players")
	end)
	Messages:send("RegisterButton", PermissionsUi.SettingsButton, PermissionsUi.SettingsButtonBG, function()
		openPermissions("Settings")
	end)

	delay(3, function()
		openPermissions("Players")
	end)

	game.Players.PlayerAdded:connect(function(player)
		if PermissionsUi.Visible == true then
			if section == "Players" then
				openPermissions("Players")
			end
		end
	end)
end

return Permissions
