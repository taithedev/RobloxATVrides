-- Run ONCE in Roblox Studio's EDIT-MODE Command Bar after:
-- (1) importing ATV.fbx as Workspace.ATV, and
-- (2) running GenerateATV.server.luau (Workspace.ZuzuATV).
-- Uses the *actual* RoPilot mesh names and measurements in the supplied ZIP.
local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")
local vehicle = assert(Workspace:FindFirstChild("ZuzuATV"), "Generate the ZuzuATV physics rig first.")
local chassis = assert(vehicle:FindFirstChild("Chassis"), "Missing chassis.")
local wheels = assert(vehicle:FindFirstChild("Wheels"), "Missing Wheels folder.")
local cfg = require(assert(vehicle:FindFirstChild("Config"), "Missing Config."))
local source = Workspace:FindFirstChild("ATV")
if not source or not source:IsA("Model") then
 error("Import ATV.fbx into Workspace as a MODEL named 'ATV' before running this script.")
end
assert(source ~= vehicle, "Do not use ZuzuATV as the source model.")
local bbox, size = source:GetBoundingBox()
-- In Studio, the FBX importer must preserve the intended 1 Blender unit = 1 stud.
-- The bounding box may vary by a few percent because of mesh import options.
if math.abs(size.X - cfg.AssetWidth) > 0.65
 or math.abs(size.Z - cfg.AssetLength) > 0.85
 or math.abs(size.Y - cfg.AssetHeight) > 0.65 then
 error(string.format("FBX axes/scale mismatch: imported XYZ=%.3f, %.3f, %.3f studs. Expected approximately 4.100, 3.619, 6.107. Correct import scale and orientation before continuing.", size.X, size.Y, size.Z))
end
local base = chassis.CFrame * CFrame.new(0, cfg.AssetBoundingCenterHeight - cfg.PhysicsChassisOriginHeight, 0)
-- No global movement of the original: clone into the vehicle using its imported bbox as reference.
local function targetCF(part)
 return base * bbox:ToObjectSpace(part.CFrame)
end
local previousStatic = vehicle:FindFirstChild("StaticVisuals")
if previousStatic then previousStatic:Destroy() end
local previousDynamic = vehicle:FindFirstChild("VisualDetails")
if previousDynamic then previousDynamic:Destroy() end
local placeholders = vehicle:FindFirstChild("PlaceholderVisuals")
if placeholders then placeholders:Destroy() end
local static = Instance.new("Folder")
static.Name = "StaticVisuals"
static.Parent = vehicle
local dynamic = Instance.new("Folder")
dynamic.Name = "VisualDetails"
dynamic.Parent = vehicle
local wheelModels = {}
for _, id in ipairs(cfg.WheelOrder) do
 local prev = wheels:FindFirstChild("Wheel_"..id)
 if prev then prev:Destroy() end
 local group = Instance.new("Model")
 group.Name = "Wheel_"..id
 group.Parent = wheels
 local pivot = Instance.new("Part")
 pivot.Name = "WheelPivot"
 pivot.Size = Vector3.new(.12,.12,.12)
 pivot.Transparency = 1
 pivot.CanCollide = false
 pivot.CanTouch = false
 pivot.CanQuery = false
 pivot.Anchored = true
 pivot.CFrame = chassis.CFrame * CFrame.new(cfg.WheelCenters[id])
 pivot.Parent = group
 group.PrimaryPart = pivot
 wheelModels[id] = group
end
local function corner(name)
 for _, id in ipairs(cfg.WheelOrder) do
  if name:find("_"..id, 1, true) then return id end
 end
 return nil
end
local function groupAndKind(part)
 local name = part.Name
 local id = corner(name)
 if name:match("^Wheel_[FR][LR]") then return "Wheel", id end
 if name:match("^FrontUpperArm_") or name:match("^RearUpperArm_") then return "UpperArm", id end
 if name:match("^FrontLowerArm_") or name:match("^RearLowerArm_") then return "LowerArm", id end
 if name:match("^FrontKnuckle_") or name:match("^RearKnuckle_")
  or name:match("^Hub_") or name:match("^BrakeDisc_") or name:match("^BrakeCaliper_")
  or name:match("^UpperBallJoint_") or name:match("^LowerBallJoint_") then
  return "Knuckle", id
 end
 if name:match("^FrontShock") or name:match("^RearShock")
  or name:match("^FrontSpring") or name:match("^RearSpring")
  or name:match("^SpringSeat_") or name:match("^ShockEye_") or name:match("^ShockLowerBracket_") then
  return "Shock", id
 end
 if name:match("^TieRod_") then return "TieRod", id end
 -- Most handlebar parts are Blender children of the SteeringAssembly empty.
 local current = part.Parent
 while current and current ~= source do
  if current.Name == "SteeringAssembly" then return "Handlebar", nil end
  current = current.Parent
 end
 if name == "SteeringShaft" or name == "Handlebars" or name == "SteeringAssembly" then
  return "Handlebar", nil
 end
 return "Static", nil
end
local counts = {Static=0, Wheel=0, UpperArm=0, LowerArm=0, Knuckle=0, Shock=0, TieRod=0, Handlebar=0}
for _, original in ipairs(source:GetDescendants()) do
 if original:IsA("BasePart") and not original.Name:match("^COL_") then
  local kind, id = groupAndKind(original)
  if kind == "Wheel" and not id then
   warn("Skipping wheel with unrecognized ID: "..original:GetFullName())
  else
   local copy = original:Clone()
   -- Apply transform before welding / animation.
   copy.CFrame = targetCF(original)
   copy.CanCollide = false
   copy.CanTouch = false
   copy.CanQuery = false
   copy.Anchored = kind ~= "Static"
   copy.Massless = true
   if kind == "Wheel" then
    copy.Parent = wheelModels[id]
   elseif kind == "Static" then
    copy.Parent = static
    local joint = Instance.new("WeldConstraint")
    joint.Name = "BodyWeld"
    joint.Part0 = chassis
    joint.Part1 = copy
    joint.Parent = copy
   else
    copy:SetAttribute("ATVKind", kind)
    if id then copy:SetAttribute("ATVCorner", id) end
    copy:SetAttribute("ATVRestLocal", chassis.CFrame:ToObjectSpace(copy.CFrame))
    copy.Parent = dynamic
   end
   counts[kind] += 1
  end
 end
end
for _, id in ipairs(cfg.WheelOrder) do
 local n = 0
 for _, child in ipairs(wheelModels[id]:GetChildren()) do
  if child:IsA("BasePart") and child.Name ~= "WheelPivot" then n+=1 end
 end
 assert(n>=3, "Missing wheel meshes for "..id.." (expected tire/rim/fasteners)")
end
local seat = vehicle:FindFirstChild("DriveSeat")
if seat and seat:IsA("BasePart") then
 seat.Transparency = 1 -- player uses invisible physical VehicleSeat under Blender padded seat
end
local backup = source
backup.Name = "ATV_SourceBackup"
backup.Parent = ServerStorage
print("Attached actual RoPilot ATV mesh to ZuzuATV. Geometry counts:", counts)
print("Original FBX moved into ServerStorage as ATV_SourceBackup. Press Play to test driving.")
