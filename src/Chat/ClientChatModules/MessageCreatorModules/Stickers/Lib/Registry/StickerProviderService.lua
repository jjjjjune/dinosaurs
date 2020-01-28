---
-- @module StickerProviderService
-- @author Quenty

local import = require(game.ReplicatedStorage.Shared.Import)

local StickerData = import "Shared/Data/StickerData"

local require = require(script:FindFirstAncestorOfClass("ModuleScript"))

local FormatStickerTag = import "Shared/Utils/FormatStickerTag"

local StickerRegisterUtils = require("StickerRegisterUtils")

local StickerProviderService = {}

function StickerProviderService:registerAllStickers()
	for stickerId, stickerData in pairs(StickerData) do
		local size = Vector2.new(160,160)
		self:_addSticker(FormatStickerTag(stickerId), StickerRegisterUtils.createSprite(stickerData.img, (stickerData.offset- Vector2.new(1,1))*size,size))
	end
end

function StickerProviderService:Init()
	self._stickers = {}

	self:registerAllStickers()
	--[[self:registerAllStickers()
	-- register entries here!
	self:_addSticker("cheer", StickerRegisterUtils.createImage("rbxassetid://825077911"));
	self:_addSticker("cow", StickerRegisterUtils.createImage("rbxassetid://940701321"));
	self:_addSticker("heart", StickerRegisterUtils.createImage("rbxassetid://49502955"));
	self:_addSticker("dance", StickerRegisterUtils.createImage("rbxassetid://3144525437"));

	-- see:
	self:_addSticker("up",
		StickerRegisterUtils.createSprite("rbxassetid://1244652930", Vector2.new(800, 800), Vector2.new(100, 100)))--]]
end

function StickerProviderService:_addSticker(name, registryEntry)
	assert(not self._stickers[name], "Already added asset with this name")
	assert(type(registryEntry) == "table")

	self._stickers[name] = registryEntry
end

function StickerProviderService:GetStickerRegistryFromName(name)
	if self._stickers[name] then
		return self._stickers[name]
	else
		return nil
	end
end

-- HACK: Init self!
StickerProviderService:Init()

return StickerProviderService