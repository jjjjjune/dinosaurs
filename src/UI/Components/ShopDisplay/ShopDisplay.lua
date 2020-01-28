local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local StyleConstants = import "Shared/Data/StyleConstants"

local Roact = import "Roact"

local Frame = import "UI/Components/Frame"
local ToolData = import "Shared/Data/ToolData"

local STORE_ICON = "rbxassetid://3493981823"
local SEARCH_ICON = "rbxassetid://3494048854"

local OFFSET = Vector3.new(0,8,0)
local ShopDisplay = Roact.PureComponent:extend("ShopDisplay")
local player = game.Players.LocalPlayer

local myShop
local displayBillboard = Instance.new("BillboardGui")
displayBillboard.Size = UDim2.new(14,0,14,0)
displayBillboard.StudsOffset = OFFSET
displayBillboard.Name = "Display"
displayBillboard.Active = true
displayBillboard.AlwaysOnTop = true

function ShopDisplay:init()
	Messages:hook("SetShop", function(shop)
		myShop = shop
		if shop ~= nil then
			self:setState({visible = true})
		else
			self:setState({visible = false})
			displayBillboard.Adornee = nil
		end
	end)
	self.frameRef = Roact.createRef()
	game:GetService("RunService").RenderStepped:connect(function()
		if self.frameRef.current then
			self.frameRef.current.Parent = displayBillboard
			if myShop then
				displayBillboard.Parent = player.PlayerGui.GameUI
				displayBillboard.Adornee = myShop.PlatformDisplay
			end
		end
	end)
end

local function hasTool(tool)
	for _, t in pairs(_G.Data.weapons) do
		if t == tool then
			return true
		end
	end
	return false
end

function ShopDisplay:render()
	if myShop then
		displayBillboard.Adornee = myShop.PlatformDisplay
		local data = ToolData[myShop.Tool.Value]
		local camera= workspace.CurrentCamera
		local worldPoint = myShop.PlatformDisplay.Position
		local vector, _= camera:WorldToScreenPoint(worldPoint)
		local scale = 2
		local nameText = data.name:upper()
		local price = myShop.Price.Value
		local buyText = "BUY"
		local buyButtonColor = StyleConstants.YES_COLOR
		local dialogueText = "PURCHASE? ($"..price..")"
		if not hasTool(data.name) then
			nameText = nameText.."[LOCKED]"
			price = myShop.Price.Value
			buyButtonColor = StyleConstants.TAB_COLOR
			buyText = "UNLOCK"
			dialogueText = "UNLOCK? ($"..price..")"
		else
			buyText = "EQUIP"
			dialogueText = "EQUIP?"
		end
		return Frame({
			size = UDim2.new(0.45*scale,0,0.2*scale,0),
			position = UDim2.new(0.5,0,0.5,0),
			visible = self.state.visible,
			anchorPoint = Vector2.new(.5,.5),
			aspectRatio = 1.5,
			closeCallback = function()
				self:setState({visible = false})
			end,
			ref = self.frameRef
		}, {
			DescLabel = Roact.createElement("TextLabel", {
				Size = UDim2.new(.9,0,.35,0),
				Position = UDim2.new(.5,0,.15,0),
				BackgroundTransparency = 1,
				BackgroundColor3 = StyleConstants.CLOSE_COLOR,
				TextScaled = true,
				BorderSizePixel = 0,
				Text = nameText,
				Font = "SciFi",
				TextStrokeTransparency = 1,
				TextColor3 = Color3.new(0,0,0),
				ZIndex = 2,
				AnchorPoint = Vector2.new(.5,0),
			}),
			PriceLabel = Roact.createElement("TextLabel", {
				Size = UDim2.new(.75,0,.2,0),
				Position = UDim2.new(.5,0,.45,0),
				BackgroundTransparency = 1,
				TextScaled = true,
				Text =  "$"..price,
				Font = "SciFi",
				TextStrokeTransparency = .8,
				TextColor3 = Color3.new(1,1,1),
				ZIndex = 2,
				AnchorPoint = Vector2.new(.5,0),
			}),
			BuyButton = Roact.createElement("TextButton", {
				Size = UDim2.new(.5,0,.15,0),
				AnchorPoint = Vector2.new(.5,.5),
				BackgroundColor3 = buyButtonColor,
				BorderSizePixel = 0,
				TextScaled = true,
				Font = "SciFi",
				TextColor3 = Color3.new(1,1,1),
				Text = buyText,
				Position = UDim2.new(.5,0,.8,0),
				ZIndex = 4,
				[Roact.Event.Activated] = function()
					Messages:send("OpenYesNoDialogue", {
						text = dialogueText,
						yesCallback = function()
							Messages:sendServer("BuyTool", myShop)
						end,
					})
				end,
			}),
		})
	else
		displayBillboard.Adornee = nil
	end
end

return ShopDisplay
