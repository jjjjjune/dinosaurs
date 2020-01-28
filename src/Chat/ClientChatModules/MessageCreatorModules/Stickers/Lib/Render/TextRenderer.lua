---
-- @classmod TextRenderer
-- @author Quenty

local require = require(script:FindFirstAncestorOfClass("ModuleScript"))

local StyleUtils = require("StyleUtils")
local TextTypes = require("TextTypes")
local StickerEntryTypes = require("StickerEntryTypes")
local Math = require("Math")

local TextRenderer = {}
TextRenderer.ClassName = "TextRenderer"
TextRenderer.__index = TextRenderer

function TextRenderer.new(container)
	local self = setmetatable({}, TextRenderer)

	self._container = container or error("No container")
	self._labelCount = 0
	self._transparency = 0

	self._guis = {}

	return self
end

function TextRenderer:SetTransparency(transparency)
	if self._transparency == transparency then
		return
	end

	self._transparency = transparency or error("No transparency")

	for gui, defaultProps in pairs(self._guis) do
		self:_updateTransparency(gui, defaultProps)
	end
end

function TextRenderer:Clear()
	self._labelCount = 0
	for gui, _ in pairs(self._guis) do
		gui:Destroy()
	end
end

function TextRenderer:Render(lines)
	assert(lines)

	self._currentStyleStack = StyleUtils.createDefaultStack()
	self._currentStyle = StyleUtils.getStyleFromStack(self._currentStyleStack)

	local height = 0
	local width = 0
	for _, line in pairs(lines) do
		self:_renderLine(line)
		height = height + line.height
		if line.width > width then
			width = line.width
		end
	end
	return Vector2.new(width, height)
end

function TextRenderer:_renderLine(line)
	local textLabel = nil

	for _, item in pairs(line.items) do
		if item.type == TextTypes.PUSH_STYLE then
			table.insert(self._currentStyleStack, item)
			self._currentStyle = StyleUtils.getStyleFromStack(self._currentStyleStack)
			textLabel = nil
		elseif item.type == TextTypes.POP_STYLE then
			table.remove(self._currentStyleStack)
			self._currentStyle = StyleUtils.getStyleFromStack(self._currentStyleStack)
			textLabel = nil
		elseif item.type == TextTypes.POSITIONED_WORD then
			if not textLabel then
				textLabel = self:_getNewTextLabel(line, item)
				textLabel.Parent = self._container
				self._guis[textLabel] = {
					TextTransparency = textLabel.TextTransparency;
					TextStrokeTransparency = textLabel.TextStrokeTransparency;
				}
				self:_updateTransparency(textLabel, self._guis[textLabel])
			end

			textLabel.Size = textLabel.Size + UDim2.new(0, item.size.x, 0, 0)
			local startText = textLabel.Text

			textLabel.Text = startText .. item.text
		elseif item.type == TextTypes.POSITIONED_STICKER then
			local entry = item.registryEntry or error("No entry")
			assert(entry.assetId)

			local imageLabel = self:_getStickerImageLabel(line, item)
			if entry.type == StickerEntryTypes.IMAGE then
				imageLabel.Image = entry.assetId
			elseif entry.type == StickerEntryTypes.SPRITE then
				imageLabel.Image = entry.assetId
				imageLabel.ImageRectOffset = entry.position
				imageLabel.ImageRectSize = entry.size
			else
				error("[TextRenderer._renderLine] - Bad sprite entry try")
			end

			imageLabel.Parent = self._container
			self._guis[imageLabel] = {
				ImageTransparency = imageLabel.ImageTransparency;
			}
			self:_updateTransparency(imageLabel, self._guis[imageLabel])

			textLabel = nil
		else
			error(("[TextRenderer._renderLine] - Unknown type %q"):format(tostring(item.type)))
		end
	end
end

function TextRenderer:_updateTransparency(gui, defaultProps)
	for prop, value in pairs(defaultProps) do
		gui[prop] = Math.map(self._transparency, 0, 1, value, 1)
	end
end

function TextRenderer:_getStickerImageLabel(line, positionedSticker)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.BackgroundTransparency = 1
	imageLabel.Name = ("%03d_ChatSticker"):format(self._labelCount)
	imageLabel.AnchorPoint = Vector2.new(0, 0)
	imageLabel.Size = UDim2.new(0, positionedSticker.size.x, 0, positionedSticker.size.y)
	imageLabel.Position = UDim2.new(0, positionedSticker.offsetX, 0, line.offsetY)

	return imageLabel
end

function TextRenderer:_getNewTextLabel(line, positionedWord)
	assert(positionedWord.offsetX)
	assert(line.offsetY)
	assert(line.height)

	self._labelCount = self._labelCount + 1

	local textLabel = Instance.new("TextLabel")
	textLabel.Text = ""
	textLabel.Name = ("%03d_ChatTextLabel"):format(self._labelCount)
	textLabel.BackgroundTransparency = 1
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextYAlignment = Enum.TextYAlignment.Center
	textLabel.Font = self._currentStyle.font
	textLabel.TextSize = self._currentStyle.textSize
	textLabel.TextColor3 = self._currentStyle.textColor3
	textLabel.TextStrokeTransparency = self._currentStyle.textStrokeTransparency
	textLabel.Size = UDim2.new(0, 0, 0, line.height)
	textLabel.Position = UDim2.new(0, positionedWord.offsetX, 0, line.offsetY)

	return textLabel
end

return TextRenderer