local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local function setProgressAmount(ui, progress)
    local backgroundColor = ui.N1.ImageColor3
    local foregroundColor = ui.B.ImageColor3
    local angle = progress*360
	local n0 = ui.N0
    local specifiedAngle = angle
    n0.Rotation = angle%180
    if specifiedAngle < 180 then
        n0.Img.ImageColor3 = backgroundColor
    else
        n0.Img.ImageColor3 = foregroundColor
    end
    if progress >= 1 then
        n0.Img.ImageColor3 = foregroundColor
        n0.Rotation = 180
    end
end

local RadialProgress = {}

function RadialProgress:start()
    Messages:hook("SetRadialProgressButtonAmount", function(progressButton, progress)
        setProgressAmount(progressButton, progress)
    end)
end

return RadialProgress