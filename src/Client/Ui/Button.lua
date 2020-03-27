local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local debounce = {}

local function registerButton(button, buttonBG, callback)
    button.Activated:connect(function()
        if not debounce[button] then
            debounce[button] = tick()
        else
            if tick() - debounce[button] < .4 then
                return
            else
                debounce[button] = tick()
            end
        end
        callback()
        local originalPosition = button.Position
        button:TweenPosition(buttonBG.Position, "Out", "Quad", .1, true, function()
            button:TweenPosition(originalPosition, "Out", "Quad", .15, true)
        end)
        Messages:send("PlaySoundOnClient",{
            instance = game.ReplicatedStorage.Sounds.ClickHigh
        })
    end)
end

local Button = {}

function Button:start()
    Messages:hook("RegisterButton", registerButton)
end

return Button