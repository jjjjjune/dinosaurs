local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"
local AnimationsFolder = import "ReplicatedStorage/Animations"

local Animations = {}

local characterToTracksTable = {}
local function getTrack(character, animationName)
	if not character.Humanoid:IsDescendantOf(game) then
		return
	end
    if not character:FindFirstChild(animationName) then
        return
    end
    if not characterToTracksTable[character] then
        characterToTracksTable[character] = {}
    end
    if not characterToTracksTable[character][animationName] then
		characterToTracksTable[character][animationName] = character.Humanoid:LoadAnimation(character[animationName])
		characterToTracksTable[character][animationName]:GetMarkerReachedSignal("AnimEvent"):Connect(function(value)
			Messages:sendClient(game.Players:GetPlayerFromCharacter(character),"AnimEvent",value)
		end)
    end
    return characterToTracksTable[character][animationName]
end

function Animations:start()

    Messages:hook("PlayAnimation", function(character, animationName, speed, blend)
        if not character:FindFirstChild(animationName) then
            local anim = AnimationsFolder[animationName]:Clone()
            anim.Parent = character
		end
		speed = speed~=nil and speed or 1
		blend = blend~=nil and blend or 0.1
        getTrack(character, animationName):Play(blend,1,speed)
    end)

    Messages:hook("StopAnimation", function(character, animationName)
        if getTrack(character, animationName) then
            getTrack(character, animationName):Stop()
        end
    end)

    Messages:hook("PlayAnimationServer", function(player,animationName)
        local character = player.Character
        if not character:FindFirstChild(animationName) then
            local anim = AnimationsFolder[animationName]:Clone()
            anim.Parent = character
        end
        getTrack(character, animationName):Play()
    end)

    Messages:hook("StopAnimationServer", function(player, animationName)
        local character = player.Character
		local track = getTrack(character, animationName)
		if track then
			track:Stop()
		end
    end)
end


return Animations
