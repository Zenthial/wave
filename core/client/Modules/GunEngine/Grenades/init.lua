local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FastCast = require(ReplicatedStorage.Shared.Modules.FastCastRedux)

local GadgetStats = require(ReplicatedStorage.Shared.Configurations.GadgetStats)
local HelperFunctions = require(script.helperFunctions)

local RNG = Random.new()	
local TAU = math.pi * 2 -- Set up mathematical constant Tau (pi * 2)

local NadeCaster = FastCast.new()
local OnRayHit, OnRayBounced, OnRayUpdated, OnRayTerminated, CanRayBounce, CastBehavior, HandleGadgetStats = HelperFunctions.OnRayHit, HelperFunctions.OnRayBounced, HelperFunctions.OnRayUpdated, HelperFunctions.OnRayTerminated, HelperFunctions.CanRayBounce, HelperFunctions.CastBehavior, HelperFunctions.HandleGadgetStats

NadeCaster.RayHit:Connect(OnRayHit)
NadeCaster.RayPierced:Connect(OnRayBounced)
NadeCaster.LengthChanged:Connect(OnRayUpdated)

local Grenades = {}

local CastParams = RaycastParams.new()

function Grenades:RenderNade(player: Player, position: Vector3, direction: Vector3, movementSpeed: Vector3, gadgetStats: GadgetStats.GadgetStats_T)
    print(player, position, direction, movementSpeed, gadgetStats)
	if not player.Character then print("returning") return end
    handleGadgetStats(player, NadeCaster, CastParams, gadgetStats)

    local directionalCF = CFrame.new(Vector3.new(), direction)
	direction = (directionalCF * CFrame.fromOrientation(0, 0, RNG:NextNumber(0, TAU)) * CFrame.fromOrientation(math.rad(RNG:NextNumber(gadgetStats.MinSpreadAngle, gadgetStats.MaxSpreadAngle)), 0, 0)).LookVector
    -- local modifiedBulletSpeed = (direction * gadgetStats.ProjectileSpeed) + movementSpeed	-- We multiply our direction unit by the bullet speed. This creates a Vector3 version of the bullet's velocity at the given speed. We then add MyMovementSpeed to add our body's motion to the velocity.

    local activeCast = NadeCaster:Fire(position, direction, gadgetStats.ProjectileSpeed, CastBehavior)
    print(activeCast)
	activeCast.UserData.SourceTeam = player.TeamColor
	activeCast.UserData.SourcePlayer = player
    activeCast.UserData.GadgetStats = gadgetStats
end

return Grenades
