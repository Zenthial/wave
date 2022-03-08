local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local Rosyn = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Rosyn"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))

local SkillBar = {}
SkillBar.__index = SkillBar
SkillBar.__Tag = "SkillBar"

function SkillBar.new(root: any)
    return setmetatable({
        Root = root,

        Cleaner = Trove.new(),
    }, SkillBar)
end

function SkillBar:Initial()
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

Rosyn.Register("SkillBar", {SkillBar})

return SkillBar