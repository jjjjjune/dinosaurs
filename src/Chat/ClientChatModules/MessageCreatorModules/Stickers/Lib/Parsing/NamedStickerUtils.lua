---
-- @module NamedStickerUtils
-- @author Quenty

local require = require(script:FindFirstAncestorOfClass("ModuleScript"))

local TextTypes = require("TextTypes")
local TextUtils = require("TextUtils")

local NamedStickerUtils = {}

function NamedStickerUtils.replaceNamedStickers(stack, stickerProviderService)
	assert(stickerProviderService)

	local index = 1
	local hasSticker = false

	while index <= #stack do
		local item = stack[index]
		if item and item.type == TextTypes.NAMED_STICKER then
			local registryEntry = stickerProviderService:GetStickerRegistryFromName(item.stickerName)

			table.remove(stack, index)

			if registryEntry then
				hasSticker = true
				table.insert(stack, index, TextUtils.createSticker(registryEntry))
			else
				-- Revert back to original... failed to find emoji
				table.insert(stack, index, TextUtils.createWord((":%s:"):format(item.stickerName)))
			end
		end

		index = index + 1
	end

	return hasSticker
end

return NamedStickerUtils