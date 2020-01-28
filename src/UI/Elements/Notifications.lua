local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local UiState = import "UI/UiState"
local StyleConstants = import "Shared/Data/StyleConstants"
local Icons = import "Shared/Data/Icons"

local RunService = game:GetService("RunService")

local Notifications = {}
local notifsActive = {}

local NOTIFICATION_TIME = 8
local MAX_NOTIFICATIONS = 5

local step = nil

local function notifAdded(notification)
	if step == nil then
		step = RunService.Stepped:Connect(function()
			if time() - Notifications.lastHud >= 4.5 then
				Notifications.HudNotif.Visible = false
			end
			if #notifsActive == 0 and time() - Notifications.lastHud >= 4.5 then
				Notifications.HudNotif.Visible = false
				step:Disconnect()
				step = nil
			return end
			if #notifsActive > MAX_NOTIFICATIONS then
				notifsActive[1].gui:Destroy()
				table.remove(notifsActive,1)
			end
			for n,notif in pairs(notifsActive) do
				if tick()>notif.timestamp + NOTIFICATION_TIME then
					notif.gui:Destroy()
					table.remove(notifsActive,n)
				end
			end
		end)
	end
end

local function newNotif(text,colorscheme,icon)
	local newNotif = Notifications.REF:Clone()
	newNotif.Frame.TextLabel.Text = text
	newNotif.Frame.TextLabel.TextColor3 = StyleConstants[colorscheme or "DEFAULT"].FG
	newNotif.Frame["end"].ImageColor3 = StyleConstants[colorscheme or "DEFAULT"].BG
	newNotif.Frame.Notif.ImageColor3 = StyleConstants[colorscheme or "DEFAULT"].BG
	newNotif.Frame.icon.ImageColor3 = StyleConstants[colorscheme or "DEFAULT"].FG
	newNotif.Frame.Position = UDim2.new(2,0,0,0)
	newNotif.Frame.icon.Image = Icons[icon][1]
	newNotif.Frame.icon.ImageRectOffset = Icons[icon][2]*Icons[icon][3]
	newNotif.Frame.icon.ImageRectSize = Vector2.new(Icons[icon][3],Icons[icon][3])
	newNotif.Visible = true
	newNotif.Parent = Notifications.Window
	newNotif.Frame.TextLabel.Position = UDim2.new(0,newNotif.Frame.icon.AbsoluteSize.X,0.5,0)
	newNotif.Frame.TextLabel.Size = UDim2.new(0,newNotif.Frame.TextLabel.TextBounds.X,0.55,0)
	newNotif.Frame.Size = UDim2.new(0,newNotif.Frame.TextLabel.TextBounds.X+newNotif.Frame.icon.AbsoluteSize.X+16,1,0)
	newNotif.Frame:TweenPosition(UDim2.new(1,0,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quint,0.25,true)
	local notif = {gui = newNotif, timestamp = tick()}
	table.insert(notifsActive,#notifsActive+1,notif)
	notifAdded(notif)
end

local function hudNotif(text,colorscheme,icon)
	Notifications.HudNotif.TextLabel.Text = text
	Notifications.HudNotif.TextLabel.TextColor3 = StyleConstants[colorscheme or "DEFAULT"].FG
	Notifications.HudNotif["end"].ImageColor3 = StyleConstants[colorscheme or "DEFAULT"].BG
	Notifications.HudNotif["end2"].ImageColor3 = StyleConstants[colorscheme or "DEFAULT"].BG
	Notifications.HudNotif.Notif.ImageColor3 = StyleConstants[colorscheme or "DEFAULT"].BG
	Notifications.HudNotif.icon.ImageColor3 = StyleConstants[colorscheme or "DEFAULT"].FG
	Notifications.HudNotif.icon.Image = Icons[icon][1]
	Notifications.HudNotif.icon.ImageRectOffset = Icons[icon][2]*Icons[icon][3]
	Notifications.HudNotif.icon.ImageRectSize = Vector2.new(Icons[icon][3],Icons[icon][3])
	Notifications.HudNotif.icon2.Image = Notifications.HudNotif.icon.Image
	Notifications.HudNotif.icon2.ImageRectOffset = Notifications.HudNotif.icon.ImageRectOffset
	Notifications.HudNotif.icon2.ImageColor3 = Notifications.HudNotif.icon.ImageColor3
	Notifications.HudNotif.icon2.ImageRectSize = Notifications.HudNotif.icon.ImageRectSize
	if not Notifications.HudNotif.Visible then
		Notifications.HudNotif.Position = UDim2.new(0.5,0,-0.3,0)
		Notifications.HudNotif:TweenPosition(UDim2.new(0.5,0,1.2,0),Enum.EasingDirection.Out,Enum.EasingStyle.Back,1,true)
	else
		Notifications.HudNotif.Position = UDim2.new(0.5,0,1.1,0)
		Notifications.HudNotif:TweenPosition(UDim2.new(0.5,0,1.2,0),Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.3,true)
	end
	Notifications.HudNotif.Visible = true
	Notifications.lastHud = time()
	notifAdded()
end

function Notifications:start()
	Notifications.REF = UiState.Reference:WaitForChild("Notif")
	Notifications.Window = UiState:GetElement("NotifContainer")
	Notifications.HudNotif = UiState:GetElement("HudNotif")
	Notifications.lastHud = time()
	Messages:hook("Notify", function(text, colorscheme, icon)
		newNotif(text,colorscheme,icon)
	end)
	Messages:hook("NotifyHud", function(text, colorscheme, icon)
		hudNotif(text,colorscheme,icon)
	end)
end

return Notifications
