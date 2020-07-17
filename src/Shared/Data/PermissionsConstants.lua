local function newPermissions()
	return {
		["can make ropes"] = true,
		["can delete ropes"] = true,
		["can sacrifice items"] = true,
		["can promote lower ranks"] = false,
		["can kick lower ranks"] = false,
		["can ban lower ranks"] = false,
		["can ride other's animals"] = true,
		["can chop down plants"] = true,
		["achievement share"] = 1,
	}
end

local PermissionsConstants = {}

PermissionsConstants.RANKS = {
	"Guest",
	"Citizen",
	"Noble",
	"Priest",
	"Leader"
}

PermissionsConstants.DEFAULT_PERMISSIONS = {}

for _, rankName in pairs(PermissionsConstants.RANKS) do
	PermissionsConstants.DEFAULT_PERMISSIONS[rankName] = newPermissions()
end

PermissionsConstants.DEFAULT_PERMISSIONS.Leader["can ban lower ranks"] = true
PermissionsConstants.DEFAULT_PERMISSIONS.Leader["can kick lower ranks"] = true
PermissionsConstants.DEFAULT_PERMISSIONS.Leader["can promote lower ranks"] = true

return PermissionsConstants
