--	// FileName: DefaultChatMessage.lua
--	// Written by: TheGamer101
--	// Description: Create a message label for a standard chat message.

local import = require(game.ReplicatedStorage.Shared.Import)

local clientChatModules = script.Parent.Parent
local ChatSettings = require(clientChatModules:WaitForChild("ChatSettings"))
local ChatConstants = require(clientChatModules:WaitForChild("ChatConstants"))
local util = require(script.Parent:WaitForChild("Util"))

local StickerRender = require(script.Parent:WaitForChild("Stickers"):WaitForChild("StickerRender"))

local chatColors = {
	BrickColor.new("Bright green").Color,
	BrickColor.new("Bright blue").Color,
	BrickColor.new("Persimmon").Color,
	BrickColor.new("Bright orange").Color,
	BrickColor.new("Br. yellowish green").Color,
	BrickColor.new("Olive").Color,
}

local function CreateMessageLabel(messageData, channelName)
	local fromSpeaker = messageData.FromSpeaker

	local teamColor = ChatSettings.DefaultNameColor
	if game.Players:FindFirstChild(messageData.FromSpeaker) then
		teamColor = game.Players[messageData.FromSpeaker].Team.TeamColor.Color
		if game.Players[messageData.FromSpeaker].Team == game.Teams.Spectators then
			local randomObj = Random.new(game.Players[messageData.FromSpeaker].UserId)
			teamColor = chatColors[randomObj:NextInteger(1, #chatColors)]
		end
	end
	local extraData = messageData.ExtraData or {}
	local useFont = extraData.Font or ChatSettings.DefaultFont
	local useTextSize = extraData.TextSize or ChatSettings.ChatWindowTextSize
	local useNameColor = extraData.NameColor or teamColor
	local useChatColor = extraData.ChatColor or ChatSettings.DefaultMessageColor
	local useChannelColor = extraData.ChannelColor or useChatColor
	local tags = extraData.Tags or {}

	local formatUseName = string.format("[%s]:", fromSpeaker)
	local numNeededSpaces = util:GetNumberOfSpaces(formatUseName, useFont, useTextSize) + 1

	local BaseFrame, BaseMessage = util:CreateBaseMessage("", useFont, useTextSize, useChatColor)
	local NameButton = util:AddNameButtonToBaseMessage(BaseMessage, useNameColor, formatUseName, fromSpeaker)
	local ChannelButton = nil

	local guiObjectSpacing = UDim2.new(0, 0, 0, 0)

	if channelName ~= messageData.OriginalChannel then
			local formatChannelName = string.format("{%s}", messageData.OriginalChannel)
			ChannelButton = util:AddChannelButtonToBaseMessage(BaseMessage, useChannelColor, formatChannelName, messageData.OriginalChannel)
			guiObjectSpacing = UDim2.new(0, ChannelButton.Size.X.Offset + util:GetStringTextBounds(" ", useFont, useTextSize).X, 0, 0)
			numNeededSpaces = numNeededSpaces + util:GetNumberOfSpaces(formatChannelName, useFont, useTextSize) + 1
	end

	local tagLabels = {}
	for _, tag in pairs(tags) do
		local tagColor = tag.TagColor or Color3.fromRGB(255, 0, 255)
		local tagText = tag.TagText or "???"
		local formatTagText = string.format("[%s] ", tagText)
		local label = util:AddTagLabelToBaseMessage(BaseMessage, tagColor, formatTagText)
		label.Position = guiObjectSpacing

		numNeededSpaces = numNeededSpaces + util:GetNumberOfSpaces(formatTagText, useFont, useTextSize)
		guiObjectSpacing = guiObjectSpacing + UDim2.new(0, label.Size.X.Offset, 0, 0)

		table.insert(tagLabels, label)
	end

	NameButton.Position = guiObjectSpacing

	local function UpdateTextFunction(messageObject)
		if messageData.IsFiltered then
			BaseMessage.Text = string.rep(" ", numNeededSpaces) .. messageObject.Message
		else
			BaseMessage.Text = string.rep(" ", numNeededSpaces) .. string.rep("_", messageObject.MessageLength)
		end
	end

	UpdateTextFunction(messageData)

	local function GetHeightFunction(xSize)
		return util:GetMessageHeight(BaseMessage, BaseFrame, xSize)
	end

	local FadeParmaters = {}
	FadeParmaters[NameButton] = {
		TextTransparency = {FadedIn = 0, FadedOut = 1},
		TextStrokeTransparency = {FadedIn = 0.75, FadedOut = 1}
	}

	FadeParmaters[BaseMessage] = {
		TextTransparency = {FadedIn = 0, FadedOut = 1},
		TextStrokeTransparency = {FadedIn = 0.75, FadedOut = 1}
	}

	for _, tagLabel in pairs(tagLabels) do
		FadeParmaters[tagLabel] = {
			TextTransparency = {FadedIn = 0, FadedOut = 1},
			TextStrokeTransparency = {FadedIn = 0.75, FadedOut = 1}
		}
	end

	if ChannelButton then
		FadeParmaters[ChannelButton] = {
			TextTransparency = {FadedIn = 0, FadedOut = 1},
			TextStrokeTransparency = {FadedIn = 0.75, FadedOut = 1}
		}
	end

	local FadeInFunction, FadeOutFunction, UpdateAnimFunction = util:CreateFadeFunctions(FadeParmaters)

	local stickerRender = StickerRender.new(numNeededSpaces)
	return stickerRender:Init(BaseFrame, BaseMessage, messageData)

	-- return {
	-- 	[util.KEY_BASE_FRAME] = BaseFrame,
	-- 	[util.KEY_BASE_MESSAGE] = BaseMessage,
	-- 	[util.KEY_UPDATE_TEXT_FUNC] = UpdateTextFunction,
	-- 	[util.KEY_GET_HEIGHT] = GetHeightFunction,
	-- 	[util.KEY_FADE_IN] = FadeInFunction,
	-- 	[util.KEY_FADE_OUT] = FadeOutFunction,
	-- 	[util.KEY_UPDATE_ANIMATION] = UpdateAnimFunction
	-- }
end

return {
	[util.KEY_MESSAGE_TYPE] = ChatConstants.MessageTypeDefault,
	[util.KEY_CREATOR_FUNCTION] = CreateMessageLabel
}
