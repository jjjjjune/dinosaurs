local CollectionService = game:GetService("CollectionService")

return {
	Organic = function(item)
		return CollectionService:HasTag(item, "Seed") or CollectionService:HasTag(item, "Organic") or CollectionService:HasTag(item, "Food")
	end,
	Mineral = function(item)
		return CollectionService:HasTag(item, "Ore") or CollectionService:HasTag(item, "Metal") or CollectionService:HasTag(item, "Bar") or CollectionService:HasTag(item, "Mineral")
	end
}
