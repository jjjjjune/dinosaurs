local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local ContextActionService = game:GetService("ContextActionService")
local PermissionsUi = game.Players.LocalPlayer.PlayerGui:WaitForChild("Permissions"):WaitForChild("Background")

local function newPermissions()
	return {
		["can make ropes"] = false,
		["can delete ropes"] = false,
		["can sacrifice items"] = false,
		["can promote lower ranks"] = false,
		["can kick lower ranks"] = false,
		["can ban lower ranks"] = false,
		["can ride other's animals"] = false,
		["can chop down plants"] = false,
		["achievement share"] = 1,
	}
end

local rankPermissions = {
	["Guest"] = newPermissions(),
	["Citizen"] = newPermissions(),
	["Noble"] = newPermissions(),
	["Priest"] = newPermissions(),
	["Leader"] = newPermissions(),
}

local craftBoundMenu
local selectedButton

local selectedRank = "Guest"
local section = "Players"

local function setPermissionValue(rank, permission, value)
	rankPermissions[rank][permission] = value
end

local function setPlayerRank(player, rank)
	print(player, " rank set to ", rank)
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
	section = "Players"

	local totalSizeY = 0

	for _, player in pairs(game.Players:GetPlayers()) do
		local label = PermissionsUi.ScrollFrameContainer.ScrollingFrame.LabelMultipleOptionFrame:Clone()
		label.Parent = PermissionsUi.ScrollFrameContainer.ScrollingFrame
		label.Visible = true
		label.TextBG.TextFG.Title.Text = player.Name
		label.TextBG.TextFG.TitleShadow.Text = player.Name
		totalSizeY = totalSizeY + label.AbsoluteSize.Y * 1.1
		Messages:send("RegisterMultipleOption", label.OptionFrameBG, {"Guest", "Citizen", "Noble", "Priest", "Leader"}, function(rank)
			if rank == "Leader" then
				return false
			else
				setPlayerRank(player, rank)
				return true
			end
		end)
	end
	PermissionsUi.ScrollFrameContainer.ScrollingFrame.CanvasSize = UDim2.new(0,0,0,totalSizeY)
end

local function openSettingsSection(desiredRank)
	section = "Settings"
	selectedRank = desiredRank or selectedRank

	local rankChoice = PermissionsUi.ScrollFrameContainer.ScrollingFrame.MultipleOptionFrame:Clone()
	rankChoice.OptionFrameBG.LabelFG.Title.Text = selectedRank
	rankChoice.Parent = PermissionsUi.ScrollFrameContainer.ScrollingFrame
	rankChoice.Visible = true

	local previousRankStuff = {}

	local totalSizeY = rankChoice.AbsoluteSize.Y *2

	local function displaySettings(rank)
		for i, v in pairs(previousRankStuff) do
			v:Destroy()
			previousRankStuff[i] = nil
		end
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
				end)
				table.insert(previousRankStuff, permissionFrame)
				totalSizeY = totalSizeY + permissionFrame.AbsoluteSize.Y * 2
			elseif type(permissionValue) == "number" then
				local permissionFrame = PermissionsUi.ScrollFrameContainer.ScrollingFrame.LabelOptionFrame:Clone()
				permissionFrame.Visible = true
				permissionFrame.Parent = PermissionsUi.ScrollFrameContainer.ScrollingFrame
				permissionFrame.LabelBG.LabelFG.Title.Text = permissionName
				permissionFrame.BoxBG.BoxFG.TextBox.Text = tostring(permissionValue)
				Messages:send("RegisterLabel", permissionFrame.BoxBG.BoxFG.TextBox, function(value)
					setPermissionValue(selectedRank, permissionName, tonumber(value))
				end)
				table.insert(previousRankStuff, permissionFrame)
				totalSizeY = totalSizeY + permissionFrame.AbsoluteSize.Y * 2
			end
		end
		PermissionsUi.ScrollFrameContainer.ScrollingFrame.CanvasSize = UDim2.new(0,0,0,totalSizeY)
	end

	displaySettings(selectedRank)

	Messages:send("RegisterMultipleOption", rankChoice.OptionFrameBG, {"Guest", "Citizen", "Noble", "Priest", "Leader"}, function(rank)
		displaySettings(rank)
		return true
	end, selectedRank)
end

local function closePermissions()
	if craftBoundMenu then
		craftBoundMenu:Destroy()
		craftBoundMenu = nil
	end

	Messages:send("PlaySoundOnClient",{
		instance = game.ReplicatedStorage.Sounds.NewUITwoPartClick,
	})

	game:GetService("GuiService").SelectedObject = nil

	PermissionsUi.Visible = false

	ContextActionService:UnbindAction("close menu")
	ContextActionService:UnbindAction("select button")

	destroyAllFrames()
end

local function openPermissions(section)
	PermissionsUi.Visible = true

	Messages:send("PlaySoundOnClient",{
		instance = game.ReplicatedStorage.Sounds.NewUIClickHigh,
	})

	destroyAllFrames()

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
	openPermissions("Players")
	game.Players.PlayerAdded:connect(function(player)
		if PermissionsUi.Visible == true then
			if section == "Players" then
				openPermissions("Players")
			end
		end
	end)
end

return Permissions
