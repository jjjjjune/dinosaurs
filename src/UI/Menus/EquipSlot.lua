local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"
local Buttons = import "UI/Elements/Buttons"
local UiState= import "UI/UiState"
local InputData = import "Client/Data/InputData"
local Styles = import "UI/Styles"
local ToolData = import "Shared/Data/ToolData"
local Window = import "UI/Menus/Window"

local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

local StickerData = import "Shared/Data/StickerData"
local RenderItem = import "UI/Elements/RenderItem"

local EquipSlot = {}

local currentSticker = nil
local CanEquip = true

function EquipSlot:updateStickers()
	for n,slot in pairs(EquipSlot.StickerSlots) do
		if slot.ItemIcon:FindFirstChild("Sticker") then slot.ItemIcon.Sticker:Destroy() end
		if _G.Data.equippedStickers[n] then
			local render = RenderItem:icon(slot.ItemIcon,"Stickers",StickerData[_G.Data.equippedStickers[n]])
			render.Name = "Sticker"
			render.Parent = slot.ItemIcon
		end
	end
	if EquipSlot.Window.ItemIcon:FindFirstChild("Sticker") then
		EquipSlot.Window.ItemIcon.Sticker:Destroy()
	end
	if currentSticker and StickerData[currentSticker] then
		local mainRender = RenderItem:icon(EquipSlot.Window.ItemIcon,"Stickers",StickerData[currentSticker])
		mainRender.Name = "Sticker"
		mainRender.Parent = EquipSlot.Window.ItemIcon
	end
end

local function hover(slot,isHovering)
	if isHovering then
		slot.SlotNum:TweenPosition(UDim2.new(0.5,0,-0.02,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true)
	else
		slot.SlotNum:TweenPosition(UDim2.new(0.5,0,0.02,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true)
	end
end

local function setupButtons()
	for n,slot in pairs(EquipSlot.StickerSlots) do
		local size = slot.Size
		slot.Button.MouseEnter:connect(function()
			if CanEquip == false then return end
			if InputData.inputType ~= "PC" then return end
			UiState.Sounds.Select:Play()
			slot.Button.ImageColor3 = Color3.new(0.8,0.8,0.8)
			hover(slot,true)
		end)
		slot.Button.MouseLeave:connect(function()
			if InputData.inputType ~= "PC" then return end
			slot.Button.ImageColor3 = Color3.new(1,1,1)
			hover(slot,false)
		end)
		slot.Button.MouseButton1Down:Connect(function()
			if CanEquip == false then return end
			slot.Button.ImageColor3 = Color3.new(0.6,0.6,0.6)
			UiState.Sounds.Click:Play()
			slot:TweenSize(size - UDim2.new(0.1,0,0.1,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.1,true)
		end)
		slot.Button.MouseButton1Up:Connect(function()
			slot.Button.ImageColor3 = Color3.new(1,1,1)
			slot:TweenSize(size,Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.1,true)
		end)
		slot.Button.Activated:Connect(function()
			if CanEquip == false then return end
			Messages:sendServer("EquipSticker",currentSticker,n)
		end)
		slot.Button.SelectionGained:Connect(function() hover(slot,true) UiState.Sounds.Select:Play() end)
		slot.Button.SelectionLost:Connect(function() hover(slot,false) end)
	end
end

function EquipSlot:start()
	EquipSlot.Window = UiState:GetElement("EquipSlotWindow")
	GuiService:AddSelectionParent("EquipSlot",EquipSlot.Window)
	EquipSlot.Stickers = EquipSlot.Window:WaitForChild("StickerSlots")
	EquipSlot.StickerSlots = {EquipSlot.Stickers:WaitForChild("Slot1"),EquipSlot.Stickers:WaitForChild("Slot2"),
							EquipSlot.Stickers:WaitForChild("Slot3"),EquipSlot.Stickers:WaitForChild("SlotSpray"),
							EquipSlot.Stickers:WaitForChild("Slot4"),EquipSlot.Stickers:WaitForChild("SlotDeath"),}
	for _,slot in pairs(EquipSlot.StickerSlots) do
		slot:WaitForChild("ItemIcon")
	end
	Messages:hook("EquipStickerSlot",function(stickerName)
		currentSticker = stickerName
		EquipSlot:updateStickers()
	end)
	Messages:hook("OnWindowOpened",function(name)
		if name == "EquipSlotWindow" then
			EquipSlot:updateStickers()
			if InputData.inputType == "Gamepad" then
				GuiService.SelectedObject = EquipSlot.StickerSlots[1]
			end
		end
	end)
	Messages:hook("UpdatedStickers",function(slot)
		if EquipSlot.Window.Visible then
			CanEquip = false
			EquipSlot:updateStickers()
			UiState.Sounds.Equip:Play()
			EquipSlot.Window.ItemIcon.Sticker:TweenSize(UDim2.new(0,0,0,0),Enum.EasingDirection.In,Enum.EasingStyle.Back,0.5,true)
			EquipSlot.Window.ItemIcon.Sticker:TweenPosition(UDim2.new(0.5,0,1,0),Enum.EasingDirection.In,Enum.EasingStyle.Back,0.5,true)
			Messages:send("MakeSparkles",{amount=4,delay=0.1,size=UDim2.new(0.8,0,0.8,0),
				center=UDim2.new(0.5,0,0.5,0),spread=UDim2.new(0.5,0,0.5,0),parent=EquipSlot.StickerSlots[slot]})
			wait(1)
			Messages:send("CloseWindow","EquipSlotWindow")
			CanEquip = true
		end
	end)
	setupButtons()
	EquipSlot:updateStickers()
end

return EquipSlot
