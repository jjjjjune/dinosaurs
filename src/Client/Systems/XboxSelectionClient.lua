local import = require(game.ReplicatedStorage.Shared.Import)

local GuiService = game:GetService("GuiService")

local XboxSelectionClient = {}

function XboxSelectionClient:start()
	GuiService.AutoSelectGuiEnabled = false
	GuiService.GuiNavigationEnabled = false
	local PlayerGui= game.Players.LocalPlayer.PlayerGui
	PlayerGui.SelectionImageObject = PlayerGui.Templates.SelectionImage
end


return XboxSelectionClient
