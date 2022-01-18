-- Originally written by Mike Mariano

local TweenService = game:GetService("TweenService")

local UITween = {}

function UITween.fadeImage(object, amount, time, delay)
    local tweenInfo = TweenInfo.new(
        time, 
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out,
        0,
        false,
        delay
    )

    local tween = TweenService:Create(object, tweenInfo, {ImageTransparency = amount})
    tween:Play()
    return tween
end

function UITween.fadeBackground(object, amount, time, delay)
    local tweenInfo = TweenInfo.new(
        time, 
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out,
        0,
        false,
        delay
    )

    local tween = TweenService:Create(object, tweenInfo, {BackgroundTransparency = amount})
    tween:Play()
    return tween
end

function UITween.fadeText(object, amount, time, delay)
    local tweenInfo = TweenInfo.new(
        time, 
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out,
        0,
        false,
        delay
    )

    local tween = TweenService:Create(object, tweenInfo, {TextTransparency = amount})
    tween:Play()
    return tween
end

function UITween.size(object, size, time, delay)
    local tweenInfo = TweenInfo.new(
        time, 
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out,
        0,
        false,
        delay
    )

    local tween = TweenService:Create(object, tweenInfo, {Size = size})
    tween:Play()
    return tween
end


return UITween