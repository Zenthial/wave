local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChatStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("ChatStats"))

local COLORED_TEXT_FORMAT = "<font color=\"#%s\">%s</font>"

local MESSAGE_FORMAT = "%s %s: %s"

local function constructTagString(tags: {[string]: Color3}): string
    local tagString = ""

    for tagName, tagColor in pairs(tags) do
        tagString = tagString .. string.format(COLORED_TEXT_FORMAT, tagColor:ToHex(), ChatStats.TagDivider.Left .. tagName:upper() .. ChatStats.TagDivider.Right)    
    end

    return tagString
end

-- first use of codify to convert this message template to a piece of code
return function(username: string, username_color: Color3, tags: {[string]: Color3}, text: string): Frame
    local message = Instance.new("Frame")
    message.Name = "message"
    message.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    message.BackgroundTransparency = 1
    message.BorderSizePixel = 0
    message.Position = UDim2.fromScale(0, 0.922)
    message.Size = UDim2.new(0.98, 0, 0, 20)

    local tagString = constructTagString(tags)
    local usernameString = string.format(COLORED_TEXT_FORMAT, username_color:ToHex(), username)
    local formattedMessage = string.format(MESSAGE_FORMAT, tagString, usernameString, text)
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "textLabel"
    textLabel.Font = Enum.Font.GothamSemibold
    textLabel.RichText = true
    textLabel.Text = formattedMessage
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextScaled = true
    textLabel.TextSize = 22
    textLabel.TextTransparency = 1
    textLabel.TextWrapped = true
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    textLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.BackgroundTransparency = 1
    textLabel.Position = UDim2.fromScale(0.5, 0.5)
    textLabel.Size = UDim2.fromScale(1, 1)
    
    local uITextSizeConstraint = Instance.new("UITextSizeConstraint")
    uITextSizeConstraint.Name = "uITextSizeConstraint"
    uITextSizeConstraint.MaxTextSize = 22
    uITextSizeConstraint.Parent = textLabel
    
    textLabel.Parent = message

    return message
end