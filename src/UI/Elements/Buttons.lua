local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local CollectionService = game:GetService("CollectionService")


local UiState = import "UI/UiState"
local Styles = import "UI/Styles"

local Buttons = {}

function Buttons:BasicClickable(button)

end

function Buttons:Sidebar(button,window)
	local baseSize = button.icon.Size
	button.MouseEnter:connect(function()
		button.icon:TweenSize(UDim2.new(baseSize.X.Scale*0.8,0,baseSize.Y.Scale*0.8,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.2,true)
		UiState.Sounds.Select:Play()
	end)
	button.MouseLeave:connect(function()
		button.icon:TweenSize(baseSize,Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.2,true)
	end)
end

function Buttons:ShowRarity(frame,rarity)
	for _,star in pairs(frame:GetChildren()) do
		if (star.Name == "star1" and rarity > 0) or (star.Name == "star2" and rarity > 1) or (star.Name == "star3" and rarity > 2) then
			star.Visible = true
			star.ImageColor3 = Styles.colors["rare"..rarity.."color"]
		elseif rarity==0 then
			star.Visible = false
		end
	end
end

function Buttons:IconShrinkButton(button)
	local baseSize = button.icon.Size
	button.MouseEnter:connect(function()
		button.icon:TweenSize(UDim2.new(baseSize.X.Scale*0.8,0,baseSize.Y.Scale*0.8,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.2,true)
		UiState.Sounds.Select:Play()
	end)
	button.MouseLeave:connect(function()
		button.icon:TweenSize(baseSize,Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.2,true)
	end)
end

return Buttons
