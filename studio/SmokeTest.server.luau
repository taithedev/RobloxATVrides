-- Studio Command Bar hierarchy test only: NOT a driving-physics test.
local model = assert(workspace:FindFirstChild("ZuzuATV"), "Run GenerateATV first")
for _, name in ipairs({"Chassis","DriveSeat","Wheels","Config","Engine","Steering","Suspension","Tires","VisualRig","VehicleController"}) do
 assert(model:FindFirstChild(name), "Missing ATV object: "..name)
end
for _, id in ipairs({"FL","FR","RL","RR"}) do
 local wheel = assert(model.Wheels:FindFirstChild("Wheel_"..id), "Missing wheel visual "..id)
 assert(wheel:IsA("Model") and wheel.PrimaryPart, "Wheel "..id.." needs a pivoted model")
end
assert(not model.Chassis.Anchored, "Chassis must be unanchored")
assert(game:GetService("StarterPlayer").StarterPlayerScripts:FindFirstChild("ATVClient"), "Missing client HUD")
local cfg = require(model.Config)
assert(math.abs(cfg.WheelCenters.FL.X+1.65)<0.001, "Incorrect imported wheel track")
assert(math.abs(cfg.WheelRadius-0.969)<0.001, "Incorrect imported tire radius")
print("ATV geometry/hierarchy smoke checks passed. Press Play to validate physics and imported visuals.")
