local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local CollectionService = game:GetService("CollectionService")

local FastSpawn = import "Shared/Utils/FastSpawn"

local UiState = import "UI/UiState"
local Styles = import "UI/Styles"
local TeamData = import "Shared/Data/TeamData"

local GetKO = {}

function GetKO:start()
	local frame = UiState:GetElement("GetKOFrame")
	local frame2 = UiState:GetElement("GetKOdFrame")
	local open = false
	Messages:hook("OnPlayerGotKill",function(victim,reason)
		if victim == nil then return end
		UiState.Sounds.getKO:Play()
		local name = victim.Name
		frame.victimName.Visible = true
		frame.glow.Visible = true
		frame.victimName.Text = name
		frame.victimName.shadow.Text = name
		frame.victimName.TextColor3 = victim.Team and TeamData[victim.Team.Name].colors.uiBasic or Color3.new(1,1,1)
		frame.victimName.Position = UDim2.new(1,0,0.7,0)
		frame.KO.Size = UDim2.new(0.1,0,0.1,0)
		frame.Visible = true
		frame.KO:TweenSize(UDim2.new(2,0,2,0),Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.6,true)
		frame.victimName:TweenPosition(UDim2.new(1,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.75,true)
		open = true
		FastSpawn(function()
			while open == true do
				frame.KO.ImageRectOffset = Vector2.new(200,0)
				wait(0.6)
				frame.KO.ImageRectOffset = Vector2.new(0,0)
				wait(0.6)
			end
		end)
		FastSpawn(function()
			wait(3)
			if frame.victimName.Text == name then
				frame.victimName.Visible = false
				frame.glow.Visible = false
				frame.KO:TweenSize(UDim2.new(0,0,0,0),Enum.EasingDirection.In,Enum.EasingStyle.Back,0.5,true)
				wait(0.5)
				if frame.victimName.Text == name then
					frame.Visible = false
					open = false
				end
			end
		end)

	end)

	Messages:hook("OnPlayerGotMurdered", function(killer,reason)
		if killer == nil then return end
		frame2.killerName.Visible = true
		frame2.glow.Visible = true
		frame2.TextLabel.Visible = true
		local name = killer.Name
		frame2.killerName.Text = name
		frame2.killerName.shadow.Text = name
		frame2.killerName.TextColor3 = killer.Team and TeamData[killer.Team.Name].colors.uiBasic or Color3.new(1,1,1)
		frame2.Icon.ImageRectOffset = TeamData[killer.Team.Name].iconOffset*300
		frame2.Icon.ImageColor3 = TeamData[killer.Team.Name].colors.brickcolor
		frame2.Icon.Size = UDim2.new(0,0,0,0)
		frame2.Visible = true
		frame2.Icon:TweenSize(UDim2.new(1,0,1,0),Enum.EasingDirection.Out,Enum.EasingStyle.Back,1,true)
		FastSpawn(function()
			wait(3)
			frame2.killerName.Visible = false
			frame2.glow.Visible = false
			frame2.TextLabel.Visible = false
			frame2.Icon:TweenSize(UDim2.new(0,0,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.5,true)
			wait(0.5)
			frame2.Visible = false
		end)
	end)
end

return GetKO
