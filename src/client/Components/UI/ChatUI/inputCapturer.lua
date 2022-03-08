local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Signal = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))
local Input = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Input"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))

local KeyboardInput = Input.Keyboard.new()
local MouseInput = Input.Mouse.new()

return function()
    local inputChangedSignal = Signal.new()
    local finishedSignal = Signal.new()
    local cleaner = Trove.new()

    local capsLock = false
    local uppercase = false
    local buildStr = ""

    cleaner:Add(KeyboardInput.KeyDown:Connect(function(keyCode: Enum.KeyCode)
        if keyCode == Enum.KeyCode.Return or keyCode == Enum.KeyCode.KeypadEnter then
            finishedSignal:Fire(buildStr)
            cleaner:Clean()
        elseif keyCode == Enum.KeyCode.LeftShift or keyCode == Enum.KeyCode.RightShift then
            uppercase = true
        elseif keyCode == Enum.KeyCode.CapsLock then
            capsLock = not capsLock
        elseif keyCode.Value <= 272 and keyCode.Value >= 32 then
            local keyStr = UserInputService:GetStringForKeyCode(keyCode)
            if uppercase == false and capsLock == false then
                keyStr:lower()
            end
            print(keyStr, uppercase, capsLock)
            buildStr = buildStr .. keyStr
            inputChangedSignal:Fire(buildStr)
        end
    end))

    cleaner:Add(KeyboardInput.KeyUp:Connect(function(keyCode: Enum.KeyCode)
        if keyCode == Enum.KeyCode.LeftShift or keyCode == Enum.KeyCode.RightShift then
            uppercase = false
        end
    end))

    cleaner:Add(MouseInput.LeftDown:Connect(function()
        finishedSignal:Fire(buildStr)
        cleaner:Clean()
    end))

    return {Changed = inputChangedSignal, Finished = finishedSignal}
end