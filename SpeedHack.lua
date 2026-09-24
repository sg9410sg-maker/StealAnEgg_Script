-- =========================================================
-- PANEL DE VELOCIDAD FUTURISTA (FORZADO CLIENTE)
-- =========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local MIN_SPEED = 100
local MAX_SPEED = 1000
local currentSpeed = MIN_SPEED
local speedEnabled = true

-- Eliminar versión anterior si ya existe
local pGui = player:WaitForChild("PlayerGui")
if pGui:FindFirstChild("FuturisticSpeedGUI") then
    pGui.FuturisticSpeedGUI:Destroy()
end

------------------------------------------------------------
-- BUCLE DE VELOCIDAD FORZADA (Bypass de WalkSpeed)
------------------------------------------------------------
-- Actualizar referencias al morir/reaparecer
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
end)

-- Este evento se ejecuta en cada frame del juego
RunService.Heartbeat:Connect(function()
    if not character or not humanoid or not rootPart or not speedEnabled then return end
    
    -- 1. Intentar forzar el WalkSpeed tradicional
    humanoid.WalkSpeed = currentSpeed

    -- 2. Forzar velocidad física manual si se está moviendo (para juegos con velocidad personalizada)
    if humanoid.MoveDirection.Magnitude > 0 then
        local moveDir = humanoid.MoveDirection
        -- Mantener la gravedad vertical original (Y) y aplicar la velocidad en X y Z
        rootPart.AssemblyLinearVelocity = Vector3.new(
            moveDir.X * currentSpeed,
            rootPart.AssemblyLinearVelocity.Y,
            moveDir.Z * currentSpeed
        )
    end
end)

local function updateSpeed(newSpeed)
    currentSpeed = math.clamp(math.round(newSpeed), MIN_SPEED, MAX_SPEED)
end

------------------------------------------------------------
-- LÓGICA DE ARRASTRE (DRAGGABLE)
------------------------------------------------------------
local function makeDraggable(guiObject, dragHandle)
    dragHandle = dragHandle or guiObject
    local dragging, dragInput, dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

------------------------------------------------------------
-- INTERFAZ GRÁFICA (GUI)
------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FuturisticSpeedGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = pGui

-- 1. BOTÓN FLOTANTE (BOLITA DEL LOBO)
local wolfBall = Instance.new("TextButton")
wolfBall.Name = "WolfBall"
wolfBall.Size = UDim2.new(0, 55, 0, 55)
wolfBall.Position = UDim2.new(0.05, 0, 0.25, 0)
wolfBall.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
wolfBall.BorderSizePixel = 0
wolfBall.Text = "🐺"
wolfBall.TextSize = 28
wolfBall.AutoButtonColor = false
wolfBall.Parent = screenGui

local ballCorner = Instance.new("UICorner")
ballCorner.CornerRadius = UDim.new(1, 0)
ballCorner.Parent = wolfBall

local ballStroke = Instance.new("UIStroke")
ballStroke.Color = Color3.fromRGB(56, 189, 248)
ballStroke.Thickness = 2
ballStroke.Parent = wolfBall

makeDraggable(wolfBall)

-- 2. PANEL PRINCIPAL
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 280, 0, 220)
mainFrame.Position = UDim2.new(0.5, -140, 0.35, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = true
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 16)
frameCorner.Parent = mainFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(56, 189, 248)
frameStroke.Thickness = 1.5
frameStroke.Transparency = 0.3
frameStroke.Parent = mainFrame

-- Barra de arrastre superior
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 16)
headerCorner.Parent = header

makeDraggable(mainFrame, header)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -20, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚡ SPEED CONTROLLER"
titleLabel.TextColor3 = Color3.fromRGB(241, 245, 249)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = header

