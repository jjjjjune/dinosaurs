---
-- @module LineUtils
-- @author Quenty

local require = require(script:FindFirstAncestorOfClass("ModuleScript"))

local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")

local LineTypes = require("LineTypes")
local TextTypes = require("TextTypes")
local TextUtils = require("TextUtils")
local StyeUtils = require("StyleUtils")

local LARGE_V2 = Vector2.new(1e6, 1e6)
local MIN_LINE_HEIGHT = 10
local LINE_PADDING = 0

local LineUtils = {}

local function searchStackForNextWord(stack, index)
	for i=index+1, #stack do
		if stack[i].type == TextTypes.WORD then
			return stack[i]
		end
	end

	return nil
end

function LineUtils.createLine(items, offsetY, height, width)
	assert(items)
	assert(offsetY)
	assert(height)
	assert(width)

	return {
		type = LineTypes.LINE;
		offsetY = offsetY;
		height = height;
		width = width;
		items = items;
	}
end

function LineUtils.parseStackToLines(stack, maxWidth)
	local lines = {}

	local currentWidth = 0
	local currentLineOffset = 0
	local currentStyleStack = StyeUtils.createDefaultStack()
	local currentStyle = StyeUtils.getStyleFromStack(currentStyleStack)
	local currentLineHeight = math.max(MIN_LINE_HEIGHT, currentStyle.textSize)
	local currentLineItems = { }

	local function endLine()
		local newLine = LineUtils.createLine(currentLineItems, currentLineOffset, currentLineHeight, currentWidth)
		table.insert(lines, newLine)
		currentLineItems = { }
		currentWidth = 0
		currentLineOffset = currentLineOffset + newLine.height + LINE_PADDING
		currentLineHeight = math.max(MIN_LINE_HEIGHT, currentStyle.textSize)
	end

	for index, item in pairs(stack) do
		if item.type == TextTypes.WORD then
			local text = item.text
			if #text == 0 then
				warn("[LineUtils.parseStackToLines] - Got word object with no text!")
			end

			-- -- Strip whitespace from end when there is no next word
			-- local nextWord = searchStackForNextWord(stack, index)
			-- if not nextWord then
			-- 	text = text:gsub("(.-)[ ]+$", "%1")
			-- end

			if #text > 0 then
				local size = TextService:GetTextSize(text, currentStyle.textSize, currentStyle.font, LARGE_V2)

				if currentWidth + size.x > maxWidth then
					endLine()
				end

				currentLineHeight = math.max(currentLineHeight, size.y)

				table.insert(currentLineItems, TextUtils.createPositionedWord(text, currentWidth, size))
				currentWidth = currentWidth + size.x
			end
		elseif item.type == TextTypes.PUSH_STYLE then
			table.insert(currentStyleStack, item)
			table.insert(currentLineItems, item)
			currentStyle = StyeUtils.getStyleFromStack(currentStyleStack)
			currentLineHeight = math.max(currentLineHeight, currentStyle.textSize)
		elseif item.type == TextTypes.POP_STYLE then
			assert(#currentStyleStack > 1, "Popping default style is not allowed")
			table.remove(currentStyleStack)
			table.insert(currentLineItems, item)
			currentStyle = StyeUtils.getStyleFromStack(currentStyleStack)
			currentLineHeight = math.max(currentLineHeight, currentStyle.textSize)
		elseif item.type == TextTypes.STICKER then
			local size = Vector2.new(currentStyle.textSize, currentStyle.textSize)*item.percentSize

			if currentWidth + size.x > maxWidth then
				endLine()
			end

			currentLineHeight = math.max(currentLineHeight, size.y)

			table.insert(currentLineItems, TextUtils.createPositionedSticker(item.registryEntry, currentWidth, size))
			currentWidth = currentWidth + size.x
		elseif item.type then
			warn(("[LineUtils.parseStackToLines] - Unknown item.type %q %q")
				:format(tostring(item.type), HttpService:JSONEncode(item)))
		else
			error("[LineUtils.parseStackToLines] - Bad item with no type")
		end
	end

	if #currentLineItems > 0 then
		table.insert(lines, LineUtils.createLine(currentLineItems, currentLineOffset, currentLineHeight, currentWidth))
	end

	return lines
end

return LineUtils