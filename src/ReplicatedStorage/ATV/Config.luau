-- Zuzu ATV shared tuning (Roblox simulation units, studs and seconds)
-- Chassis faces -Z; X is left/right, Y is up.
return {
	Version = "0.2.0",
	WheelOrder = {"FL", "FR", "RL", "RR"},
	WheelMounts = {
		FL = Vector3.new(-2.35, 0, -2.15),
		FR = Vector3.new(2.35, 0, -2.15),
		RL = Vector3.new(-2.35, 0, 2.15),
		RR = Vector3.new(2.35, 0, 2.15),
	},
	WheelRadius = 1.32,
	WheelWidth = 0.85,
	SuspensionRestLength = 1.85,
	SuspensionMinLength = 0.25,
	SuspensionMaxLength = 2.30,
	SuspensionSagFraction = 0.36,
	SuspensionDampingRatio = 0.83,
	SuspensionMaxLoadMultiplier = 4.0,
	DriveMode = "AWD", -- "AWD" or "RWD"
	MaxForwardSpeed = 95, -- studs/second
	MaxReverseSpeed = 30,
	FullPowerUntilSpeed = 55,
	DriveAcceleration = 57, -- studs/second^2
	BrakeAcceleration = 125,
	OpposingBrakeThreshold = 3,
	CoastingDrag = 0.75,
	ThrottleResponse = 5,
	SteeringAngleDegrees = 34,
	SteeringSpeedReduction = 0.65,
	SteeringResponse = 8,
	LateralResponse = 8.0,
	IdleRPM = 1000,
	RedlineRPM = 7600,
	TireGrip = 1.2,
	MaterialGrip = {
		[Enum.Material.Asphalt] = 1.25,
		[Enum.Material.Concrete] = 1.2,
		[Enum.Material.Grass] = 1.0,
		[Enum.Material.Ground] = 0.9,
		[Enum.Material.Mud] = 0.7,
		[Enum.Material.Sand] = 0.63,
		[Enum.Material.Snow] = 0.50,
		[Enum.Material.Ice] = 0.18,
	},
	VisualWheelSteeringMultiplier = 1,
	EnableServerPhysics = true, -- preserve server authority for initial testing
}
