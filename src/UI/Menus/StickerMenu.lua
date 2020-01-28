
local import = require(game.ReplicatedStorage.Shared.Import)
local GuiService = game:GetService("GuiService")

local Messages = import "Shared/Utils/Messages"
local Buttons = import "UI/Elements/Buttons"
local UiState= import "UI/UiState"
local Styles = import "UI/Styles"
local StickerData = import "Shared/Data/StickerData"

local ContextActionService = game:GetService("ContextActionService")

local TweenService = game:GetService("TweenService")

local Tweens = {}

local StickerMenu = {}

local function useSticker(num)
	Messages:sendServer("OnSendSticker",_G.Data.equippedStickers[num])
end

local function updateStickers()
	local eq = _G.Data.equippedStickers
	StickerMenu.Stickers.Sticker1.icon.Image = StickerData[eq[1]].img
	StickerMenu.Stickers.Sticker1.icon.ImageRectOffset = Vector2.new(StickerData[eq[1]].offset.X-1,StickerData[eq[1]].offset.Y-1)*160
	StickerMenu.Stickers.Sticker2.icon.Image = StickerData[eq[2]].img
	StickerMenu.Stickers.Sticker2.icon.ImageRectOffset = Vector2.new(StickerData[eq[2]].offset.X-1,StickerData[eq[2]].offset.Y-1)*160
	StickerMenu.Stickers.Sticker3.icon.Image = StickerData[eq[3]].img
	StickerMenu.Stickers.Sticker3.icon.ImageRectOffset = Vector2.new(StickerData[eq[3]].offset.X-1,StickerData[eq[3]].offset.Y-1)*160
	if StickerData[eq[4]] then
		StickerMenu.StickersGamepad.Spray.Image = StickerData[eq[4]].img
		StickerMenu.StickersGamepad.Spray.ImageRectOffset = Vector2.new(StickerData[eq[4]].offset.X-1,StickerData[eq[4]].offset.Y-1)*160
	else
		StickerMenu.StickersGamepad.Spray.Image = ""
	end
	if StickerData[eq[5]] then
		StickerMenu.Stickers.Sticker4.Visible = true
		StickerMenu.Stickers.Sticker4.icon.Image = StickerData[eq[5]].img
		StickerMenu.Stickers.Sticker4.icon.ImageRectOffset = Vector2.new(StickerData[eq[5]].offset.X-1,StickerData[eq[5]].offset.Y-1)*160
	else
		StickerMenu.Stickers.Sticker4.Visible = false
		StickerMenu.Stickers.Sticker4.icon.Image = ""
	end
	StickerMenu.StickersGamepad.Sticker1.Image = StickerMenu.Stickers.Sticker1.icon.Image
	StickerMenu.StickersGamepad.Sticker1.ImageRectOffset = StickerMenu.Stickers.Sticker1.icon.ImageRectOffset
	StickerMenu.StickersGamepad.Sticker2.Image = StickerMenu.Stickers.Sticker2.icon.Image
	StickerMenu.StickersGamepad.Sticker2.ImageRectOffset = StickerMenu.Stickers.Sticker2.icon.ImageRectOffset
	StickerMenu.StickersGamepad.Sticker3.Image = StickerMenu.Stickers.Sticker3.icon.Image
	StickerMenu.StickersGamepad.Sticker3.ImageRectOffset = StickerMenu.Stickers.Sticker3.icon.ImageRectOffset
end

local function openCloseStickers()
	updateStickers()
	if StickerMenu.Stickers.Visible then
		-- close
		UiState.Sounds.stickerClose:Play()
		StickerMenu.StickerButton.icon.ImageRectOffset = Vector2.new(200,600)
		--Tweens.closeSticker[1]:Play()
		Tweens.closeSticker[2]:Play()
	else
		-- open
		UiState.Sounds.stickerOpen:Play()
		StickerMenu.StickerButton.icon.ImageRectOffset = Vector2.new(0,200)
		StickerMenu.Stickers.Rotation = -6
		StickerMenu.Stickers.Position = UDim2.new(0.8,0,0.68,0)
		StickerMenu.Stickers:TweenPosition(UDim2.new(0.85,0,0.68,0),Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.4,true)
		--Tweens.openSticker[1]:Play()
		Tweens.openSticker[2]:Play() Tweens.openSticker[3]:Play()
	end
	StickerMenu.Stickers.Visible = not StickerMenu.Stickers.Visible
end

