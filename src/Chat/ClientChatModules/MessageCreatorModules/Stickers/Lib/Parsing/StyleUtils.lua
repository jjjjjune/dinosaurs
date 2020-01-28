---
-- @module StyleUtils
-- @author Quenty

local require = require(script:FindFirstAncestorOfClass("ModuleScript"))

local TextTypes = require("TextTypes")
local ChatSettings = require("ChatSettings")

local StyleUtils = {}

function StyleUtils.getStyleFromStack(styleStack)
	local style = {}

	for i=#styleStack, 1, -1 do
		local item = styleStack[i]
		style.font = style.font or item.font
		style.textColor3 = style.textColor3 or item.textColor3
		style.textSize = style.textSize or item.textSize
		style.textStrokeTransparency = style.textStrokeTransparency or item.textStrokeTransparency
	end

	return style
end

function StyleUtils.createPushStyle(options)
	return {
		type = TextTypes.PUSH_STYLE;
		textSize = options.textSize;
		textColor3 = options.textColor3;
		font = options.font;
		textStrokeTransparency = options.textStrokeTransparency;
	}
end

function StyleUtils.createPopStyle()
	return {
		type = TextTypes.POP_STYLE;
	}
end

function StyleUtils.createPushDefaultStyle()
	return StyleUtils.createPushStyle({
		font = ChatSettings.DefaultFont;
		textColor3 = ChatSettings.DefaultMessageColor;
		textSize = ChatSettings.ChatWindowTextSize;
		textStrokeTransparency = 0.75;
	})
end

function StyleUtils.createDefaultStack()
	return {
		StyleUtils.createPushDefaultStyle()
	}
end

return StyleUtils