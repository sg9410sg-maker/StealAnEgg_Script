-- STREAMING_CHUNK:Initializing services and player references...
-- ==============================================================================
-- SPEED HACK PANEL V2.0 (LUA ROBLOX)
-- ==============================================================================
-- Compatibilidad: Funciona en LocalScript (StarterPlayerScripts / StarterGui)
-- y en Ejecutores de exploits/mods (Synapse, Krnl, Fluxus, Delta, Solara, etc.)
-- ==============================================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

-- Determinar el contenedor para la interfaz (CoreGui para ejecutores, PlayerGui para juegos)
local ParentGui
if gethui then
ParentGui = gethui()
elseif syn and syn.protect_gui then
ParentGui = game:GetService("CoreGui")
syn.protect_gui(ParentGui)
elseif game:GetService("CoreGui"):FindFirstChild("RobloxGui") then
ParentGui = game:GetService("CoreGui")
else
ParentGui = LocalPlayer:WaitForChild("PlayerGui")
end

-- Limpiar versiones previas si existen
if ParentGui:FindFirstChild("SpeedHackPanelGui") then
ParentGui:FindFirstChild("SpeedHackPanelGui"):Destroy()
end

-- STREAMING_CHUNK:Creating main ScreenGui and container elements...

-- CREACIÓN DE LA INTERFAZ

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeedHackPanelGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = ParentGui

-- Panel Principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 310)
MainFrame.Position = UDim2.new(0.5, -160, 0.4, -155)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 22, 33)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(60, 65, 90)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- STREAMING_CHUNK:Building top title bar and action buttons...
-- Barra Superior (Drag Handle)
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 42)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

-- Parche para esquinas inferiores rectables de la barra
local TitleBarFix = Instance.new("Frame")
TitleBarFix.Size = UDim2.new(1, 0, 0, 10)
TitleBarFix.Position = UDim2.new(0, 0, 1, -10)
TitleBarFix.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
TitleBarFix.BorderSizePixel = 0
TitleBarFix.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ Speed Controller (1-1000)"
TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Botón de Cerrar / Ocultar
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(45, 50, 70)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- STREAMING_CHUNK:Creating floating toggle button for opening/closing...
-- Botón Flotante para Reabrir cuando el panel está oculto
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "SpeedToggleBtn"
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 20, 0.5, -25)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
ToggleBtn.Text = "⚡"
ToggleBtn.TextSize = 22
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Visible = false
ToggleBtn.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleBtn

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(129, 140, 248)
ToggleStroke.Thickness = 2
ToggleStroke.Parent = ToggleBtn

-- STREAMING_CHUNK:Designing speed display and manual text box input...
-- Contenido Interno
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -24, 1, -54)
Content.Position = UDim2.new(0, 12, 0, 48)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Cuadro de Indicación de Velocidad
local SpeedDisplayFrame = Instance.new("Frame")
SpeedDisplayFrame.Size = UDim2.new(1, 0, 0, 55)
SpeedDisplayFrame.BackgroundColor3 = Color3.fromRGB(12, 15, 24)
SpeedDisplayFrame.Parent = Content

local DisplayCorner = Instance.new("UICorner")
DisplayCorner.CornerRadius = UDim.new(0, 8)
DisplayCorner.Parent = SpeedDisplayFrame

local SpeedTitle = Instance.new("TextLabel")
SpeedTitle.Size = UDim2.new(0.5, 0, 0, 20)
SpeedTitle.Position = UDim2.new(0, 10, 0, 8)
SpeedTitle.BackgroundTransparency = 1
SpeedTitle.Text = "VELOCIDAD ACTUAL"
SpeedTitle.TextColor3 = Color3.fromRGB(140, 145, 170)
SpeedTitle.TextSize = 10
SpeedTitle.Font = Enum.Font.GothamBold
SpeedTitle.TextXAlignment = Enum.TextXAlignment.Left
SpeedTitle.Parent = SpeedDisplayFrame

