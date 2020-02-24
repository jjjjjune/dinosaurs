return function(origin, direction, additionalIgnore)
    local CollectionService = game:GetService("CollectionService")
    local ignore = CollectionService:GetTagged("RayIgnore")
    local ray = Ray.new(origin, direction)
    if additionalIgnore then
        for i, v in pairs(additionalIgnore) do
            table.insert(ignore, v)
        end
    end
    local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, ignore)
    return hit, pos
end