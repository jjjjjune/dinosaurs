---
-- @classmod StickerRender
-- @author Quenty

local require = require(script.Parent:WaitForChild("Lib"))

local MessageCreatorModulesUtil = require(script.Parent.Parent:WaitForChild("Util"))

local TextUtils = require("TextUtils")
local StickerUtils = require("StickerUtils")
local LineUtils = require("LineUtils")
local TextRenderer = require("TextRenderer")
local NamedStickerUtils = require("NamedStickerUtils")
local StyleUtils = require("StyleUtils")
local EnlargeStickers = require("EnlargeStickers")

-- Effective guestimated number from text rendering to keep width smaller than necessary to prevent
-- cutoff
local SUBTRACT_FROM_WIDTH_TO_PREVENT_CUTOFF = 8

-- NOTE: You should probably move this service to your own codebase and require accordingly
local StickerProviderService = require("StickerProviderService")

local StickerRender = {}
StickerRender.ClassName = "StickerRender"
StickerRender.__index = StickerRender

function StickerRender.new(addedSpaces)
	local self = setmetatable({}, StickerRender)

	self._addedSpaces = addedSpaces or error("No addedSpaces")

	return self
end

function StickerRender:Init(baseFrame, baseMessageLabel, messageObject)
	assert(baseFrame)
	assert(baseMessageLabel)
	assert(messageObject)
	assert(not self._textRender, "Already have a renderer!")

	-- Sanity checks to verify widith is calculated properly
	assert(baseMessageLabel.Size.X.Scale == 1)
	assert(baseMessageLabel.Size.X.Offset < 0)

	self._baseMessageLabel = baseMessageLabel or error("No baseMessageLabel")
	self._baseMessageLabel.Text = "" -- Hide message so we can render our own!

	-- render
	self._textRender = TextRenderer.new(self._baseMessageLabel)
	self._lastWidth = nil

	self:_setLastMessageObject(messageObject)

	return {
		[MessageCreatorModulesUtil.KEY_BASE_FRAME] = baseFrame,
		[MessageCreatorModulesUtil.KEY_BASE_MESSAGE] = baseMessageLabel,
		[MessageCreatorModulesUtil.KEY_UPDATE_TEXT_FUNC] = function(...)
			return self:_setLastMessageObject(...)
		end,
		[MessageCreatorModulesUtil.KEY_GET_HEIGHT] = function(...)
			return self:_getHeight(...)
		end,
	}
end

function StickerRender:_buildStack(messageObject, baseMessageLabel)
	local stack

	if messageObject.IsFiltered then
		local words = TextUtils.splitIntoWords(messageObject.Message)
		stack = TextUtils.parseWordsToStack(words)

		StickerUtils.parseStickers(stack, messageObject)
		NamedStickerUtils.replaceNamedStickers(stack, StickerProviderService)
		EnlargeStickers.enlargeStickersAsNeeded(stack)
	else
		stack = {}
		table.insert(stack, TextUtils.createWord(("_")
			:rep(messageObject.MessageLength)))
	end

	-- Prepend objects to stack
	table.insert(stack, 1, TextUtils.createWord((" "):rep(self._addedSpaces)))
	table.insert(stack, 1, StyleUtils.createPushStyle({
		textSize = baseMessageLabel.TextSize;
		textColor3 = baseMessageLabel.TextColor3;
		font = baseMessageLabel.Font;
	}))

	return stack
end

function StickerRender:_update()
	if not self._lastWidth then
		return
	end
	if not self._stack then
		return
	end

	local lines = LineUtils.parseStackToLines(self._stack, self._lastWidth)

	self._textRender:Clear()

	-- returns the height!
	self._lastHeight = self._textRender:Render(lines).y
	return self._lastHeight
end

function StickerRender:_getHeight(width, stack)
	width = width - SUBTRACT_FROM_WIDTH_TO_PREVENT_CUTOFF

	if self._lastWidth == width and self._lastHeight then
		return self._lastHeight
	end

	self._lastWidth = width
	return self:_update()
end

function StickerRender:_setLastMessageObject(messageObject)
	self._lastMessageObject = messageObject
	self._stack = self:_buildStack(messageObject, self._baseMessageLabel)
	self:_update()
end

return StickerRender