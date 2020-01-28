local import = require(game.ReplicatedStorage.Shared.Import)
local UiState = import "UI/UiState"
local Messages = import "Shared/Utils/Messages"
local InputData = import "Client/Data/InputData"
local InputPrompts = import "Client/Data/InputPrompts"

local FastSpawn = import "Shared/Utils/FastSpawn"

local CollectionService = game:GetService("CollectionService")

local InputIcons = {}

local function updateIcons(inputType)
	for _,icon in pairs(CollectionService:GetTagged("KeyIcon")) do
		if InputData.hotkeys[icon.Name] and InputData.hotkeys[icon.Name][inputType] then
			local iconData = InputPrompts[InputData.hotkeys[icon.Name][inputType]]
			if inputType == "PC" and InputData.mouseLock then
				local tempData = InputData.hotkeys[icon.Name]["MouseLock"]
				if tempData and _G.Data.settings.altSpecial==1 then iconData = InputPrompts[tempData] end
			end
			if not iconData then
				icon.TextLabel.Text = InputData.hotkeys[icon.Name][inputType].Name
				icon.TextLabel.TextColor3 = Color3.fromRGB(60, 60, 60)
				icon.ImageRectOffset = Vector2.new(0,0)
				icon.ImageRectSize = Vector2.new(200,200)
				icon.Visible = true
			else
				icon.TextLabel.Text = iconData.Text or ""
				icon.TextLabel.TextColor3 = iconData.TextColor or Color3.fromRGB(60, 60, 60)
				icon.ImageRectOffset = iconData.Offset and Vector2.new(iconData.Offset.X-1,iconData.Offset.Y-1)*200 or Vector2.new(0,0)
				icon.ImageRectSize = iconData.Size and iconData.Size*200 or Vector2.new(200,200)
				icon.Visible = true
			end
		else
			icon.Visible = false
		end
	end
	for _,frame in pairs(CollectionService:GetTagged("NotVisibleOnTouch")) do
		frame.Visible = inputType ~= "Touch"
	end
	for _,frame in pairs(CollectionService:GetTagged("NotVisibleOnPC")) do
		frame.Visible = inputType ~= "PC"
	end
	for _,frame in pairs(CollectionService:GetTagged("NotVisibleOnGamepad")) do
		frame.Visible = inputType ~= "Gamepad"
	end
	if InputData.inputType == "PC" then
		for _,frame in pairs(CollectionService:GetTagged("NotVisibleOnPC")) do
			frame.Visible = inputType ~= "PC"
		end
	end
	if InputData.inputType == "Touch" then
		for _,frame in pairs(CollectionService:GetTagged("NotVisibleOnTouch")) do
			frame.Visible = inputType ~= "Touch"
		end
	end
	if InputData.inputType == "Gamepad" then
		for _,frame in pairs(CollectionService:GetTagged("NotVisibleOnGamepad")) do
			frame.Visible = inputType ~= "Gamepad"
		end
	end
end

function InputIcons:start()
	Messages:hook("InputTypeChanged",function(name)
		updateIcons(name)
	end)
	Messages:hook("MouseLockChanged",function(value)
		updateIcons(InputData.inputType)
	end)
	FastSpawn(function()
		repeat wait() until InputData.inputType
		wait(0.5)
		updateIcons(InputData.inputType)
	end)
	updateIcons(InputData.inputType)
end

return InputIcons
