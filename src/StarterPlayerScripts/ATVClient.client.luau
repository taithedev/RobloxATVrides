--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "ATVTelemetry"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
local label = Instance.new("TextLabel")
label.Size = UDim2.fromOffset(230, 78)
label.Position = UDim2.new(1, -245, 1, -100)
label.BackgroundColor3 = Color3.fromRGB(18, 20, 22)
label.BackgroundTransparency = 0.15
label.TextColor3 = Color3.new(1, 1, 1)
label.Font = Enum.Font.GothamBold
label.TextSize = 20
label.Visible = false
label.Parent = gui
Instance.new("UICorner", label).CornerRadius = UDim.new(0, 12)
RunService.RenderStepped:Connect(function()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local seat = humanoid and humanoid.SeatPart
	local vehicle = seat and seat.Parent
	if seat and seat.Name == "DriveSeat" and vehicle and vehicle:GetAttribute("RPM") ~= nil then
		label.Visible = true
		local speed = (vehicle:GetAttribute("Speed") or 0) * 1.008
		label.Text = string.format("%03d km/h\n%d RPM", math.floor(speed + 0.5), vehicle:GetAttribute("RPM") or 0)
	else
		label.Visible = false
	end
end)
