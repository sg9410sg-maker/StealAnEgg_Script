/* STREAMING_CHUNK:Adding Universal Speed Modes and CFrame Bypass... */
-- ... existing code ...
-- LOGICA DE APLICACIÓN DE VELOCIDAD
local TargetSpeed = 16
local SafeEggSpeed = 22
local EggBypassEnabled = true
local LoopEnabled = true
local SpeedMode = "WalkSpeed" -- OPCIONES: "WalkSpeed", "CFrame", "Velocity"
function _G.SetSpeed(val)
local num = tonumber(val)
if not num then return end
TargetSpeed = math.clamp(math.floor(num), 1, 1000)
SpeedValLabel.Text = tostring(TargetSpeed)
InputBox.Text = tostring(TargetSpeed)

local alpha = (TargetSpeed - 1) / (1000 - 1)
SliderFill.Size = UDim2.new(math.clamp(alpha, 0.02, 1), 0, 1, 0)


end
-- ... existing code ...
/* STREAMING_CHUNK:Adding Mode Selector UI Control... */
-- Selector de Modo de Velocidad (WalkSpeed vs CFrame Bypass)
local ModeFrame = Instance.new("Frame")
ModeFrame.Size = UDim2.new(1, 0, 0, 36)
ModeFrame.Position = UDim2.new(0, 0, 0, 278)
ModeFrame.BackgroundColor3 = Color3.fromRGB(10, 12, 20)
ModeFrame.Parent = Content
local ModeCorner = Instance.new("UICorner")
ModeCorner.CornerRadius = UDim.new(0, 8)
ModeCorner.Parent = ModeFrame
local ModeLabel = Instance.new("TextLabel")
ModeLabel.Size = UDim2.new(0.5, 0, 1, 0)
ModeLabel.Position = UDim2.new(0, 10, 0, 0)
ModeLabel.BackgroundTransparency = 1
ModeLabel.Text = "⚡ Método de Velocidad:"
ModeLabel.TextColor3 = Color3.fromRGB(200, 205, 220)
ModeLabel.Font = Enum.Font.GothamMedium
ModeLabel.TextSize = 10
ModeLabel.TextXAlignment = Enum.TextXAlignment.Left
ModeLabel.Parent = ModeFrame
local ModeBtn = Instance.new("TextButton")
ModeBtn.Size = UDim2.new(0, 85, 0, 24)
ModeBtn.Position = UDim2.new(1, -95, 0.5, -12)
ModeBtn.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
ModeBtn.Text = "WalkSpeed"
ModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ModeBtn.Font = Enum.Font.GothamBold
ModeBtn.TextSize = 10
ModeBtn.Parent = ModeFrame
local ModeBtnCorner = Instance.new("UICorner")
ModeBtnCorner.CornerRadius = UDim.new(0, 6)
ModeBtnCorner.Parent = ModeBtn
ModeBtn.MouseButton1Click:Connect(function()
if SpeedMode == "WalkSpeed" then
SpeedMode = "CFrame"
ModeBtn.Text = "CFrame Bypass"
ModeBtn.BackgroundColor3 = Color3.fromRGB(236, 72, 153)
elseif SpeedMode == "CFrame" then
SpeedMode = "Velocity"
ModeBtn.Text = "Velocity Boost"
ModeBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
else
SpeedMode = "WalkSpeed"
ModeBtn.Text = "WalkSpeed"
ModeBtn.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
end
end)
-- ... existing code ...
/* STREAMING_CHUNK:Implementing Universal Loop with CFrame and Velocity support... */
-- Bucle principal de velocidad universal (RenderStepped & Stepped)
RunService.RenderStepped:Connect(function(deltaTime)
if not LocalPlayer.Character then return end
local character = LocalPlayer.Character
local humanoid = character:FindFirstChildOfClass("Humanoid")
local hrp = character:FindFirstChild("HumanoidRootPart")
if not humanoid or not hrp then return end
local currentTarget = TargetSpeed

-- Si tenemos el bypass activado y llevamos un huevo -> usaremos la velocidad segura
if EggBypassEnabled and IsCarryingEgg() then
    currentTarget = SafeEggSpeed
end

-- MODO 1: Standard WalkSpeed
if SpeedMode == "WalkSpeed" then
    if LoopEnabled and humanoid.WalkSpeed ~= currentTarget then
        humanoid.WalkSpeed = currentTarget
    end

-- MODO 2: CFrame Step (Pasa por encima de bloqueos de WalkSpeed del servidor)
elseif SpeedMode == "CFrame" then
    if humanoid.MoveDirection.Magnitude > 0 then
        local speedMultiplier = (currentTarget / 16) - 1
        if speedMultiplier > 0 then
            hrp.CFrame = hrp.CFrame + (humanoid.MoveDirection * (speedMultiplier * 16 * deltaTime))
        end
    end

-- MODO 3: Assembly Linear Velocity (Impulso Físico Directo)
elseif SpeedMode == "Velocity" then
    if humanoid.MoveDirection.Magnitude > 0 then
        local currentVelY = hrp.AssemblyLinearVelocity.Y
        local moveDir = humanoid.MoveDirection * currentTarget
        hrp.AssemblyLinearVelocity = Vector3.new(moveDir.X, currentVelY, moveDir.Z)
    end
end


end)
-- ... existing code ...
