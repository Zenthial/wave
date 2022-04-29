local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local tcs = require(ReplicatedStorage.Shared.tcs)

local Input = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Input"))
local Queue = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Queue"))
local ChatStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("ChatStats"))
local ClientComm = require(script.Parent.Parent.Parent.Modules.ClientComm)

local createMessage = require(script.createMessage)

local KeyboardInput = Input.Keyboard.new()
local comm = ClientComm.GetClientComm()

local sendChat = comm:GetFunction("AttemptChat")
local sendChatSignal = comm:GetSignal("SendChat")
local systemNotificationSignal = comm:GetSignal("SystemNotification")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local DEFAULT_TEAM_CHAT_KEY = Enum.KeyCode.LeftAlt

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
ChatUI.Name = "ChatUI"
ChatUI.Tag = "ChatUI"
ChatUI.Ancestor = PlayerGui
ChatUI.Needs = {"Cleaner"}

function ChatUI.new(root: any)
    return setmetatable({
        Root = root,
        Main = root.Main,
        Container = root.Main.Container,
        InputBar = root.InputBar,
        Input = root.InputBar.Input,
        Detail = root.Detail,
    }, ChatUI)
end

function ChatUI:Start()
    local input = self.Input :: TextBox
    input.Text = ""
    input.PlaceholderColor3 = Color3.fromRGB(255, 255, 255)
    input.PlaceholderText = string.format(ChatStats.DefaultChatText, UserInputService:GetStringForKeyCode(Enum.KeyCode[LocalPlayer.Keybinds:GetAttribute("Chat")]))
    
    for _, thing in pairs(self.Container:GetChildren()) do
        if thing:IsA("Frame") then
            thing:Destroy()
        end
    end

    local chattingChangedSignal = LocalPlayer:GetAttributeChangedSignal("Chatting")
    self.Cleaner:Add(chattingChangedSignal:Connect(function()
        if LocalPlayer:GetAttribute("Chatting") == true then
            task.wait()
            input:CaptureFocus()
        end
    end))

    local messageQueue = Queue.new()
    self.Cleaner:Add(sendChatSignal:Connect(function(username: string, username_color: Color3, tags: {[string]: Color3}, message: string)
        local messageUI = createMessage(username, username_color, tags, message)
        messageUI.Parent = self.Container
        TweenService:Create(messageUI.textLabel, TweenInfo.new(ChatStats.DefaultChatTextFadeInTime), {TextTransparency = 0}):Play()

        Queue.push(messageQueue, messageUI)
        if messageQueue.size >= ChatStats.Lines then
            local deleteMessage: Frame = Queue.pop(messageQueue)
            deleteMessage:Destroy()
        end
    end))

    self.Cleaner:Add(input.FocusLost:Connect(function(enterPressed: boolean, _inputThatCausedFocusLoss: InputObject)
        LocalPlayer:SetAttribute("Chatting", false)
        local contentText = input.ContentText
        if enterPressed and string.len(contentText) > ChatStats.MinimumMessageSize and contentText ~= "" and contentText ~= string.format(ChatStats.DefaultChatFocusedText, DEFAULT_TEAM_CHAT_KEY.Name) then
            input.Text = string.format(ChatStats.DefaultChatText, UserInputService:GetStringForKeyCode(Enum.KeyCode[LocalPlayer.Keybinds:GetAttribute("Chat")]))
            sendChat(contentText)
        end
    
        TweenService:Create(self.Main, TWEEN_CONSTANTS.ShowTweenInfo, {BackgroundTransparency = TWEEN_CONSTANTS.HideBackgroundTransparency}):Play()
        TweenService:Create(self.InputBar, TWEEN_CONSTANTS.ShowTweenInfo, {BackgroundTransparency = TWEEN_CONSTANTS.HideBackgroundTransparency}):Play()
        TweenService:Create(self.Detail, TWEEN_CONSTANTS.ShowTweenInfo, {Size = TWEEN_CONSTANTS.HideDetailSize}):Play()
    end))

    self.Cleaner:Add(input.Focused:Connect(function()
        input.PlaceholderText = string.format(ChatStats.DefaultChatFocusedText, DEFAULT_TEAM_CHAT_KEY.Name)
        input.PlaceholderColor3 = Color3.fromRGB(255, 255, 255)
        input.Text = ""
        TweenService:Create(self.Main, TWEEN_CONSTANTS.ShowTweenInfo, {BackgroundTransparency = TWEEN_CONSTANTS.ShowBackgroundTransparency}):Play()
        TweenService:Create(self.InputBar, TWEEN_CONSTANTS.ShowTweenInfo, {BackgroundTransparency = TWEEN_CONSTANTS.ShowBackgroundTransparency}):Play()
        TweenService:Create(self.Detail, TWEEN_CONSTANTS.ShowTweenInfo, {Size = TWEEN_CONSTANTS.ShowDetailSize}):Play()
    end))
end

function ChatUI:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(ChatUI)

return ChatUI