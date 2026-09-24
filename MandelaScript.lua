-- STREAMING_CHUNK:Initializing services and mobile/PC compatibility layer...
-- ==============================================================================
-- SPEED CONTROL PANEL V3.0 (UNIVERSAL MOBILE & PC)
-- ==============================================================================
-- Compatible con: PC (Mouse/Teclado) y Celulares/Tablets (Pantalla Táctil)
-- Ejecutores: Delta, Codex, Solara, Wave, Fluxus, Krnl, Synapse, Hydrogen, etc.
-- ==============================================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

-- Determinar el contenedor seguro para la interfaz (Evita detecciones y fallos)
local ParentGui
local success, result = pcall(function()
if gethui then
return gethui()
elseif syn and syn.protect_gui then
local folder = Instance.new("Folder")
syn.protect_gui(folder)
return game:GetService("CoreGui")
elseif game:GetService("CoreGui"):FindFirstChild("RobloxGui") then
return game:GetService("CoreGui")
end
return LocalPlayer:WaitForChild("PlayerGui")
end)

if success and result then
ParentGui = result
else
ParentGui = LocalPlayer:WaitForChild("PlayerGui")
end

-- Limpiar versiones anteriores si existen
if ParentGui:FindFirstChild("UniversalSpeedPanel") then
ParentGui:FindFirstChild("UniversalSpeedPanel"):Destroy()
end

-- STREAMING_CHUNK:Creating core ScreenGui and main container frame...

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalSpeedPanel"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = ParentGui

-- Panel Principal (Diseño Adaptativo Móvil / PC)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Size = UDim2.new(0, 310, 0, 320)
MainFrame.Position = UDim2.new(0.5, 0, 0.45, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 28)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(55, 60, 85)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- STREAMING_CHUNK:Building draggable title bar and mobile toggle button...

-- Barra Superior (Zonal de Arrastre)
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 44)
TitleBar.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 14)
TitleCorner.Parent = TitleBar

-- Parche para evitar esquinas redondeadas abajo en la barra
local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 12)
TitleFix.Position = UDim2.new(0, 0, 1, -12)
TitleFix.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ Speed Panel (1-1000)"
TitleLabel.TextColor3 = Color3.fromRGB(240, 245, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Botón Cerrar (Tamaño ideal para dedos táctiles)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -38, 0.5, -16)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 45, 65)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(220, 220, 240)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- Botón Flotante para MÓVIL y PC (Para Abrir / Cerrar sin teclado)
local FloatingToggle = Instance.new("TextButton")
FloatingToggle.Name = "SpeedFloatingBtn"
FloatingToggle.Size = UDim2.new(0, 52, 0, 52)
FloatingToggle.Position = UDim2.new(0, 15, 0.4, 0)
FloatingToggle.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
FloatingToggle.Text = "⚡"
FloatingToggle.TextSize = 24
FloatingToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatingToggle.Font = Enum.Font.GothamBold
FloatingToggle.Visible = false
FloatingToggle.Active = true
FloatingToggle.Draggable = true -- Arrastrable en móvil por si estorba
FloatingToggle.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = FloatingToggle

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(130, 140, 255)
ToggleStroke.Thickness = 2
ToggleStroke.Parent = FloatingToggle

-- STREAMING_CHUNK:Designing responsive speed slider and numerical inputs...

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -24, 1, -56)
Content.Position = UDim2.new(0, 12, 0, 50)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Cuadro de Despliegue de Velocidad
local DisplayFrame = Instance.new("Frame")
DisplayFrame.Size = UDim2.new(1, 0, 0, 58)
DisplayFrame.BackgroundColor3 = Color3.fromRGB(10, 12, 20)
DisplayFrame.Parent = Content

local DisplayCorner = Instance.new("UICorner")
DisplayCorner.CornerRadius = UDim.new(0, 10)
DisplayCorner.Parent = DisplayFrame

local SpeedTitle = Instance.new("TextLabel")
SpeedTitle.Size = UDim2.new(0.5, 0, 0, 18)
SpeedTitle.Position = UDim2.new(0, 12, 0, 8)
SpeedTitle.BackgroundTransparency = 1
SpeedTitle.Text = "VELOCIDAD"
SpeedTitle.TextColor3 = Color3.fromRGB(130, 135, 160)
SpeedTitle.TextSize = 10
SpeedTitle.Font = Enum.Font.GothamBold
SpeedTitle.TextXAlignment = Enum.TextXAlignment.Left
SpeedTitle.Parent = DisplayFrame

local SpeedValLabel = Instance.new("TextLabel")
SpeedValLabel.Size = UDim2.new(0.5, 0, 0, 26)
SpeedValLabel.Position = UDim2.new(0, 12, 0, 24)
SpeedValLabel.BackgroundTransparency = 1
SpeedValLabel.Text = "16"
SpeedValLabel.TextColor3 = Color3.fromRGB(129, 140, 248)
SpeedValLabel.TextSize = 22
SpeedValLabel.Font = Enum.Font.GothamBlack
SpeedValLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedValLabel.Parent = DisplayFrame

