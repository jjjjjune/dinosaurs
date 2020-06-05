local runService = game:GetService("RunService")
local httpService = game:GetService("HttpService")

local replicationReady = {}
local actionQueue = {}
local nonPlayerActionQueue = {}

local isReady = false

local SignalObject = {}

function SignalObject.new(signals, action, callback)
    local SignalObject =  {
        callback = callback,
        ID = httpService:GenerateGUID(),
    }

    return SignalObject
end

local SIGNAL_REMOTE
local SIGNAL_REMOTE_FUNCTION
local SIGNAL_BINDABLE = Instance.new("BindableEvent")
local SIGNAL_BINDABLE_FUNCTION = Instance.new("BindableFunction")

local isClient = runService:IsClient()
local isServer = runService:IsServer()

local Messages = {}

Messages.hooks = {}

SIGNAL_BINDABLE.Event:connect(function(callback, ...)
	callback(...)
end)

function Messages:hook(action, callback)
    local hooks = self.hooks
    if not hooks[action] then
        hooks[action] = {}
    end
    local signalObject = SignalObject.new(self, action, callback)
    table.insert(hooks[action], signalObject)
    return signalObject
end

function Messages:hookRequest(action, callback)
	local hooks = self.hooks
    if not hooks[action] then
        hooks[action] = {}
    end
    local signalObject = SignalObject.new(self, action, callback)
    table.insert(hooks[action], signalObject)
    return signalObject
end

function Messages:send(action, ...)
	local actionHooksTable = self.hooks[action]

	if actionHooksTable then
		if not isReady then
			table.insert(nonPlayerActionQueue, {
				args = {...},
				action = action,
			})
		else
			local args = {...}
			for _, signalObject in pairs(actionHooksTable) do
				SIGNAL_BINDABLE:Fire(signalObject.callback, unpack(args))
			end
			--warn("No defined hook for message: "..action)
		end
	end
end

function Messages:getFunctionResult(action, player, ...)
	local actionHooksTable = self.hooks[action]

	if actionHooksTable then
		local args = {...}
		local hookFunction = actionHooksTable[1] -- there can only be one of thse
		return hookFunction.callback(unpack(args))
	end
end

function Messages:sendServer(action, ...)
    SIGNAL_REMOTE:FireServer(action, ...)
end

function Messages:requestServer(action, ...)
	return SIGNAL_REMOTE_FUNCTION:InvokeServer(action, ...)
end

function Messages:sendClient(player, action, ...)
	if typeof(player) ~= "Instance" then
		warn("for action ", action, " you might have forgotten to use a player as your first arg")
	end
	if not replicationReady[player] or not isReady then
		if not actionQueue[player] then
			actionQueue[player] = {}
		end
		table.insert(actionQueue[player], {
			args = {...},
			action = action,
		})
	else
		SIGNAL_REMOTE:FireClient(player, action, ...)
	end
end

function Messages:reproOnClients(player, action, ...)
	for _, p in pairs(game.Players:GetPlayers()) do
		if p ~= player then
			if replicationReady[p] then
				SIGNAL_REMOTE:FireClient(p, action, ...)
			else
				if not actionQueue[p] then
					actionQueue[p] = {}
				end
				table.insert(actionQueue[p], {
					args = {...},
					action = action,
				})
			end
		end
	end
end

function Messages:sendAllClients(action, ...)
	for _, p in pairs(game.Players:GetPlayers()) do
		if not replicationReady[p] then
			if not actionQueue[p] then
				actionQueue[p] = {}
			end
			table.insert(actionQueue[p], {
				args = {...},
				action = action,
			})
		else
			SIGNAL_REMOTE:FireClient(p, action, ...)
		end
	end
end

function Messages:sendTeam(team, action, ...)
	for _, p in pairs(game.Players:GetPlayers()) do
		if p.Team.Name == team then
			if not replicationReady[p] then
				if not actionQueue[p] then
					actionQueue[p] = {}
				end
				table.insert(actionQueue[p], {
					args = {...},
					action = action,
				})
			else
				SIGNAL_REMOTE:FireClient(p, action, ...)
			end
		end
	end
end

function Messages:init()
	if not game.ReplicatedStorage:FindFirstChild("SIGNAL_REMOTE") then
		local SIGNAL_REMOTE = Instance.new("RemoteEvent", game.ReplicatedStorage)
		SIGNAL_REMOTE.Name = "SIGNAL_REMOTE"
	end
	if not game.ReplicatedStorage:FindFirstChild("SIGNAL_REMOTE_FUNCTION") then
		local SIGNAL_REMOTE = Instance.new("RemoteFunction", game.ReplicatedStorage)
		SIGNAL_REMOTE.Name = "SIGNAL_REMOTE_FUNCTION"
	end

	SIGNAL_REMOTE = game.ReplicatedStorage:FindFirstChild("SIGNAL_REMOTE")
	SIGNAL_REMOTE_FUNCTION = game.ReplicatedStorage:FindFirstChild("SIGNAL_REMOTE_FUNCTION")

	Messages:hook("ReplicationReady", function(player)
		replicationReady[player] = true
		if actionQueue[player] then
			for _, actionData in pairs(actionQueue[player]) do
				SIGNAL_REMOTE:FireClient(player, actionData.action, unpack(actionData.args))
			end
			actionQueue[player] = nil
		end
	end)

    if isClient then
        SIGNAL_REMOTE.OnClientEvent:connect(function(action, ...)
            Messages:send(action, ...)
        end)
	end

    if isServer then
        SIGNAL_REMOTE.OnServerEvent:connect(function(player, action, ...)
            self:send(action, player, ...)
		end)
		SIGNAL_REMOTE_FUNCTION.OnServerInvoke = (function(player,action,...)
			return self:getFunctionResult(action, player, ...)
		end)
    end
end

Messages:init()

function Messages.fireQueue()
	isReady = true
	for _, actionData in pairs(nonPlayerActionQueue) do
		Messages:send(actionData.action, unpack(actionData.args))
	end
end

return Messages
