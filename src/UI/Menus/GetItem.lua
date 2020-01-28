local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"
local Buttons = import "UI/Elements/Buttons"
local UiState= import "UI/UiState"
local InputData = import "Client/Data/InputData"
local Styles = import "UI/Styles"
local ToolData = import "Shared/Data/ToolData"
local StickerData = import "Shared/Data/StickerData"
local RenderItem = import "UI/Elements/RenderItem"
local Window = import "UI/Menus/Window"

local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

local GetItem = {}

local Preview = nil
local SpinConnect = nil

local currentItems = {}

local function okay()
	table.remove(currentItems,1)
	GetItem:update()
end

local function equip()
	if currentItems[1].itemType == "Tools" then
		Messages:sendServer("EquipTool",currentItems[1].name)
	end
	if currentItems[1].itemType == "Stickers" then
		Messages:send("EquipStickerSlot",currentItems[1].name)
		Messages:send("OpenWindow","EquipSlotWindow")
	end
	table.remove(currentItems,1)
	GetItem:update()
end

local function animate(data)
	UiState.Sounds.GetItem:Play()
	GetItem.Window.starburst.Rotation = 0
	GetItem.Window.starburst_shadow.Rotation = 0
	GetItem.Window.starburst.Size = UDim2.new(0.1,0,0.1,0)
	GetItem.Window.starburst_shadow.Size = GetItem.Window.starburst.Size
	GetItem.Window.starburst:TweenSize(UDim2.new(0.66,0,0.66,0),Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.85,true)
	GetItem.Window.starburst_shadow:TweenSize(UDim2.new(0.66,0,0.66,0),Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.85,true)
	GetItem.Window.ItemName.Text = data.name
	GetItem.Window.Message.Text = data.message and data.message or ""
	GetItem.Window.ItemName.Position = UDim2.new(0.5,0,-0.08,0)
	GetItem.Window.ItemName:TweenPosition(UDim2.new(0.5,0,0.08,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.5,true)
	GetItem.Window.Title.Position = UDim2.new(0.5,0,-0.1,0)
	GetItem.Window.Title:TweenPosition(UDim2.new(0.5,0,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.5,true)
	if Preview then Preview:Destroy() end
	Preview = RenderItem:icon(GetItem.Window.ItemIcon,data.itemType,data)
	local Frame = Preview

	--hide equip button if you can't equip!
	GetItem.Window.Equip.Visible = data.itemType ~= "Crowns"
	if GetItem.Window.Equip.Visible == false then
		GetItem.Window.Ok.Position = UDim2.new(0.5,0,0.9,0)
	else
		GetItem.Window.Ok.Position = UDim2.new(0.25,0,0.9,0)
	end

	if data.itemType == "Tools" or data.itemType == "Pets" or data.itemType == "Crowns" then
		Frame = Preview.Frame
	end
	Frame.Size = UDim2.new(0,0,0,0)
	Preview.Parent = GetItem.Window.ItemIcon
	Frame.Parent = GetItem.Window.ItemIcon
	if InputData.inputType == "Gamepad" then
		GuiService.SelectedObject = GetItem.Window.Ok
	end

	local frameEndSize = UDim2.new(1,0,1,0)
	if data.itemType == "Stickers" then
		frameEndSize = UDim2.new(0.7,0,0.7,0)
	end
	Frame:TweenSize(frameEndSize,Enum.EasingDirection.Out,Enum.EasingStyle.Quad,1.2,true)

	local orientation = data.previewRotation or Vector3.new(0,0,0)
	if SpinConnect then SpinConnect:disconnect() SpinConnect = nil end
	if not SpinConnect then
		local spin = 0
		local damp = 16
		SpinConnect = RunService.RenderStepped:Connect(function()
			if data.itemType == "Tools" or data.itemType == "Pets" or data.itemType == "Crowns" then
				spin = (spin + 2 + damp) % 360
				damp = Styles.lerp(damp,0,0.06)
				Preview.setOrientation(Vector3.new(orientation.X,spin,orientation.Z))
			end
			GetItem.Window.starburst.Rotation = GetItem.Window.starburst.Rotation + 0.3
			GetItem.Window.starburst_shadow.Rotation = GetItem.Window.starburst.Rotation
		end)
	end

	Messages:send("MakeSparkles",{amount=5,delay=0.25,size=UDim2.new(0.22,0,0.22,0),
		center=UDim2.new(0.5,0,0.5,0),spread=UDim2.new(0.2,0,0.2,0),parent=GetItem.Window})
	Messages:send("MakeSparkles",{amount=6,delay=0.1,size=UDim2.new(0.1,0,0.1,0),
		center=UDim2.new(0.5,0,0.5,0),spread=UDim2.new(0.07,0,0.15,0),parent=GetItem.Window})
end

function GetItem:update()
	if #currentItems==0 then Messages:send("CloseWindow","GotItemFrame") return end
	animate(currentItems[1])
end

function GetItem:add(data)
	table.insert(currentItems,#currentItems+1,data)
	GetItem:update()
end

function GetItem:start()
	GetItem.Window = UiState:GetElement("GotItemFrame")
	GuiService:AddSelectionParent("GotItem",GetItem.Window)
	Messages:hook("GetItem",function(data,message)
		Messages:send("OpenWindow","GotItemFrame")
		data.message = message
		GetItem:add(data)
	end)
	Messages:hook("OnWindowClosed",function(name)
		if name == "GotItemFrame" then
			currentItems = {}
			GetItem:update()
		end
	end)
	GetItem.OkButton = GetItem.Window:WaitForChild("Ok")
	GetItem.EquipButton = GetItem.Window:WaitForChild("Equip")
	Buttons:IconShrinkButton(GetItem.OkButton)
	Buttons:IconShrinkButton(GetItem.EquipButton)
	GetItem.OkButton.MouseButton1Click:connect(function()
		UiState.Sounds.Click:Play()
		okay()
	end)
	GetItem.EquipButton.MouseButton1Click:Connect(function()
		UiState.Sounds.Click:Play()
		equip()
	end)
end

return GetItem
