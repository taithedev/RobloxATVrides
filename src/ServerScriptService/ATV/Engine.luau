--!strict
local Engine = {}
function Engine.step(currentThrottle: number, requestedThrottle: number, dt: number, response: number): number
	local alpha = 1 - math.exp(-response * math.max(dt, 0))
	return currentThrottle + (math.clamp(requestedThrottle, -1, 1) - currentThrottle) * alpha
end
function Engine.rpm(speed: number, throttle: number, config: any): number
	local fraction = math.clamp(math.abs(speed) / config.MaxSpeedStudsPerSecond, 0, 1)
	return math.floor(config.IdleRPM + (config.RedlineRPM - config.IdleRPM) * math.max(fraction, math.abs(throttle) * 0.25))
end
return Engine
