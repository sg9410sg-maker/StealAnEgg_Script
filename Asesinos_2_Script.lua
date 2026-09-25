-- Crear un ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpeedPanel"
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Crear el Frame principal
local frame = Instance.new("Frame")
frame.Name = "SpeedFrame"
frame.Size = UDim2.new(0, 200, 0, 150)
frame.Position = UDim2.new(0.5, -100, 0.5, -75)
frame.BackgroundTransparency = 0.5
frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
frame.Parent = screenGui

-- Crear el botón de cerrar
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Text = "Cerrar"
closeButton.Size = UDim2.new(0, 100, 0, 30)
closeButton.Position = UDim2.new(0.5, -50, 0, 110)
closeButton.TextColor3 = Color3.fromRGB(0, 0, 0)
closeButton.Parent = frame

-- Función para cerrar el panel
closeButton.MouseButton1Click:Connect(function()
    frame.Visible = false
end)

-- Crear el label y textbox para la velocidad
local speedLabel = Instance.new("TextLabel")
speedLabel.Name = "SpeedLabel"
speedLabel.Text = "Velocidad"
speedLabel.Size = UDim2.new(0, 100, 0, 20)
speedLabel.Position = UDim2.new(0.5, -50, 0, 10)
speedLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
speedLabel.Parent = frame

local speedTextBox = Instance.new("TextBox")
speedTextBox.Name = "SpeedTextBox"
speedTextBox.Text = "1"
speedTextBox.Size = UDim2.new(0, 50, 0, 20)
speedTextBox.Position = UDim2.new(0.5, -25, 0, 35)
speedTextBox.TextColor3 = Color3.fromRGB(0, 0, 0)
speedTextBox.Parent = frame

-- Función para actualizar la velocidad del personaje
speedTextBox.FocusLost:Connect(function()
    local newSpeed = tonumber(speedTextBox.Text) or 1
    local character = game.Players.LocalPlayer.Character
    if character then
        character.Humanoid.WalkSpeed = newSpeed
    end
end)

-- Crear el dragger para mover el panel
local dragger = Instance.new("TextButton")
dragger.Name = "Dragger"
dragger.Size = UDim2.new(1, 0, 0, 20)
dragger.BackgroundTransparency = 1
dragger.Parent = frame

local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

dragger.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

dragger.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)
