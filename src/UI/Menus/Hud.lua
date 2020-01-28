local import = require(game.ReplicatedStorage.Shared.Import)
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local FastSpawn = import "Shared/Utils/FastSpawn"

local Messages = import "Shared/Utils/Messages"
local UiState= import "UI/UiState"
local Input = import "Client/Systems/Input"
local Styles = import "UI/Styles"
local TeamData = import "Shared/Data/TeamData"

local PlayerData = import "Shared/PlayerData"

local Hud = {}
Hud.gui = nil
Hud.player = game.Players.LocalPlayer
Hud.char = nil
Hud.h = nil --humanoid
Hud.crownCache = _G.Data["cash"]
Hud.bricksCache = _G.Data["bricks"]
Hud.towerCache = 0
Hud.timerEnd = 0

local RNG = Random.new()

local function HealthBar()
	local bar = Hud.gui.HPBar.BarFrame.HealthBar
	local healthDanger = false
	bar.BackgroundColor3 = TeamData[Hud.player.Team.Name].colors.uiBasic
	bar.ImageColor3 = TeamData[Hud.player.Team.Name].colors.uiHighlight
	bar.gradient.ImageColor3 = bar.ImageColor3
	bar.Frame.BackgroundColor3 = bar.ImageColor3
	local barPos = bar.Parent.Parent.Position
	local currentHP = Hud.h.Health
	local dmgTweenRot = TweenService:Create(bar.Parent.Parent,TweenInfo.new(0.33,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Rotation=0})

	local function UpdateBar(newHP)
		local tweenTime = 0.5
		bar:TweenSize(UDim2.new(newHP/Hud.h.MaxHealth,0,1,0),Enum.EasingDirection.Out,Enum.EasingStyle.Sine,newHP>=currentHP and tweenTime or tweenTime*.5,true)
		if newHP < currentHP then
			--damaged
			bar.Parent.BackgroundColor3 = Color3.fromRGB(240,0,0)
			bar.Parent.BackgroundTransparency=0.5
			bar.Parent.Parent.Position = UDim2.new(barPos.X.Scale,math.random(-(currentHP-newHP),(currentHP-newHP))*0.2,barPos.Y.Scale,math.random(-(currentHP-newHP),(currentHP-newHP))*0.3)
			bar.Parent.Parent:TweenPosition(barPos,Enum.EasingDirection.Out,Enum.EasingStyle.Elastic,0.3,true)
			local rotDir = math.random()>.5 and 1 or -1
			bar.Parent.Parent.Rotation = (currentHP-newHP)*rotDir*0.15
			local dmgTween = TweenService:Create(bar.Parent,TweenInfo.new(0.4+(currentHP-newHP)*0.02,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.8})
			dmgTween:Play()
			dmgTweenRot:Play()
		end
		if newHP > currentHP then
			--healed
		end
		-- dangerously low on HP, so show a warning
		if newHP <= Hud.h.MaxHealth*0.3 and newHP>0 then
			if healthDanger == false then
				healthDanger = true
				FastSpawn(function()
					repeat
						Hud.gui.WarningHP.Visible = not Hud.gui.WarningHP.Visible
						wait(1.5)
					until healthDanger == false or Hud.h == nil or Hud.h.Health <= 0
					Hud.gui.WarningHP.Visible = false
				end)
			end
		else
			healthDanger = false
			Hud.gui.WarningHP.Visible = false
		end
		currentHP = newHP
	end

	Hud.h.HealthChanged:connect(function(newHP) UpdateBar(newHP) end)
	UpdateBar(Hud.h.Health)
end

