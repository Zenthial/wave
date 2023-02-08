--[[
	BEWARE, UGLY CODE AHEAD!

	MANY HOURS HAVE BEEN SPENT HERE TRYING TO MAKE THIS LOOK BETTER
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local FastCast = require(ReplicatedStorage.Shared.Modules.FastCastRedux)
local GadgetStats = require(ReplicatedStorage.Shared.Configurations.GadgetStats)

local CastBehavior = FastCast.newBehavior()

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
	if cast.UserData.Hits > (gadgetStats.NumBounces or 0) then
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

-- Event Handlers

local function OnRayHit(cast, raycastResult, segmentVelocity, cosmeticBulletObject)
	-- This function will be connected to the Caster's "RayHit" event.
	local hitPart = raycastResult.Instance
	local hitPoint = raycastResult.Position
	if hitPart ~= nil and hitPart.Parent ~= nil then -- Test if we hit something
		cast.UserData.LastHitPart = hitPart
		cast.UserData.LastHitPoint = hitPoint
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
	local terminationFunction = cast.UserData.TerminationFunction
	if cosmeticBullet ~= nil and cosmeticBullet.Position ~= nil then
		cast:SetPosition(cosmeticBullet.Position)

		terminationFunction(CastBehavior.CosmeticBulletProvider, cosmeticBullet.CFrame, cast.UserData.SourceTeam, cast.UserData.SourcePlayer, cast.UserData.GadgetStats, cast.UserData.LastHitPart, cast.UserData.LastHitPoint)
		CastBehavior.CosmeticBulletProvider:ReturnPart(cosmeticBullet)
	end
end

local function HandleGadgetStats(player: Player, NadeCaster, CastParams, gadgetStats: GadgetStats.GadgetStats_T)
    FastCast.DebugLogging = gadgetStats.DEBUG
    FastCast.VisualizeCasts = gadgetStats.DEBUG
    NadeCaster.CastTerminating:Connect(OnRayTerminated)

    CastParams.IgnoreWater = true
    CastParams.FilterType = Enum.RaycastFilterType.Blacklist

    local ignoreTable = {}
    for _, part in player.Character:GetChildren() do
        table.insert(ignoreTable, part)
    end
    for _, thing in CollectionService:GetTagged("Ignore") do
        table.insert(ignoreTable, thing)
    end

    CastParams.FilterDescendantsInstances = ignoreTable

    if gadgetStats.Bounce == true then
        CastBehavior.CanPierceFunction = CanRayBounce
    end

    CastBehavior.RaycastParams = CastParams
    CastBehavior.CosmeticBulletProvider = gadgetStats.Cache
    CastBehavior.CosmeticBulletContainer = gadgetStats.CacheFolder
    CastBehavior.Acceleration = gadgetStats.Gravity
    CastBehavior.AutoIgnoreContainer = false -- We already do this! We don't need the default value of true (see the bottom of this script)
end

return {
    CanRayBounce = CanRayBounce,
    Reflect = reflect,
    OnRayHit = OnRayHit,
    OnRayBounced = OnRayBounced,
    OnRayUpdated = OnRayUpdated,
    OnRayTerminated = OnRayTerminated,
    CastBehavior = CastBehavior,
    HandleGadgetStats = HandleGadgetStats
}
