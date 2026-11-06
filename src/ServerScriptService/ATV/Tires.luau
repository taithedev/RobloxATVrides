-- Forces applied at the contact patch to produce turning, acceleration,
-- braking and slip. Includes a traction-circle clamp for each tire.
local Tires = {}

local function planar(v, normal)
	local p = v - normal * v:Dot(normal)
	if p.Magnitude < 0.001 then return nil end
	return p.Unit
end

function Tires.compute(chassis, contact, surfaceNormal, normalLoad, material, steerDegrees,
	propulsionTotal, resistTotal, assemblyMass, drivenCount, isDriven, cfg)
	if normalLoad <= 0 then return Vector3.zero, 0 end
	local up = chassis.CFrame.UpVector
	local yaw = CFrame.fromAxisAngle(up, math.rad(steerDegrees))
	local nominalForward = yaw:VectorToWorldSpace(chassis.CFrame.LookVector)
	local forward = planar(nominalForward, surfaceNormal)
	if not forward then return Vector3.zero, 0 end
	local right = forward:Cross(surfaceNormal).Unit
	local velocity = chassis:GetVelocityAtPosition(contact)
	local longSpeed = velocity:Dot(forward)
	local lateralSpeed = velocity:Dot(right)
	local drive = isDriven and propulsionTotal / math.max(1, drivenCount) or 0
	local braking = resistTotal / 4
	local lateral = -lateralSpeed * (assemblyMass / 4) * cfg.LateralResponse
	local wanted = forward * (drive + braking) + right * lateral
	local materialGrip = cfg.MaterialGrip[material] or 0.88
	local tractionCap = normalLoad * cfg.TireGrip * materialGrip
	if wanted.Magnitude > tractionCap and wanted.Magnitude > 0 then
		wanted = wanted.Unit * tractionCap
	end
	return wanted, longSpeed
end

return Tires
