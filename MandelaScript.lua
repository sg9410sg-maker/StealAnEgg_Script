--// TEST AIM UI
--// Colócalo en StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--// CONFIG
local FOV_MIN = 30
local FOV_MAX = 180
local DEFAULT_FOV = 90

local SMOOTH_MIN = 0
local SMOOTH_MAX = 1
local DEFAULT_SMOOTH = 0.5

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "AimTestUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

--// Main frame
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(280, 310)
main.Position = UDim2.new(0, 25, 0.5, -155)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
main.BorderSizePixel = 0
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(55, 55, 65)
stroke.Thickness = 1
stroke.Parent = main

--// Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 0, 45)
title.Position = UDim2.fromOffset(15, 8)
title.BackgroundTransparency = 1
title.Text = "AIM TEST PANEL"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -30, 0, 20)
subtitle.Position = UDim2.fromOffset(15, 43)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Private testing controls"
subtitle.TextColor3 = Color3.fromRGB(140, 140, 150)
subtitle.TextSize = 11
subtitle.Font = Enum.Font.Gotham
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = main

--// Utility
local function createButton(text, position, size)
	local button = Instance.new("TextButton")
	button.Size = size
	button.Position = position
	button.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = Color3.fromRGB(240, 240, 240)
	button.TextSize = 13
	button.Font = Enum.Font.GothamMedium
	button.AutoButtonColor = false
	button.Parent = main

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = button

	return button
end

--// Toggle
local enabled = false

local toggle = createButton(
	"AIM SYSTEM     OFF",
	UDim2.fromOffset(15, 78),
	UDim2.new(1, -30, 0, 42)
)

toggle.MouseButton1Click:Connect(function()
	enabled = not enabled

	if enabled then
		toggle.Text = "AIM SYSTEM     ON"
		toggle.BackgroundColor3 = Color3.fromRGB(45, 110, 75)
	else
		toggle.Text = "AIM SYSTEM     OFF"
		toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
	end

	-- Aquí puedes conectar tu sistema de pruebas.
	print("Aim system:", enabled)
end)

--// Section creator
local function createSlider(labelText, y, minValue, maxValue, defaultValue)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromOffset(110, 25)
	label.Position = UDim2.fromOffset(15, y)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.TextColor3 = Color3.fromRGB(210, 210, 220)
	label.TextSize = 12
	label.Font = Enum.Font.GothamMedium
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = main

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.fromOffset(50, 25)
	valueLabel.Position = UDim2.new(1, -65, 0, y)
	valueLabel.BackgroundTransparency = 1
	valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	valueLabel.TextSize = 12
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = main

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1, -30, 0, 6)
	bar.Position = UDim2.fromOffset(15, y + 27)
	bar.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	bar.BorderSizePixel = 0
	bar.Parent = main

	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(1, 0)
	barCorner.Parent = bar

	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(
		(defaultValue - minValue) / (maxValue - minValue),
		1
	)
	fill.BackgroundColor3 = Color3.fromRGB(220, 45, 55)
	fill.BorderSizePixel = 0
	fill.Parent = bar

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = fill

	local dragging = false
	local value = defaultValue

	local function update(input)
		local x = math.clamp(
			(input.Position.X - bar.AbsolutePosition.X) /
			bar.AbsoluteSize.X,
			0,
			1
		)

		value = minValue + (maxValue - minValue) * x

		if labelText == "FOV" then
			value = math.floor(value + 0.5)
		else
			value = math.floor(value * 100 + 0.5) / 100
		end

		local percent = (value - minValue) / (maxValue - minValue)
		fill.Size = UDim2.fromScale(percent, 1)
		valueLabel.Text = tostring(value)

		return value
	end

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			update(input)
		end
	end)

	bar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	game:GetService("UserInputService").InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			update(input)
		end
	end)

	valueLabel.Text = tostring(defaultValue)

	return function()
		return value
	end
end

local getFOV = createSlider(
	"FOV",
	135,
	FOV_MIN,
	FOV_MAX,
	DEFAULT_FOV
)

local getSmoothness = createSlider(
	"Smoothness",
	190,
	SMOOTH_MIN,
	SMOOTH_MAX,
	DEFAULT_SMOOTH
)

--// Target Lock
local targetLock = false

local lockButton = createButton(
	"TARGET LOCK     OFF",
	UDim2.fromOffset(15, 245),
	UDim2.new(1, -30, 0, 42)
)

lockButton.MouseButton1Click:Connect(function()
	targetLock = not targetLock

	if targetLock then
		lockButton.Text = "TARGET LOCK     ON"
		lockButton.BackgroundColor3 = Color3.fromRGB(45, 85, 125)
	else
		lockButton.Text = "TARGET LOCK     OFF"
		lockButton.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
	end

	-- Conecta aquí tu lógica de selección de objetivo
	print("Target lock:", targetLock)
end)

--// Public test values
_G.AimTestSettings = {
	IsEnabled = function()
		return enabled
	end,

	GetFOV = getFOV,

	GetSmoothness = getSmoothness,

	IsTargetLockEnabled = function()
		return targetLock
	end
}

print("Aim Test UI loaded")
