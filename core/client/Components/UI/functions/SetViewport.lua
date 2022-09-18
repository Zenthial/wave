local ViewportCameraPositioner = require(script.Parent.ViewportCameraPositioner)

return function(viewport: ViewportFrame, modelFolder: Configuration | Folder)
    local camera = Instance.new("Camera")
    viewport.CurrentCamera = camera
    
    local inspectModel
    if modelFolder:IsA("Configuration") and modelFolder:FindFirstChild("DeployableModel") then
        inspectModel = modelFolder.DeployableModel:Clone() :: Model
        inspectModel.PrimaryPart = nil
        inspectModel:PivotTo(CFrame.new(Vector3.new(0, 0, 0),  Vector3.new(0, 0, 5)) * CFrame.Angles(0, math.rad(180), 0))
    elseif modelFolder:IsA("Configuration") and modelFolder:FindFirstChild("Model") then
        inspectModel = modelFolder.Model:Clone() :: Model
        inspectModel.PrimaryPart = nil
        inspectModel:PivotTo(CFrame.new(Vector3.new(0, 0, 0),  Vector3.new(0, 0, 5)) * CFrame.Angles(0, math.rad(180), 0))
    elseif modelFolder:IsA("Configuration") and modelFolder:FindFirstChild("Projectile") then
        local model = Instance.new("Model")
        local proj = modelFolder.Projectile:Clone()
        proj.Parent = model
        inspectModel = model
        inspectModel:PivotTo(CFrame.new(Vector3.new(0, 0, 0)))
    elseif modelFolder:IsA("Model") then -- skill
        inspectModel = modelFolder:Clone()
        inspectModel.PrimaryPart = nil
        inspectModel:PivotTo(CFrame.new(Vector3.new(0, 0, 0), Vector3.new(0, 0, 5)))
    end
    
    assert(inspectModel, "No model for "..modelFolder.Name)
    -- for _, thing in pairs(inspectModel:GetChildren()) do
    --     if thing:IsA("BasePart") then thing.Anchored = true thing.Material = Enum.Material.Neon thing.BrickColor = BrickColor.new("Institutional white") end
    -- end

    inspectModel.Name = "InspectModel" .. modelFolder.Name
    inspectModel.Parent = viewport
    
    if modelFolder.Name == "PBW" then
        inspectModel:PivotTo(CFrame.new(Vector3.new(0, 0, 0),  Vector3.new(0, 0, 5)) * CFrame.Angles(0, math.rad(90), 0))
    end
    camera.CFrame = ViewportCameraPositioner(camera, viewport, inspectModel)
end