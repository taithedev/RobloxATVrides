-- Run this in Studio Command Bar while editing, not as a permanent script.
-- It constructs a four-wheel spring-guided prototype and embeds the vehicle scripts.
local vehicle = Instance.new("Model")
vehicle.Name = "ZuzuATV"
vehicle.Parent = workspace
local function part(name, size, cf, color, parent, anchored)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Anchored=anchored or false;p.Parent=parent;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;return p
end
local chassis=part("Chassis",Vector3.new(4.2,0.8,6),CFrame.new(0,7,0),Color3.fromRGB(83,72,58),vehicle,false)
chassis.CustomPhysicalProperties=PhysicalProperties.new(2,0.7,0.2)
local seat=Instance.new("VehicleSeat");seat.Name="DriveSeat";seat.Size=Vector3.new(2,0.6,2);seat.CFrame=chassis.CFrame*CFrame.new(0,0.7,0.4);seat.Parent=vehicle
local weld=Instance.new("WeldConstraint");weld.Part0=chassis;weld.Part1=seat;weld.Parent=seat
local wheels=Instance.new("Folder");wheels.Name="WheelAssemblies";wheels.Parent=vehicle
local function att(p,name,cf)
 local a=Instance.new("Attachment");a.Name=name;a.CFrame=cf;a.Parent=p;return a
end
-- Each wheel rides on a sliding hub: spring between chassis and hub,
-- cylindrical constraint permits vertical translation; hinge spins tire.
for _,side in ipairs({-1,1}) do
 for _,z in ipairs({-2.05,2.05}) do
  local front=z<0
  local id=(front and "F" or "R")..(side<0 and "L" or "R")
  local x=side*2.55
  local folder=Instance.new("Model");folder.Name=id;folder.Parent=wheels
  local hub=part("Hub",Vector3.new(.45,.45,.45),chassis.CFrame*CFrame.new(x,-1,z),Color3.fromRGB(95,95,95),folder,false)
  hub.CanCollide=false
  local guide=part("Guide",Vector3.new(.35,.35,.35),chassis.CFrame*CFrame.new(x,0,z),Color3.fromRGB(50,50,50),folder,false)
  guide.CanCollide=false
  local guideWeld=Instance.new("WeldConstraint");guideWeld.Part0=chassis;guideWeld.Part1=guide;guideWeld.Parent=guide
  local upper=att(guide,"SuspensionTop",CFrame.new())
  local lower=att(hub,"SuspensionBottom",CFrame.new(0,1,0))
  local slide=Instance.new("PrismaticConstraint");slide.Name="SuspensionSlider";slide.Attachment0=upper;slide.Attachment1=lower;slide.LimitsEnabled=true;slide.LowerLimit=-.55;slide.UpperLimit=.55;slide.Parent=folder
  local spring=Instance.new("SpringConstraint");spring.Name="SuspensionSpring";spring.Attachment0=upper;spring.Attachment1=att(hub,"SpringHub",CFrame.new());spring.Stiffness=10500;spring.Damping=1250;spring.FreeLength=1.45;spring.Visible=true;spring.Thickness=.16;spring.Parent=folder
  local wheel=part("Wheel",Vector3.new(2.9,1.1,2.9),hub.CFrame*CFrame.new(side*.55,0,0)*CFrame.Angles(0,0,math.pi/2),Color3.fromRGB(35,34,30),folder,false)
  wheel.Shape=Enum.PartType.Cylinder
  wheel.CustomPhysicalProperties=PhysicalProperties.new(1,1,0)
  local motor=Instance.new("HingeConstraint");motor.Name="DriveMotor";motor.Attachment0=att(hub,"AxleHub",CFrame.Angles(0,0,math.pi/2));motor.Attachment1=att(wheel,"AxleWheel",CFrame.new());motor.ActuatorType=Enum.ActuatorType.Motor;motor.MotorMaxTorque=16000;motor.MotorMaxAcceleration=150;motor.Parent=folder
  -- Steering placeholder: the wheel hub is vertically guided, not yaw steerable.
  -- Front steering requires a dedicated steer knuckle/servo assembly after initial rig validation.
 end
end
vehicle.PrimaryPart=chassis
local function module(name,source)
 local m=Instance.new("ModuleScript");m.Name=name;m.Source=source;m.Parent=vehicle
end
local function scriptObj(name,source)
 local s=Instance.new("Script");s.Name=name;s.Source=source;s.Parent=vehicle
