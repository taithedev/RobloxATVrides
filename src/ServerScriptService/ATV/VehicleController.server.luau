-- Server-authoritative raycast ATV, matched to ATV_Manifest.json.
-- The imported 165-part visual geometry is installed by ImportBlenderATV command.
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local vehicle = script.Parent
local cfg = require(vehicle:WaitForChild("Config"))
local Engine = require(vehicle:WaitForChild("Engine"))
local Steering = require(vehicle:WaitForChild("Steering"))
local Suspension = require(vehicle:WaitForChild("Suspension"))
local Tires = require(vehicle:WaitForChild("Tires"))
local VisualRig = require(vehicle:WaitForChild("VisualRig"))
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
local rig = VisualRig.create(vehicle:FindFirstChild("VisualDetails"), cfg)
local function buildWheelForce(id)
 local attachment = Instance.new("Attachment")
 attachment.Name = "ForcePoint_" .. id
 attachment.Position = cfg.WheelMounts[id]
 attachment.Parent = chassis
 local force = Instance.new("VectorForce")
 force.Name = "ContactForce_" .. id
 force.Attachment0 = attachment
 force.RelativeTo = Enum.ActuatorRelativeTo.World
 force.ApplyAtCenterOfMass = false
 force.Parent = chassis
 return {attachment = attachment, force = force}
end
for _, id in ipairs(cfg.WheelOrder) do wheelState[id] = buildWheelForce(id) end
local wheelTravel = {}
-- Recreate visual-cache if the Blender importer runs while the game is stopped
-- (regular edit-mode workflow initializes it correctly at Play time).
pcall(function() chassis:SetNetworkOwner(nil) end)
RunService.Heartbeat:Connect(function(dt)
 dt = math.clamp(dt, 1/240, 0.1)
 local humanoid = seat.Occupant
 local driver = humanoid and Players:GetPlayerFromCharacter(humanoid.Parent)
 local t = driver and seat.ThrottleFloat or 0
 local s = driver and seat.SteerFloat or 0
 throttle = Engine.smooth(throttle, t, dt, cfg.ThrottleResponse)
 local forwardSpeed = chassis.AssemblyLinearVelocity:Dot(chassis.CFrame.LookVector)
 steeringAngle = Steering.step(steeringAngle, Steering.target(s, forwardSpeed, cfg), dt, cfg)
 local mass = chassis.AssemblyMass
 local driveForce, resistForce, braking = Engine.forces(throttle, forwardSpeed, mass, cfg)
 local drivenCount = cfg.DriveMode=="AWD" and 4 or 2
 local grounded = 0
 for _, id in ipairs(cfg.WheelOrder) do
  local wheel = wheelState[id]
  local state = Suspension.sample(chassis, cfg.WheelMounts[id], params, cfg, mass)
  local steer = string.sub(id,1,1)=="F" and steeringAngle or 0
  local tireForce = Vector3.zero
  local groundSpeed = forwardSpeed
  if state.grounded then
   grounded += 1
   local powered = cfg.DriveMode=="AWD" or string.sub(id,1,1)=="R"
   tireForce, groundSpeed = Tires.compute(chassis, state.contact, state.normal,
    state.load, state.material, steer, driveForce, resistForce, mass, drivenCount, powered, cfg)
  end
  wheel.attachment.Position = chassis.CFrame:PointToObjectSpace(state.contact or state.center)
  wheel.force.Force = state.springForce + tireForce
  -- Angle zero at the wheel's *Blender axle-X* rest pose. The imported
  -- visual group includes a nonvisible center pivot at that axis.
  spin[id] += groundSpeed / math.max(cfg.WheelRadius, 0.1) * dt
  local wheelVisual = visuals:FindFirstChild("Wheel_" .. id)
  if wheelVisual then
   local frame = CFrame.new(state.center) * chassis.CFrame.Rotation
    * CFrame.Angles(0,math.rad(steer),0) * CFrame.Angles(spin[id],0,0)
   if wheelVisual:IsA("Model") then wheelVisual:PivotTo(frame)
   elseif wheelVisual:IsA("BasePart") then wheelVisual.CFrame = frame * CFrame.Angles(0,0,math.pi/2) end
  end
  wheelTravel[id] = math.clamp(cfg.NominalHubTravel - state.length, -0.7, 0.7)
 end
 VisualRig.step(rig, chassis.CFrame, wheelTravel, steeringAngle, cfg)
 local rpm, gear = Engine.telemetry(throttle, forwardSpeed, cfg)
 vehicle:SetAttribute("Speed", math.abs(forwardSpeed))
 vehicle:SetAttribute("RPM", rpm)
 vehicle:SetAttribute("Gear", gear)
 vehicle:SetAttribute("GroundedWheels", grounded)
 vehicle:SetAttribute("SteeringAngle", steeringAngle)
 vehicle:SetAttribute("Braking", braking)
 vehicle:SetAttribute("DriveMode", cfg.DriveMode)
end)
