---
-- @module StickerRegisterUtils
-- @author Quenty

local require = require(script:FindFirstAncestorOfClass("ModuleScript"))

local StickerEntryTypes = require("StickerEntryTypes")

local StickerRegisterUtils = {}

function StickerRegisterUtils.createImage(assetId)
	assert(type(assetId) == "string")

	return {
		type = StickerEntryTypes.IMAGE;
		assetId = assetId;
	}
end

function StickerRegisterUtils.createSprite(assetId, position, size)
	assert(type(assetId) == "string")
	assert(typeof(position) == "Vector2")
	assert(typeof(size) == "Vector2")

	return {
		type = StickerEntryTypes.SPRITE;
		assetId = assetId;
		position = position;
		size = size;
	}
end

return StickerRegisterUtils