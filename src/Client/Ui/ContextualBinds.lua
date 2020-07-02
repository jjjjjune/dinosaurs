local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local ContextActionService = game:GetService("ContextActionService")
local ActionBinds = import "Shared/Data/ActionBinds"
local BindsUi = game.Players.LocalPlayer.PlayerGui:WaitForChild("Controls")
local GetDevice = import "Shared/Utils/GetDevice"

local currentBinds = {}

local function animate(tooltip)
    for _, v in pairs(tooltip:GetChildren()) do
        if not v:FindFirstChild("Tweening") then
            local tweening = Instance.new("BoolValue", v)
            tweening.Name = "Tweening"
            v:TweenPosition(v.Position + UDim2.new(0,0,0,4), "Out", "Quad", .1, false, function()
                v:TweenPosition(v.Position - UDim2.new(0,0,0,4), "Out", "Quad", .1, false, function()
                    tweening:Destroy()
                end)
            end)
        end
    end
end

local function updateBindsUi()
    local tooltipFrame = BindsUi.Frame.TooltipGeneric
    local descriptionFrame = BindsUi.Frame.DescriptionLabel
    local device = GetDevice()
    for _, v in pairs(BindsUi.Frame:GetChildren()) do
        if v:IsA("ImageButton") and v.Visible == true then
            v:Destroy()
        end
    end
    local counter = 0
    for actionName, bindInfo in pairs(currentBinds) do
        local actionBindInfo = ActionBinds[actionName]
        local tooltip = tooltipFrame:Clone()
        local description = descriptionFrame:Clone()

        tooltip.ImageLabel.ImageColor3 = actionBindInfo.color
        tooltip.ImageColor3 = Color3.new(actionBindInfo.color.r - .2, actionBindInfo.color.g - .2, actionBindInfo.color.b - .2)
        tooltip.Parent = BindsUi.Frame
        tooltip.Name = actionName
        tooltip.LayoutOrder = counter
        tooltip.Visible = true

        tooltip.Activated:connect(function()
            bindInfo.callback()
            animate(tooltip)
        end)

        if device == "Desktop" then
            tooltip.TextLabel.Text = actionBindInfo.pc
            tooltip.TextLabelShadow.Text = actionBindInfo.pc
        elseif device == "Mobile" then
            tooltip.TextLabel.Text = ""
            tooltip.TextLabelShadow.Text = ""
        elseif device == "Gamepad" then
            tooltip.TextLabel.Text = actionBindInfo.gamepad
            tooltip.TextLabelShadow.Text = actionBindInfo.gamepad
        end

        counter = counter + 1

        description.LayoutOrder = counter
        description.Parent = BindsUi.Frame
        description.Name = actionName.."Desc"
        description.ImageLabel.ImageColor3 = actionBindInfo.color
        description.ImageColor3 = Color3.new(actionBindInfo.color.r - .2, actionBindInfo.color.g - .2, actionBindInfo.color.b - .2)
        description.TextLabel.Text = bindInfo.title
        description.TextLabelShadow.Text = bindInfo.title
        description.Visible = true
    end
end

local ContextualBinds = {}

function ContextualBinds:start()
    Messages:hook("CreateContextualBind", function(actionName, callback, title)
        local actions = {}
        local bindInfo = ActionBinds[actionName]
        table.insert(actions, bindInfo.gamepadBind)
        if bindInfo.pcBind ~= "Mouse1" then
            table.insert(actions, bindInfo.pcBind)
        else
            table.insert(actions, Enum.UserInputType.MouseButton1)
        end
        if callback then
            ContextActionService:BindAction("contextual"..actionName, function(contextActionName, inputState, inputObject)
                if inputState == Enum.UserInputState.Begin then
                    callback()
                    if BindsUi.Frame:FindFirstChild(actionName) then
                        animate(BindsUi.Frame[actionName])
                    end
                end
            end, false, unpack(actions))
        end
        currentBinds[actionName] = {
            title = title or "REP",
            action = actionName,
            callback = callback,
        }
        updateBindsUi()
    end)
    Messages:hook("DestroyContextualBind", function(actionName)
        ContextActionService:UnbindAction("contextual"..actionName)
        currentBinds[actionName] = nil
        updateBindsUi()
    end)
end

return ContextualBinds
