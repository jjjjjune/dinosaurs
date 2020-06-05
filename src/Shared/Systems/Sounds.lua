local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local SoundsFolder = import "ReplicatedStorage/Sounds"
local Sounds = {}
local SoundFolderCache = {}

local function makeSoundPart(position)
    local part = Instance.new("Attachment", workspace.Terrain)
    part.WorldPosition = position
	game:GetService("Debris"):AddItem(part, 5)
	part.Name = "SoundAttachment"
    return part
end

local function playSoundObj(sound,pitchShift)
	if sound == nil or sound.Parent == nil or sound.Parent == workspace then return end
	if pitchShift then sound.PlaybackSpeed=math.random(1000-pitchShift,1000+pitchShift)*0.001 end
	if sound then sound:Play() end
end

local function playSound(soundName, position, group, pitchshift, useFolder, forcePitch)
    local sound
	local part

	local folder = SoundsFolder
	if useFolder then
		folder = useFolder
	end
	if SoundFolderCache[folder] == nil then SoundFolderCache[folder] = {} end

	if position then
		if typeof(position) == "Instance" then
			part = position
			if part == nil or part.Parent == nil then return end
		else
			part = makeSoundPart(position)
		end
		--If it finds a folder, play one of the random sounds inside, otherwise just play the Sound
		if folder[soundName]:IsA("Folder") then
			if SoundFolderCache[folder][soundName]==nil then SoundFolderCache[folder][soundName]=folder[soundName]:GetChildren() end
			sound = SoundFolderCache[folder][soundName][math.random(1,#SoundFolderCache[folder][soundName])]:clone()
		else
			sound = folder[soundName]:Clone()
		end
		--shift sound's pitch randomly
		
	else
        sound = folder[soundName]:Clone()
	end
	if pitchshift then
		if forcePitch then
			sound.PlaybackSpeed = pitchshift
		else
			sound.PlaybackSpeed=math.random(1000-pitchshift,1000+pitchshift)/1000
		end
	end
	if group then
		sound.SoundGroup = game:GetService("SoundService")[group]
	end
    sound.Parent = part or workspace
	sound:Play()
	if sound.Parent == workspace then
		game:GetService("Debris"):AddItem(sound, 5)
	end
end

function Sounds:start()
	Messages:hook("PlaySoundServer", function(player, soundName, position, group, pitchshift)
        playSound(soundName, position, group, pitchshift)
	end)
	Messages:hook("PlaySoundObjectServer", function(player, sound, pitchshift)
        playSoundObj(sound, pitchshift)
	end)
	Messages:hook("PlaySoundObject", function(sound,pitchshift)
		playSoundObj(sound, pitchshift)
	end)
    Messages:hook("PlaySound", function(soundName, position, pitchshift, forcepitch)
        playSound(soundName, position, nil, pitchshift, nil, forcepitch)
    end)

	Messages:hook("PlaySoundClient", function(soundName, position, group)
		playSound(soundName, position, group)
    end)
end


return Sounds
