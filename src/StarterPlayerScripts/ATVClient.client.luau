-- Client-only telemetry overlay: no client control of physics or vehicle forces.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "ATVTelemetry"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")
local container = Instance.new("Frame")
container.Size = UDim2.fromOffset(244, 120)
container.Position = UDim2.new(1, -260, 1, -138)
container.BackgroundColor3 = Color3.fromRGB(18, 20, 22)
container.BackgroundTransparency = 0.11
container.BorderSizePixel = 0
container.Visible = false
container.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = container
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(87, 92, 95)
stroke.Thickness = 1
stroke.Transparency = 0.4
stroke.Parent = container
local function label(y, h, size, color)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, -24, 0, h)
	l.Position = UDim2.fromOffset(12, y)
	l.BackgroundTransparency = 1
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextColor3 = color
	l.Font = Enum.Font.GothamBold
	l.TextSize = size
	l.Parent = container
	return l
end
local speed = label(8, 44, 30, Color3.fromRGB(247, 249, 250))
local rev = label(55, 24, 16, Color3.fromRGB(224, 150, 93))
local status = label(86, 21, 13, Color3.fromRGB(174, 180, 185))
RunService.RenderStepped:Connect(function()
	local char = player.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	local occupied = humanoid and humanoid.SeatPart
	local model = occupied and occupied.Parent
	if occupied and occupied.Name == "DriveSeat" and model and model:GetAttribute("RPM") ~= nil then
		container.Visible = true
		local kph = math.abs(model:GetAttribute("Speed") or 0) * 1.008
		speed.Text = string.format("%03d km/h", math.floor(kph + 0.5))
		rev.Text = string.format("%s  •  %d RPM", model:GetAttribute("Gear") or "N", model:GetAttribute("RPM") or 0)
		status.Text = string.format("%s  •  %d/4 wheels grounded", model:GetAttribute("DriveMode") or "AWD", model:GetAttribute("GroundedWheels") or 0)
	else
		container.Visible = false
	end
end)