-- Display del valor
local speedDisplay = Instance.new("TextLabel")
speedDisplay.Size = UDim2.new(1, 0, 0, 35)
speedDisplay.Position = UDim2.new(0, 0, 0, 48)
speedDisplay.BackgroundTransparency = 1
speedDisplay.Text = "100"
speedDisplay.TextColor3 = Color3.fromRGB(56, 189, 248)
speedDisplay.Font = Enum.Font.GothamBlack
speedDisplay.TextSize = 26
speedDisplay.Parent = mainFrame

local unitLabel = Instance.new("TextLabel")
unitLabel.Size = UDim2.new(1, 0, 0, 15)
unitLabel.Position = UDim2.new(0, 0, 0, 80)
unitLabel.BackgroundTransparency = 1
unitLabel.Text = "STUDS / SECOND"
unitLabel.TextColor3 = Color3.fromRGB(148, 163, 184)
unitLabel.Font = Enum.Font.GothamBold
unitLabel.TextSize = 9
unitLabel.Parent = mainFrame

-- 3. BARRA DESLIZANTE (SLIDER)
local sliderBack = Instance.new("Frame")
sliderBack.Name = "SliderBack"
sliderBack.Size = UDim2.new(0.85, 0, 0, 10)
sliderBack.Position = UDim2.new(0.075, 0, 0.52, 0)
sliderBack.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
sliderBack.BorderSizePixel = 0
sliderBack.Parent = mainFrame

local sliderBackCorner = Instance.new("UICorner")
sliderBackCorner.CornerRadius = UDim.new(1, 0)
sliderBackCorner.Parent = sliderBack

local sliderFill = Instance.new("Frame")
sliderFill.Name = "SliderFill"
sliderFill.Size = UDim2.new(0, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(56, 189, 248)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBack

local sliderFillCorner = Instance.new("UICorner")
sliderFillCorner.CornerRadius = UDim.new(1, 0)
sliderFillCorner.Parent = sliderFill

local sliderKnob = Instance.new("Frame")
sliderKnob.Name = "SliderKnob"
sliderKnob.Size = UDim2.new(0, 20, 0, 20)
sliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
sliderKnob.Position = UDim2.new(0, 0, 0.5, 0)
sliderKnob.BackgroundColor3 = Color3.fromRGB(241, 245, 249)
sliderKnob.BorderSizePixel = 0
sliderKnob.Parent = sliderBack

local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1, 0)
knobCorner.Parent = sliderKnob

-- Controles del Slider
local isSliding = false

local function setSliderFromSpeed(speed)
    local pct = (speed - MIN_SPEED) / (MAX_SPEED - MIN_SPEED)
    pct = math.clamp(pct, 0, 1)
    sliderFill.Size = UDim2.new(pct, 0, 1, 0)
    sliderKnob.Position = UDim2.new(pct, 0, 0.5, 0)
    speedDisplay.Text = tostring(math.round(speed))
    updateSpeed(speed)
end

local function updateSlider(input)
    local absPos = sliderBack.AbsolutePosition.X
    local absSize = sliderBack.AbsoluteSize.X
    local mouseX = input.Position.X
    local pct = (mouseX - absPos) / absSize
    pct = math.clamp(pct, 0, 1)
    
    local calculatedSpeed = MIN_SPEED + (pct * (MAX_SPEED - MIN_SPEED))
    setSliderFromSpeed(calculatedSpeed)
end

sliderBack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isSliding = true
        updateSlider(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isSliding = false
    end
end)

-- 4. BOTONES (- / +)
local function createQuickBtn(text, pos, delta)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.4, 0, 0, 32)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
    btn.TextColor3 = Color3.fromRGB(241, 245, 249)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Text = text
    btn.Parent = mainFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    btn.Activated:Connect(function()
        setSliderFromSpeed(currentSpeed + delta)
    end)
end

createQuickBtn("- 50", UDim2.new(0.075, 0, 0.72, 0), -50)
createQuickBtn("+ 50", UDim2.new(0.525, 0, 0.72, 0), 50)

-- Abrir / Cerrar con la Bolita del Lobo
wolfBall.Activated:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

setSliderFromSpeed(MIN_SPEED)
