---
-- @module TextUtils
-- @author Quenty

local require = require(script:FindFirstAncestorOfClass("ModuleScript"))

local TextTypes = require("TextTypes")

local TextUtils = {}

local WORD_SPLIT_WHITESPACE = {
	[" "] = true;
	["\n"] = true;
}

function TextUtils.splitIntoWords(text)
	assert(text)

	local words = {}
	local current = ""
	local lastWasWhitespace = false

	for first, last in utf8.graphemes(text) do
		local grapheme = text:sub(first, last)

		if WORD_SPLIT_WHITESPACE[grapheme] then
			if grapheme == "\n" then
				-- Never collect \n
				if #current > 0 then
					table.insert(words, current)
				end
				table.insert(words, grapheme)
				current = ""
				lastWasWhitespace = false
			else
				-- collect whitespace
				current = current .. grapheme
				lastWasWhitespace = true
			end
		else
			-- added collected whitespace
			if lastWasWhitespace then
				table.insert(words, current)
				current = grapheme
			else
				current = current .. grapheme
			end
			lastWasWhitespace = false
		end
	end

	if #current > 0 then
		table.insert(words, current)
	end

	return words
end

function TextUtils.parseWordsToStack(words)
	local stack = {}

	for _, word in pairs(words) do
		table.insert(stack, TextUtils.createWord(word))
	end

	return stack
end

function TextUtils.createFailedWord(text)
	assert(text)
	assert(#text > 0)

	return {
		type = TextTypes.WORD;
		text = text;
		failed = true;
	}
end

function TextUtils.createWord(text)
	assert(text)
	assert(#text > 0)

	return {
		type = TextTypes.WORD;
		text = text;
	}
end

function TextUtils.createNamedSticker(stickerName)
	return {
		type = TextTypes.NAMED_STICKER;
		stickerName = stickerName;
	}
end

function TextUtils.createSticker(registryEntry, percentSize)
	assert(type(registryEntry) == "table")
	assert(registryEntry.type)

	return {
		type = TextTypes.STICKER;
		registryEntry = registryEntry;
		percentSize = percentSize or 1;
	}
end

function TextUtils.createPositionedWord(text, offsetX, size)
	assert(text)
	assert(offsetX)
	assert(size)
	assert(#text > 0)

	return {
		type = TextTypes.POSITIONED_WORD;
		text = text;
		offsetX = offsetX;
		size = size;
	}
end

function TextUtils.createPositionedSticker(registryEntry, offsetX, size)
	assert(type(registryEntry) == "table")
	assert(registryEntry.type)

	return {
		type = TextTypes.POSITIONED_STICKER;
		registryEntry = registryEntry;
		offsetX = offsetX;
		size = size;
	}
end

return TextUtils