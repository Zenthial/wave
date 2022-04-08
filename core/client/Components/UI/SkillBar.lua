local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local bluejay = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("bluejay"))

local SkillBar = {}
SkillBar.__index = SkillBar
SkillBar.Name = "SkillBar"
SkillBar.Tag = "SkillBar"
SkillBar.Needs = {"Cleaner"}
SkillBar.Ancestor = PlayerGui

function SkillBar.new(root: any)
    return setmetatable({
        Root = root,

    }, SkillBar)
end

function SkillBar:Start()
    local equippedSkillSignal = LocalPlayer:GetAttributeChangedSignal("EquippedSkill")

    self.Cleaner:Add(equippedSkillSignal:Connect(function()
        local equippedSkill = LocalPlayer:GetAttribute("EquippedSkill") or "--" :: string
        if equippedSkill == "" or equippedSkill == "--" then
            self:SetCharge(0)
            self.Root.NameDisplay.Text = "<i>--</i>"
        else
            self:SetCharge(100)
            self.Root.NameDisplay.Text = string.format("<i>%s</i>", equippedSkill)
        end
    end))
end

function SkillBar:SetCharge(num)
    local goalNum = (num/100) - 0.5
    TweenService:Create(self.Root.ChargeOutline.Charge.Fill.UIGradient, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {Offset = Vector2.new(-goalNum, 0)}):Play()
end

function SkillBar:Destroy()
    self.Cleaner:Clean()
end

bluejay.create_component(SkillBar)

return SkillBar