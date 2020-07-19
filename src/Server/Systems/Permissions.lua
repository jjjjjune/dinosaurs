local import = require(game.ReplicatedStorage.Shared.Import)

local ServerData = import "Server/Systems/ServerData"

local Messages = import "Shared/Utils/Messages"

local PermissionsConstants = import "Shared/Data/PermissionsConstants"

local function getRankIndex(rank)
	local index
	for i, v in ipairs(PermissionsConstants.RANKS) do
		if v == rank then
			index = i
			break
		end
	end
	return index
end

local function setPlayerRank(setter, personBeingRankedUp, rank)
	local ranks = ServerData:getValue("ranks")
	local permissions = ServerData:getValue("permissions")
	local setterRank = ranks[tostring(setter.UserId)] or PermissionsConstants.RANKS[1]
	local personBeingRankedUpRank = ranks[tostring(personBeingRankedUp.UserId)] or PermissionsConstants.RANKS[1]
	if getRankIndex(setterRank) > getRankIndex(personBeingRankedUpRank) then
		print("it is fine for ", setterRank, " to rank to ", rank)
		local myPermissions = permissions[setterRank]
		if myPermissions["can promote lower ranks"] then
			ranks[tostring(personBeingRankedUp.UserId)] = rank
			ServerData:setValue("ranks", ranks)
			Messages:sendClient(personBeingRankedUp, "Notify", "HEALTH_COLOR", "SPRING", "YOUR RANK IS NOW: "..rank)
		end
	end
end

local function setPermissionValue(setter, rank, permission, value)
	local permissions = ServerData:getValue("permissions")
	local ranks = ServerData:getValue("ranks")
	local setterRank = ranks[tostring(setter.UserId)] or PermissionsConstants.RANKS[1]
	if getRankIndex(setterRank) == #PermissionsConstants.RANKS then
		permissions[rank][permission] = value
		ServerData:setValue("permissions", permissions)
	end
end

local Permissions = {}

function Permissions:playerHasPermission(player, permissionName)
	local permissions = ServerData:getValue("permissions")
	local ranks = ServerData:getValue("ranks")
	local myRank = ranks[tostring(player.UserId)] or PermissionsConstants.RANKS[1]
	local myPermissions = permissions[myRank]
	if myPermissions[permissionName] == true then
		return true
	end
	return false
end

function Permissions:start()
	Messages:hook("SetPlayerRank", setPlayerRank)
	Messages:hook("SetPermissionValue", setPermissionValue)
end

return Permissions
