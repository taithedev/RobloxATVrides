-- Tire steering targets, in degrees. No physics-hinge steering required:
-- forces are calculated using each front wheel's steered ground plane.
local Steering = {}

function Steering.target(input, speed, cfg)
	local v = math.clamp(math.abs(speed) / math.max(cfg.MaxForwardSpeed, 1), 0, 1)
	local factor = 1 - cfg.SteeringSpeedReduction * v
	return math.clamp(input, -1, 1) * cfg.SteeringAngleDegrees * factor
end

function Steering.step(current, target, dt, cfg)
	return current + (target - current) * (1 - math.exp(-cfg.SteeringResponse * math.clamp(dt, 0, 0.2)))
end

return Steering
