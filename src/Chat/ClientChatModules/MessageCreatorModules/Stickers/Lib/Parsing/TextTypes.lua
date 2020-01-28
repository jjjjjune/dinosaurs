---
-- @module TextTypes
-- @author Quenty

local require = require(script:FindFirstAncestorOfClass("ModuleScript"))

local Table = require("Table")

return Table.ReadOnly({
	POP_STYLE = "popStyle";
	PUSH_STYLE = "pushStyle";
	WORD = "word";
	NAMED_STICKER = "namedSticker";
	STICKER = "sticker";
	POSITIONED_WORD = "positionedWord";
	POSITIONED_STICKER = "positionedSticker";
})