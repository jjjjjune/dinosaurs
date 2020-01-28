local import = require(game.ReplicatedStorage.Shared.Import)
local UiState = import "UI/UiState"
local Messages = import "Shared/Utils/Messages"

local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local ContextActionService = game:GetService("ContextActionService")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local ToolData = import "Shared/Data/ToolData"
local StickerData = import "Shared/Data/StickerData"

local ToolCosmetics = import "Shared/Data/ToolCosmetics"
local RenderItem = import "UI/Elements/RenderItem"
local Gui3D = import "UI/Elements/3DGui"
local Styles = import "UI/Styles"
local Buttons = import "UI/Elements/Buttons"
local InputData = import "Client/Data/InputData"
local DoStats = import "UI/Elements/ItemStats"

local StickerSoundsFolder = import "Assets/StickerSounds"

local InventoryItem = {}
InventoryItem.__index = InventoryItem

local Description = UiState:GetElement("InventoryDescription")
local CurrentItem = nil
local DescPreview = nil
local DescSpinConnect = nil

local player = game.Players.LocalPlayer

local LayoutOrder = {["ROCKET"]=1,["SWORD"]=2,["BOMB"]=3,["BALL"]=4,["TROWEL"]=5,}
local cycleTeams = {"Red","Yellow","Green","Blue","Spectators"}
local teamNums = {["Red"]=1,["Yellow"]=2,["Green"]=3,["Blue"]=4,["Spectators"]=5}


local function isThisTopWindow()
	return UiState.openWindows[1] == "Inventory_Main"
end

local iconSizes = {
	["Tools"] = {
		Normal = UDim2.new(0.8,0,0.8,0),
		Hover = UDim2.new(0.95,0,0.95,0),
	},
	["Stickers"] = {
		Normal = UDim2.new(0.8,0,0.8,0),
		Hover = UDim2.new(0.9,0,0.9,0),
	},
}

function InventoryItem:destroy()
	if self.destroyed then
		return
	else
		self.destroyed = true
	end
	if self.spinConnect then self.spinConnect:disconnect() end
	if self.button then self.button:Destroy() end
	if self.CustomFrame then self.CustomFrame:Destroy() end
end

function InventoryItem:UpdateDescription()
	Description.Visible = true
	Description.ItemName.TextLabel.Text = self.item
	Description.ItemName.TextLabel.TextColor3 = Color3.new(1,1,1)
	Description.ItemName.back.ImageColor3 = Styles.colors["rare"..self.data.rarity.."color"]
	Description.ItemName.back.BackgroundColor3 = Description.ItemName.back.ImageColor3
	Description.ItemName.Visible = true
	Description.ItemIcon.Visible = true
	Description.ItemType.Visible = false
	Description.ItemIcon.ImageColor3 = Styles.colors["rare"..self.data.rarity.."color"]
	Description.ItemDesc.TextLabel.Text = self.data.description
	Description.ItemDate.Text = self.itemInfo["date"]

	if self.itemType == "Tools" then
		Description.ItemType.Visible = true
		if self.data.baseTool and not self.data.notASkin then
			Description.ItemDesc.extraInfo.Text = "("..self.data.baseTool.." skin)"
			Description.ItemDesc.extraInfo.Visible = true
		else
			Description.ItemDesc.extraInfo.Visible = false
		end
		Description.ItemType.ImageRectOffset = Styles.weaponIcons[self.data.slot]
	else
		if self.data.extraInfo then
			Description.ItemDesc.extraInfo.Text = self.data.extraInfo
			Description.ItemDesc.extraInfo.Visible = true
		else
			Description.ItemDesc.extraInfo.Visible = false
		end
	end
	if self.data.by then
		Description.ItemDesc.by.Text = "by "..self.data.by
		Description.ItemDesc.by.Visible = true
	else
		Description.ItemDesc.by.Visible = false
	end
	if self.data.stats then
		DoStats(self.data.stats,Description.ItemDesc.ItemStats)
	else
		DoStats(nil,Description.ItemDesc.ItemStats)
	end
	Description.BrickCost.Visible = false
	if self.data.brickCost then
		Description.BrickCost.TextLabel.Text = self.data.brickCost
		Description.BrickCost.Visible = true
	end
	RenderItem:rarityStars(Description.ItemRarity,self.data.rarity)
	RenderItem:rarityText(Description.ItemRarity.TextLabel,self.data.rarity)
	Description.ItemRarity.Visible = true
	-- Set up 3D preview
	if DescPreview then DescPreview:Destroy() end
	DescPreview = RenderItem:icon(Description.ItemIcon,self.itemType,self.data)
	DescPreview.Parent = Description.ItemIcon
	DescPreview.Position = UDim2.new(0.5,0,0.5,0)
	if DescSpinConnect then DescSpinConnect:disconnect() DescSpinConnect = nil end
	if self.itemType == "Stickers" then
		if not DescSpinConnect then
			DescSpinConnect = RunService.RenderStepped:Connect(function()
				DescPreview.Position = UDim2.new(0.5,0,math.sin(tick() * 3)*0.05+0.5,0)
				DescPreview.Rotation = math.sin(tick() * 6)*2
			end)
		end
	end
	if self.itemType == "Tools" or self.itemType == "Pets" then
		local orientation = self.data.previewRotation or Vector3.new(0,0,0)
		DescPreview.setOrientation(orientation)
		DescPreview.Frame.Name = "Item3D"
		DescPreview.Frame.ZIndex = Description.ItemIcon.ZIndex
		if not DescSpinConnect then
			local spin = 0
			local teamTimer = 0
			local teamNum = teamNums[player.Team.Name]
			DescSpinConnect = RunService.RenderStepped:Connect(function()
				spin = (spin + 2) % 360
				teamTimer = teamTimer + 1
				DescPreview.setOrientation(Vector3.new(self.orientation.X,spin,self.orientation.Z))
				if teamTimer > 100 and self.itemType == "Tools" then
					teamTimer = 0
					teamNum = teamNum >= 5 and 1 or teamNum + 1
					ToolCosmetics:skin(game.Teams[cycleTeams[teamNum]],DescPreview.Model,self.item)
				end
			end)
		end
	end
