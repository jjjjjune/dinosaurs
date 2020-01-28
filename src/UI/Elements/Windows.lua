local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"
local Buttons = import "UI/Elements/Buttons"
local UiState= import "UI/UiState"
local Styles = import "UI/Styles"
local InputData = import "Client/Data/InputData"
local GuiService = game:GetService("GuiService")

local Windows = {}
Windows.__index = Windows

function Windows:open(openUnder)
	if self.opened == true then return end
	self.opened = true
	self.frame.Visible = true
	Messages:send("OnWindowOpenedInitial",self.name,openUnder)
end

function Windows:close()
	if self.opened == false then return end
	self.frame.Visible = false
	self.opened = false
	Messages:send("OnWindowClosedInitial",self.name)
	if InputData.inputType == "Touch" then
		GuiService.SelectedObject = nil
	end
end

function Windows:spawn()
	local CloseButton = self.frame:FindFirstChild("CloseButton")
	if CloseButton then
		Buttons:IconShrinkButton(CloseButton)
		CloseButton.MouseButton1Click:connect(function()
			if UiState.openWindows[1] ~= self.name then return end
			UiState.Sounds.Back:Play()
			self:close()
		end)
	end

	--[[Messages:hook("OpenCloseWindow",function(name)
		if name == self.name then
			if self.opened == false then
				self:open()
				print("Opening "..self.name)
			else
				self:close()
				print("Closing "..self.name)
			end
		end
	end)
	Messages:hook("OpenWindow",function(name)
		if name == self.name then
			self:open()
		end
	end)
	Messages:hook("CloseWindow",function(name)
		if name == self.name then
			self:close()
		end
	end)
	Messages:hook("CloseAllWindows",function(name)
		if self.opened == true then
			self:close()
		end
	end)--]]
	--Window.Windows[self.name] = self
end

function Windows.new(frame)
	local self = {}
	self.frame = frame
	self.name = frame.Name
	self.opened = false
	return setmetatable(self, Windows)
end

return Windows
