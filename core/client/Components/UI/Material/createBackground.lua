return function(frame: Frame)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 1

    local background = Instance.new("Frame")
    background.Name = "Background"
    background.AnchorPoint = Vector2.new(0.5, 0.5)
    background.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    background.BorderSizePixel = 0
    background.Position = UDim2.fromScale(0.5, 0.5)
    background.Size = UDim2.new(1, -10, 1, -10)

    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.96
    shadow.Position = UDim2.fromScale(0.5, 0.5)
    shadow.Size = UDim2.new(1, 10, 1, 10)

    local uICorner = Instance.new("UICorner")
    uICorner.Name = "UICorner"
    uICorner.CornerRadius = UDim.new(0, 10)
    uICorner.Parent = shadow

    shadow.Parent = background

    local uICorner1 = Instance.new("UICorner")
    uICorner1.Name = "UICorner"
    uICorner1.CornerRadius = UDim.new(0, 10)
    uICorner1.Parent = background

    local uIStroke = Instance.new("UIStroke")
    uIStroke.Name = "UIStroke"
    uIStroke.Transparency = 0.94
    uIStroke.Parent = background

    background.Parent = frame
end