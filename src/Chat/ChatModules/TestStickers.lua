--- Utility command script to test speaking
-- @module TestStickers
-- @author Quenty

local Players = game:GetService("Players")
local Chat = game:GetService("Chat")
local RunService = game:GetService("RunService")

local ChatSettings = require(Chat:WaitForChild("ClientChatModules"):WaitForChild("ChatSettings"))

local TestStickers = {}

function TestStickers:Init(chatService)
	self._chatService = chatService

	for _, player in pairs(Players:GetPlayers()) do
		spawn(function()
			self:_handleNewSpeaker(player.Name)
		end)
	end
	chatService.SpeakerAdded:Connect(function(speakerName)
		self:_handleNewSpeaker(speakerName)
	end)
end

function TestStickers:_handleNewSpeaker(speakerName)
	local speaker = self._chatService:GetSpeaker(speakerName)
	if not speaker then
		return
	end

	if not RunService:IsStudio() then
		return
	end
end

return function(chatService)
	TestStickers:Init(chatService)
end