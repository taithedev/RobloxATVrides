-- Drivetrain input model. This is a continuous-ratio ATV approximation,
-- not an experimentally validated engine/gearbox simulation.
local Engine = {}

function Engine.smooth(current, target, dt, response)
	local a = 1 - math.exp(-math.max(0, response) * math.clamp(dt, 0, 0.2))
	return current + (math.clamp(target, -1, 1) - current) * a
end

function Engine.forces(throttle, forwardSpeed, mass, cfg)
	-- All outputs are TOTAL vehicle forces, split across tires by TirePhysics.
	if math.abs(throttle) < 0.035 then
		return 0, -forwardSpeed * mass * cfg.CoastingDrag, false
	end
	if forwardSpeed * throttle < -cfg.OpposingBrakeThreshold then
		return 0, -math.sign(forwardSpeed) * mass * cfg.BrakeAcceleration, true
	end
	local speedInDirection = forwardSpeed * math.sign(throttle)
	local cap = throttle >= 0 and cfg.MaxForwardSpeed or cfg.MaxReverseSpeed
	if speedInDirection >= cap then
		return 0, -forwardSpeed * mass * cfg.CoastingDrag, false
	end
	local reduction = math.clamp((cap - speedInDirection) / math.max(cap - cfg.FullPowerUntilSpeed, 1), 0, 1)
	-- Reverse receives less acceleration for controlled low-speed maneuvering.
	local reverseScale = throttle < 0 and 0.65 or 1
	return throttle * mass * cfg.DriveAcceleration * reduction * reverseScale, 0, false
end

function Engine.telemetry(throttle, speed, cfg)
	local ratio = math.clamp(math.abs(speed) / cfg.MaxForwardSpeed, 0, 1)
	local throttleRatio = math.abs(throttle) * 0.38
	local rpm = math.floor(cfg.IdleRPM + (cfg.RedlineRPM - cfg.IdleRPM) * math.max(ratio, throttleRatio))
	local gear = "N"
	if throttle > 0.08 then gear = "D" elseif throttle < -0.08 then gear = "R" end
	return rpm, gear
end

return Engine
