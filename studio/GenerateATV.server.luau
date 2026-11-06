-- RUN ONCE in Roblox Studio > View > Command Bar, in EDIT mode (not Play).
-- Creates a test chassis and installs all runtime code and the client HUD.
local Workspace = game:GetService("Workspace")
local StarterPlayer = game:GetService("StarterPlayer")
local existing = Workspace:FindFirstChild("ZuzuATV")
if existing then existing:Destroy() end
local atv = Instance.new("Model")
atv.Name = "ZuzuATV"
atv:SetAttribute("PrototypeVersion", "0.2.0")
atv.Parent = Workspace
local function make(name, size, color, cf, parent, anchored, collision)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Color = color
	p.Material = Enum.Material.Metal
	p.CFrame = cf
	p.Anchored = anchored
	p.CanCollide = collision
	p.CanQuery = collision
	p.CanTouch = collision
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end
local rootCF = CFrame.new(0, 6, 0)
local chassis = make("Chassis", Vector3.new(3.7, .9, 5.5), Color3.fromRGB(64, 68, 62), rootCF, atv, false, true)
chassis.CustomPhysicalProperties = PhysicalProperties.new(2.0, 0.7, 0.1, 100, 100)
chassis.RootPriority = 127
local function attachDecor(name, size, color, localCF)
	local part = make(name, size, color, rootCF * localCF, atv, false, false)
	part.Massless = true
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = chassis
	weld.Part1 = part
	weld.Parent = part
	return part
end
attachDecor("LeftFender", Vector3.new(1.7, .34, 4.8), Color3.fromRGB(149, 85, 60), CFrame.new(-1.7, .74, 0))
attachDecor("RightFender", Vector3.new(1.7, .34, 4.8), Color3.fromRGB(149, 85, 60), CFrame.new(1.7, .74, 0))
attachDecor("FuelTank", Vector3.new(1.8, .9, 1.3), Color3.fromRGB(85, 100, 75), CFrame.new(0, .8, -1.0))
attachDecor("SeatCushion", Vector3.new(1.75, .35, 2.1), Color3.fromRGB(44, 43, 40), CFrame.new(0, .98, 1.05))
attachDecor("FrontBumper", Vector3.new(3.2, .38, .35), Color3.fromRGB(49, 53, 50), CFrame.new(0, -.25, -3.05))
attachDecor("RearBumper", Vector3.new(3.2, .38, .35), Color3.fromRGB(49, 53, 50), CFrame.new(0, -.25, 3.05))
attachDecor("Handlebar", Vector3.new(3.0, .20, .25), Color3.fromRGB(31, 34, 35), CFrame.new(0, 2.05, -.95))
local seat = Instance.new("VehicleSeat")
seat.Name = "DriveSeat"
seat.Size = Vector3.new(1.8, .5, 1.6)
seat.Color = Color3.fromRGB(36, 38, 39)
seat.Material = Enum.Material.SmoothPlastic
seat.CFrame = rootCF * CFrame.new(0, 1.13, 1.12)
seat.Anchored = false
seat.CanCollide = false
seat.Parent = atv
local sw = Instance.new("WeldConstraint")
sw.Part0 = chassis
sw.Part1 = seat
sw.Parent = seat
local wheels = Instance.new("Folder")
wheels.Name = "Wheels"
wheels.Parent = atv
for id, v in pairs({
	FL = Vector3.new(-2.35, -1.6, -2.15),
	FR = Vector3.new(2.35, -1.6, -2.15),
	RL = Vector3.new(-2.35, -1.6, 2.15),
	RR = Vector3.new(2.35, -1.6, 2.15),
}) do
	local tire = make("Wheel_" .. id, Vector3.new(2.64, .85, 2.64), Color3.fromRGB(28, 28, 29),
		rootCF * CFrame.new(v) * CFrame.Angles(0, 0, math.pi / 2), wheels, true, false)
	tire.Material = Enum.Material.Rubber
	tire.Shape = Enum.PartType.Cylinder
