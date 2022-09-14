local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
local PolicyService = game:GetService("PolicyService")
local TweenService = game:GetService("TweenService")

local random = Random.new()

local string_format = "<b><i>%d</i></b>"

local function chooseOne(one, two)
    if random:NextInteger(0, 1) == 0 then
        return one
    else
        return two
    end
end

local function getPosition(hitPart: Part)
    local cframe = CFrame.new(Vector3.new(chooseOne(-5, 5), math.random(-4, 4), 0))
    return hitPart.CFrame:ToWorldSpace(cframe)
end

return function(hitPart: Part, damage: number, shieldHit: boolean, headshot: boolean)
    print(headshot)

    local part = Instance.new("Part")
    part.Name = "part"
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.CFrame = hitPart.CFrame
    part.Size = Vector3.new(1, 1, 1)
    part.TopSurface = Enum.SurfaceType.Smooth
    part.Transparency = 1
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false

    CollectionService:AddTag(part, "Ignore")
    
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "billboardGui"
    billboardGui.Active = true
    billboardGui.AlwaysOnTop = true
    billboardGui.ClipsDescendants = true
    billboardGui.LightInfluence = 1
    billboardGui.MaxDistance = 100
    billboardGui.Size = UDim2.fromOffset(25, 25)
    billboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local textColor = Color3.fromRGB(255, 255, 255)
    if headshot then
        textColor = Color3.fromRGB(170, 0, 0)
    elseif shieldHit then
        textColor = Color3.fromRGB(52, 157, 255)
    end

    local strokeColor = Color3.fromRGB(255, 149, 79)
    if headshot then
        strokeColor = Color3.fromRGB(44, 1, 1)
    elseif shieldHit then
        strokeColor = Color3.fromRGB(10, 72, 147)
    end
    
    local damageIndicator = Instance.new("TextLabel")
    damageIndicator.Name = "damageIndicator"
    damageIndicator.Font = Enum.Font.SciFi
    damageIndicator.FontFace = Font.new("rbxasset://fonts/families/Zekton.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    damageIndicator.RichText = true
    damageIndicator.Text = string.format(string_format, damage)
    damageIndicator.TextColor3 = textColor
    damageIndicator.TextScaled = true
    damageIndicator.TextSize = 100
    damageIndicator.TextStrokeColor3 = strokeColor
    damageIndicator.TextStrokeTransparency = 0.6
    damageIndicator.TextWrapped = true
    damageIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    damageIndicator.BackgroundTransparency = 1
    damageIndicator.Size = UDim2.fromScale(1, 1)
    damageIndicator.Parent = billboardGui
    
    billboardGui.Parent = part
    part.Parent = workspace

    Debris:AddItem(part, 0.4)
    TweenService:Create(part, TweenInfo.new(.5), {CFrame = getPosition(hitPart)}):Play()
end