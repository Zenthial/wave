return function(Frame: Frame, ButtonText: string)
    local textButton = Instance.new("TextButton")
    textButton.Name = "TextButton"
    textButton.Font = Enum.Font.SourceSans
    textButton.Text = ""
    textButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    textButton.TextSize = 14
    textButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    textButton.Size = UDim2.new(1, -2, 1, -6)
    textButton.ZIndex = 4

    local uICorner = Instance.new("UICorner")
    uICorner.Name = "UICorner"
    uICorner.CornerRadius = UDim.new(0, 10)
    uICorner.Parent = textButton

    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.96
    shadow.Position = UDim2.new(0.5, 2, 0.5, 6)
    shadow.Size = UDim2.fromScale(1, 1)
    shadow.ZIndex = 3

    local uICorner1 = Instance.new("UICorner")
    uICorner1.Name = "UICorner"
    uICorner1.CornerRadius = UDim.new(0, 10)
    uICorner1.Parent = shadow

    shadow.Parent = textButton

    local uIStroke = Instance.new("UIStroke")
    uIStroke.Name = "UIStroke"
    uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    uIStroke.Transparency = 0.97
    uIStroke.Parent = textButton

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "TextLabel"
    textLabel.Font = Enum.Font.SourceSans
    textLabel.Text = ButtonText
    textLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.TextSize = 14
    textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    textLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.BackgroundTransparency = 1
    textLabel.Position = UDim2.fromScale(0.5, 0.5)
    textLabel.Size = UDim2.fromScale(1, 1)
    textLabel.ZIndex = 5

    textLabel.Parent = Frame
    textButton.Parent = Frame

    Frame.BackgroundTransparency = 1
end