local SpeedValLabel = Instance.new("TextLabel")
SpeedValLabel.Size = UDim2.new(0.5, 0, 0, 25)
SpeedValLabel.Position = UDim2.new(0, 10, 0, 24)
SpeedValLabel.BackgroundTransparency = 1
SpeedValLabel.Text = "16"
SpeedValLabel.TextColor3 = Color3.fromRGB(129, 140, 248)
SpeedValLabel.TextSize = 22
SpeedValLabel.Font = Enum.Font.GothamBlack
SpeedValLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedValLabel.Parent = SpeedDisplayFrame

-- Input Numérico Manual
local InputBox = Instance.new("TextBox")
InputBox.Size = UDim2.new(0, 90, 0, 32)
InputBox.Position = UDim2.new(1, -100, 0.5, -16)
InputBox.BackgroundColor3 = Color3.fromRGB(28, 33, 50)
InputBox.Text = "16"
InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
InputBox.TextSize = 14
InputBox.Font = Enum.Font.GothamBold
InputBox.PlaceholderText = "1-1000"
InputBox.Parent = SpeedDisplayFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = InputBox

-- STREAMING_CHUNK:Constructing interactive range slider control...
-- Slider
local SliderBack = Instance.new("Frame")
SliderBack.Size = UDim2.new(1, 0, 0, 12)
SliderBack.Position = UDim2.new(0, 0, 0, 75)
SliderBack.BackgroundColor3 = Color3.fromRGB(28, 33, 50)
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

local SliderKnob = Instance.new("TextButton")
SliderKnob.Size = UDim2.new(0, 20, 0, 20)
SliderKnob.Position = UDim2.new(1, -10, 0.5, -10)
SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderKnob.Text = ""
SliderKnob.Parent = SliderFill

local KnobCorner = Instance.new("UICorner")
KnobCorner.CornerRadius = UDim.new(1, 0)
KnobCorner.Parent = SliderKnob

-- STREAMING_CHUNK:Creating fast preset buttons layout...
-- Presets Rápidos
local PresetsLabel = Instance.new("TextLabel")
PresetsLabel.Size = UDim2.new(1, 0, 0, 18)
PresetsLabel.Position = UDim2.new(0, 0, 0, 100)
PresetsLabel.BackgroundTransparency = 1
PresetsLabel.Text = "PRESETS RÁPIDOS"
PresetsLabel.TextColor3 = Color3.fromRGB(140, 145, 170)
PresetsLabel.TextSize = 10
PresetsLabel.Font = Enum.Font.GothamBold
PresetsLabel.TextXAlignment = Enum.TextXAlignment.Left
PresetsLabel.Parent = Content

local PresetsGrid = Instance.new("Frame")
PresetsGrid.Size = UDim2.new(1, 0, 0, 36)
PresetsGrid.Position = UDim2.new(0, 0, 0, 122)
PresetsGrid.BackgroundTransparency = 1
PresetsGrid.Parent = Content

local presetValues = {16, 50, 100, 500, 1000}
for i, val in ipairs(presetValues) do
local Btn = Instance.new("TextButton")
Btn.Size = UDim2.new(0.18, 0, 1, 0)
Btn.Position = UDim2.new((i - 1) * 0.205, 0, 0, 0)
Btn.BackgroundColor3 = Color3.fromRGB(28, 33, 50)
Btn.Text = tostring(val)
Btn.TextColor3 = Color3.fromRGB(200, 200, 230)
Btn.Font = Enum.Font.GothamBold
Btn.TextSize = 11
Btn.Parent = PresetsGrid

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = Btn

Btn.MouseButton1Click:Connect(function()
    _G.SetSpeed(val)
end)



end

-- STREAMING_CHUNK:Adding anti-reset speed enforcement toggle switch...
-- Bucle de Seguridad / Anti-Reset
local LoopFrame = Instance.new("Frame")
LoopFrame.Size = UDim2.new(1, 0, 0, 40)
LoopFrame.Position = UDim2.new(0, 0, 0, 172)
LoopFrame.BackgroundColor3 = Color3.fromRGB(12, 15, 24)
LoopFrame.Parent = Content

