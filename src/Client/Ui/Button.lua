local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local debounce = {}
local backgrounds = {}
local callbacks = {}

local function pressButton(button)
	if not debounce[button] then
		debounce[button] = tick()
	else
		if tick() - debounce[button] < .4 then
			return
		else
			debounce[button] = tick()
		end
	end

	local buttonBG = backgrounds[button]

	callbacks[button]()

	local originalPosition = button.Position
	button:TweenPosition(buttonBG.Position, "Out", "Quad", .1, true, function()
		button:TweenPosition(originalPosition, "Out", "Quad", .15, true)
	end)

	Messages:send("PlaySoundOnClient",{
		instance = game.ReplicatedStorage.Sounds.NewUIBonk
	})
end

local function registerButton(button, buttonBG, callback)
	callbacks[button] = callback
	backgrounds[button] = buttonBG
    button.Activated:connect(function()
        pressButton(button)
    end)
end


local Button = {}

function Button:start()
	Messages:hook("RegisterButton", registerButton)
	Messages:hook("PressButton", pressButton)
end

return Button
