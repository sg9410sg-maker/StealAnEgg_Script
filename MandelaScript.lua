/* STREAMING_CHUNK:Initializing services and player detection... */
-- ==============================================================================
-- SPEED CONTROL PANEL V4.0 (UNIVERSAL MOBILE & PC - ANTI-CHEAT EGG BYPASS)
-- ==============================================================================
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
/* STREAMING_CHUNK:Defining safe UI parent container... */
-- Determinar el contenedor seguro para la interfaz (Soporte para Delta, Codex, Hydrogen, Solara, etc.)
local ParentGui = nil
local function getSafeParent()
if gethui then
local s, res = pcall(gethui)
if s and res then return res end
end
if syn and syn.protect_gui then
local s, res = pcall(function()
local folder = Instance.new("Folder")
syn.protect_gui(folder)
return game:GetService("CoreGui")
end)
if s and res then return res end
end
local s, res = pcall(function()
return game:GetService("CoreGui")
end)
if s and res then return res end
return LocalPlayer:WaitForChild("PlayerGui", 10) or LocalPlayer:FindFirstChildOfClass("PlayerGui")


end
ParentGui = getSafeParent()
-- Limpiar versiones anteriores si existen
if ParentGui and ParentGui:FindFirstChild("UniversalSpeedPanel") then
ParentGui:FindFirstChild("UniversalSpeedPanel"):Destroy()
end
/* STREAMING_CHUNK:Building main ScreenGui and frames... */
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalSpeedPanel"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = ParentGui
-- Panel Principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Size = UDim2.new(0, 310, 0, 380)
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
/* STREAMING_CHUNK:Creating TitleBar and controls... */
-- Barra Superior
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 44)
TitleBar.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 14)
TitleCorner.Parent = TitleBar
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
TitleLabel.Text = "⚡ Speed Panel (Egg Bypass)"
TitleLabel.TextColor3 = Color3.fromRGB(240, 245, 255)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar
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
/* STREAMING_CHUNK:Creating floating toggle button for mobile... */
-- Botón Flotante para Móvil y PC
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
FloatingToggle.Draggable = true
FloatingToggle.Parent = ScreenGui
local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = FloatingToggle
/* STREAMING_CHUNK:Building UI contents and speed display... */
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -24, 1, -56)
Content.Position = UDim2.new(0, 12, 0, 50)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame
-- Display de Velocidad Normal
local DisplayFrame = Instance.new("Frame")
DisplayFrame.Size = UDim2.new(1, 0, 0, 52)
DisplayFrame.BackgroundColor3 = Color3.fromRGB(10, 12, 20)
DisplayFrame.Parent = Content
local DisplayCorner = Instance.new("UICorner")
DisplayCorner.CornerRadius = UDim.new(0, 10)
DisplayCorner.Parent = DisplayFrame
local SpeedTitle = Instance.new("TextLabel")
SpeedTitle.Size = UDim2.new(0.5, 0, 0, 16)
SpeedTitle.Position = UDim2.new(0, 12, 0, 6)
SpeedTitle.BackgroundTransparency = 1
SpeedTitle.Text = "VELOCIDAD NORMAL"
SpeedTitle.TextColor3 = Color3.fromRGB(130, 135, 160)
SpeedTitle.TextSize = 9
SpeedTitle.Font = Enum.Font.GothamBold
SpeedTitle.TextXAlignment = Enum.TextXAlignment.Left
SpeedTitle.Parent = DisplayFrame
local SpeedValLabel = Instance.new("TextLabel")
SpeedValLabel.Size = UDim2.new(0.5, 0, 0, 24)
SpeedValLabel.Position = UDim2.new(0, 12, 0, 22)
SpeedValLabel.BackgroundTransparency = 1
SpeedValLabel.Text = "16"
SpeedValLabel.TextColor3 = Color3.fromRGB(129, 140, 248)
SpeedValLabel.TextSize = 20
SpeedValLabel.Font = Enum.Font.GothamBlack
SpeedValLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedValLabel.Parent = DisplayFrame
local InputBox = Instance.new("TextBox")
InputBox.Size = UDim2.new(0, 90, 0, 32)
InputBox.Position = UDim2.new(1, -102, 0.5, -16)
InputBox.BackgroundColor3 = Color3.fromRGB(24, 28, 44)
InputBox.Text = "16"
InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
InputBox.TextSize = 13
InputBox.Font = Enum.Font.GothamBold
InputBox.PlaceholderText = "1-1000"
InputBox.ClearTextOnFocus = false
InputBox.Parent = DisplayFrame
local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 8)
InputCorner.Parent = InputBox
/* STREAMING_CHUNK:Building speed slider and preset grid... */
-- Slider
local SliderBack = Instance.new("Frame")
SliderBack.Size = UDim2.new(1, 0, 0, 12)
SliderBack.Position = UDim2.new(0, 0, 0, 64)
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
-- Presets
local PresetsGrid = Instance.new("Frame")
PresetsGrid.Size = UDim2.new(1, 0, 0, 32)
PresetsGrid.Position = UDim2.new(0, 0, 0, 86)
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
/* STREAMING_CHUNK:Building Egg Bypass controls... */
-- Toggle Modo Huevo Seguro
local EggBypassFrame = Instance.new("Frame")
EggBypassFrame.Size = UDim2.new(1, 0, 0, 56)
EggBypassFrame.Position = UDim2.new(0, 0, 0, 128)
EggBypassFrame.BackgroundColor3 = Color3.fromRGB(18, 30, 25)
EggBypassFrame.Parent = Content
local EggCorner = Instance.new("UICorner")
EggCorner.CornerRadius = UDim.new(0, 10)
EggCorner.Parent = EggBypassFrame
local EggStroke = Instance.new("UIStroke")
EggStroke.Color = Color3.fromRGB(34, 197, 94)
EggStroke.Thickness = 1
EggStroke.Parent = EggBypassFrame
local EggTitle = Instance.new("TextLabel")
EggTitle.Size = UDim2.new(0.65, 0, 0, 18)
EggTitle.Position = UDim2.new(0, 12, 0, 8)
EggTitle.BackgroundTransparency = 1
EggTitle.Text = "🥚 Modo Huevo Seguro (Bypass)"
EggTitle.TextColor3 = Color3.fromRGB(134, 239, 172)
EggTitle.Font = Enum.Font.GothamBold
EggTitle.TextSize = 11
EggTitle.TextXAlignment = Enum.TextXAlignment.Left
EggTitle.Parent = EggBypassFrame
local EggSub = Instance.new("TextLabel")
EggSub.Size = UDim2.new(0.65, 0, 0, 16)
EggSub.Position = UDim2.new(0, 12, 0, 26)
EggSub.BackgroundTransparency = 1
EggSub.Text = "Sostener Huevo = Vel. Segura"
EggSub.TextColor3 = Color3.fromRGB(100, 160, 130)
EggSub.Font = Enum.Font.Gotham
EggSub.TextSize = 9
EggSub.TextXAlignment = Enum.TextXAlignment.Left
EggSub.Parent = EggBypassFrame
local EggToggle = Instance.new("TextButton")
EggToggle.Size = UDim2.new(0, 44, 0, 24)
EggToggle.Position = UDim2.new(1, -54, 0.5, -12)
EggToggle.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
EggToggle.Text = "ON"
EggToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
EggToggle.Font = Enum.Font.GothamBold
EggToggle.TextSize = 10
EggToggle.Parent = EggBypassFrame
local EggToggleCorner = Instance.new("UICorner")
EggToggleCorner.CornerRadius = UDim.new(1, 0)
EggToggleCorner.Parent = EggToggle
-- Ajuste de Velocidad Segura para el Huevo
local SafeSpeedFrame = Instance.new("Frame")
SafeSpeedFrame.Size = UDim2.new(1, 0, 0, 36)
SafeSpeedFrame.Position = UDim2.new(0, 0, 0, 192)
SafeSpeedFrame.BackgroundColor3 = Color3.fromRGB(10, 12, 20)
SafeSpeedFrame.Parent = Content
local SafeCorner = Instance.new("UICorner")
SafeCorner.CornerRadius = UDim.new(0, 8)
SafeCorner.Parent = SafeSpeedFrame
local SafeLabel = Instance.new("TextLabel")
SafeLabel.Size = UDim2.new(0.6, 0, 1, 0)
SafeLabel.Position = UDim2.new(0, 10, 0, 0)
SafeLabel.BackgroundTransparency = 1
SafeLabel.Text = "Velocidad Max con Huevo:"
SafeLabel.TextColor3 = Color3.fromRGB(180, 185, 200)
SafeLabel.Font = Enum.Font.GothamMedium
SafeLabel.TextSize = 10
SafeLabel.TextXAlignment = Enum.TextXAlignment.Left
SafeLabel.Parent = SafeSpeedFrame
local SafeInput = Instance.new("TextBox")
SafeInput.Size = UDim2.new(0, 50, 0, 24)
SafeInput.Position = UDim2.new(1, -60, 0.5, -12)
SafeInput.BackgroundColor3 = Color3.fromRGB(24, 28, 44)
SafeInput.Text = "22"
SafeInput.TextColor3 = Color3.fromRGB(134, 239, 172)
SafeInput.Font = Enum.Font.GothamBold
SafeInput.TextSize = 11
SafeInput.ClearTextOnFocus = false
SafeInput.Parent = SafeSpeedFrame
local SafeInputCorner = Instance.new("UICorner")
SafeInputCorner.CornerRadius = UDim.new(0, 6)
SafeInputCorner.Parent = SafeInput
-- Bucle Infinito Normal
local LoopFrame = Instance.new("Frame")
LoopFrame.Size = UDim2.new(1, 0, 0, 36)
LoopFrame.Position = UDim2.new(0, 0, 0, 236)
LoopFrame.BackgroundColor3 = Color3.fromRGB(10, 12, 20)
LoopFrame.Parent = Content
local LoopCorner = Instance.new("UICorner")
LoopCorner.CornerRadius = UDim.new(0, 8)
LoopCorner.Parent = LoopFrame
local LoopLabel = Instance.new("TextLabel")
LoopLabel.Size = UDim2.new(0.7, 0, 1, 0)
LoopLabel.Position = UDim2.new(0, 10, 0, 0)
LoopLabel.BackgroundTransparency = 1
LoopLabel.Text = "🔒 Forzar Velocidad Constante"
LoopLabel.TextColor3 = Color3.fromRGB(200, 205, 220)
LoopLabel.Font = Enum.Font.GothamMedium
LoopLabel.TextSize = 10
LoopLabel.TextXAlignment = Enum.TextXAlignment.Left
LoopLabel.Parent = LoopFrame
local LoopToggle = Instance.new("TextButton")
LoopToggle.Size = UDim2.new(0, 44, 0, 22)
LoopToggle.Position = UDim2.new(1, -54, 0.5, -11)
LoopToggle.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
LoopToggle.Text = "ON"
LoopToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
LoopToggle.Font = Enum.Font.GothamBold
LoopToggle.TextSize = 10
LoopToggle.Parent = LoopFrame
local LoopToggleCorner = Instance.new("UICorner")
LoopToggleCorner.CornerRadius = UDim.new(1, 0)
LoopToggleCorner.Parent = LoopToggle
/* STREAMING_CHUNK:Implementing dragging logic... */
-- LÓGICA DE CONTROL Y DRAG
local dragging = false
local dragInput, dragStart, startPos
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
local delta = input.Position - dragStart
MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
end)
/* STREAMING_CHUNK:Implementing speed loop and egg detector... */
-- LOGICA DE APLICACIÓN DE VELOCIDAD
local TargetSpeed = 16
local SafeEggSpeed = 22
local EggBypassEnabled = true
local LoopEnabled = true
function _G.SetSpeed(val)
local num = tonumber(val)
if not num then return end
TargetSpeed = math.clamp(math.floor(num), 1, 1000)
SpeedValLabel.Text = tostring(TargetSpeed)
InputBox.Text = tostring(TargetSpeed)

