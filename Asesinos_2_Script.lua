-- Crear un ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpeedPanel"
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Crear el Frame principal
local frame = Instance.new("Frame")
frame.Name = "SpeedFrame"
frame.Size = UDim2.new(0, 250, 0, 210)
frame.Position = UDim2.new(0.5, -125, 0.5, -105)
frame.BackgroundTransparency = 0.8
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
frame.Visible = false
frame.Parent = screenGui

-- Crear el botón de abrir
local openButton = Instance.new("TextButton")
openButton.Name = "OpenButton"
openButton.Text = "Abrir"
openButton.Size = UDim2.new(0, 100, 0, 30)
openButton.Position = UDim2.new(0.5, -50, 0, 10)
openButton.TextColor3 = Color3.fromRGB(255, 255, 255)
openButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
openButton.Parent = screenGui

-- Función para abrir el panel
openButton.MouseButton1Click:Connect(function()
    frame.Visible = true
    frame.Position = UDim2.new(0.5, -125, 0.5, -105)
end)

-- Crear el botón de cerrar
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Text = "Cerrar"
closeButton.Size = UDim2.new(0, 100, 0, 30)
closeButton.Position = UDim2.new(0.5, -50, 0, 170)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
closeButton.Parent = frame

-- Función para cerrar el panel
closeButton.MouseButton1Click:Connect(function()
    frame.Visible = false
    frame.Position = UDim2.new(0.5, -125, 0.5, -105)
end)

-- Crear el botón de inyección
local injectButton = Instance.new("TextButton")
injectButton.Name = "InjectButton"
injectButton.Text = "Inyectar"
injectButton.Size = UDim2.new(0, 100, 0, 30)
injectButton.Position = UDim2.new(0.5, -50, 0, 140)
injectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
injectButton.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
injectButton.Parent = frame

-- Función para inyectar la velocidad
injectButton.MouseButton1Click:Connect(function()
    local newSpeed = tonumber(speedTextBox.Text) or 100
    if newSpeed < 100 then
        newSpeed = 100
    elseif newSpeed > 1000 then
        newSpeed = 1000
    end
    local character = game.Players.LocalPlayer.Character
    if character then
        if game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name == "Asesinos 2" or game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name == "Steal An Egg" then
            character.Humanoid.WalkSpeed = newSpeed
        end
    end
end)

-- Crear el label y textbox para la velocidad
local speedLabel = Instance.new("TextLabel")
speedLabel.Name = "SpeedLabel"
speedLabel.Text = "Velocidad (100-1000)"
speedLabel.Size = UDim2.new(0, 200, 0, 20)
speedLabel.Position = UDim2.new(0.5, -100, 0, 10)
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextScaled = true
speedLabel.Parent = frame

local speedTextBox = Instance.new("TextBox")
speedTextBox.Name = "SpeedTextBox"
speedTextBox.Text = "100"
speedTextBox.Size = UDim2.new(0, 50, 0, 20)
speedTextBox.Position = UDim2.new(0.5, -25, 0, 35)
speedTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedTextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedTextBox.TextScaled = true
speedTextBox.Parent = frame

-- Crear el dragger para mover el panel
local dragger = Instance.new("TextButton")
dragger.Name = "Dragger"
dragger.Size = UDim2.new(1, 0, 0, 20)
dragger.BackgroundTransparency = 1
dragger.Text = ""
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
