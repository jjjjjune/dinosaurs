local import = require(game.ReplicatedStorage.Shared.Import)
local UiState = import "UI/UiState"
local Messages = import "Shared/Utils/Messages"

local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local ToolData = import "Shared/Data/ToolData"
local StickerData = import "Shared/Data/StickerData"
local ToolCosmetics = import "Shared/Data/ToolCosmetics"
local Gui3D = import "UI/Elements/3DGui"
local Styles = import "UI/Styles"

-- item types: Tool, Pet, Sticker, Title
-- extra item data: All: [date] Pet: [name, colors, face] Title: [color, font]
-- rarities: Common, Uncommon, Rare, Legendary, Unique

local RenderItem = {}

function RenderItem:rarityStars(frame,rarity)
	--star.ImageColor3 = Styles.colors["rare"..rarity.."color"]
	frame.ImageRectOffset = Vector2.new(0,100*rarity)
	--frame.ImageColor3 = Styles.colors["rare"..rarity.."color"]
end

local rarityNames = {"Basic","Common","Rare","Very Rare","Awesome","Legendary","Unique","Special","Super Special"}
function RenderItem:rarityText(textLabel,rarity)
	textLabel.Text = rarityNames[rarity+1]
	textLabel.TextColor3 = Styles.colors["rare"..rarity.."color"]
end

function RenderItem:icon(frame,itemType,itemData)
	if itemType == "Crowns" then
		local model = game.ReplicatedStorage.Assets.Misc.CrownCoinModel:Clone()
		-- Set up 3D preview
		local CustomFrame = Gui3D.new(model)
		local orientation =  Vector3.new(0,0,0)
		CustomFrame.setOrientation(orientation)
		CustomFrame.Frame.ZIndex = frame.ZIndex + 1
		CustomFrame.Frame.Name = "CrownCoin"
		return CustomFrame
	end
	if itemType == "Tools" then
		local model = import(itemData.model):Clone()
		ToolCosmetics:skin(game.Players.LocalPlayer.Team,model,itemData.name)
		-- Set up 3D preview
		local CustomFrame = Gui3D.new(model)
		local orientation =  itemData.previewRotation or Vector3.new(0,0,0)
		CustomFrame.setOrientation(orientation)
		CustomFrame.Frame.ZIndex = frame.ZIndex
		return CustomFrame
	end
	if itemType == "Stickers" then
		local CustomFrame = Instance.new("ImageLabel")
		CustomFrame.BackgroundTransparency = 1
		CustomFrame.BorderSizePixel = 0
		CustomFrame.Size = UDim2.new(1,0,1,0)
		CustomFrame.Position = UDim2.new(0.5,0,0.5,0)
		CustomFrame.AnchorPoint = Vector2.new(0.5,0.5)
		--print(itemData.name)
		CustomFrame.Image = itemData.img
		CustomFrame.ImageRectOffset = Vector2.new(itemData.offset.X-1,itemData.offset.Y-1)*160
		CustomFrame.ImageRectSize = Vector2.new(160,160)
		CustomFrame.ZIndex = frame.ZIndex
		return CustomFrame
	end
end

return RenderItem
