--!strict
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local vehicle = script.Parent
local config = require(vehicle:WaitForChild("Config"))
local Engine = require(vehicle:WaitForChild("Engine"))
local Steering = require(vehicle:WaitForChild("Steering"))
local seat = vehicle:WaitForChild("DriveSeat") :: VehicleSeat
local chassis = vehicle:WaitForChild("Chassis") :: BasePart
local wheels = vehicle:WaitForChild("WheelAssemblies")
local throttle = 0
local currentDriver: Player? = nil
local function updateOwner()
	local humanoid = seat.Occupant
	local player: Player? = nil
	if humanoid then
		player = Players:GetPlayerFromCharacter(humanoid.Parent)
	end
	if player ~= currentDriver then
		currentDriver = player
		pcall(function()
			chassis:SetNetworkOwner(player)
		end)
	end
end
seat:GetPropertyChangedSignal("Occupant"):Connect(updateOwner)
updateOwner()
RunService.Heartbeat:Connect(function(dt)
	local occupied = seat.Occupant ~= nil and currentDriver ~= nil
	local requested = if occupied then seat.ThrottleFloat else 0
	local steeringInput = if occupied then seat.SteerFloat else 0
	throttle = Engine.step(throttle, requested, dt, config.ThrottleResponse)
	local velocity = chassis.AssemblyLinearVelocity.Magnitude
	local targetAngle = Steering.angle(steeringInput, velocity, config)
	for _, wheel in wheels:GetChildren() do
		local motor = wheel:FindFirstChild("DriveMotor", true)
		local steer = wheel:FindFirstChild("SteerServo", true)
		if motor and motor:IsA("HingeConstraint") then
			local limitedThrottle = if velocity > config.MaxSpeedStudsPerSecond and throttle > 0 then 0 else throttle
			motor.AngularVelocity = -limitedThrottle * config.DriveAngularVelocity
			motor.MotorMaxTorque = if occupied and math.abs(throttle) > 0.04 then config.MotorMaxTorque else config.BrakeTorque
			motor.MotorMaxAcceleration = config.MotorMaxAcceleration
		end
		if steer and steer:IsA("HingeConstraint") then
			steer.TargetAngle = math.deg(targetAngle)
		end
	end
	vehicle:SetAttribute("Speed", velocity)
	vehicle:SetAttribute("RPM", Engine.rpm(velocity, throttle, config))
end)
