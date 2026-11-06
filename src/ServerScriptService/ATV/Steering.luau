--!strict
local Steering = {}
function Steering.angle(input: number, speed: number, config: any): number
	local speedFactor = 1 - 0.55 * math.clamp(math.abs(speed) / config.MaxSpeedStudsPerSecond, 0, 1)
	return math.rad(config.SteeringAngleDegrees) * math.clamp(input, -1, 1) * speedFactor
end
return Steering
