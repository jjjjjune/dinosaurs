local import = require(game.ReplicatedStorage.Shared.Import)

local Roact = import "Roact"
local RoactRodux = import "RoactRodux"

local UserInputService = game:GetService("UserInputService")

local SetLayout = import "Shared/Actions/Interface/SetLayout"
local SetScale = import "Shared/Actions/Interface/SetScale"

local ScalingBoundaries, LayoutTypes = import("Shared/Data/InterfaceConstants", {"ScalingBoundaries", "LayoutTypes"})

local LayoutProvider = Roact.PureComponent:extend("LayoutProvider")

function LayoutProvider:init(props)

end

function LayoutProvider:didMount()
end

function LayoutProvider:willUnmount()

end

function LayoutProvider:render()
	return
end

return RoactRodux.connect(nil, function(dispatch)
	return {
		setLayout = function(layout)
			dispatch(SetLayout(layout))
		end,
		setScale = function(scale)
			dispatch(SetScale(scale))
		end,
	}
end)(LayoutProvider)