-- Input Numérico Manual
local InputBox = Instance.new("TextBox")
InputBox.Size = UDim2.new(0, 95, 0, 36)
InputBox.Position = UDim2.new(1, -107, 0.5, -18)
InputBox.BackgroundColor3 = Color3.fromRGB(24, 28, 44)
InputBox.Text = "16"
InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
InputBox.TextSize = 14
InputBox.Font = Enum.Font.GothamBold
InputBox.PlaceholderText = "1-1000"
InputBox.ClearTextOnFocus = false
InputBox.Parent = DisplayFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 8)
InputCorner.Parent = InputBox

local InputStroke = Instance.new("UIStroke")
InputStroke.Color = Color3.fromRGB(50, 55, 80)
InputStroke.Thickness = 1
InputStroke.Parent = InputBox

-- Slider Táctil y de Ratón
local SliderBack = Instance.new("Frame")
SliderBack.Size = UDim2.new(1, 0, 0, 14)
SliderBack.Position = UDim2.new(0, 0, 0, 76)
SliderBack.BackgroundColor3 = Color3.fromRGB(24, 28, 44)
SliderBack.Parent = Content

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(1, 0)
SliderCorner.Parent = SliderBack

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.016, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
SliderFill.Parent = SliderBack

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(1, 0)
FillCorner.Parent = SliderFill

local SliderKnob = Instance.new("Frame")
SliderKnob.Size = UDim2.new(0, 22, 0, 22)
SliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
SliderKnob.Position = UDim2.new(1, 0, 0.5, 0)
SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderKnob.Parent = SliderFill

local KnobCorner = Instance.new("UICorner")
KnobCorner.CornerRadius = UDim.new(1, 0)
KnobCorner.Parent = SliderKnob

-- STREAMING_CHUNK:Adding preset speed buttons and anti-reset loop toggle...

-- Presets Rápidos
local PresetsLabel = Instance.new("TextLabel")
PresetsLabel.Size = UDim2.new(1, 0, 0, 18)
PresetsLabel.Position = UDim2.new(0, 0, 0, 104)
PresetsLabel.BackgroundTransparency = 1
PresetsLabel.Text = "PRESETS RÁPIDOS"
PresetsLabel.TextColor3 = Color3.fromRGB(130, 135, 160)
PresetsLabel.TextSize = 10
PresetsLabel.Font = Enum.Font.GothamBold
PresetsLabel.TextXAlignment = Enum.TextXAlignment.Left
PresetsLabel.Parent = Content

local PresetsGrid = Instance.new("Frame")
PresetsGrid.Size = UDim2.new(1, 0, 0, 38)
PresetsGrid.Position = UDim2.new(0, 0, 0, 126)
PresetsGrid.BackgroundTransparency = 1
PresetsGrid.Parent = Content

local presetValues = {16, 50, 100, 500, 1000}
for i, val in ipairs(presetValues) do
local Btn = Instance.new("TextButton")
Btn.Size = UDim2.new(0.18, 0, 1, 0)
Btn.Position = UDim2.new((i - 1) * 0.205, 0, 0, 0)
Btn.BackgroundColor3 = Color3.fromRGB(24, 28, 44)
Btn.Text = tostring(val)
Btn.TextColor3 = Color3.fromRGB(210, 215, 240)
Btn.Font = Enum.Font.GothamBold
Btn.TextSize = 11
Btn.Parent = PresetsGrid

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = Btn

Btn.MouseButton1Click:Connect(function()
    _G.SetSpeed(val)
end)


end

-- Interruptor de Bucle Infinito (Anti-Reset al Morir o Cambiar de Zona)
local LoopFrame = Instance.new("Frame")
LoopFrame.Size = UDim2.new(1, 0, 0, 42)
LoopFrame.Position = UDim2.new(0, 0, 0, 178)
LoopFrame.BackgroundColor3 = Color3.fromRGB(10, 12, 20)
LoopFrame.Parent = Content

local LoopCorner = Instance.new("UICorner")
LoopCorner.CornerRadius = UDim.new(0, 10)
LoopCorner.Parent = LoopFrame

local LoopLabel = Instance.new("TextLabel")
LoopLabel.Size = UDim2.new(0.7, 0, 1, 0)
LoopLabel.Position = UDim2.new(0, 12, 0, 0)
LoopLabel.BackgroundTransparency = 1
LoopLabel.Text = "🔒 Forzar Velocidad (Bucle)"
LoopLabel.TextColor3 = Color3.fromRGB(220, 225, 245)
LoopLabel.Font = Enum.Font.GothamMedium
LoopLabel.TextSize = 11
LoopLabel.TextXAlignment = Enum.TextXAlignment.Left
LoopLabel.Parent = LoopFrame

