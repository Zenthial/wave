local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts

local FastCast = require(ReplicatedStorage.Shared.Modules.FastCastRedux)
local GadgetStats = require(ReplicatedStorage.Shared.Configurations.GadgetStats)
local ClientComm = require(StarterPlayerScripts.Client.Modules.ClientComm)

local CastBehavior = FastCast.newBehavior()
local Comm = ClientComm.GetClientComm()
local Player = Players.LocalPlayer

local dealSelfDamage = Comm:GetFunction("DealSelfDamage")

local function CanRayBounce(cast, rayResult, segmentVelocity)
    local gadgetStats = cast.UserData.GadgetStats :: GadgetStats.GadgetStats_T
	
	-- Let's keep track of how many times we've hit something.
	local hits = cast.UserData.Hits
	if hits == nil then
		-- If the hit data isn't registered, set it to 1 (because this is our first hit)
		cast.UserData.Hits = 1
	else
		-- If the hit data is registered, add 1.
		cast.UserData.Hits += 1
	end
	
	-- And if the hit count is over GadgetStats.NumBounces, don't allow piercing and instead stop the ray.
	if cast.UserData.Hits > gadgetStats.NumBounces then
		return false
	end
	
	-- Now if we make it here, we want our ray to continue.
	-- This is extra important! If a bullet bounces off of something, maybe we want it to do damage too!
	-- So let's implement that.
	local hitPart = rayResult.Instance
	if hitPart ~= nil and hitPart.Parent ~= nil then
		local humanoid = hitPart.Parent:FindFirstChildOfClass("Humanoid")
		if humanoid then
			-- possibly integrate a csgo-like deal 1 damage here
		end
	end
	
	-- And then lastly, return true to tell FC to continue simulating.
	return true
end

local function reflect(surfaceNormal, bulletNormal)
	return bulletNormal - (2 * bulletNormal:Dot(surfaceNormal) * surfaceNormal)
end

local function handleNadeTermination(part: Part, sourceTeam: BrickColor, sourcePlayer: Player, gadgetStats: GadgetStats.GadgetStats_T)
	local character = Player.Character
	if character then
		local distance = (character.HumanoidRootPart.Position - part.Position).Magnitude
		local explosion = Instance.new("Explosion")
        explosion.Position = part.Position
        explosion.BlastRadius = GadgetStats.NadeRadius
        explosion.BlastPressure = 0
        explosion.DestroyJointRadiusPercent = 0
        explosion.Parent = workspace

        task.delay(1, function()
            explosion:Destroy()
        end)

        local function Damage()
            local distanceDamageFactor = 1-(distance/GadgetStats.NadeRadius)
            dealSelfDamage(math.abs(GadgetStats.MaxDamage*distanceDamageFactor))
        end

        if distance <= GadgetStats.NadeRadius then
            if Player.TeamColor ~= sourceTeam then
                Damage()
            -- elseif Player == sourcePlayer then
            --     Damage()
            end
        end
	end
end

-- Event Handlers

local function OnRayHit(cast, raycastResult, segmentVelocity, cosmeticBulletObject)
	-- This function will be connected to the Caster's "RayHit" event.
	local hitPart = raycastResult.Instance
	local hitPoint = raycastResult.Position
	local normal = raycastResult.Normal
	if hitPart ~= nil and hitPart.Parent ~= nil then -- Test if we hit something
		local humanoid = hitPart.Parent:FindFirstChildOfClass("Humanoid") -- Is there a humanoid?
		if humanoid then
			-- Deal 1 damage like CSGO?
		end
	end
end

local function OnRayBounced(cast, raycastResult, segmentVelocity, cosmeticBulletObject)
	-- You can do some really unique stuff with BOUNCE behavior - In reality, BOUNCE is just the module's way of asking "Do I keep the bullet going, or do I stop it here?"
	-- You can make use of this unique behavior in a manner like this, for instance, which causes bullets to be bouncy.
	local position = raycastResult.Position
	local normal = raycastResult.Normal
	
	local newNormal = reflect(normal, segmentVelocity.Unit)
	cast:SetVelocity(newNormal * segmentVelocity.Magnitude / 2)
	-- It's super important that we set the cast's position to the ray hit position. Remember: When a BOUNCE is successful, it increments the ray forward by one increment.
	-- If we don't do this, it'll actually start the bounce effect one segment *after* it continues through the object, which for thin walls, can cause the bullet to almost get stuck in the wall.
	cast:SetPosition(position)
	
	-- Generally speaking, if you plan to do any velocity modifications to the bullet at all, you should use the line above to reset the position to where it was when the BOUNCE was registered.
end

local function OnRayUpdated(cast, segmentOrigin, segmentDirection, length, segmentVelocity, cosmeticBulletObject)
	-- Whenever the caster steps forward by one unit, this function is called.
	-- The bullet argument is the same object passed into the fire function.
	if cosmeticBulletObject == nil then return end
	local bulletLength = cosmeticBulletObject.Size.Z / 2 -- This is used to move the bullet to the right spot based on a CFrame offset
	local baseCFrame = CFrame.new(segmentOrigin, segmentOrigin + segmentDirection)
	cosmeticBulletObject.CFrame = baseCFrame * CFrame.new(0, 0, -(length - bulletLength))
end

local function OnRayTerminated(cast)
	local cosmeticBullet: BasePart = cast.RayInfo.CosmeticBulletObject
    local GadgetStats = cast.UserData.GadgetStats :: GadgetStats.GadgetStats_T
	if cosmeticBullet ~= nil then
		cast:SetPosition(cosmeticBullet.Position)
		task.wait(GadgetStats.PopTime)
		handleNadeTermination(cosmeticBullet, cast.UserData.SourceTeam, cast.UserData.SourcePlayer)
		task.wait(GadgetStats.DelayTime)
		CastBehavior.CosmeticBulletProvider:ReturnPart(cosmeticBullet)
	end
end

return {
    CanRayBounce = CanRayBounce,
    Reflect = reflect,
    OnRayHit = OnRayHit,
    OnRayBounced = OnRayBounced,
    OnRayUpdated = OnRayUpdated,
    OnRayTerminated = OnRayTerminated,
    CastBehavior = CastBehavior,
}