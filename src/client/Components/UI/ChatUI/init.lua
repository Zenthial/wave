local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Rosyn = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Rosyn"))

local Input = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Input"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))
local Queue = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Queue"))
local ChatStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("ChatStats"))
local ClientComm = require(script.Parent.Parent.Parent.Modules.ClientComm)

local createMessage = require(script.createMessage)
local inputCapturer = require(script.inputCapturer)

local KeyboardInput = Input.Keyboard.new()
local comm = ClientComm.GetClientComm()

local sendChat = comm:GetFunction("AttemptChat")
local sendChatSignal = comm:GetSignal("SendChat")
local systemNotificationSignal = comm:GetSignal("SystemNotification")

local DEFAULT_KEY = Enum.KeyCode.Slash

local TWEEN_CONSTANTS = {
    HideBackgroundTransparency = 1,
    ShowBackgroundTransparency = 0.5,
    ShowDetailSize = UDim2.new(0.97, 0, 0, 2),
    HideDetailSize = UDim2.new(0.3, 0, 0, 2),
    ShowTweenInfo = TweenInfo.new(0.2)
}

--[[
    ChatUI structure
    Main
        Container
            UIListLayout
            {Messages}
    Detail
    InputBar
        Input (TextBox)
]]
local ChatUI = {}
ChatUI.__index = ChatUI
ChatUI.__Tag = "ChatUI"

function ChatUI.new(root: any)
    return setmetatable({
        Root = root,
        Main = root.Main,
        Container = root.Main.Container,
        InputBar = root.InputBar,
        Input = root.InputBar.Input,
        Detail = root.Detail,

        Cleaner = Trove.new()
    }, ChatUI)
end

function ChatUI:Initial()
    self.Input.Text = string.format(ChatStats.DefaultChatText, UserInputService:GetStringForKeyCode(DEFAULT_KEY))
    
    for _, thing in pairs(self.Container:GetChildren()) do
        if thing:IsA("Frame") then
            thing:Destroy()
        end
    end

    self.Cleaner:Add(KeyboardInput.KeyDown:Connect(function(keyCode)
        if keyCode == DEFAULT_KEY then
            local capturer = inputCapturer()
            local internalCleaner = Trove.new()
            internalCleaner:Add(capturer.Changed:Connect(function(text)
                self:UpdateText(text)
            end))

            internalCleaner:Add(capturer.Finished:Connect(function(text)
                self:UpdateText(text)
                self:FocusLost(text)
                internalCleaner:Clean()
            end))
        end
    end))

    local messageQueue = Queue.new()
    self.Cleaner:Add(sendChatSignal:Connect(function(username: string, username_color: Color3, tags: {[string]: Color3}, message: string)
        local messageUI = createMessage(username, username_color, tags, message)
        messageUI.Parent = self.Container

        Queue.push(messageQueue, messageUI)
        if messageQueue.size >= ChatStats.Lines then
            local deleteMessage: Frame = Queue.pop(messageQueue)
            deleteMessage:Destroy()
        end
    end))
end

function ChatUI:UpdateText(contentText)
    self.Input.Text = contentText
end

function ChatUI:FocusLost(contentText: string)
    if string.len(contentText) > ChatStats.MinimumMessageSize and contentText ~= "" then
        self.Input.Text = string.format(ChatStats.DefaultChatText, UserInputService:GetStringForKeyCode(DEFAULT_KEY))
        sendChat(contentText)
    end

    TweenService:Create(self.Main, TWEEN_CONSTANTS.ShowTweenInfo, {BackgroundTransparency = TWEEN_CONSTANTS.HideBackgroundTransparency}):Play()
    TweenService:Create(self.InputBar, TWEEN_CONSTANTS.ShowTweenInfo, {BackgroundTransparency = TWEEN_CONSTANTS.HideBackgroundTransparency}):Play()
    TweenService:Create(self.Detail, TWEEN_CONSTANTS.ShowTweenInfo, {Size = TWEEN_CONSTANTS.HideDetailSize}):Play()
end

function ChatUI:Focused()
    self.Input.Text = "PRESS LEFT ALT TO TOGGLE TEAMCHAT"
    TweenService:Create(self.Main, TWEEN_CONSTANTS.ShowTweenInfo, {BackgroundTransparency = TWEEN_CONSTANTS.ShowBackgroundTransparency}):Play()
    TweenService:Create(self.InputBar, TWEEN_CONSTANTS.ShowTweenInfo, {BackgroundTransparency = TWEEN_CONSTANTS.ShowBackgroundTransparency}):Play()
    TweenService:Create(self.Detail, TWEEN_CONSTANTS.ShowTweenInfo, {Size = TWEEN_CONSTANTS.ShowDetailSize}):Play()
end

function ChatUI:Destroy()
    self.Cleaner:Clean()
end

Rosyn.Register("ChatUI", {ChatUI})

return ChatUI