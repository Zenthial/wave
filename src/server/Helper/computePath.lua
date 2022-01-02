local PathfindingService = game:GetService("PathfindingService")

local function computePath(startPoint: Vector3, endPoint: Vector3)
    local path = PathfindingService:CreatePath()
	path:ComputeAsync(startPoint, endPoint)
	if path.Status == Enum.PathStatus.Success then
		return true, path:GetWaypoints()
	else
		return false
	end
end

return computePath