local LoopCorner = Instance.new("UICorner")
LoopCorner.CornerRadius = UDim.new(0, 8)
LoopCorner.Parent = LoopFrame

local LoopLabel = Instance.new("TextLabel")
LoopLabel.Size = UDim2.new(0.7, 0, 1, 0)
LoopLabel.Position = UDim2.new(0, 10, 0, 0)
LoopLabel.BackgroundTransparency = 1
LoopLabel.Text = "🔒 Bloquear Velocidad (Bucle)"
LoopLabel.TextColor3 = Color3.fromRGB(220, 220, 240)
LoopLabel.Font = Enum.Font.GothamMedium
LoopLabel.TextSize = 12
LoopLabel.TextXAlignment = Enum.TextXAlignment.Left
LoopLabel.Parent = LoopFrame

local LoopToggle = Instance.new("TextButton")
LoopToggle.Size = UDim2.new(0, 40, 0, 22)
LoopToggle.Position = UDim2.new(1, -50, 0.5, -11)
LoopToggle.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
LoopToggle.Text = "ON"
LoopToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
LoopToggle.Font = Enum.Font.GothamBold
LoopToggle.TextSize = 10
LoopToggle.Parent = LoopFrame

local LoopToggleCorner = Instance.new("UICorner")
LoopToggleCorner.CornerRadius = UDim.new(1, 0)
LoopToggleCorner.Parent = LoopToggle

-- Info de atajo de teclado
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, 0, 0, 20)
InfoLabel.Position = UDim2.new(0, 0, 1, -20)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "Atajo de teclado: 

$$Insert$$

 o 

$$Right Ctrl$$

"
InfoLabel.TextColor3 = Color3.fromRGB(100, 105, 130)
InfoLabel.TextSize = 10
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.Parent = Content

-- STREAMING_CHUNK:Implementing smooth window dragging logic...

-- LÓGICA DE ARRASTRE (DRAGGABLE)

local dragging = false
local dragInput, dragStart, startPos

local function updateDrag(input)
local delta = input.Position - dragStart
MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
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

-- STREAMING_CHUNK:Connecting speed modifier and WalkSpeed loop...

-- LÓGICA DE VELOCIDAD

local TargetSpeed = 16
local LoopEnabled = true

function _G.SetSpeed(val)
local num = tonumber(val)
if not num then return end

-- Limitar entre 1 y 1000
TargetSpeed = math.clamp(math.floor(num), 1, 1000)

-- Actualizar UI
SpeedValLabel.Text = tostring(TargetSpeed)
InputBox.Text = tostring(TargetSpeed)

-- Actualizar Slider
local alpha = (TargetSpeed - 1) / (1000 - 1)
SliderFill.Size = UDim2.new(math.clamp(alpha, 0.02, 1), 0, 1, 0)

-- Aplicar directamente al Humanoid
if LocalPlayer.Character then
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = TargetSpeed
    end
end



end

-- Bucle constante para evitar que el juego reajuste tu velocidad
RunService.Stepped:Connect(function()
if LoopEnabled and LocalPlayer.Character then
local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
if humanoid and humanoid.WalkSpeed ~= TargetSpeed then
humanoid.WalkSpeed = TargetSpeed
end
end
end)

-- Arrastre del Slider
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

-- Eventos de entrada manual
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

-- STREAMING_CHUNK:Handling visibility toggles and hotkeys...

-- VISIBILIDAD Y CERRAR / ABRIR

local function ToggleVisibility()
MainFrame.Visible = not MainFrame.Visible
ToggleBtn.Visible = not MainFrame.Visible
end

CloseBtn.MouseButton1Click:Connect(ToggleVisibility)
ToggleBtn.MouseButton1Click:Connect(ToggleVisibility)

-- Atajos de teclado (Insert y Right Control)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
if gameProcessed then return end
if input.KeyCode == Enum.KeyCode.Insert or input.KeyCode == Enum.KeyCode.RightControl then
ToggleVisibility()
end
end)

-- Inicialización
_G.SetSpeed(16)
print("

$$SpeedHack Panel$$