end
atv.PrimaryPart = chassis
local function installModule(name, source)
	local m = Instance.new("ModuleScript")
	m.Name = name
	m.Source = source
	m.Parent = atv
end
local function installScript(name, source, parent, cls)
	local s = Instance.new(cls)
	s.Name = name
	s.Source = source
	s.Parent = parent
end
installModule("Config", "-- Zuzu ATV shared tuning (Roblox simulation units, studs and seconds)\n-- Chassis faces -Z; X is left/right, Y is up.\nreturn {\n\tVersion = \"0.2.0\",\n\tWheelOrder = {\"FL\", \"FR\", \"RL\", \"RR\"},\n\tWheelMounts = {\n\t\tFL = Vector3.new(-2.35, 0, -2.15),\n\t\tFR = Vector3.new(2.35, 0, -2.15),\n\t\tRL = Vector3.new(-2.35, 0, 2.15),\n\t\tRR = Vector3.new(2.35, 0, 2.15),\n\t},\n\tWheelRadius = 1.32,\n\tWheelWidth = 0.85,\n\tSuspensionRestLength = 1.85,\n\tSuspensionMinLength = 0.25,\n\tSuspensionMaxLength = 2.30,\n\tSuspensionSagFraction = 0.36,\n\tSuspensionDampingRatio = 0.83,\n\tSuspensionMaxLoadMultiplier = 4.0,\n\tDriveMode = \"AWD\", -- \"AWD\" or \"RWD\"\n\tMaxForwardSpeed = 95, -- studs/second\n\tMaxReverseSpeed = 30,\n\tFullPowerUntilSpeed = 55,\n\tDriveAcceleration = 57, -- studs/second^2\n\tBrakeAcceleration = 125,\n\tOpposingBrakeThreshold = 3,\n\tCoastingDrag = 0.75,\n\tThrottleResponse = 5,\n\tSteeringAngleDegrees = 34,\n\tSteeringSpeedReduction = 0.65,\n\tSteeringResponse = 8,\n\tLateralResponse = 8.0,\n\tIdleRPM = 1000,\n\tRedlineRPM = 7600,\n\tTireGrip = 1.2,\n\tMaterialGrip = {\n\t\t[Enum.Material.Asphalt] = 1.25,\n\t\t[Enum.Material.Concrete] = 1.2,\n\t\t[Enum.Material.Grass] = 1.0,\n\t\t[Enum.Material.Ground] = 0.9,\n\t\t[Enum.Material.Mud] = 0.7,\n\t\t[Enum.Material.Sand] = 0.63,\n\t\t[Enum.Material.Snow] = 0.50,\n\t\t[Enum.Material.Ice] = 0.18,\n\t},\n\tVisualWheelSteeringMultiplier = 1,\n\tEnableServerPhysics = true, -- preserve server authority for initial testing\n}\n")
installModule("Engine", "-- Drivetrain input model. This is a continuous-ratio ATV approximation,\n-- not an experimentally validated engine/gearbox simulation.\nlocal Engine = {}\n\nfunction Engine.smooth(current, target, dt, response)\n\tlocal a = 1 - math.exp(-math.max(0, response) * math.clamp(dt, 0, 0.2))\n\treturn current + (math.clamp(target, -1, 1) - current) * a\nend\n\nfunction Engine.forces(throttle, forwardSpeed, mass, cfg)\n\t-- All outputs are TOTAL vehicle forces, split across tires by TirePhysics.\n\tif math.abs(throttle) < 0.035 then\n\t\treturn 0, -forwardSpeed * mass * cfg.CoastingDrag, false\n\tend\n\tif forwardSpeed * throttle < -cfg.OpposingBrakeThreshold then\n\t\treturn 0, -math.sign(forwardSpeed) * mass * cfg.BrakeAcceleration, true\n\tend\n\tlocal speedInDirection = forwardSpeed * math.sign(throttle)\n\tlocal cap = throttle >= 0 and cfg.MaxForwardSpeed or cfg.MaxReverseSpeed\n\tif speedInDirection >= cap then\n\t\treturn 0, -forwardSpeed * mass * cfg.CoastingDrag, false\n\tend\n\tlocal reduction = math.clamp((cap - speedInDirection) / math.max(cap - cfg.FullPowerUntilSpeed, 1), 0, 1)\n\t-- Reverse receives less acceleration for controlled low-speed maneuvering.\n\tlocal reverseScale = throttle < 0 and 0.65 or 1\n\treturn throttle * mass * cfg.DriveAcceleration * reduction * reverseScale, 0, false\nend\n\nfunction Engine.telemetry(throttle, speed, cfg)\n\tlocal ratio = math.clamp(math.abs(speed) / cfg.MaxForwardSpeed, 0, 1)\n\tlocal throttleRatio = math.abs(throttle) * 0.38\n\tlocal rpm = math.floor(cfg.IdleRPM + (cfg.RedlineRPM - cfg.IdleRPM) * math.max(ratio, throttleRatio))\n\tlocal gear = \"N\"\n\tif throttle > 0.08 then gear = \"D\" elseif throttle < -0.08 then gear = \"R\" end\n\treturn rpm, gear\nend\n\nreturn Engine\n")
installModule("Steering", "-- Tire steering targets, in degrees. No physics-hinge steering required:\n-- forces are calculated using each front wheel's steered ground plane.\nlocal Steering = {}\n\nfunction Steering.target(input, speed, cfg)\n\tlocal v = math.clamp(math.abs(speed) / math.max(cfg.MaxForwardSpeed, 1), 0, 1)\n\tlocal factor = 1 - cfg.SteeringSpeedReduction * v\n\treturn math.clamp(input, -1, 1) * cfg.SteeringAngleDegrees * factor\nend\n\nfunction Steering.step(current, target, dt, cfg)\n\treturn current + (target - current) * (1 - math.exp(-cfg.SteeringResponse * math.clamp(dt, 0, 0.2)))\nend\n\nreturn Steering\n")
installModule("Suspension", "-- Physically applied wheel loads from four independent spring-damper raycasts.\nlocal Suspension = {}\n\nfunction Suspension.sample(chassis, localMount, params, cfg, assemblyMass)\n\tlocal frame = chassis.CFrame\n\tlocal up = frame.UpVector\n\tlocal mount = frame:PointToWorldSpace(localMount)\n\tlocal distance = cfg.SuspensionMaxLength + cfg.WheelRadius\n\tlocal hit = workspace:Raycast(mount, -up * distance, params)\n\tlocal fallbackCenter = mount - up * cfg.SuspensionRestLength\n\tif not hit or hit.Normal:Dot(up) < 0.28 then\n\t\treturn {\n\t\t\tgrounded = false, center = fallbackCenter, contact = nil,\n\t\t\tnormal = up, load = 0, springForce = Vector3.zero,\n\t\t\tmaterial = nil, length = cfg.SuspensionRestLength\n\t\t}\n\tend\n\tlocal length = math.clamp(hit.Distance - cfg.WheelRadius, cfg.SuspensionMinLength, cfg.SuspensionMaxLength)\n\tlocal compression = math.max(0, cfg.SuspensionRestLength - length)\n\tlocal mPerWheel = math.max(1, assemblyMass / 4)\n\tlocal k = mPerWheel * workspace.Gravity / math.max(cfg.SuspensionRestLength * cfg.SuspensionSagFraction, 0.1)\n\tlocal damping = 2 * math.sqrt(k * mPerWheel) * cfg.SuspensionDampingRatio\n\tlocal pointVelocity = chassis:GetVelocityAtPosition(mount)\n\tlocal verticalSpeed = pointVelocity:Dot(up)\n\tlocal maxLoad = mPerWheel * workspace.Gravity * cfg.SuspensionMaxLoadMultiplier\n\tlocal load = math.clamp(k * compression - damping * verticalSpeed, 0, maxLoad)\n\treturn {\n\t\tgrounded = true, center = hit.Position + up * cfg.WheelRadius,\n\t\tcontact = hit.Position, normal = hit.Normal, load = load,\n\t\tspringForce = up * load, material = hit.Material, length = length\n\t}\nend\n\nreturn Suspension\n")
installModule("Tires", "-- Forces applied at the contact patch to produce turning, acceleration,\n-- braking and slip. Includes a traction-circle clamp for each tire.\nlocal Tires = {}\n\nlocal function planar(v, normal)\n\tlocal p = v - normal * v:Dot(normal)\n\tif p.Magnitude < 0.001 then return nil end\n\treturn p.Unit\nend\n\nfunction Tires.compute(chassis, contact, surfaceNormal, normalLoad, material, steerDegrees,\n\tpropulsionTotal, resistTotal, assemblyMass, drivenCount, isDriven, cfg)\n\tif normalLoad <= 0 then return Vector3.zero, 0 end\n\tlocal up = chassis.CFrame.UpVector\n\tlocal yaw = CFrame.fromAxisAngle(up, math.rad(steerDegrees))\n\tlocal nominalForward = yaw:VectorToWorldSpace(chassis.CFrame.LookVector)\n\tlocal forward = planar(nominalForward, surfaceNormal)\n\tif not forward then return Vector3.zero, 0 end\n\tlocal right = forward:Cross(surfaceNormal).Unit\n\tlocal velocity = chassis:GetVelocityAtPosition(contact)\n\tlocal longSpeed = velocity:Dot(forward)\n\tlocal lateralSpeed = velocity:Dot(right)\n\tlocal drive = isDriven and propulsionTotal / math.max(1, drivenCount) or 0\n\tlocal braking = resistTotal / 4\n\tlocal lateral = -lateralSpeed * (assemblyMass / 4) * cfg.LateralResponse\n\tlocal wanted = forward * (drive + braking) + right * lateral\n\tlocal materialGrip = cfg.MaterialGrip[material] or 0.88\n\tlocal tractionCap = normalLoad * cfg.TireGrip * materialGrip\n\tif wanted.Magnitude > tractionCap and wanted.Magnitude > 0 then\n\t\twanted = wanted.Unit * tractionCap\n\tend\n\treturn wanted, longSpeed\nend\n\nreturn Tires\n")
installScript("VehicleController", "-- Server-authoritative four-wheel raycast ATV chassis.\n-- Parent this Script and Config, Engine, Steering, Suspension, Tires Modules\n-- directly under a Workspace vehicle model with Chassis, DriveSeat, Wheels.\nlocal RunService = game:GetService(\"RunService\")\nlocal Players = game:GetService(\"Players\")\nlocal vehicle = script.Parent\nlocal config = require(vehicle:WaitForChild(\"Config\"))\nlocal Engine = require(vehicle:WaitForChild(\"Engine\"))\nlocal Steering = require(vehicle:WaitForChild(\"Steering\"))\nlocal Suspension = require(vehicle:WaitForChild(\"Suspension\"))\nlocal Tires = require(vehicle:WaitForChild(\"Tires\"))\nlocal seat = vehicle:WaitForChild(\"DriveSeat\")\nlocal chassis = vehicle:WaitForChild(\"Chassis\")\nlocal visuals = vehicle:WaitForChild(\"Wheels\")\nlocal params = RaycastParams.new()\nparams.FilterType = Enum.RaycastFilterType.Exclude\nparams.FilterDescendantsInstances = {vehicle}\nparams.RespectCanCollide = true\nlocal throttle, steeringAngle = 0, 0\nlocal spin = {FL = 0, FR = 0, RL = 0, RR = 0}\nlocal wheelState = {}\nfor _, id in ipairs(config.WheelOrder) do\n\tlocal attachment = Instance.new(\"Attachment\")\n\tattachment.Name = \"WheelForce_\" .. id\n\tattachment.Position = config.WheelMounts[id]\n\tattachment.Parent = chassis\n\tlocal force = Instance.new(\"VectorForce\")\n\tforce.Name = \"ContactForce_\" .. id\n\tforce.Attachment0 = attachment\n\tforce.ApplyAtCenterOfMass = false\n\tforce.RelativeTo = Enum.ActuatorRelativeTo.World\n\tforce.Parent = chassis\n\twheelState[id] = {\n\t\tattachment = attachment,\n\t\tforce = force,\n\t\tvisual = visuals:WaitForChild(\"Wheel_\" .. id)\n\t}\nend\n-- With physics computed on the server, keep ownership on the server.\npcall(function() chassis:SetNetworkOwner(nil) end)\nlocal function visualAt(item, cf)\n\tif item:IsA(\"Model\") then\n\t\titem:PivotTo(cf)\n\telseif item:IsA(\"BasePart\") then\n\t\titem.CFrame = cf\n\tend\nend\nRunService.Heartbeat:Connect(function(dt)\n\tdt = math.clamp(dt, 1 / 240, 0.1)\n\tlocal humanoid = seat.Occupant\n\tlocal driver = humanoid and Players:GetPlayerFromCharacter(humanoid.Parent)\n\tlocal t = driver and seat.ThrottleFloat or 0\n\tlocal s = driver and seat.SteerFloat or 0\n\tthrottle = Engine.smooth(throttle, t, dt, config.ThrottleResponse)\n\tlocal forwardSpeed = chassis.AssemblyLinearVelocity:Dot(chassis.CFrame.LookVector)\n\tlocal targetSteer = Steering.target(s, forwardSpeed, config)\n\tsteeringAngle = Steering.step(steeringAngle, targetSteer, dt, config)\n\tlocal mass = chassis.AssemblyMass\n\tlocal driveForce, resistForce, braking = Engine.forces(throttle, forwardSpeed, mass, config)\n\tlocal drivenCount = config.DriveMode == \"AWD\" and 4 or 2\n\tlocal grounded = 0\n\tfor _, id in ipairs(config.WheelOrder) do\n\t\tlocal w = wheelState[id]\n\t\tlocal state = Suspension.sample(chassis, config.WheelMounts[id], params, config, mass)\n\t\tlocal angle = (string.sub(id, 1, 1) == \"F\") and steeringAngle or 0\n\t\tlocal tireForce = Vector3.zero\n\t\tlocal speedAtWheel = forwardSpeed\n\t\tif state.grounded then\n\t\t\tgrounded += 1\n\t\t\tlocal isDriven = config.DriveMode == \"AWD\" or string.sub(id, 1, 1) == \"R\"\n\t\t\ttireForce, speedAtWheel = Tires.compute(chassis, state.contact, state.normal,\n\t\t\t\tstate.load, state.material, angle, driveForce, resistForce, mass, drivenCount, isDriven, config)\n\t\tend\n\t\t-- Application point includes the tire's contact patch for body pitch/roll.\n\t\tlocal forcePoint = state.contact or state.center\n\t\tw.attachment.Position = chassis.CFrame:PointToObjectSpace(forcePoint)\n\t\tw.force.Force = state.springForce + tireForce\n\t\tspin[id] += speedAtWheel / math.max(config.WheelRadius, 0.1) * dt\n\t\tlocal yaw = math.rad(angle * config.VisualWheelSteeringMultiplier)\n\t\tlocal cf = CFrame.new(state.center)\n\t\t\t* chassis.CFrame.Rotation\n\t\t\t* CFrame.Angles(0, yaw, 0)\n\t\t\t* CFrame.Angles(0, 0, math.pi / 2)\n\t\t\t* CFrame.Angles(0, spin[id], 0)\n\t\tvisualAt(w.visual, cf)\n\tend\n\tlocal rpm, gear = Engine.telemetry(throttle, forwardSpeed, config)\n\tvehicle:SetAttribute(\"Speed\", math.abs(forwardSpeed))\n\tvehicle:SetAttribute(\"RPM\", rpm)\n\tvehicle:SetAttribute(\"Gear\", gear)\n\tvehicle:SetAttribute(\"GroundedWheels\", grounded)\n\tvehicle:SetAttribute(\"SteeringAngle\", steeringAngle)\n\tvehicle:SetAttribute(\"Braking\", braking)\n\tvehicle:SetAttribute(\"DriveMode\", config.DriveMode)\nend)\n", atv, "Script")
local scripts = StarterPlayer:WaitForChild("StarterPlayerScripts")
local old = scripts:FindFirstChild("ATVClient")
if old then old:Destroy() end
installScript("ATVClient", "-- Client-only telemetry overlay: no client control of physics or vehicle forces.\nlocal Players = game:GetService(\"Players\")\nlocal RunService = game:GetService(\"RunService\")\nlocal player = Players.LocalPlayer\nlocal gui = Instance.new(\"ScreenGui\")\ngui.Name = \"ATVTelemetry\"\ngui.ResetOnSpawn = false\ngui.IgnoreGuiInset = true\ngui.Parent = player:WaitForChild(\"PlayerGui\")\nlocal container = Instance.new(\"Frame\")\ncontainer.Size = UDim2.fromOffset(244, 120)\ncontainer.Position = UDim2.new(1, -260, 1, -138)\ncontainer.BackgroundColor3 = Color3.fromRGB(18, 20, 22)\ncontainer.BackgroundTransparency = 0.11\ncontainer.BorderSizePixel = 0\ncontainer.Visible = false\ncontainer.Parent = gui\nlocal corner = Instance.new(\"UICorner\")\ncorner.CornerRadius = UDim.new(0, 12)\ncorner.Parent = container\nlocal stroke = Instance.new(\"UIStroke\")\nstroke.Color = Color3.fromRGB(87, 92, 95)\nstroke.Thickness = 1\nstroke.Transparency = 0.4\nstroke.Parent = container\nlocal function label(y, h, size, color)\n\tlocal l = Instance.new(\"TextLabel\")\n\tl.Size = UDim2.new(1, -24, 0, h)\n\tl.Position = UDim2.fromOffset(12, y)\n\tl.BackgroundTransparency = 1\n\tl.TextXAlignment = Enum.TextXAlignment.Left\n\tl.TextColor3 = color\n\tl.Font = Enum.Font.GothamBold\n\tl.TextSize = size\n\tl.Parent = container\n\treturn l\nend\nlocal speed = label(8, 44, 30, Color3.fromRGB(247, 249, 250))\nlocal rev = label(55, 24, 16, Color3.fromRGB(224, 150, 93))\nlocal status = label(86, 21, 13, Color3.fromRGB(174, 180, 185))\nRunService.RenderStepped:Connect(function()\n\tlocal char = player.Character\n\tlocal humanoid = char and char:FindFirstChildOfClass(\"Humanoid\")\n\tlocal occupied = humanoid and humanoid.SeatPart\n\tlocal model = occupied and occupied.Parent\n\tif occupied and occupied.Name == \"DriveSeat\" and model and model:GetAttribute(\"RPM\") ~= nil then\n\t\tcontainer.Visible = true\n\t\tlocal kph = math.abs(model:GetAttribute(\"Speed\") or 0) * 1.008\n\t\tspeed.Text = string.format(\"%03d km/h\", math.floor(kph + 0.5))\n\t\trev.Text = string.format(\"%s  •  %d RPM\", model:GetAttribute(\"Gear\") or \"N\", model:GetAttribute(\"RPM\") or 0)\n\t\tstatus.Text = string.format(\"%s  •  %d/4 wheels grounded\", model:GetAttribute(\"DriveMode\") or \"AWD\", model:GetAttribute(\"GroundedWheels\") or 0)\n\telse\n\t\tcontainer.Visible = false\n\tend\nend)\n", scripts, "LocalScript")
print("ZuzuATV v0.2 created! Press Play and sit in DriveSeat. W/S throttle and A/D steer. Read README for Blender mesh handoff.")
