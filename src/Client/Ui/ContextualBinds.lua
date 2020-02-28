local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local ContextActionService = game:GetService("ContextActionService")
local ActionBinds = import "Shared/Data/ActionBinds"

local currentBinds = {}

local ContextualBinds = {}

function ContextualBinds:start()
    Messages:hook("CreateContextualBind", function(actionName, callback)
        local actions = {}
        local bindInfo = ActionBinds[actionName]
        table.insert(actions, bindInfo.gamepadBind)
        if bindInfo.pcBind ~= "Mouse1" then
            table.insert(actions, bindInfo.pcBind)
        else
            table.insert(actions, Enum.UserInputType.MouseButton1)
        end
        ContextActionService:BindAction("contextual"..actionName, function(contextActionName, inputState, inputObject)
            if inputState == Enum.UserInputState.Begin then
                callback()
            end
        end, false, unpack(actions))
    end)
    Messages:hook("DestroyContextualBind", function(actionName)
        ContextActionService:UnbindAction("contextual"..actionName)
    end)
end

return ContextualBinds