end
module("Config","--!strict\nreturn {\n\tMaxSpeedStudsPerSecond = 95,\n\tWheelRadius = 1.45,\n\tDriveAngularVelocity = 68,\n\tMotorMaxTorque = 16000,\n\tMotorMaxAcceleration = 150,\n\tBrakeTorque = 22000,\n\tIdleRPM = 900,\n\tRedlineRPM = 8000,\n\tThrottleResponse = 4,\n\tSteeringAngleDegrees = 28,\n\tSteeringSpeed = 3.5,\n\tSpringStiffness = 10500,\n\tSpringDamping = 1250,\n\tSpringFreeLength = 1.45,\n\tSuspensionLowerLimit = -0.55,\n\tSuspensionUpperLimit = 0.55,\n}\n")
module("Engine","--!strict\nlocal Engine = {}\nfunction Engine.step(currentThrottle: number, requestedThrottle: number, dt: number, response: number): number\n\tlocal alpha = 1 - math.exp(-response * math.max(dt, 0))\n\treturn currentThrottle + (math.clamp(requestedThrottle, -1, 1) - currentThrottle) * alpha\nend\nfunction Engine.rpm(speed: number, throttle: number, config: any): number\n\tlocal fraction = math.clamp(math.abs(speed) / config.MaxSpeedStudsPerSecond, 0, 1)\n\treturn math.floor(config.IdleRPM + (config.RedlineRPM - config.IdleRPM) * math.max(fraction, math.abs(throttle) * 0.25))\nend\nreturn Engine\n")
module("Steering","--!strict\nlocal Steering = {}\nfunction Steering.angle(input: number, speed: number, config: any): number\n\tlocal speedFactor = 1 - 0.55 * math.clamp(math.abs(speed) / config.MaxSpeedStudsPerSecond, 0, 1)\n\treturn math.rad(config.SteeringAngleDegrees) * math.clamp(input, -1, 1) * speedFactor\nend\nreturn Steering\n")
scriptObj("VehicleController","--!strict\nlocal RunService = game:GetService(\"RunService\")\nlocal Players = game:GetService(\"Players\")\nlocal vehicle = script.Parent\nlocal config = require(vehicle:WaitForChild(\"Config\"))\nlocal Engine = require(vehicle:WaitForChild(\"Engine\"))\nlocal Steering = require(vehicle:WaitForChild(\"Steering\"))\nlocal seat = vehicle:WaitForChild(\"DriveSeat\") :: VehicleSeat\nlocal chassis = vehicle:WaitForChild(\"Chassis\") :: BasePart\nlocal wheels = vehicle:WaitForChild(\"WheelAssemblies\")\nlocal throttle = 0\nlocal currentDriver: Player? = nil\nlocal function updateOwner()\n\tlocal humanoid = seat.Occupant\n\tlocal player: Player? = nil\n\tif humanoid then\n\t\tplayer = Players:GetPlayerFromCharacter(humanoid.Parent)\n\tend\n\tif player ~= currentDriver then\n\t\tcurrentDriver = player\n\t\tpcall(function()\n\t\t\tchassis:SetNetworkOwner(player)\n\t\tend)\n\tend\nend\nseat:GetPropertyChangedSignal(\"Occupant\"):Connect(updateOwner)\nupdateOwner()\nRunService.Heartbeat:Connect(function(dt)\n\tlocal occupied = seat.Occupant ~= nil and currentDriver ~= nil\n\tlocal requested = if occupied then seat.ThrottleFloat else 0\n\tlocal steeringInput = if occupied then seat.SteerFloat else 0\n\tthrottle = Engine.step(throttle, requested, dt, config.ThrottleResponse)\n\tlocal velocity = chassis.AssemblyLinearVelocity.Magnitude\n\tlocal targetAngle = Steering.angle(steeringInput, velocity, config)\n\tfor _, wheel in wheels:GetChildren() do\n\t\tlocal motor = wheel:FindFirstChild(\"DriveMotor\", true)\n\t\tlocal steer = wheel:FindFirstChild(\"SteerServo\", true)\n\t\tif motor and motor:IsA(\"HingeConstraint\") then\n\t\t\tlocal limitedThrottle = if velocity > config.MaxSpeedStudsPerSecond and throttle > 0 then 0 else throttle\n\t\t\tmotor.AngularVelocity = -limitedThrottle * config.DriveAngularVelocity\n\t\t\tmotor.MotorMaxTorque = if occupied and math.abs(throttle) > 0.04 then config.MotorMaxTorque else config.BrakeTorque\n\t\t\tmotor.MotorMaxAcceleration = config.MotorMaxAcceleration\n\t\tend\n\t\tif steer and steer:IsA(\"HingeConstraint\") then\n\t\t\tsteer.TargetAngle = math.deg(targetAngle)\n\t\tend\n\tend\n\tvehicle:SetAttribute(\"Speed\", velocity)\n\tvehicle:SetAttribute(\"RPM\", Engine.rpm(velocity, throttle, config))\nend)\n")
print("ZuzuATV created. Front steering not yet mechanically connected; see README limitations.")
