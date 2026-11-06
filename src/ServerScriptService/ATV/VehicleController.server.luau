-- Server-authoritative four-wheel raycast ATV chassis.
-- Parent this Script and Config, Engine, Steering, Suspension, Tires Modules
-- directly under a Workspace vehicle model with Chassis, DriveSeat, Wheels.
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local vehicle = script.Parent
local config = require(vehicle:WaitForChild("Config"))
local Engine = require(vehicle:WaitForChild("Engine"))
local Steering = require(vehicle:WaitForChild("Steering"))
local Suspension = require(vehicle:WaitForChild("Suspension"))
local Tires = require(vehicle:WaitForChild("Tires"))
local seat = vehicle:WaitForChild("DriveSeat")
local chassis = vehicle:WaitForChild("Chassis")
local visuals = vehicle:WaitForChild("Wheels")
local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Exclude
params.FilterDescendantsInstances = {vehicle}
params.RespectCanCollide = true
local throttle, steeringAngle = 0, 0
local spin = {FL = 0, FR = 0, RL = 0, RR = 0}
local wheelState = {}
for _, id in ipairs(config.WheelOrder) do
	local attachment = Instance.new("Attachment")
	attachment.Name = "WheelForce_" .. id
	attachment.Position = config.WheelMounts[id]
	attachment.Parent = chassis
	local force = Instance.new("VectorForce")
	force.Name = "ContactForce_" .. id
	force.Attachment0 = attachment
	force.ApplyAtCenterOfMass = false
	force.RelativeTo = Enum.ActuatorRelativeTo.World
	force.Parent = chassis
	wheelState[id] = {
		attachment = attachment,
		force = force,
		visual = visuals:WaitForChild("Wheel_" .. id)
	}
end
-- With physics computed on the server, keep ownership on the server.
pcall(function() chassis:SetNetworkOwner(nil) end)
local function visualAt(item, cf)
	if item:IsA("Model") then
		item:PivotTo(cf)
	elseif item:IsA("BasePart") then
		item.CFrame = cf
	end
end
RunService.Heartbeat:Connect(function(dt)
	dt = math.clamp(dt, 1 / 240, 0.1)
	local humanoid = seat.Occupant
	local driver = humanoid and Players:GetPlayerFromCharacter(humanoid.Parent)
	local t = driver and seat.ThrottleFloat or 0
	local s = driver and seat.SteerFloat or 0
	throttle = Engine.smooth(throttle, t, dt, config.ThrottleResponse)
	local forwardSpeed = chassis.AssemblyLinearVelocity:Dot(chassis.CFrame.LookVector)
	local targetSteer = Steering.target(s, forwardSpeed, config)
	steeringAngle = Steering.step(steeringAngle, targetSteer, dt, config)
	local mass = chassis.AssemblyMass
	local driveForce, resistForce, braking = Engine.forces(throttle, forwardSpeed, mass, config)
	local drivenCount = config.DriveMode == "AWD" and 4 or 2
	local grounded = 0
	for _, id in ipairs(config.WheelOrder) do
		local w = wheelState[id]
		local state = Suspension.sample(chassis, config.WheelMounts[id], params, config, mass)
		local angle = (string.sub(id, 1, 1) == "F") and steeringAngle or 0
		local tireForce = Vector3.zero
		local speedAtWheel = forwardSpeed
		if state.grounded then
			grounded += 1
			local isDriven = config.DriveMode == "AWD" or string.sub(id, 1, 1) == "R"
			tireForce, speedAtWheel = Tires.compute(chassis, state.contact, state.normal,
				state.load, state.material, angle, driveForce, resistForce, mass, drivenCount, isDriven, config)
		end
		-- Application point includes the tire's contact patch for body pitch/roll.
		local forcePoint = state.contact or state.center
		w.attachment.Position = chassis.CFrame:PointToObjectSpace(forcePoint)
		w.force.Force = state.springForce + tireForce
		spin[id] += speedAtWheel / math.max(config.WheelRadius, 0.1) * dt
		local yaw = math.rad(angle * config.VisualWheelSteeringMultiplier)
		local cf = CFrame.new(state.center)
			* chassis.CFrame.Rotation
			* CFrame.Angles(0, yaw, 0)
			* CFrame.Angles(0, 0, math.pi / 2)
			* CFrame.Angles(0, spin[id], 0)
		visualAt(w.visual, cf)
	end
	local rpm, gear = Engine.telemetry(throttle, forwardSpeed, config)
	vehicle:SetAttribute("Speed", math.abs(forwardSpeed))
	vehicle:SetAttribute("RPM", rpm)
	vehicle:SetAttribute("Gear", gear)
	vehicle:SetAttribute("GroundedWheels", grounded)
	vehicle:SetAttribute("SteeringAngle", steeringAngle)
	vehicle:SetAttribute("Braking", braking)
	vehicle:SetAttribute("DriveMode", config.DriveMode)
end)