end

function InventoryItem:equip()
	if self.itemType == "Tools" then
		Messages:sendServer("EquipTool",self.item)
	end
	if self.itemType == "Stickers" then
		Messages:send("EquipStickerSlot",self.item)
		Messages:send("OpenWindow","EquipSlotWindow")
	end
end

function InventoryItem:hover()
	--print(InputData.InputType)
	if self.hovering == true then return end
	if CurrentItem and CurrentItem.button and CurrentItem.button:FindFirstChild("ItemIcon") then
		CurrentItem:unhover()
		if CurrentItem.button and CurrentItem.button:FindFirstChild("TouchEquip") then
			CurrentItem.button.TouchEquip.Visible = false
		end
	end
	CurrentItem = self
	if InputData.inputType == "Touch" and self.button:FindFirstChild("TouchEquip") then
		self.button.TouchEquip.Visible = true
	end
	self.hovering = true
	self.button.ItemIcon:TweenSize(iconSizes[self.itemType].Hover,Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.25,true)
	if self.itemType == "Tools" or self.itemType == "Pets" then
		self.spin = self.orientation.Y
		if not self.spinConnect then
			self.spinConnect = RunService.RenderStepped:Connect(function()
				self.spin = (self.spin + 1.5) % 360
				self.CustomFrame.setOrientation(Vector3.new(self.orientation.X,self.spin,self.orientation.Z))
			end)
		end
	end
	self:UpdateDescription()
	ContextActionService:BindAction("PreviewSound",function(action,state,obj)
		if state == Enum.UserInputState.Begin then
			if self.playSound then self.playSound() end
		end
	end,false,Enum.KeyCode.ButtonX)
end

function InventoryItem:unhover()
	if self.hovering == false then return end
	if self.button and self.button:FindFirstChild("TouchEquip") then
		self.button.TouchEquip.Visible = false
	end
	self.hovering = false
	if self.button == nil or not self.button.ItemIcon then return end
	self.button.ItemIcon:TweenSize(iconSizes[self.itemType].Normal,Enum.EasingDirection.InOut,Enum.EasingStyle.Quad,0.1,true)
	if not self.button.Equipped.Visible then
		self.button.Button.ImageColor3 = Color3.new(1,1,1)
	end
	if self.spinConnect then self.spinConnect:Disconnect() self.spinConnect = nil end
	if self.itemType == "Tools" or self.itemType == "Pets" then
		if self.CustomFrame then
			self.CustomFrame.setOrientation(self.data.previewRotation or Vector3.new(0,0,0))
		end
	end
	ContextActionService:UnbindAction("PreviewSound")
end

