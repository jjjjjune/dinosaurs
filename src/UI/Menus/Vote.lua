local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Buttons = import "UI/Elements/Buttons"
local UiState= import "UI/UiState"
local InputData = import "Client/Data/InputData"
local GamemodeData = import "Shared/Data/GamemodeData"

local FastSpawn = import "Shared/Utils/FastSpawn"

local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local update = nil

local Vote = {}

Vote.stickyButton = nil

local function isThisTopWindow()
	return UiState.openWindows[1] == "VoteFrame"
end

local function Mode()
	Vote.Title.Text = "Vote for a gamemode!"
	if Vote.Window.Visible then UiState.Sounds.vote1:Play() end
	if update then update:Disconnect() end

	Vote.Window.Mode.Position = UDim2.new(1.5,0,0.5,0)
	Vote.Window.Mode:TweenPosition(UDim2.new(0.5,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,1,true)
	Vote.Window.ModeSelected.Position = UDim2.new(1.5,0,0.5,0)
	Vote.Window.ModeSelected.Visible = false
	Vote.Window.Map.Visible = false
	Vote.Window.Map.Position = UDim2.new(1.5,0,0.5,0)
	Vote.Window.Mode.Visible = true
	local window = Vote.Window.Mode.Main.modes
	local window2 = Vote.Window.Mode.Special.modes
	if not Vote.modeSetup then
		Vote.modeSetup = true
		Vote.modeButtons = {}
		for _,v in pairs(Vote.Folder.Gamemode:GetChildren()) do
			local vote = Vote.modeRef:Clone()
			vote.Name = v.Name
			vote.name.Text = GamemodeData.Gamemodes[v.Name].Name
			vote.Icon.Image = GamemodeData.Gamemodes[v.Name].Icon
			vote.Icon.ImageRectSize = Vector2.new(300,300)
			vote.Icon.ImageRectOffset = GamemodeData.Gamemodes[v.Name].Offset*300
			vote.MouseEnter:Connect(function()
				vote.ImageColor3 = Color3.new(0.8,0.8,0.8)
				UiState.Sounds.Select:Play()
			end)
			vote.MouseLeave:Connect(function()
				vote.ImageColor3 = Color3.new(1,1,1)
			end)
			vote.MouseButton1Down:Connect(function()
				vote.ImageColor3 = Color3.new(0.6,0.6,0.6)
				vote.Icon:TweenSize(UDim2.new(0.75,0,0.75,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true)
			end)
			vote.MouseButton1Up:Connect(function()
				vote.ImageColor3 = Color3.new(0.6,0.6,0.6)
				vote.Icon:TweenSize(UDim2.new(0.85,0,0.85,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true)
			end)
			vote.Activated:Connect(function()
				UiState.Sounds.Click:Play()
				Messages:sendServer("GamemodeVote",v.Name)
				vote.ImageColor3 = Color3.new(1,1,1)
			end)
			vote.LayoutOrder = GamemodeData.Gamemodes[v.Name].Order
			if GamemodeData.Gamemodes[v.Name].new then
				vote.NEW.Visible = true
			end
			vote.Parent = GamemodeData.Gamemodes[v.Name].Type == "Basic" and window or window2
			table.insert(Vote.modeButtons,#Vote.modeButtons+1,vote)
		end
	end

	if InputData.inputType == "Gamepad" then
		Vote.stickyButton = nil
		if isThisTopWindow() then
			GuiService.SelectedObject = nil
		end
		FastSpawn(function()
			wait(1)
			Vote.stickyButton = Vote.modeButtons[1]
			if isThisTopWindow() then
				GuiService.SelectedObject = Vote.modeButtons[1]
			end
		end)
	end

	for _,button in pairs(Vote.modeButtons) do
		if Vote.Folder.lastMode and Vote.Folder.lastMode.Value == button.Name
		and not GamemodeData.Gamemodes[button.Name].canRevote then
			button.Visible = false
		else
			button.Visible = true
		end
	end

	update = RunService.Stepped:Connect(function()
		for _,button in pairs(Vote.modeButtons) do
			local obj = Vote.Folder.Gamemode:FindFirstChild(button.Name)
			local pin = button.pin
			if obj and obj:FindFirstChild("Votes") then
				local votes = #obj.Votes:GetChildren()
				if votes ~= button.votes.Value then
					if votes > button.votes.Value then
						for _=1,votes-button.votes.Value do
							local newPin = pin:Clone()
							newPin.Visible = true
							newPin.pin.ImageColor3 = Color3.fromHSV(math.random(),1,1)
							newPin.Parent = button.voters
							newPin.pin.Position = UDim2.new(0.5,0,0.3,0)
							newPin.pin:TweenPosition(UDim2.new(0.5,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.33,true)
						end
					elseif votes < button.votes.Value then
						for _=1,button.votes.Value-votes do
							local diePin = button.voters:FindFirstChild("pin")
							if diePin then diePin:Destroy() end
						end
					end
					button.votes.Value = votes
				end
			end
		end
	end)

end

local function Map()
	if Vote.Window.Visible then UiState.Sounds.vote3:Play() end
	Vote.Title.Text = "Vote for a map!"
	if update then update:Disconnect() end

	Vote.Window.Mode.Visible = false
	Vote.Window.Map.Visible = true
	Vote.Window.ModeSelected:TweenPosition(UDim2.new(-1.5,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,1,true)
	Vote.Window.Map:TweenPosition(UDim2.new(0.5,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,1,true)
	local window = Vote.Window.Map
	for _,i in pairs(window.maps:GetChildren()) do
		if i:IsA("ImageButton") then i:Destroy() end
	end

	local buttons = {}

	for _,v in pairs(Vote.Folder.Map:GetChildren()) do
		local vote = Vote.mapRef:Clone()
		vote.Name = v.Name
		vote.name.Text = GamemodeData.Maps[v.Name].Name
		vote.Icon.Image = GamemodeData.Maps[v.Name].Icon

		vote.MouseEnter:Connect(function()
			vote.ImageColor3 = Color3.new(0.8,0.8,0.8)
			UiState.Sounds.Select:Play()
		end)
		vote.MouseLeave:Connect(function()
			vote.ImageColor3 = Color3.new(1,1,1)
		end)
		vote.MouseButton1Down:Connect(function()
			vote.ImageColor3 = Color3.new(0.6,0.6,0.6)
			vote.Icon:TweenSize(UDim2.new(0.75,0,0.75,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true)
		end)
		vote.MouseButton1Up:Connect(function()
			vote.ImageColor3 = Color3.new(0.6,0.6,0.6)
			vote.Icon:TweenSize(UDim2.new(0.85,0,0.85,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true)
		end)
		vote.Activated:Connect(function()
			UiState.Sounds.Click:Play()
			Messages:sendServer("MapVote",v.Name)
			vote.ImageColor3 = Color3.new(1,1,1)
		end)

		vote.Parent = window.maps
		table.insert(buttons,#buttons+1,vote)
	end

	if InputData.inputType == "Gamepad" then
		if isThisTopWindow() then
			GuiService.SelectedObject = nil
		end
		Vote.stickyButton = nil
		FastSpawn(function()
			wait(1)
			Vote.stickyButton = buttons[1]
			if isThisTopWindow() then
				GuiService.SelectedObject = buttons[1]
			end
		end)
	end

	for _,button in pairs(buttons) do
		if Vote.Folder.lastMap and Vote.Folder.lastMap.Value == button.Name
		and not GamemodeData.Maps[button.Name].canRevote then
			button.Visible = false
		else
			button.Visible = true
		end
	end

	update = RunService.Stepped:Connect(function()
		for _,button in pairs(buttons) do
			local obj = Vote.Folder.Map:FindFirstChild(button.Name)
			local pin = button.pin
			if obj and obj:FindFirstChild("Votes") then
				local votes = #obj.Votes:GetChildren()
				if votes ~= button.votes.Value then
					if votes > button.votes.Value then
						for _=1,votes-button.votes.Value do
							local newPin = pin:Clone()
							newPin.Visible = true
							newPin.pin.ImageColor3 = Color3.fromHSV(math.random(),1,1)
							newPin.Parent = button.voters
							newPin.pin.Position = UDim2.new(0.5,0,0.3,0)
							newPin.pin:TweenPosition(UDim2.new(0.5,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.33,true)
						end
					elseif votes < button.votes.Value then
						for _=1,button.votes.Value-votes do
							local diePin = button.voters:FindFirstChild("pin")
							if diePin then diePin:Destroy() end
						end
					end
					button.votes.Value = votes
				end
			end
		end
	end)
end

local function ModeSelected(mode)
	if Vote.Window.Visible then UiState.Sounds.vote2:Play() end
	Vote.Title.Text = "Gamemode selected!"
	Vote.Window.ModeSelected.Visible = true
	Vote.Window.Map.Visible = false
	Vote.Window.Mode:TweenPosition(UDim2.new(-1.5,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,1,true)
	local window = Vote.Window.ModeSelected
	window:TweenPosition(UDim2.new(0.5,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,1,true)
	window.name.TextLabel.Text = GamemodeData.Gamemodes[mode].Name
	window.mode.Icon.Image = GamemodeData.Gamemodes[mode].Icon
	window.mode.Icon.ImageRectSize = Vector2.new(300,300)
	window.mode.Icon.ImageRectOffset = GamemodeData.Gamemodes[mode].Offset*300
	Vote.Window.Map.Mode.Icon.Image = GamemodeData.Gamemodes[mode].Icon
	Vote.Window.Map.Mode.Icon.ImageRectSize = Vector2.new(300,300)
	Vote.Window.Map.Mode.Icon.ImageRectOffset = GamemodeData.Gamemodes[mode].Offset*300
	if update then update:Disconnect() end
	if InputData.inputType == "Gamepad" then
		Vote.stickyButton = nil
		if isThisTopWindow() then
			GuiService.SelectedObject = nil
		end
	end
end

local function readyToVote()
	if not workspace:FindFirstChild("SpectateZone") then return nil end
	if not workspace.SpectateZone:FindFirstChild("Voting") then return nil end
	if not workspace.SpectateZone.Voting:FindFirstChild("Gamemode") then return nil end
	if not workspace.SpectateZone.Voting:FindFirstChild("Map") then return nil end
	Vote.Folder = workspace.SpectateZone.Voting
	return true
end

local function doTimer(voteTime)
	Vote.Timer.bar.Frame.Size = UDim2.new(1,0,1,0)
	Vote.Timer.bar.Frame:TweenSize(UDim2.new(0,0,1,0),Enum.EasingDirection.Out,Enum.EasingStyle.Linear,voteTime-0.25,true)
end

function Vote:start()
	local player = game.Players.LocalPlayer
	Vote.Window = UiState:GetElement("VoteFrame")
	Vote.Timer = Vote.Window:WaitForChild("timer")
	Vote.Title = Vote.Window:WaitForChild("TextLabel")
	Vote.modeRef = UiState:GetElement("modeVote")
	Vote.mapRef = UiState:GetElement("mapVote")
	Vote.modeSetup = false
	readyToVote()

	GuiService:AddSelectionParent("ModeVote",Vote.Window:WaitForChild("Mode"))
	GuiService:AddSelectionParent("MapVote",Vote.Window:WaitForChild("Map"))

	Messages:hook("GamemodeVote",function(voteTime)
		if not readyToVote() then return end
		if CollectionService:HasTag(player,"Afk") then return end
		Messages:send("OpenWindowUnder","VoteFrame")
		doTimer(voteTime)
		Mode()
	end)

	Messages:hook("GamemodeSet",function(mode)
		if not readyToVote() then return end
		ModeSelected(mode)
	end)

	Messages:hook("MapVote",function(voteTime)
		if not readyToVote() then return end
		doTimer(voteTime)
		Map()
	end)

	Messages:hook("OnWindowClosed",function(name)
		if isThisTopWindow() and InputData.inputType == "Gamepad" and Vote.stickyButton then
			GuiService.SelectedObject = Vote.stickyButton
		end
	end)

	Messages:hook("VoteEnd",function()
		if update then update:Disconnect() end
		if not readyToVote() then return end
		Messages:send("CloseWindow","VoteFrame")
	end)

end

return Vote
