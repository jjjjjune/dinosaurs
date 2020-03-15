--[[
    Messages:reproOnClients(player, "PlaySound", "HeavyWhoosh", item.PrimaryPart.Position)
]]
local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local swings = 0

local function getSwingAnimation()
    local swingAnims = {
        "SwingEnd"
    }
    return swingAnims[swings%(#swingAnims) + 1]
end

local Tool = {}

Tool.debounce = .4

function Tool.clientUse(item)
    delay(.2, function()
        Messages:send("PlaySoundOnClient",{
            instance = game.ReplicatedStorage.Sounds.Swing1,
            part = item.PrimaryPart,
        })
    end)
    Messages:send("PlayAnimationClient", getSwingAnimation())
    swings = swings + 1
end

function Tool.serverUse(player, item)
    Messages:reproOnClients(player, "PlaySound", "Swing2", item.PrimaryPart.Position)
end

function Tool.clientEquip(item)
end

function Tool.serverEquip(player, item)
end

function Tool.clientUnequip(item)
end

function Tool.serverUnequip(player, item)
end

return Tool