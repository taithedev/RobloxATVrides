-- Run in Studio Command Bar after generating the prototype.
local model = workspace:FindFirstChild("ZuzuATV")
assert(model, "ZuzuATV model missing. Run GenerateATV first.")
for _, name in ipairs({"Chassis", "DriveSeat", "Wheels", "Config", "Engine", "Steering", "Suspension", "Tires", "VehicleController"}) do
	assert(model:FindFirstChild(name), "Missing ATV item: " .. name)
end
for _, id in ipairs({"FL", "FR", "RL", "RR"}) do
	assert(model.Wheels:FindFirstChild("Wheel_" .. id), "Missing visual wheel " .. id)
end
assert(game:GetService("StarterPlayer").StarterPlayerScripts:FindFirstChild("ATVClient"), "Missing client HUD")
assert(not model.Chassis.Anchored, "Chassis must not be anchored")
print("ATV static hierarchy checks passed. You MUST also Play test physics and steering.")
