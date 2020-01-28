local import = require(game.ReplicatedStorage.Shared.Import)
local UiState = import "UI/UiState"
local Messages = import "Shared/Utils/Messages"

local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")

local ToolData = import "Shared/Data/ToolData"
local ToolCosmetics = import "Shared/Data/ToolCosmetics"
local RenderItem = import "UI/Elements/RenderItem"
local Gui3D = import "UI/Elements/3DGui"
local Styles = import "UI/Styles"
local Buttons = import "UI/Elements/Buttons"
local InputData = import "Client/Data/InputData"
local BuyConfirm = import "UI/Menus/BuyConfirm"
local Window = import "UI/Menus/Window"

local StickerSoundsFolder = import "Assets/StickerSounds"

local ShopItem = {}
ShopItem.__index = ShopItem

local player = game.Players.LocalPlayer
local cycleTeams = {"Red","Yellow","Green","Blue","Spectators"}
local teamNums = {["Red"]=1,["Yellow"]=2,["Green"]=3,["Blue"]=4,["Spectators"]=5}

local function isThisTopWindow()
	return UiState.openWindows[1] == "Shop_Main"
end

function ShopItem:destroy()
	if self.destroyed then
		return
	else
		self.destroyed = true
	end
	if self.spinConnect then self.spinConnect:Disconnect() end
	self.button:Destroy()
	if self.CustomFrame then self.CustomFrame:Destroy() end
end

function ShopItem:hover()
	if self.hovering == true then return end
	self.hovering = true
	self.button.ItemIcon:TweenSize(UDim2.new(0.8,0,0.8,0),Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.25,true)
	if (self.itemType == "Tools" or self.itemType == "Pets") then
		self.spin = self.orientation.Y
		if not self.spinConnect then
			local teamTimer = 0
			local teamNum = teamNums[player.Team.Name]
			self.spinConnect = RunService.RenderStepped:Connect(function()
				self.spin = (self.spin + 1.5) % 360
				teamTimer = teamTimer + 1
				self.CustomFrame.setOrientation(Vector3.new(self.orientation.X,self.spin,self.orientation.Z))
				if teamTimer > 100 and self.itemType == "Tools" then
					teamTimer = 0
					teamNum = teamNum >= 5 and 1 or teamNum + 1
					ToolCosmetics:skin(game.Teams[cycleTeams[teamNum]],self.CustomFrame.Model,self.item)
				end
			end)
		end
	end
	ContextActionService:BindAction("PreviewSound",function(action,state,obj)
		if state == Enum.UserInputState.Begin then
			if self.playSound then self.playSound() end
		end
	end,false,Enum.KeyCode.ButtonX)
end

function ShopItem:unhover()
	if self.hovering == false then return end
	self.hovering = false
	if not self.button.Owned.Visible then
		self.button.Button.ImageColor3 = Color3.new(1,1,1)
	end
	self.button.ItemIcon:TweenSize(UDim2.new(0.66,0,0.66,0),Enum.EasingDirection.InOut,Enum.EasingStyle.Quad,0.1,true)
	if self.spinConnect then
		self.spinConnect:Disconnect() self.spinConnect = nil
		if self.itemType == "Tools" then ToolCosmetics:skin(player.Team,self.CustomFrame.Model,self.item) end
	end
	if self.itemType == "Tools" or self.itemType == "Pets" then
		if self.CustomFrame then
			self.CustomFrame.setOrientation(self.data.previewRotation or Vector3.new(0,0,0))
		end
	end
	ContextActionService:UnbindAction("PreviewSound")
end

function ShopItem:pressed()
	BuyConfirm:update(self.data)
	Messages:send("OpenWindow","Shop_YesNo",self.data)
end

