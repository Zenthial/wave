local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ViewportModel = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ViewportModel"))

return function(frame: ViewportFrame, model: Model, optionalDistance: number)
    model.Parent = frame
    
    local camera = Instance.new("Camera")
    camera.FieldOfView = 70
    camera.Parent = frame

    frame.CurrentCamera = camera

    local vpfModel = ViewportModel.new(frame, camera)
    local cf, _ = model:GetBoundingBox()
	
	vpfModel:SetModel(model)
	
	local theta = 0
	local orientation = CFrame.new()
	local distance = vpfModel:GetFitDistance(cf.Position)

    if optionalDistance then
        distance -= optionalDistance
    end
	
	local con = RunService.RenderStepped:Connect(function(dt)
		theta = theta + math.rad(30 * dt)
		orientation = CFrame.fromEulerAnglesYXZ(0, theta, 0)
		camera.CFrame = CFrame.new(cf.Position) * orientation * CFrame.new(0, 0, distance)
	end)

    return con
end