local function darkenStickers(tf)
	for _,s in pairs(StickerMenu.Stickers:GetChildren()) do
		if s:IsA("ImageButton") then
			s.icon.ImageColor3 = tf and Color3.new(0.5,0.5,0.5) or Color3.new(1,1,1)
			s.ImageColor3 = tf and Color3.new(0.5,0.5,0.5) or Color3.fromRGB(240,240,240)
		end
	end
	StickerMenu.StickersGamepad.Sticker1.ImageColor3 = tf and Color3.new(0.5,0.5,0.5) or Color3.new(1,1,1)
	StickerMenu.StickersGamepad.Sticker2.ImageColor3 = tf and Color3.new(0.5,0.5,0.5) or Color3.new(1,1,1)
	StickerMenu.StickersGamepad.Sticker3.ImageColor3 = tf and Color3.new(0.5,0.5,0.5) or Color3.new(1,1,1)
	StickerMenu.StickerButton.ImageColor3 = tf and Color3.new(0.5,0.5,0.5) or Color3.new(1,1,1)
	StickerMenu.StickerButton.icon.ImageColor3 = tf and Color3.new(0.5,0.5,0.5) or Color3.new(1,1,1)
end

local function setupStickers()
	Tweens.openSticker = {}
	Tweens.closeSticker = {}
	Tweens.openSticker[1] = TweenService:Create(StickerMenu.StickerButton,
		TweenInfo.new(0.6,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Rotation = 320})
	Tweens.openSticker[2] = TweenService:Create(StickerMenu.StickerButton.icon,
		TweenInfo.new(0.6,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Rotation = -360})
	Tweens.openSticker[3] = TweenService:Create(StickerMenu.Stickers,
		TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Rotation = 8})
	Tweens.closeSticker[1] = TweenService:Create(StickerMenu.StickerButton,
		TweenInfo.new(0.6,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Rotation = 0})
	Tweens.closeSticker[2] = TweenService:Create(StickerMenu.StickerButton.icon,
		TweenInfo.new(0.6,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Rotation = 0})
	StickerMenu.StickerButton.MouseButton1Click:connect(function()
		openCloseStickers()
	end)

	-- individual sticker buttons
	StickerMenu.Stickers.Sticker1.MouseButton1Click:Connect(function()
		useSticker(1)
	end)
	StickerMenu.Stickers.Sticker2.MouseButton1Click:Connect(function()
		useSticker(2)
	end)
	StickerMenu.Stickers.Sticker3.MouseButton1Click:Connect(function()
		useSticker(3)
	end)
	StickerMenu.Stickers.Sticker4.MouseButton1Click:Connect(function()
		useSticker(5)
	end)

	-- bind hotkeys for stickers
	ContextActionService:BindActionAtPriority("UseSticker1",
	function(action,state,obj)
		if state ~= Enum.UserInputState.Begin then return end
		useSticker(1)
	end,
	false,5000,Enum.KeyCode.DPadLeft,Enum.KeyCode.Z)
	ContextActionService:BindActionAtPriority("UseSticker2",
	function(action,state,obj)
		if state ~= Enum.UserInputState.Begin then return end
		useSticker(2)
	end,
	false,5000,Enum.KeyCode.DPadUp,Enum.KeyCode.X)
	ContextActionService:BindActionAtPriority("UseSticker3",
	function(action,state,obj)
		if state ~= Enum.UserInputState.Begin then return end
		useSticker(3)
	end,
	false,5000,Enum.KeyCode.DPadRight,Enum.KeyCode.C)
	ContextActionService:BindActionAtPriority("UseSticker4",
	function(action,state,obj)
		if state ~= Enum.UserInputState.Begin then return end
		useSticker(5)
	end,
	false,5000,Enum.KeyCode.V)
	--[[ContextActionService:BindActionAtPriority("StickerMenu",
	function(action,state,obj)
		if state ~= Enum.UserInputState.Begin then return end
		openCloseStickers()
	end,
	false,2000,Enum.KeyCode.DPadDown)--]]

	for _,s in pairs(StickerMenu.Stickers:GetChildren()) do
		if s:IsA("ImageButton") then
			s.MouseEnter:Connect(function()
				s:TweenSize(UDim2.new(1,0,1,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true)
			end)
			s.MouseLeave:Connect(function()
				s:TweenSize(UDim2.new(0.8,0,0.8,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true)
			end)
			s.MouseButton1Click:Connect(function()
				s.icon.Size = UDim2.new(1.1,0,1.1,0)
				s.icon:TweenSize(UDim2.new(0.8,0,0.8,0),Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.5,true)
			end)
		end
	end
end

function StickerMenu:start()
	local player = game.Players.LocalPlayer
	StickerMenu.StickerButton = UiState:GetElement("StickersSidebar")
	Buttons:IconShrinkButton(StickerMenu.StickerButton)
	StickerMenu.Stickers = UiState:GetElement("StickersWindow")
	StickerMenu.StickersGamepad = UiState:GetElement("GamepadStickers")
	setupStickers()
	updateStickers()

	Messages:hook("UpdatedStickers",function()
		updateStickers()
	end)
	Messages:hook("CharacterAdded",function()
		updateStickers()
	end)

	Messages:hook("StickerBubble",function(sourcePlayer)
		if sourcePlayer == player then
			darkenStickers(true)
			delay(4,function()
				darkenStickers(false)
			end)
		end
	end)


end

return StickerMenu
