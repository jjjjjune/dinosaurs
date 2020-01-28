---
-- @module StickerUtils
-- @author Quenty

local require = require(script:FindFirstAncestorOfClass("ModuleScript"))

local import = require(game.ReplicatedStorage.Shared.Import)

local FormatStickerTag = import "Shared/Utils/FormatStickerTag"

local TextTypes = require("TextTypes")
local TextUtils = require(script.Parent.TextUtils)

local StickerUtils = {}

local stickerDataReceiver = import "Client/Systems/StickerDataReceiver"

function StickerUtils.parseStickers(stack, messageObject)
	local index = 1
	while index <= #stack do
		local before, tag, after = StickerUtils.getBrokenParts(stack, index)
		if tag then
			table.remove(stack, index)

			if before then
				table.insert(stack, index, TextUtils.createWord(before))
				index = index + 1
			end

			if stickerDataReceiver and messageObject.FromSpeaker and stickerDataReceiver.stickerData and stickerDataReceiver.stickerData[messageObject.FromSpeaker] then
				if stickerDataReceiver.stickerData[messageObject.FromSpeaker][FormatStickerTag(tag)] then 
				table.insert(stack, index, TextUtils.createNamedSticker(FormatStickerTag(tag)))
				else
					table.insert(stack, index, TextUtils.createFailedWord(":"..tag..":"))
					index = index + 1 
				end
			else
				table.insert(stack, index, TextUtils.createFailedWord(":"..tag..":"))
				index = index + 1
			end

			if after then
				index = index + 1
				table.insert(stack, index, TextUtils.createWord(after))
			end
		else
			index = index + 1
		end
	end
end

function StickerUtils.getBrokenParts(stack, index)
	local item = stack[index]
	if item.type ~= TextTypes.WORD then
		return nil, nil, nil
	end

	local text = item.text

	local start, _end = text:find(":[^:]+:")
	if not start then
		return nil, nil, nil
	end

	local beforeText = start > 1 and text:sub(1, start-1) or nil
	local tag = text:sub(start + 1, _end -1)
	local afterText = _end < #text and text:sub(_end + 1) or nil

	tag = FormatStickerTag(tag)

	return beforeText, tag, afterText
end

return StickerUtils