local alpha = (TargetSpeed - 1) / (1000 - 1)
SliderFill.Size = UDim2.new(math.clamp(alpha, 0.02, 1), 0, 1, 0)


end
-- Función para comprobar si el jugador lleva un huevo
local function IsCarryingEgg()
if not LocalPlayer.Character then return false end
-- 1. Comprobar si tiene una herramienta (Tool) equipada
local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
if tool then return true end

-- 2. Comprobar si tiene un modelo o parte adherida llamada Egg/Huevo
for _, child in ipairs(LocalPlayer.Character:GetChildren()) do
    if child:IsA("Model") or child:IsA("BasePart") then
        local name = child.Name:lower()
        if name:find("egg") or name:find("huevo") or name:find("carry") or name:find("item") then
            return true
        end
    end
end

return false


end
-- Bucle principal de velocidad
RunService.Stepped:Connect(function()
if not LocalPlayer.Character then return end
local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
if not humanoid then return end
local currentTarget = TargetSpeed

-- Si tenemos el bypass activado y llevamos un huevo -> usaremos la velocidad segura
if EggBypassEnabled and IsCarryingEgg() then
    currentTarget = SafeEggSpeed
end

if LoopEnabled and humanoid.WalkSpeed ~= currentTarget then
    humanoid.WalkSpeed = currentTarget
end


end)
/* STREAMING_CHUNK:Setting up slider interactions and event listeners... */
-- Slider Interaction
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
InputBox.FocusLost:Connect(function()
_G.SetSpeed(InputBox.Text)
end)
SafeInput.FocusLost:Connect(function()
local num = tonumber(SafeInput.Text)
if num then
SafeEggSpeed = math.clamp(math.floor(num), 16, 50)
SafeInput.Text = tostring(SafeEggSpeed)
end
end)
EggToggle.MouseButton1Click:Connect(function()
EggBypassEnabled = not EggBypassEnabled
if EggBypassEnabled then
EggToggle.Text = "ON"
EggToggle.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
else
EggToggle.Text = "OFF"
EggToggle.BackgroundColor3 = Color3.fromRGB(60, 65, 85)
end
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
local function ToggleVisibility()
MainFrame.Visible = not MainFrame.Visible
FloatingToggle.Visible = not MainFrame.Visible
end
CloseBtn.MouseButton1Click:Connect(ToggleVisibility)
FloatingToggle.MouseButton1Click:Connect(ToggleVisibility)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
if gameProcessed then return end
if input.KeyCode == Enum.KeyCode.Insert or input.KeyCode == Enum.KeyCode.RightControl then
ToggleVisibility()
end
end)
_G.SetSpeed(16)
/* STREAMING_CHUNK:Displaying notification upon load... */
pcall(function()
StarterGui:SetCore("SendNotification", {
Title = "Speed Panel ⚡",
Text = "¡Panel cargado con éxito!",
Duration = 4
})
end)
print("⚡ Speed Panel V4.0 Cargado Exitosamente.")
