---
-- @module EnlargeStickers
-- @author Quenty

local require = require(script:FindFirstAncestorOfClass("ModuleScript"))

local TextTypes = require("TextTypes")
local TextUtils = require("TextUtils")

local EnlargeStickers = {}

local PERCENT_SIZE_ENLARGED = 2

function EnlargeStickers.enlargeStickersAsNeeded(stack)
	if not EnlargeStickers.shouldEnlargeStickers(stack) then
		return
	end

	local index = 1

	while index <= #stack do
		local item = stack[index]
		if item.type == TextTypes.STICKER then
			table.remove(stack, index)
			table.insert(stack, index,
				TextUtils.createSticker(item.registryEntry, PERCENT_SIZE_ENLARGED))
		end

		index = index + 1
	end
end

function EnlargeStickers.shouldEnlargeStickers(stack)
	local hasStickers = false
	local hasWordsWithText = false

	local index = 1

	while index <= #stack do
		local item = stack[index]
		if item.type == TextTypes.STICKER then
			hasStickers = true
		elseif item.type == TextTypes.WORD then
			-- Ignore whitespace only words
			if item.text:gsub(" ", "") ~= "" then
				hasWordsWithText = true
			end
		end

		index = index + 1
	end

	return hasStickers and (not hasWordsWithText)
end


return EnlargeStickers