local function updatePlayersLeft(num)
	local icon = Hud.gui.TeamPlayers
	icon.Amount.Text = num

	local textTween = TweenService:Create(icon.Amount,TweenInfo.new(2,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{TextColor3 = Color3.new(1,1,1)})

	if num < Hud.playersCache then
		if num~=1 and num~=2 then
			if icon.Visible then
				UiState.Sounds.LoseSpawn:Play()
			end
		else
			if icon.Visible then
				UiState.Sounds.LoseSpawn2:Play()
			end
			icon.Position = UDim2.new(0.89,0,0.6,0)
			icon:TweenPosition(UDim2.new(0.89,0,0.55,0),Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.2,true)
		end
		icon.Amount.Size = UDim2.new(0.6,0,0.65,0)
		icon.Amount.TextColor3 = Color3.new(1,0.2,0.2)
		icon.Amount:TweenSize(UDim2.new(0.45,0,0.45,0),Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.5,true)
		textTween:Play()
	end

	Hud.playersCache = num
end

local function updateTowers()
	local tower = Hud.gui.Tower
	local spawns = CollectionService:GetTagged("Spawn")
	local num = 0
	if Hud.player.Team.Name == "Spectators" then
		tower.Visible = false
		return
	end
	for _,spawn in pairs(spawns) do
		if spawn.TeamColor == Hud.player.TeamColor then
			num = num + 1
		end
	end
	tower.Amount.Text = num

	local textTween = TweenService:Create(tower.Amount,TweenInfo.new(2,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{TextColor3 = Color3.new(1,1,1)})

	if num < Hud.towerCache then
		if num~=1 and num~=2 then
			if Hud.gui.Tower.Visible then
				UiState.Sounds.LoseSpawn:Play()
			end
		else
			if Hud.gui.Tower.Visible then
				UiState.Sounds.LoseSpawn2:Play()
			end
			Hud.gui.Tower.Position = UDim2.new(0.89,0,0.6,0)
			Hud.gui.Tower:TweenPosition(UDim2.new(0.89,0,0.55,0),Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.2,true)
		end
		tower.Amount.Size = UDim2.new(0.6,0,0.65,0)
		tower.Amount.TextColor3 = Color3.new(1,0.2,0.2)
		tower.Amount:TweenSize(UDim2.new(0.45,0,0.45,0),Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.5,true)
		textTween:Play()
	end

	Hud.towerCache = num

	if Hud.towerDanger==false and (num == 1 or num == 2) and tower.Visible then
		Hud.towerDanger = true
		FastSpawn(function()
			repeat
				Hud.gui.WarningTower.Visible = not Hud.gui.WarningTower.Visible
				wait(2)
			until not tower or not tower.Amount or Hud.towerCache == 0 or tower.Visible == false or Hud.h.Health<=0 or Hud.towerCache > 2
				or Hud.player.Team.Name == "Spectators"
			Hud.gui.WarningTower.Visible = false
			Hud.towerDanger = false
		end)
	end
	tower.ImageColor3 = TeamData[Hud.player.Team.Name].colors.brickcolor
end

local function UpdateCrowns(val)
	if Hud.gui == nil then return end
	if Hud.crownsCache == nil then Hud.crownsCache = val end
	local crowns = Hud.gui.Crowns
	local crowns2 = UiState.TopBar.CrownCount.TextLabel
	local colorTween = TweenService:Create(crowns.Amount,TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0.25),
		{TextColor3 = Color3.fromRGB(255, 233, 49)})
	local colorTween2 = TweenService:Create(crowns2,TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0.25),
	{TextColor3 = Color3.fromRGB(255, 233, 49)})
	crowns.Amount.Text = Styles.addComma(val)
	if val ~= Hud.crownsCache then
		if val > Hud.crownsCache then
			crowns.Amount.TextColor3 = Color3.fromRGB(255,255,255)
			crowns2.TextColor3 = crowns.Amount.TextColor3
			crowns.Amount.Position = UDim2.new(0.25,0,0.41,0)
			colorTween:Play() colorTween2:Play()
		else
			crowns.Amount.TextColor3 = Color3.fromRGB(255, 52, 69)
			crowns2.TextColor3 = crowns.Amount.TextColor3
			crowns.Amount.Position = UDim2.new(0.25,0,0.61,0)
			colorTween:Play() colorTween2:Play()
		end
		crowns.Amount:TweenPosition(UDim2.new(0.25,0,0.51,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.25,true)
	end
	Hud.crownsCache = val
end

local function updateBricks(val)
	if Hud.gui == nil then return end
	local bricks = Hud.gui.MyBricks
	bricks.Amount.Text = Styles.addComma(val)
	--value changed, so make the text move!
	if val ~= Hud.bricksCache then
		if val > Hud.bricksCache then
			-- add bricks
			bricks.Amount.Position = UDim2.new(0.4,0,0.4,0)
			bricks.Icon.Size = UDim2.new(0.7,0,0.7,0)
		else
			-- subtract bricks
			bricks.Amount.Position = UDim2.new(0.4,0,0.6,0)
			bricks.Icon.Size = UDim2.new(0.35,0,0.35,0)
		end
		bricks.Amount:TweenPosition(UDim2.new(0.4,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.25,true)
		bricks.Icon:TweenSize(UDim2.new(0.45,0,0.45,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.5,true)
	end
	if val > 0 then
		bricks.Amount.TextColor3 = Styles.colors.bricksColor
	else
		bricks.Amount.TextColor3 = Color3.fromRGB(167, 57, 59)
	end

	Hud.bricksCache = val
end

local brickLoop = nil
local brickQueue = {}
local brickAmt = 0
local lastBrickIn = time()
local soundAlt = false
local iconTween = nil

local function addBricks(amount,color)
	if not iconTween then
		iconTween = TweenService:Create(Hud.gui.MyBricks.Icon,
			TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,1),
			{ImageColor3 = Color3.fromRGB(184, 184, 184)})
	end
	local frame = Hud.gui.MyBricks.Added
	Hud.gui.MyBricks.Amount.Visible = false
	Hud.gui.MyBricks.Amount2.Visible = true
	for i=1,amount do
		local b = frame.brick:Clone()
		b.ImageColor3 = color or Color3.new(0.8,0.8,0.8)
		local colorShift = RNG:NextNumber(-0.1,0.1)
		b.ImageColor3 = Color3.new(b.ImageColor3.r+colorShift,
									b.ImageColor3.g+colorShift,
									b.ImageColor3.b+colorShift)
		b.Position = UDim2.new(RNG:NextNumber(0.1,0.9),0,RNG:NextNumber(0.2,0.8),0)
		b.Size = UDim2.new(0,0,0,0)
		b.Visible = true
		b.Parent = frame
		local rotate = TweenService:Create(b,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out,0,false,RNG:NextNumber(0,0.5)),{Rotation = RNG:NextNumber(-25,25)})
		--brickQueue[b] = time() + 0.3 + (i*0.1) + (brickAmt*0.12) - ((brickAmt>5 and 0.05*brickAmt) or (brickAmt>10 and 0.1*brickAmt) or 0)
		--if brickAmt > 30 then brickQueue[b] = time() + brickAmt*0.001 end
		brickQueue[b] = time() + (i*0.1) + (brickAmt/16) + 0.15
		brickQueue[b] = math.min(time() + 1 + brickAmt*0.01,brickQueue[b])
		brickAmt = brickAmt + 1
		FastSpawn(function()
			wait(0.1)
			if b then
				local size = RNG:NextNumber(0.35,0.5)
				b:TweenSize(UDim2.new(size,0,size,0),Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.15,true)
				rotate:Play()
			end
		end)
	end
	Hud.gui.MyBricks.Amount2.Text = Styles.addComma(Hud.bricksCache - brickAmt)
	if not brickLoop then
		brickLoop = RunService.Stepped:Connect(function()
			for b,t in pairs(brickQueue) do
				if b and time() >= t then
					soundAlt = not soundAlt
					local sound = soundAlt and UiState.Sounds.BrickGet or UiState.Sounds.BrickGet2
					brickQueue[b] = nil
					FastSpawn(function()
						b:TweenSizeAndPosition(UDim2.new(0,0,0,0),UDim2.new(0.31,0,-0.24,0),Enum.EasingDirection.In,Enum.EasingStyle.Back,0.45,true)
						if UiState.Sounds.BrickGet.PlaybackSpeed >= 0.9 then UiState.Sounds.BrickGet.PlaybackSpeed = 0.8 end
						UiState.Sounds.BrickGet.PlaybackSpeed = time()-lastBrickIn<0.5 and
							math.min(0.9,UiState.Sounds.BrickGet.PlaybackSpeed+0.05) or 0.6
						UiState.Sounds.BrickGet2.PlaybackSpeed = UiState.Sounds.BrickGet.PlaybackSpeed
						wait(0.3)
						brickAmt = brickAmt - 1
						iconTween:Cancel()
						Hud.gui.MyBricks.Icon.ImageColor3 = b.ImageColor3
						iconTween:Play()
						Hud.gui.MyBricks.Amount2.Text = Styles.addComma(Hud.bricksCache - brickAmt)
						Hud.gui.MyBricks.Amount2.Position = UDim2.new(0.4,0,0.4,0)
						Hud.gui.MyBricks.Icon.Size = UDim2.new(0.7,0,0.7,0)
						Hud.gui.MyBricks.Amount2:TweenPosition(UDim2.new(0.4,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.25,true)
						Hud.gui.MyBricks.Icon:TweenSize(UDim2.new(0.45,0,0.45,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.5,true)
						if time() - lastBrickIn > 0.05 then
							sound:Play()
						end
						lastBrickIn = time()
						wait(0.2)
						if b then b:Destroy() end
					end)
				end
			end
			if brickAmt == 0 then
				Hud.gui.MyBricks.Amount2.Visible = false
				Hud.gui.MyBricks.Amount.Visible = true
			end
		end)
	end
end

function Hud:setup(char,h)
	if not Hud.gui then Hud.gui = Hud.player.PlayerGui:WaitForChild("Hud"):WaitForChild("HudFrame") end
	if not UiState.TopBar then repeat wait() until UiState.TopBar ~= nil end
	if not _G.Data then repeat wait() until _G.Data end
	Hud.player = game.Players.LocalPlayer
	Hud.char = char
	Hud.h = h
	Hud.gui:WaitForChild("Crowns")
	Hud.gui:WaitForChild("HPBar")
	Hud.gui:WaitForChild("MyBricks")
	Hud.gui:WaitForChild("Tower")
	HealthBar()
	UiState.Sounds.Respawn:Play()
	Hud.crownCache = _G.Data["cash"]
	Hud.bricksCache = _G.Data["bricks"]
	UpdateCrowns(Hud.crownCache)
	updateBricks(Hud.bricksCache)
	Hud.gui.Visible = true
	if Hud.firstSetup == false then
		Hud.gui.Crowns.BuyMore.Activated:Connect(function()
			UiState.Sounds.Click:Play()
			Messages:send("OpenShopTab","Crowns")
		end)
		Hud.gui.Crowns.BuyMore.MouseEnter:Connect(function()
			Hud.gui.Crowns.BuyMore:TweenSize(UDim2.new(0.4,0,0.4,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.25,true)
			UiState.Sounds.Select:Play()
		end)
		Hud.gui.Crowns.BuyMore.MouseLeave:Connect(function()
			Hud.gui.Crowns.BuyMore:TweenSize(UDim2.new(0.33,0,0.33,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.25,true)
		end)
	end
	Hud.firstSetup = true
end

function Hud:updateTimer()
	local seconds = math.max(0,math.floor(self.timerEnd - tick()))
	local mins = string.format("%02.f", math.floor(seconds/60));
	local secs = string.format("%02.f", math.floor(seconds - mins *60));
	local str =  ""..mins..":"..secs
	self.gui.Timer.TextLabel.Text = str
end

function Hud:updateLobbyTimer()
	if Hud.player.Team.Name == "Spectators" then
		Hud.gui.Tower.Visible = false
	end
	local seconds = math.max(0,math.floor(self.lobbyEnd - tick()))
	local mins = string.format("%01.f", math.floor(seconds/60));
	local secs = string.format("%02.f", math.floor(seconds - mins *60));
	local str =  ""..mins..":"..secs
	self.gui.LobbyTimer.TextLabel.Text = str
end

function Hud:start()
	Hud.firstSetup = false

	local visibleTick = tick()
	local visibleStep = nil
	if not UiState.Sounds then repeat wait() until UiState.Sounds ~= nil end
	if not UiState.TopBar then repeat wait() until UiState.TopBar ~= nil end

	UiState.TopBar:WaitForChild("CrownCount")
	Messages:hook("PlayerDataSet", function(stat, value)
		updateBricks(_G.Data["bricks"])
		UpdateCrowns(_G.Data["cash"])
	end)

	Messages:hook("AddBricks", function(bricks,color)
		addBricks(bricks,color)
	end)

	local crownAdd = 0
	Messages:hook("AddCrowns", function(cash)
		crownAdd = crownAdd + cash
		cash = crownAdd
		Hud.gui.Crowns.Add.Text = (cash > 0 and "+" or "")..cash
		Hud.gui.Crowns.Add.TextColor3 = cash > 0 and Color3.fromRGB(255, 233, 49) or Color3.fromRGB(255, 52, 69)
		Hud.gui.Crowns.Add.Position = UDim2.new(0.25,0,1,0)
		Hud.gui.Crowns.Add.Visible = true
		Hud.gui.Crowns.Add:TweenPosition(UDim2.new(0.25,0,0.9,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.25,true)
		UiState.TopBar.CrownCount.Add.Visible = true
		UiState.TopBar.CrownCount.Add.Text = Hud.gui.Crowns.Add.Text
		UiState.TopBar.CrownCount.Add.TextColor3 = Hud.gui.Crowns.Add.TextColor3
		UiState.TopBar.CrownCount.Add.Position = UDim2.new(0.5,0,1.5,0)
		UiState.TopBar.CrownCount.Add:TweenPosition(UDim2.new(0.5,0,1.25,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.25,true)
		visibleTick = tick()
		if visibleStep == nil then
			visibleStep = RunService.Stepped:Connect(function()
				if tick() > visibleTick + 3.3 then
					Hud.gui.Crowns.Add.Visible = false
					UiState.TopBar.CrownCount.Add.Visible = false
					crownAdd = 0
					visibleStep:Disconnect()
					visibleStep = nil
				return end
			end)
		end
	end)

	FastSpawn(function()
		Messages:hook("EnableTimer", function(timeLeft)
			if not Hud.gui then repeat wait() until Hud.gui and Hud.gui:FindFirstChild("Timer") end
			Hud.timerEnd = tick() + timeLeft
			Hud.gui.Timer.Visible = true
			Hud.updateMethod = RunService.Stepped:connect(function()
				Hud:updateTimer()
			end)
		end)
		Messages:hook("DisableTimer", function()
			if not Hud.gui then repeat wait() until Hud.gui and Hud.gui:FindFirstChild("Timer") end
			Hud.gui.Timer.Visible = false
			if Hud.updateMethod then
				Hud.updateMethod:disconnect()
			end
		end)
		Messages:hook("LobbyTimer", function(timeLeft)
			Hud.lobbyEnd = tick() + timeLeft
			Hud.gui.LobbyTimer.Visible = Hud.player.Team.Name == "Spectators"
			if Hud.updateMethod then
				Hud.updateMethod:disconnect()
			end
			Hud.updateMethod = RunService.Stepped:connect(function()
				Hud:updateLobbyTimer()
			end)
		end)

		Messages:hook("EnableTowerGui", function()
			if Hud.player.Team.Name ~= "Spectators" then
				Hud.gui.Tower.Visible = true
			end
	end)
		Messages:hook("DisableTowerGui", function()
			Hud.towerCache = 0
			Hud.playersCache = 0
			Hud.gui.Tower.Visible = false
			Hud.gui.TeamPlayers.Visible = false
			Hud.gui.TeamBricks.Visible = false
		end)
		Messages:hook("EnableBricksGui", function()
			if Hud.player.Team.Name ~= "Spectators" then
				Hud.gui.TeamBricks.Visible = true
				Hud.gui.TeamBricks.ImageColor3 = Hud.player.Team.TeamColor.Color
			end
		end)
		Messages:hook("UpdateTeamBricks", function(bricks)
			if Hud.gui.TeamBricks.Visible then
				Hud.gui.TeamBricks.Amount.Text = Styles.addComma(bricks)
			end
		end)

		Messages:hook("EnablePlayersLeftGui", function(team)
			Hud.playersCache = 0
			if Hud.player.Team.Name ~= "Spectators" then
				Hud.teamTracking = team
				Hud.gui.TeamPlayers.ImageColor3 = team.TeamColor.Color
				Hud.gui.TeamPlayers.Visible = true
			end
		end)
		Messages:hook("UpdatePlayersLeftGui", function(team,players)
			if Hud.teamTracking == team then
				updatePlayersLeft(players)
			end
		end)
	end)

	Messages:hook("CharacterAdded",function()
		Hud.towerDanger = false
		updateTowers()
		if Hud.player.Team.Name ~= "Spectators" then
			--Hud.gui.Tower.Visible = true
			Hud.gui.LobbyTimer.Visible = false
		else
			Hud.gui.Tower.Visible = false
		end
	end)
	CollectionService:GetInstanceAddedSignal("Spawn"):Connect(function(i)
		updateTowers()
	end)
	CollectionService:GetInstanceRemovedSignal("Spawn"):Connect(function(i)
		updateTowers()
	end)
end

return Hud