local LoopToggle = Instance.new("TextButton")
LoopToggle.Size = UDim2.new(0, 44, 0, 24)
LoopToggle.Position = UDim2.new(1, -54, 0.5, -12)
LoopToggle.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
LoopToggle.Text = "ON"
LoopToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
LoopToggle.Font = Enum.Font.GothamBold
LoopToggle.TextSize = 10
LoopToggle.Parent = LoopFrame

local LoopToggleCorner = Instance.new("UICorner")
LoopToggleCorner.CornerRadius = UDim.new(1, 0)
LoopToggleCorner.Parent = LoopToggle

-- Info de Atajos / Ayuda
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, 0, 0, 18)
InfoLabel.Position = UDim2.new(0, 0, 1, -18)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "PC: [Insert] / [Ctrl Der] | Móvil: Toca el botón ⚡"
InfoLabel.TextColor3 = Color3.fromRGB(100, 105, 130)
InfoLabel.TextSize = 9
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.Parent = Content

-- STREAMING_CHUNK:Implementing universal drag mechanics for Mouse and Touch...

-- LÓGICA DE ARRASTRE COMPATIBLE CON MÓVIL Y PC
local dragging = false
local dragInput, dragStart, startPos

local function updateDrag(input)
local delta = input.Position - dragStart
MainFrame.Position = UDim2.new(
startPos.X.Scale,
startPos.X.Offset + delta.X,
startPos.Y.Scale,
startPos.Y.Offset + delta.Y
)
end

TitleBar.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging = true
dragStart = input.Position
startPos = MainFrame.Position

    input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
            dragging = false
        end
    end)
end


end)

TitleBar.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
dragInput = input
end
end)

UserInputService.InputChanged:Connect(function(input)
if input == dragInput and dragging then
updateDrag(input)
end
end)

-- STREAMING_CHUNK:Connecting character respawn listeners and speed enforcement...

-- APLICACIÓN DE VELOCIDAD
local TargetSpeed = 16
local LoopEnabled = true

function _G.SetSpeed(val)
local num = tonumber(val)
if not num then return end

TargetSpeed = math.clamp(math.floor(num), 1, 1000)

SpeedValLabel.Text = tostring(TargetSpeed)
InputBox.Text = tostring(TargetSpeed)

local alpha = (TargetSpeed - 1) / (1000 - 1)
SliderFill.Size = UDim2.new(math.clamp(alpha, 0.02, 1), 0, 1, 0)

if LocalPlayer.Character then
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = TargetSpeed
    end
end


end

-- Mantener la velocidad al reaparecer (Reset/Muerto en juego)
LocalPlayer.CharacterAdded:Connect(function(char)
task.wait(0.5)
_G.SetSpeed(TargetSpeed)
end)

-- Bucle de comprobación para evitar que el script del servidor resetee tu velocidad
RunService.Stepped:Connect(function()
if LoopEnabled and LocalPlayer.Character then
local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
if humanoid and humanoid.WalkSpeed ~= TargetSpeed then
humanoid.WalkSpeed = TargetSpeed
end
end
end)

-- Arrastre del Slider (Mouse y Touch)
local sliding = false
local function updateSlider(input)
local sliderPosition = SliderBack.AbsolutePosition.X
local sliderSize = SliderBack.AbsoluteSize.X
local mousePosition = input.Position.X

local relativeX = math.clamp(mousePosition - sliderPosition, 0, sliderSize)
local alpha = relativeX / sliderSize
local calculatedSpeed = math.floor(1 + (alpha * 999))

_G.SetSpeed(calculatedSpeed)


end

SliderBack.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
sliding = true
updateSlider(input)
end
end)

UserInputService.InputChanged:Connect(function(input)
if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
updateSlider(input)
end
end)

UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
sliding = false
end
end)

InputBox.FocusLost:Connect(function(enterPressed)
_G.SetSpeed(InputBox.Text)
end)

LoopToggle.MouseButton1Click:Connect(function()
LoopEnabled = not LoopEnabled
if LoopEnabled then
LoopToggle.Text = "ON"
LoopToggle.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
else
LoopToggle.Text = "OFF"
LoopToggle.BackgroundColor3 = Color3.fromRGB(60, 65, 85)
end
end)

-- Ocultar / Mostrar Interfaz
local function ToggleVisibility()
MainFrame.Visible = not MainFrame.Visible
FloatingToggle.Visible = not MainFrame.Visible
end

CloseBtn.MouseButton1Click:Connect(ToggleVisibility)
FloatingToggle.MouseButton1Click:Connect(ToggleVisibility)

-- Atajos de teclado para PC (Insert y Control Derecho)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
if gameProcessed then return end
if input.KeyCode == Enum.KeyCode.Insert or input.KeyCode == Enum.KeyCode.RightControl then
ToggleVisibility()
end
end)

-- Inicializar velocidad inicial de Roblox (16)
_G.SetSpeed(16)
print("[Universal Speed Panel] Cargado con éxito.")
