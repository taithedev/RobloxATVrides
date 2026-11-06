-- Imported-mesh visual posing for the Blender ATV. Cosmetic only;
-- physics and traction remain entirely inside server raycasts/forces.
local Rig = {}
local function rotatedAround(pivot, rotation)
 return CFrame.new(pivot) * rotation * CFrame.new(-pivot)
end
local function swingBetween(a, b)
 local oldDir = a.Unit
 local newDir = b.Unit
 local cross = oldDir:Cross(newDir)
 local dot = math.clamp(oldDir:Dot(newDir), -1, 1)
 if cross.Magnitude < 0.00001 then return CFrame.new() end
 return CFrame.fromAxisAngle(cross.Unit, math.acos(dot))
end
function Rig.create(folder, cfg)
 local entries = {}
 if not folder then return entries end
 for _, item in ipairs(folder:GetDescendants()) do
  if item:IsA("BasePart") then
   local kind = item:GetAttribute("ATVKind")
   local corner = item:GetAttribute("ATVCorner")
   local rest = item:GetAttribute("ATVRestLocal")
   if type(kind) == "string" and typeof(rest) == "CFrame" then
    table.insert(entries, {part=item, kind=kind, corner=corner, rest=rest})
   end
  end
 end
 return entries
end
function Rig.step(entries, chassisCF, wheelTravel, steerAngle, cfg)
 for _, entry in ipairs(entries) do
  local kind = entry.kind
  local id = entry.corner
  local delta = (type(id) == "string" and wheelTravel[id]) or 0
  local offset = CFrame.new()
  local settings = type(id) == "string" and cfg.SuspensionPivots[id] or nil
  if kind == "UpperArm" or kind == "LowerArm" then
   if settings then
    local p = kind == "UpperArm" and settings.upper or settings.lower
    local side = string.sub(id, 2, 2) == "R" and 1 or -1
    local armReach = kind == "UpperArm" and 0.72 or 0.68
    local angle = math.atan2(delta, armReach) * side
    offset = rotatedAround(p, CFrame.Angles(0,0,angle))
   end
  elseif kind == "Knuckle" then
   local yaw = string.sub(id,1,1)=="F" and math.rad(steerAngle) or 0
   local center = cfg.WheelCenters[id]
   offset = CFrame.new(0,delta,0) * rotatedAround(center, CFrame.Angles(0,yaw,0))
  elseif kind == "Shock" then
   if settings then
    local top = settings.shockUpper
    local restVec = settings.shockLower - top
    local newVec = restVec + Vector3.new(0, delta, 0)
    offset = rotatedAround(top, swingBetween(restVec, newVec))
    -- Spring/rod length is still a fixed mesh. Mesh deformation needs rigging.
    if string.find(entry.part.Name, "Piston") or string.find(entry.part.Name, "LowerBracket") then
     offset = CFrame.new(0,delta*0.75,0) * offset
    end
   end
  elseif kind == "Handlebar" then
   offset = rotatedAround(cfg.SteeringPivot, CFrame.Angles(0, math.rad(steerAngle)*0.65,0))
  elseif kind == "TieRod" then
   offset = CFrame.new(0,delta*0.5,0)
  end
  if entry.part.Parent then
   entry.part.CFrame = chassisCF * offset * entry.rest
  end
 end
end
return Rig
