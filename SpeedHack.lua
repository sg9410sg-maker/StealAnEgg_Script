-- Script de Control de Velocidad Móvil
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local MIN_SPEED = 100
local MAX_SPEED = 1000
local currentSpeed = MIN_SPEED

-- Función para cambiar velocidad
local function updateSpeed(newSpeed)
    currentSpeed = math.clamp(newSpeed, MIN_SPEED, MAX_SPEED)
    if humanoid and humanoid.Parent then
        humanoid.WalkSpeed = currentSpeed
    end
end

-- Mantener la velocidad al morir/reaparecer
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    humanoid.WalkSpeed = currentSpeed
end)

-- Destruir GUI previa si ya existe
local pGui = player:WaitForChild("PlayerGui")
if pGui:FindFirstChild("MobileSpeedGUI") then
    pGui.MobileSpeedGUI:Destroy()
end

-- GUI Principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MobileSpeedGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = pGui

-- Botón para Abrir/Cerrar (Toggle)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Text = "⚡"
toggleBtn.TextSize = 25
toggleBtn.Active = true
toggleBtn.Draggable = true -- Se puede mover por la pantalla
toggleBtn.Parent = screenGui

local corner1 = Instance.new("UICorner")
corner1.CornerRadius = UDim.new(0, 12)
corner1.Parent = toggleBtn

-- Panel Contenedor
local panel = Instance.new("Frame")
panel.Name = "MainPanel"
panel.Size = UDim2.new(0, 220, 0, 240)
panel.Position = UDim2.new(0.05, 0, 0.3, 0)
panel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
panel.BorderSizePixel = 0
panel.Visible = true
panel.Parent = screenGui

local corner2 = Instance.new("UICorner")
corner2.CornerRadius = UDim.new(0, 12)
corner2.Parent = panel

-- Título y contador de velocidad
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.Text = "Velocidad: " .. currentSpeed
title.Parent = panel

-- Función creadora de botones
local function createButton(text, pos, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.42, 0, 0, 40)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.Text = text
    btn.Parent = panel
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    btn.Activated:Connect(function()
        callback()
        title.Text = "Velocidad: " .. currentSpeed
    end)
end

-- Botones de incremento/decremento
createButton("+50", UDim2.new(0.53, 0, 0.2, 0), Color3.fromRGB(40, 160, 60), function()
    updateSpeed(currentSpeed + 50)
end)

createButton("-50", UDim2.new(0.05, 0, 0.2, 0), Color3.fromRGB(180, 50, 50), function()
    updateSpeed(currentSpeed - 50)
end)

createButton("+100", UDim2.new(0.53, 0, 0.4, 0), Color3.fromRGB(30, 130, 50), function()
    updateSpeed(currentSpeed + 100)
end)

createButton("-100", UDim2.new(0.05, 0, 0.4, 0), Color3.fromRGB(140, 40, 40), function()
    updateSpeed(currentSpeed - 100)
end)

-- Botones de atajos rápidos
createButton("MIN (100)", UDim2.new(0.05, 0, 0.62, 0), Color3.fromRGB(70, 70, 70), function()
    updateSpeed(MIN_SPEED)
end)

createButton("MAX (1000)", UDim2.new(0.53, 0, 0.62, 0), Color3.fromRGB(200, 120, 0), function()
    updateSpeed(MAX_SPEED)
end)

-- Evento para ocultar/mostrar panel con el botón flotante
toggleBtn.Activated:Connect(function()
    panel.Visible = not panel.Visible
end)

-- Inicializar velocidad al ejecutar
updateSpeed(MIN_SPEED)
