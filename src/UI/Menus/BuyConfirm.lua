local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"
local Buttons = import "UI/Elements/Buttons"
local UiState= import "UI/UiState"
local InputData = import "Client/Data/InputData"
local Styles = import "UI/Styles"
local ToolData = import "Shared/Data/ToolData"
local RenderItem = import "UI/Elements/RenderItem"
local Window = import "UI/Menus/Window"
local DoStats = import "UI/Elements/ItemStats"

local StickerSoundsFolder = import "Assets/StickerSounds"

local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

local BuyConfirm = {}

local Preview3D = nil
local SpinConnect = nil
local currentData = nil
local currentItem = nil
local currentItemType = nil
local icon
--ItemType - displays what slot it's in
--ItemRarity - displays the rarity
--ItemIcon - shows 3D or 2D icon
--ItemDesc, ItemName
--extraInfo - shows the "basetool" for tools or "extradata" value

local function Buy()
	if currentItemType == "Tools" then
		Messages:sendServer("BuyTool",currentItem)
	end
	if currentItemType == "Stickers" then
		Messages:sendServer("BuySticker",currentItem)
	end
end

function BuyConfirm:update(data)
	currentItem = data.name
	currentData = data
	currentItemType = data.itemType
	local window = BuyConfirm.previewWindow
	local desc = window.desc
	--if data.itemType == "Tools" or data.itemType == "Pets" then make3DPreview(data) end
	if icon then icon:Destroy() end
	icon = RenderItem:icon(BuyConfirm.Window.ItemPreview.ItemIcon,currentItemType,data)
	icon.Parent = BuyConfirm.Window.ItemPreview.ItemIcon
	window.ItemName.Text = data.name
	desc.extraInfo.Visible = false
	desc.by.Visible = false
	desc.baseTool.Visible = false
	window.ItemType.Visible = false
	window.SoundPreview.Visible = false
	if data.itemType == "Tools" then
		window.ItemType.Visible = true
		if data.baseTool and not data.notASkin then
			desc.baseTool.Text = "("..data.baseTool.." skin)"
			desc.baseTool.Visible = true
		end
		window.ItemType.ImageRectOffset = Styles.weaponIcons[data.slot]
	end
	if data.itemType == "Stickers" then
		if data.sound and data.sound ~= "Basic" then
			window.SoundPreview.Visible = true
			if window.SoundPreview:FindFirstChild("Sound") then
				window.SoundPreview.Sound:Destroy()
			end
			local sound = StickerSoundsFolder[data.sound]:Clone()
			sound.Name = "Sound"
			sound.Parent = window.SoundPreview
		end
	end
	if data.stats then
		DoStats(data.stats,window.stats)
		window.stats.Visible = true
	else
		DoStats(nil,window.stats)
		window.stats.Visible = false
	end
	if data.extraInfo then
		desc.extraInfo.Text = data.extraInfo
		desc.extraInfo.Visible = true
	end
	if data.by then
		desc.by.Text = "by "..data.by
		desc.by.Visible = true
	end

	--Rotate if a 3D asset
	if data.itemType == "Tools" or data.itemType == "Pets" then
		local orientation = data.previewRotation or Vector3.new(0,0,0)
		if SpinConnect then SpinConnect:disconnect() SpinConnect = nil end
		if not SpinConnect then
			local spin = 0
			SpinConnect = RunService.RenderStepped:Connect(function()
				spin = (spin + 1) % 360
				icon.setOrientation(Vector3.new(orientation.X,spin,orientation.Z))
			end)
		end
	end

	RenderItem:rarityStars(window.ItemRarity,data.rarity)
	--RenderItem:rarityText(window.ItemRarity.TextLabel,data.rarity)
	--window.ItemIcon.ImageColor3 = Styles.colors["rare"..data.rarity.."color"]
	desc.ItemDesc.Text = data.description
	BuyConfirm.Window.Price.Num.Text = Styles.addComma(data.price)
end

function BuyConfirm:start()
	BuyConfirm.Window = UiState:GetElement("Shop_YesNo")
	BuyConfirm.previewWindow = BuyConfirm.Window:WaitForChild("ItemPreview")
	GuiService:AddSelectionParent("BuyConfirm",BuyConfirm.Window)

	Messages:hook("OnWindowOpened",function(name,data)
		if name == "Shop_YesNo" then
			BuyConfirm.Window.Position = UDim2.new(0.5,0,0.55,0)
			BuyConfirm.Window:TweenPosition(UDim2.new(0.5,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true)
			if InputData.inputType == "Gamepad" then
				GuiService.SelectedObject = BuyConfirm.Window.Yes
			else
				GuiService.SelectedObject = nil
			end
		end
	end)

	Messages:hook("OnWindowClosed",function(name)
		if name == "Shop_YesNo" then
			if Preview3D then Preview3D:Destroy() end
			if SpinConnect then SpinConnect:disconnect() SpinConnect = nil end
		end
	end)

	Buttons:IconShrinkButton(BuyConfirm.Window.Yes)
	Buttons:IconShrinkButton(BuyConfirm.Window.No)
	BuyConfirm.Window.Yes.MouseButton1Click:connect(function()
		UiState.Sounds.Click:Play()
		Buy()
	end)
	BuyConfirm.Window.No.MouseButton1Click:connect(function()
		UiState.Sounds.Back:Play()
		Messages:send("CloseWindow","Shop_YesNo")
	end)

	Messages:hook("ShopTransaction",function(result,message)
		local open = BuyConfirm.Window.Visible
		Messages:send("CloseWindow","Shop_YesNo")
		if result == true and open then
			UiState.Sounds.Purchase:Play()
			Messages:send("GetItem",currentData)
		else
			UiState.Sounds.Error:Play()
		end
	end)

	BuyConfirm.previewWindow.SoundPreview.Activated:Connect(function()
		BuyConfirm.previewWindow.SoundPreview.Size = UDim2.new(0.12,0,0.12,0)
		BuyConfirm.previewWindow.SoundPreview:TweenSize(UDim2.new(0.15,0,0.15,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.5,true)
		if BuyConfirm.previewWindow.SoundPreview:FindFirstChild("Sound") then
			BuyConfirm.previewWindow.SoundPreview.Sound:Play()
		end
	end)
	BuyConfirm.previewWindow.SoundPreview.MouseEnter:Connect(function()
		BuyConfirm.previewWindow.SoundPreview.circle:TweenSize(UDim2.new(1.3,0,1.3,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true)
		UiState.Sounds.Select:Play()
	end)
	BuyConfirm.previewWindow.SoundPreview.MouseLeave:Connect(function()
		BuyConfirm.previewWindow.SoundPreview.circle:TweenSize(UDim2.new(1.5,0,1.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true)
	end)
end

return BuyConfirm
