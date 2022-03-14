local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FastCast = require(ReplicatedStorage.Shared.Modules.FastCastRedux)

local GadgetStats = require(ReplicatedStorage.Shared.Configurations.GadgetStats)
local HelperFunctions = require(script.helperFunctions)

local RNG = Random.new()	
local TAU = math.pi * 2 -- Set up mathematical constant Tau (pi * 2)

local NadeCaster = FastCast.new()
local OnRayHit, OnRayBounced, OnRayUpdated, OnRayTerminated, CanRayBounce, CastBehavior = HelperFunctions.OnRayHit, HelperFunctions.OnRayBounced, HelperFunctions.OnRayUpdated, HelperFunctions.OnRayTerminated, HelperFunctions.CanRayBounce, HelperFunctions.CastBehavior

NadeCaster.RayHit:Connect(OnRayHit)
NadeCaster.RayPierced:Connect(OnRayBounced)
NadeCaster.LengthChanged:Connect(OnRayUpdated)
NadeCaster.CastTerminating:Connect(OnRayTerminated)

local Grenades = {}

local CastParams = RaycastParams.new()

local function handleGadgetStats(gadgetStats: GadgetStats.GadgetStats_T)
    FastCast.DebugLogging = gadgetStats.DEBUG
    FastCast.VisualizeCasts = gadgetStats.DEBUG

    CastParams.IgnoreWater = true
    CastParams.FilterType = Enum.RaycastFilterType.Blacklist
    CastParams.FilterDescendantsInstances = CollectionService:GetTagged("Ignore")

    if gadgetStats.Bounce == true then
        CastBehavior.CanPierceFunction = CanRayBounce
    end

    CastBehavior.RaycastParams = CastParams
    CastBehavior.MaxDistance = gadgetStats.MaxDistance
    CastBehavior.CosmeticBulletProvider = gadgetStats.Cache
    CastBehavior.CosmeticBulletContainer = gadgetStats.CacheFolder
    CastBehavior.Acceleration = gadgetStats.Gravity
    CastBehavior.AutoIgnoreContainer = false -- We already do this! We don't need the default value of true (see the bottom of this script)
end

function Grenades:RenderNade(player: Player, position: Vector3, direction: Vector3, movementSpeed: number, gadgetStats: GadgetStats.GadgetStats_T)
	handleGadgetStats(gadgetStats)

    local directionalCF = CFrame.new(Vector3.new(), direction)
	direction = (directionalCF * CFrame.fromOrientation(0, 0, RNG:NextNumber(0, TAU)) * CFrame.fromOrientation(math.rad(RNG:NextNumber(gadgetStats.MinSpreadAngle, gadgetStats.MaxSpreadAngle)), 0, 0)).LookVector
    local modifiedBulletSpeed = (direction * gadgetStats.ProjectileSpeed) + movementSpeed	-- We multiply our direction unit by the bullet speed. This creates a Vector3 version of the bullet's velocity at the given speed. We then add MyMovementSpeed to add our body's motion to the velocity.

    local activeCast = NadeCaster:Fire(position, direction, modifiedBulletSpeed, CastBehavior)
	activeCast.UserData.SourceTeam = player.TeamColor
	activeCast.UserData.SourcePlayer = player
    activeCast.UserData.gadgetStats = gadgetStats
end

return Grenades