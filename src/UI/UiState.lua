local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'
local GuiService = game:GetService("GuiService")

local FastSpawn = import "Shared/Utils/FastSpawn"

local UiState = {}

local RNG = Random.new()

function UiState:GetElement(name)
	local element = game.Players.LocalPlayer.PlayerGui:FindFirstChild(name,true)
	local attempts = 0
	if not element then
		repeat
			wait()
			element = game.Players.LocalPlayer.PlayerGui:FindFirstChild(name,true)
			if attempts == 100 then
				warn("Still waiting for Ui element ".. name .. " after 100 attempts")
			end
		until element
	end
	return element
end

local lastTrans = 0
function UiState:transition(comingIn)
	if not UiState.DeathTransition then repeat wait() until UiState.DeathTransition end
	if comingIn == false then
		if tick() - lastTrans > 1 then
			lastTrans = tick()
			UiState.DeathTransition.Position = UDim2.new(-2,0,0.5,0)
			UiState.DeathTransition.Visible = true
			UiState.DeathTransition:TweenPosition(UDim2.new(0.5,0,0.5,0),Enum.EasingDirection.In,Enum.EasingStyle.Quad,1,true)
		end
		FastSpawn(function()
			wait(6)
			if tick() - lastTrans >= 5 then
				UiState.DeathTransition.Visible = false
			end
		end)
	else
		UiState.DeathTransition:TweenPosition(UDim2.new(2,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,1,true)
		Messages:send("TweenOutRoundStarting")
	end
end

local function makeSparkles(data)
	--{amount=5,delay=0.1,size=UDim2.new(),center=UDim2.new(),spread=UDim2.new(),parent=nil}
	for _=1,data.amount do
		local sparkle = UiState.sparkles:Clone()
		local spread = data.spread or UDim2.new(0,0,0,0)
		sparkle.Position = (data.center or UDim2.new(0.5,0,0.5,0)) + UDim2.new(RNG:NextNumber(-spread.X.Scale,spread.X.Scale),
			RNG:NextNumber(-spread.X.Offset,spread.X.Offset),RNG:NextNumber(-spread.Y.Scale,spread.Y.Scale),
			RNG:NextNumber(-spread.Y.Offset,spread.Y.Offset))
		local sizerando = RNG:NextNumber(0.9,1.2)
		sparkle.Rotation = RNG:NextInteger(-360,360)
		sparkle.Size = UDim2.new(data.size.X.Scale*sizerando,data.size.X.Offset*sizerando,
			data.size.Y.Scale*sizerando,data.size.Y.Offset*sizerando)
		sparkle.Parent = data.parent or UiState.Gui.effects
		sparkle:TweenSize(UDim2.new(sparkle.Size.X.Scale*0.5,sparkle.Size.X.Offset*0.5,
		sparkle.Size.Y.Scale*0.5,sparkle.Size.Y.Offset*0.5),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.6)
		FastSpawn(function()
			wait(0.1) sparkle.ImageRectOffset = Vector2.new(200,0)
			wait(0.1) sparkle.ImageRectOffset = Vector2.new(400,0)
			wait(0.1) sparkle.ImageRectOffset = Vector2.new(0,200)
			wait(0.1) sparkle.ImageRectOffset = Vector2.new(200,200)
			wait(0.1) sparkle.ImageRectOffset = Vector2.new(400,200)
			wait(0.1) if sparkle then sparkle:Destroy() end
		end)
		wait(data.delay or 0.1)
	end
end

function UiState:start()
	-- Current focused window
	UiState.currentWindow = nil
	-- Windows currently open; when the first one closes the next in table takes precedent
	UiState.openWindows = {}
	-- SoftSelection is what will be selected when Gamepad's enabled
	UiState.SoftSelection = nil
	UiState.Gui = game.Players.LocalPlayer.PlayerGui
	UiState.DeathTransition = UiState:GetElement("DeathTransitionFrame")
	UiState.DeathTransition.Visible = true
	UiState.Sounds = UiState:GetElement("Sounds")
	UiState.Reference = UiState:GetElement("ElementReference")
	UiState.Sidebar = UiState:GetElement("SidebarFrame")
	UiState.Hud = UiState.Gui:WaitForChild("Hud")
	UiState.TopBar = UiState:GetElement("TopMenuBar")
	UiState.Toolbar = UiState.Gui:WaitForChild("Toolbar")
	UiState.Hotkeys = UiState.Toolbar:WaitForChild("Hotkeys")
	UiState.topbarOn = false
	UiState.sparkles = UiState:GetElement("SparkleBase")
	game.Players.LocalPlayer.PlayerGui.SelectionImageObject = UiState.Reference.SELECTION

	Messages:hook("MakeSparkles",function(data)
		FastSpawn(function()
			makeSparkles(data)
		end)
	end)
end

return UiState
