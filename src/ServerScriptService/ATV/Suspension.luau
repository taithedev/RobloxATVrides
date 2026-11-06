-- Physically applied wheel loads from four independent spring-damper raycasts.
local Suspension = {}

function Suspension.sample(chassis, localMount, params, cfg, assemblyMass)
	local frame = chassis.CFrame
	local up = frame.UpVector
	local mount = frame:PointToWorldSpace(localMount)
	local distance = cfg.SuspensionMaxLength + cfg.WheelRadius
	local hit = workspace:Raycast(mount, -up * distance, params)
	local fallbackCenter = mount - up * cfg.SuspensionRestLength
	if not hit or hit.Normal:Dot(up) < 0.28 then
		return {
			grounded = false, center = fallbackCenter, contact = nil,
			normal = up, load = 0, springForce = Vector3.zero,
			material = nil, length = cfg.SuspensionRestLength
		}
	end
	local length = math.clamp(hit.Distance - cfg.WheelRadius, cfg.SuspensionMinLength, cfg.SuspensionMaxLength)
	local compression = math.max(0, cfg.SuspensionRestLength - length)
	local mPerWheel = math.max(1, assemblyMass / 4)
	local k = mPerWheel * workspace.Gravity / math.max(cfg.SuspensionRestLength * cfg.SuspensionSagFraction, 0.1)
	local damping = 2 * math.sqrt(k * mPerWheel) * cfg.SuspensionDampingRatio
	local pointVelocity = chassis:GetVelocityAtPosition(mount)
	local verticalSpeed = pointVelocity:Dot(up)
	local maxLoad = mPerWheel * workspace.Gravity * cfg.SuspensionMaxLoadMultiplier
	local load = math.clamp(k * compression - damping * verticalSpeed, 0, maxLoad)
	return {
		grounded = true, center = hit.Position + up * cfg.WheelRadius,
		contact = hit.Position, normal = hit.Normal, load = load,
		springForce = up * load, material = hit.Material, length = length
	}
end

return Suspension
