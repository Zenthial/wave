local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Rosyn = require(Shared:WaitForChild("Rosyn"))
local Trove = require(Shared:WaitForChild("util"):WaitForChild("Trove"))

local ChatStats = require(Shared:WaitForChild("Configurations"):WaitForChild("ChatStats"))

local NametagUI = Shared:WaitForChild("Assets"):WaitForChild("UI"):WaitForChild("NameTagGUI")

local LocalPlayer = game.Players.LocalPlayer

--[=[
    Creates the nametag by cloning the template and parenting it to the player's head

    @return BillboardGui | nil -- returns the nametag if the player's head exists, nil if not
]=]
local function createTag(player: Player): BillboardGui | nil
    local nametag = NametagUI:Clone() :: BillboardGui

	if player.Character and player.Character:FindFirstChild("Head") then
		nametag.Adornee = player.Character.Head
		nametag.Name = player.Name
		nametag.PlayerNameFrame.PlayerName.Text = player.Name
		nametag.Parent = player.Character.Head	
		
		local team = tostring(player.TeamColor)
		if not ChatStats.TeamColors[team] then team = "Default" end		
		
		nametag.PlayerNameFrame.PlayerName.TextColor3 = ChatStats.TeamColors[team].Text
		nametag.PlayerNameFrame.PlayerName.TextStrokeColor3 = ChatStats.TeamColors[team].Stroke		
		
		local nameFrame = nametag:WaitForChild("PlayerNameFrame")
		local nameLabel = nameFrame:WaitForChild("PlayerName")
		nameLabel.Text = player.Name		
		nameLabel.TextColor3 = ChatStats.TeamColors[team].Text
		nameLabel.TextStrokeColor3 = ChatStats.TeamColors[team].Stroke		
		
		-- Nametag stuff, what the hell??? (wace carry over comment)
		player:GetAttributeChangedSignal("TotalHealth"):Connect(function(x)
			local gui = nametag:FindFirstChild("HealthBarFrame")
			if gui and gui:FindFirstChild("HealthBar") then
				task.wait()
				-- Error occurs here (wace carry over comment)
                local totalHealth = player:GetAttribute("TotalHealth")
                local maxHealth = player:GetAttribute("MaxTotalHealth")

				gui.HealthBar:TweenSize(UDim2.new(totalHealth / maxHealth, 0, 1, 0), "Out", "Quad", .2, true)

				if totalHealth < maxHealth * .30 then
					gui.HealthBar.BackgroundColor3 = Color3.fromRGB(255, 78, 96)
				else
					gui.HealthBar.BackgroundColor3 = Color3.fromRGB(85, 255, 127)
				end
			end
		end)
        
        return nametag
	end
end

--[=[
    Handles the name tag rendering of each player
    There is a question of "should this be attached to the player or the actual tag?"
    At the current point, I have decided that attaching it to the player, and having the component continuously add in name tags when the player dies is the correct solution
    I reserve the right to say I was fucking stupid later on

    @class Nametag
]=]
local Nametag = {}
Nametag.__index = Nametag
Nametag.__Tag = "Nametag"

function Nametag.new(player: any)
    print(player)
    return setmetatable({
        Player = player,

        Cleaner = Trove.new()
    }, Nametag)
end

function Nametag:Initial()
    local player = self.Player :: Player
    if player == LocalPlayer then
        self:Destroy()
        return
    end

    if not player.Character then
        repeat
            task.wait()
        until player.Character ~= nil
    end

    self.Character = player.Character
    self:CreateNametag()

    self.Cleaner:Add(player.CharacterAdded:Connect(function(character)
        self.Character = character
        self:CreateNametag()
    end))
end

function Nametag:CreateNametag()
    local player = self.Player :: Player
    warn("creating nametag for "..player.Name)
	-- Destroys player's nametag if it already exists
    local head = self.Character:FindFirstChild("Head")
    assert(head, player.Name.." head does not exist")
	local nametag = head:FindFirstChild(player.Name)
	if nametag then
		warn("found an old nametag for "..player.Name)
		self:DestroyNametag(nametag)
	end

    local humanoid = self.Character:FindFirstChild("Humanoid") :: Humanoid
    assert(humanoid, player.Name.." humanoid does not exist")
    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

    local tag = createTag(self.Player)
    self.Tag = tag

    self.Cleaner:Add(function()
        self:DestroyNametag(tag)
    end)

    self:DisplayNameTag(true, false, false)
    self.Cleaner:Add(player:GetAttributeChangedSignal("Spotted"):Connect(function()
        self:DisplayNameTag(true, true, false)
    end))
end

function Nametag:DisplayNameTag(display: boolean, forced: boolean, instant: boolean)
    local player = self.Player
	local nametag = self.Character.Head:FindFirstChild(player.Name)
	if nametag then
		nametag.Size = UDim2.new(0,49,0,24) -- Temporary workaround to fix a gui bug that makes the healthbar use the full screenwidth of a player.
		nametag.Size = UDim2.new(0,50,0,25)
		if display and (player.Team == LocalPlayer.Team or forced) then
			nametag.GuiPart:TweenSizeAndPosition(UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 0, 13), "Out", "Linear", .2, true)
            
            local i = 0
            while not nametag.PlayerNameFrame.PlayerName and not nametag.HealthBarFrame and i < 10 do
                i = i + 1
                task.wait(0.1)
            end

            nametag.PlayerNameFrame.PlayerName:TweenPosition(UDim2.new(0, 0, -.1, 0), "Out", "Quad", .2, true)
            nametag.HealthBarFrame:TweenSize(UDim2.new(1, 0, 0, 5), "Out", "Quad", .2, true)
		elseif not display and (not player.Team == LocalPlayer.Team or forced) then
			if instant then
				nametag.PlayerNameFrame.PlayerName.Position = UDim2.new(0, 0, 1, 0)
				nametag.HealthBarFrame.Size = UDim2.new(1, 0, 0, 0)
				nametag.GuiPart.Position = UDim2.new(.5, 0, 0, 13)
				nametag.GuiPart.Size = UDim2.new(0, 0, 0, 1)
			else
				nametag.PlayerNameFrame.PlayerName:TweenPosition(UDim2.new(0, 0, 1, 0), "Out", "Quad", .2, true)
				nametag.HealthBarFrame:TweenSize(UDim2.new(1, 0, 0, 0), "Out", "Quad", .2, true)
				
				task.delay(0.2, function()
					if not nametag or nametag:FindFirstChild("GuiPart") == nil then
						self:CreateNametag() --attempted fix
					end
					nametag.GuiPart:TweenSizeAndPosition(UDim2.new(0, 0, 0, 1), UDim2.new(.5, 0, 0, 13), "Out", "Linear", .2, true)
				end)
			end
		end
	end
end

function Nametag:DestroyNametag(nametag: BillboardGui)
    nametag.Active = false
    nametag:Destroy()
end

function Nametag:Destroy()
    self.Cleaner:Destroy()
end

Rosyn.Register("Nametag", {Nametag})

return Nametag