function InventoryItem:spawn(itemType)
	self.hovering = false
	self.itemType = itemType
	if itemType == "Tools" then
		self.data = ToolData[self.item]
		self.orientation = self.data.previewRotation or Vector3.new(0,0,0)
		-- Set up 3D preview
		self.CustomFrame = RenderItem:icon(self.button.ItemIcon,"Tools",self.data)
		self.CustomFrame.Parent = self.button.ItemIcon
		--
		self.button.ItemType.ImageRectOffset = Styles.weaponIcons[self.data.slot]
		self.button.ItemType.Visible = true
	end
	if itemType == "Stickers" then
		self.data = StickerData[self.item]
		if self.data.deleteThis then self:destroy() return end
		self.CustomFrame = RenderItem:icon(self.button.ItemIcon,"Stickers",self.data)
		self.CustomFrame.Size = UDim2.new(0.8,0,0.8,0)
		self.CustomFrame.Parent = self.button.ItemIcon
		self.button.ItemType.Visible = false
		if self.data.sound ~= "Basic" then
			self.button.SoundPreview.Visible = true
			self.sound = StickerSoundsFolder[self.data.sound]:Clone()
			self.sound.Name = "Sound"
			self.sound.Parent = self.button.SoundPreview
			self.button.SoundPreview.MouseEnter:connect(function()
				if InputData.inputType ~= "PC" then return end
				UiState.Sounds.Select:Play()
				self.button.SoundPreview.circle:TweenSize(UDim2.new(1.3,0,1.3,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true)
			end)
			self.button.SoundPreview.MouseLeave:connect(function()
				self.button.SoundPreview.circle:TweenSize(UDim2.new(1.5,0,1.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true)
			end)
			self.playSound = function()
				self.button.ItemIcon.Position = UDim2.new(0.5,0,0.6,0)
				self.button.ItemIcon:TweenPosition(UDim2.new(0.5,0,0.55,0),Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.5,true)
				self.button.SoundPreview.Size = UDim2.new(0.14,0,0.14,0)
				self.button.SoundPreview:TweenSize(UDim2.new(0.19,0,0.19,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.5,true)
				if self.sound then self.sound:Stop() self.sound:Play() end
			end
			self.button.SoundPreview.Activated:Connect(function()
				self.playSound()
			end)
		end
	end
	-- Set up the button
	self.button.LayoutOrder = -self.itemInfo["num"]
	self.timeOrder = -self.itemInfo["num"]
	self.rarityOrder = -self.data.rarity
	self.button.ItemIcon.Size = iconSizes[self.itemType].Normal
	self.button.ItemName.TextLabel.Text = self.item
	self.button.ItemName.BackgroundColor3 = Styles.colors["rare"..self.data.rarity.."color"]
	self.button.Name = self.item
	RenderItem:rarityStars(self.button.ItemRarity,self.data.rarity)

	self.button.Button.MouseEnter:connect(function()
		if not isThisTopWindow() then return end
		if InputData.inputType ~= "PC" then return end
		UiState.Sounds.Select:Play()
		self:hover()
		if not self.button.Equipped.Visible then
			self.button.Button.ImageColor3 = Color3.new(0.8,0.8,0.8)
		end
	end)
	self.button.Button.MouseLeave:connect(function()
		if not isThisTopWindow() then return end
		if InputData.inputType == "Touch" then
			if not self.button.Equipped.Visible then
				self.button.Button.ImageColor3 = Color3.new(1,1,1)
			end
		else
			self:unhover()
		end
	end)

	self.button.Button.MouseButton1Down:Connect(function()
		if not isThisTopWindow() then return end
		if not self.button.Equipped.Visible then
			self.button.Button.ImageColor3 = Color3.new(0.6,0.6,0.6)
		end
		UiState.Sounds.Click:Play()
	end)
	self.button.Button.MouseButton1Up:Connect(function()
		if not isThisTopWindow() then return end
		if not self.button.Equipped.Visible then
			if InputData.inputType == "Touch" then
				self.button.Button.ImageColor3 = Color3.new(1,1,1)
			else
				self.button.Button.ImageColor3 = Color3.new(0.8,0.8,0.8)
			end
		end
	end)

	-- Activated
	self.button.Button.Activated:Connect(function()
		if not isThisTopWindow() then return end
		-- Make it so touch devices need to tap first to see info, then tap again to equip
		if InputData.inputType == "Touch" then
			if self.button.TouchEquip.Visible == true then
				self:equip()
			else
				self:hover()
			end
		else
			self:equip()
		end
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
	self.button.Visible = true
end

function InventoryItem.new(k,t)
	local self = {}
	self.button = UiState.Reference.InventoryItem:Clone()
	self.item = k
	self.itemInfo = t
	setmetatable(self, InventoryItem)
	return self
end

return InventoryItem
