local import = require(game.ReplicatedStorage.Shared.Import)

local TweenService = game:GetService("TweenService")

local RunService = game:GetService("RunService")

local Messages = import "Shared/Utils/Messages"

local LightingData = import "Shared/Data/LightingData"

local sounds = {
    ["Rainforest"] = "rbxassetid://4967510105",
    ["Desert"] = "rbxassetid://4967507617",
    ["Forest"] = "rbxassetid://4967508836",
    ["Ocean"] = "rbxassetid://419321414",
}

local maxVolumes = {
    ["Rainforest"] = .01,
    ["Ocean"] = .03,
    ["Desert"] = .2,
}

local lastTweens = {}

local soundInstances = {}
local soundChannels = {}

local lastSoundChange = tick()
local lastBiome
local lastNightString

local function playSound(channel, sound)
    local goals = {
        Volume = maxVolumes[sound] or 1
    }
    local info = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local oldSound = soundChannels[channel]

    if oldSound and oldSound.Name ~= sound and(tick() - lastSoundChange > 1) then
        local tween

        if sound ~= nil then
            --print("we are playing: ", sound)
            tween = TweenService:Create(soundInstances[sound], info, goals)
            tween:Play()
        end

        goals = {
            Volume = 0
        }

        tween = TweenService:Create(oldSound, info, goals)
        tween:Play()

        lastSoundChange = tick()

        soundChannels[channel] = soundInstances[sound]
    else
        if sound then
         local tween = TweenService:Create(soundInstances[sound], info, goals)
            tween:Play()
        end
        soundChannels[channel] = soundInstances[sound]
    end
end

local function setBiomeLighting(biome)
	if biome == nil then
		return
	end
	local nightString = "Day"
	if tick()%120 > 60 then
		nightString = "Night"
	end
	if biome == lastBiome and nightString == lastNightString then
		return
	end
	lastBiome = biome
	lastNightString = nightString
	for i, tween in pairs(lastTweens) do
        if tween.PlaybackState == Enum.PlaybackState.Playing then
			tween:Pause()
			lastTweens[i] = nil
        end
	end
    lastTweens = {}
    local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
    for instance, properties in pairs(LightingData[biome][nightString]) do
        local tween = TweenService:Create(instance, tweenInfo, properties)
        table.insert(lastTweens, tween)
        tween:Play()
    end
end

local function isWithin(position, part)
    local barrierCorner1 = part.Position - Vector3.new(part.Size.X/2,0,part.Size.Z/2)
    local barrierCorner2 = part.Position + Vector3.new(part.Size.X/2,0,part.Size.Z/2)
    local x1, y1, x2, y2 = barrierCorner1.X, barrierCorner1.Z, barrierCorner2.X, barrierCorner2.Z
    if position.X > x1 and position.X < x2 then
        if position.Z > y1 and position.Z < y2 then
            return true
        end
    end
end

local function biomeSoundStep()
    local pos = workspace.CurrentCamera.CFrame.p
    local biome = nil
    for _, v in pairs(workspace.Tiles:GetChildren()) do
        for _, tile in pairs(v:GetChildren()) do
            if tile.PrimaryPart and isWithin(pos, tile.PrimaryPart) and tile.PrimaryPart.Position.Y >= workspace.Effects.Sand.Position.Y - 100 then
                biome = tile.Biome.Value
            end
        end
    end
	playSound("BiomeChannel", biome)
	setBiomeLighting(biome)
end

local BiomeSounds = {}

function BiomeSounds:start()
    for biome, soundId in pairs(sounds) do
        soundInstances[biome] = Instance.new("Sound")
        local sound = soundInstances[biome]
        sound.Parent = workspace
        sound.Volume = 0
        sound.Looped = true
        sound.Name = biome
        sound.SoundId = soundId
        sound:Play()
    end
    playSound("OceanChannel", "Ocean")
    RunService.Stepped:connect(biomeSoundStep)
end

return BiomeSounds
