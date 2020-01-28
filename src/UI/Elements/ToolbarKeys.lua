local import = require(game.ReplicatedStorage.Shared.Import)
local UiState = import "UI/UiState"
local Messages = import "Shared/Utils/Messages"
local InputData = import "Client/Data/InputData"

local ToolbarKeys = {}

ToolbarKeys.actionButton = nil

function ToolbarKeys:start()
	local player = game.Players.LocalPlayer
	local Window = UiState.Toolbar:WaitForChild("Hotkeys")

	local TouchActionEvent = Instance.new("BindableEvent")
	TouchActionEvent.Name = "TouchAction"
	TouchActionEvent.Parent = player.PlayerScripts

	Messages:hook("ToolKey",function(actionName,text)
		local frame = Window:FindFirstChild(actionName)
		if frame then
			if text == nil then
				frame.Visible = false
			else
				frame.TextLabel.Text = text
				frame.Visible = true
			end
		end
		if InputData.inputType == "Touch" and actionName == "SpecialAttack" then
			if ToolbarKeys.actionButton == nil then
				local touch=player.PlayerGui:WaitForChild("TouchGui",10)
				touch=touch:WaitForChild("TouchControlFrame",10)
				if touch then
					local j=touch:WaitForChild("JumpButton")
					local a = UiState:GetElement("TouchActionButton"):Clone()
					a.Size=j.Size
					a.Position=j.Position+UDim2.new(0,-j.Size.X.Offset-6,0,0)
					a.Parent = j.Parent
					a.MouseButton1Down:connect(function()
						a.ImageRectOffset=Vector2.new(146,146)
						TouchActionEvent:Fire()
					end)
					a.MouseButton1Up:connect(function()
						a.ImageRectOffset=Vector2.new(1,146)
					end)
					ToolbarKeys.actionButton = a
					ToolbarKeys.actionButton.TextLabel.Text = text
				end
			end
			if ToolbarKeys.actionButton then
				if text ~= nil then
					ToolbarKeys.actionButton.Visible = true
				else
					if ToolbarKeys.actionButton then
						ToolbarKeys.actionButton:Destroy()
						ToolbarKeys.actionButton = nil
					end
				end
			end
		end
	end)
end

return ToolbarKeys