function ShopItem:spawn(itemType)
	self.hovering = false
	self.itemType = itemType
	self.data.itemType = itemType
	if itemType == "Tools" then
		self.orientation = self.data.previewRotation or Vector3.new(0,0,0)
		-- Set up 3D preview
		self.CustomFrame = RenderItem:icon(self.button.ItemIcon,"Tools",self.data)
		self.CustomFrame.Parent = self.button.ItemIcon
		self.button.ItemType.ImageRectOffset = Styles.weaponIcons[self.data.slot]
		self.button.ItemType.Visible = true
	end
	if itemType == "Stickers" then
		self.CustomFrame = RenderItem:icon(self.button.ItemIcon,"Stickers",self.data)
		self.CustomFrame.Size = UDim2.new(1.05,0,1.05,0)
		self.CustomFrame.Parent = self.button.ItemIcon
		self.button.ItemType.Visible = false
		if self.data.sound ~= "Basic" then
			self.button.SoundPreview.Visible = true
			self.sound = StickerSoundsFolder[self.data.sound]:Clone()
			self.sound.Name = "Sound"
			self.sound.Parent = self.button.SoundPreview
			self.button.SoundPreview.MouseEnter:connect(function()
				UiState.Sounds.Select:Play()
				self.button.SoundPreview.circle:TweenSize(UDim2.new(1.3,0,1.3,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true)
			end)
			self.button.SoundPreview.MouseLeave:connect(function()
				self.button.SoundPreview.circle:TweenSize(UDim2.new(1.5,0,1.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true)
			end)
			self.playSound = function()
				self.button.ItemIcon.Position = UDim2.new(0.5,0,0.6,0)
				self.button.ItemIcon:TweenPosition(UDim2.new(0.5,0,0.55,0),Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.5,true)
				self.button.SoundPreview.Size = UDim2.new(0.1,0,0.1,0)
				self.button.SoundPreview:TweenSize(UDim2.new(0.14,0,0.14,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.5,true)
				if self.sound then self.sound:Stop() self.sound:Play() end
			end
			self.button.SoundPreview.Activated:Connect(function()
				self.playSound()
			end)
		end
	end
	-- Set up the button
	self.button.Visible = true
	self.button.ItemName.TextLabel.Text = self.item

	self.button.ItemName.BackgroundColor3 = Styles.colors["rare"..self.data.rarity.."color"]
	RenderItem:rarityStars(self.button.ItemRarity,self.data.rarity)
	RenderItem:rarityText(self.button.ItemRarity.TextLabel,self.data.rarity)

	self.button.Price.TextLabel.Text = Styles.addComma(self.data.price)

	self.button.Button.MouseEnter:connect(function()
		if not isThisTopWindow() then return end
		if InputData.inputType ~= "PC" then return end
		self:hover()
		UiState.Sounds.Select:Play()
		if not self.button.Owned.Visible then
			self.button.Button.ImageColor3 = Color3.new(0.8,0.8,0.8)
		end
	end)
	self.button.Button.MouseLeave:connect(function()
		if InputData.inputType ~= "PC" then return end
		self:unhover()
	end)

	self.button.Button.MouseButton1Down:Connect(function()
		if not isThisTopWindow() then return end
		if not self.button.Owned.Visible then
			self.button.Button.ImageColor3 = Color3.new(0.6,0.6,0.6)
			UiState.Sounds.Click:Play()
		end
	end)
	self.button.Button.MouseButton1Up:Connect(function()
		if not isThisTopWindow() then return end
		if not self.button.Owned.Visible then
			self.button.Button.ImageColor3 = Color3.new(0.8,0.8,0.8)
		end
	end)

	-- Activated
	self.button.Button.Activated:connect(function()
		if not self.hovering and InputData.inputType == "Touch" then
			UiState.Sounds.Select:Play()
			self:hover()
		return end
		if not isThisTopWindow() then return end
		if self.button.Owned.Visible == true then return end
		self:pressed()
	end)

	self.button.Button.SelectionGained:Connect(function()
		self:hover()
		UiState.Sounds.Select:Play()
		self.button.SoundPreview.Gamepad.Visible = true
	end)
	self.button.Button.SelectionLost:Connect(function()
		self:unhover()
		self.button.SoundPreview.Gamepad.Visible = false
	end)
end

function ShopItem.new(item,itemData)
	local self = {}
	self.button = UiState.Reference.ShopItem:Clone()
	self.item = item
	self.data = itemData
	setmetatable(self, ShopItem)
	return self
end

return ShopItem
