local import = require(game.ReplicatedStorage.Shared.Import)
local SoundsFolder = game.ReplicatedStorage.Sounds
local Debris = game:GetService("Debris")
local Messages = import "Shared/Utils/Messages"

local ClientSound = {}

function ClientSound:start()
    Messages:hook("PlaySoundOnClient", function(soundInfo)
        local soundInstance = soundInfo.instance or SoundsFolder:FindFirstChild(soundInfo.soundName)
        soundInstance = soundInstance:Clone()
        if soundInfo.position then
            local soundAttachment = Instance.new("Attachment", workspace.Terrain)
            Debris:AddItem(soundAttachment, soundInstance.TimeLength)
            soundAttachment.CFrame = CFrame.new(soundInfo.position)
            soundInstance.Parent = soundAttachment
        elseif soundInfo.part then
            soundInstance.Parent = soundInfo.part
            Debris:AddItem(soundInstance, soundInstance.TimeLength)
        else
            soundInstance.Parent = workspace
            Debris:AddItem(soundInstance, soundInstance.TimeLength)
        end
        soundInstance:Play()
    end)
end

return ClientSound