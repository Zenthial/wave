return function (frame: Frame)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    
    local surfaceFrame = Instance.new("Frame")
    surfaceFrame.Name = "Surface"
    surfaceFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    surfaceFrame.Size = UDim2.new(1, -2, 1, -6)

    local uICorner = Instance.new("UICorner")
    uICorner.Name = "UICorner"
    uICorner.CornerRadius = UDim.new(0, 10)
    uICorner.Parent = surfaceFrame

    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.96
    shadow.Position = UDim2.new(0.5, 2, 0.5, 6)
    shadow.Size = UDim2.fromScale(1, 1)

    local uICorner1 = Instance.new("UICorner")
    uICorner1.Name = "UICorner"
    uICorner1.CornerRadius = UDim.new(0, 10)
    uICorner1.Parent = shadow

    shadow.Parent = surfaceFrame

    local uIStroke = Instance.new("UIStroke")
    uIStroke.Name = "UIStroke"
    uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    uIStroke.Transparency = 0.97
    uIStroke.Parent = surfaceFrame

    surfaceFrame.Parent = frame
end