-- ╔═══════════════════════════════════════════════════════════════╗
-- ║                      SPIRITHUB v1.0                           ║
-- ║              ESP Player com Interface Bonita                  ║
-- ╚═══════════════════════════════════════════════════════════════╝

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ╔═ CONFIGURAÇÕES ═╗
local CONFIG = {
    KEY = "SpiritHub",
    PANEL_NAME = "SpiritHub",
    VALID = false,
    ESP_ENABLED = false,
    NAME_ENABLED = false,
    FLY_ENABLED = false,
    SPEED_ENABLED = false,
    INVISIBLE_ENABLED = false,
    KILL_ENABLED = false,
    FLY_SPEED = 50,
    PLAYER_SPEED = 50,
}

-- ╔═ VARIÁVEIS GLOBAIS ═╗
local espBoxes = {}
local flying = false
local bodyVelocity = nil
local bodyGyro = nil
local invisibilityFolder = nil

-- ╔═ FUNÇÃO: CRIAR UI ═╗
local function createUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = CONFIG.PANEL_NAME
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- ╔═ FRAME PRINCIPAL ═╗
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 350, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    -- Adicionar Stroke (Borda)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(138, 43, 226)
    stroke.Thickness = 2
    stroke.Parent = mainFrame

    -- Adicionar Rounded Corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame

    -- ╔═ HEADER ═╗
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 60)
    header.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    header.BorderSizePixel = 0
    header.Parent = mainFrame

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "⚡ " .. CONFIG.PANEL_NAME .. " ⚡"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = header

    -- ╔═ SCROLLING FRAME ═╗
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Size = UDim2.new(1, -10, 1, -80)
    scrollFrame.Position = UDim2.new(0, 5, 0, 70)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.Parent = mainFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.Parent = scrollFrame

    -- ╔═ FUNÇÃO: CRIAR BOTÃO ═╗
    local function createButton(parent, name, action)
        local button = Instance.new("Frame")
        button.Name = name
        button.Size = UDim2.new(1, -20, 0, 45)
        button.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        button.BorderSizePixel = 0
        button.Parent = parent

        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 8)
        buttonCorner.Parent = button

        local buttonStroke = Instance.new("UIStroke")
        buttonStroke.Color = Color3.fromRGB(100, 100, 150)
        buttonStroke.Thickness = 1
        buttonStroke.Parent = button

        local textButton = Instance.new("TextButton")
        textButton.Name = "TextButton"
        textButton.Size = UDim2.new(1, 0, 1, 0)
        textButton.BackgroundTransparency = 1
        textButton.Text = name
        textButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        textButton.TextScaled = true
        textButton.Font = Enum.Font.Gotham
        textButton.Parent = button

        local toggled = false
        textButton.MouseButton1Click:Connect(function()
            toggled = not toggled
            button.BackgroundColor3 = toggled and Color3.fromRGB(138, 43, 226) or Color3.fromRGB(40, 40, 60)
            buttonStroke.Color = toggled and Color3.fromRGB(200, 100, 255) or Color3.fromRGB(100, 100, 150)
            action(toggled)
        end)

        textButton.MouseEnter:Connect(function()
            button.BackgroundColor3 = toggled and Color3.fromRGB(160, 60, 240) or Color3.fromRGB(60, 60, 80)
        end)

        textButton.MouseLeave:Connect(function()
            button.BackgroundColor3 = toggled and Color3.fromRGB(138, 43, 226) or Color3.fromRGB(40, 40, 60)
        end)

        return toggled
    end

    -- ╔═ BOTÕES DE FUNCIONALIDADES ═╗
    createButton(scrollFrame, "🎯 ESP PLAYER", function(state)
        CONFIG.ESP_ENABLED = state
    end)

    createButton(scrollFrame, "📝 ESP NAME", function(state)
        CONFIG.NAME_ENABLED = state
    end)

    createButton(scrollFrame, "✈️ FLY", function(state)
        CONFIG.FLY_ENABLED = state
        if state then startFlying() else stopFlying() end
    end)

    createButton(scrollFrame, "⚡ SPEED", function(state)
        CONFIG.SPEED_ENABLED = state
    end)

    createButton(scrollFrame, "👻 INVISIBLE", function(state)
        CONFIG.INVISIBLE_ENABLED = state
        if state then toggleInvisibility(true) else toggleInvisibility(false) end
    end)

    createButton(scrollFrame, "💀 KILL ALL", function(state)
        if state then killAll() end
    end)

    -- ╔═ FOOTER ═╗
    local footer = Instance.new("Frame")
    footer.Name = "Footer"
    footer.Size = UDim2.new(1, 0, 0, 40)
    footer.Position = UDim2.new(0, 0, 1, -40)
    footer.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    footer.BorderSizePixel = 0
    footer.Parent = mainFrame

    local footerCorner = Instance.new("UICorner")
    footerCorner.CornerRadius = UDim.new(0, 12)
    footerCorner.Parent = footer

    local versionLabel = Instance.new("TextLabel")
    versionLabel.Size = UDim2.new(1, 0, 1, 0)
    versionLabel.BackgroundTransparency = 1
    versionLabel.Text = "v1.0 | Feito por @andreluisborato"
    versionLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    versionLabel.TextScaled = true
    versionLabel.Font = Enum.Font.GothamBold
    versionLabel.Parent = footer

    -- ╔═ FUNÇÃO DRAG ═╗
    local dragging = false
    local dragStart = nil
    local startPos = nil

    header.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = Mouse.Position
            startPos = mainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input, gameProcessed)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = Mouse.Position - dragStart
            mainFrame.Position = startPos + UDim2.new(0, delta.X, 0, delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    return screenGui
end

-- ╔═ FUNÇÃO: CRIAR DIÁLOGO DE KEY ═╗
local function createKeyDialog()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KeyDialog"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local bgFrame = Instance.new("Frame")
    bgFrame.Size = UDim2.new(1, 0, 1, 0)
    bgFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bgFrame.BackgroundTransparency = 0.5
    bgFrame.BorderSizePixel = 0
    bgFrame.Parent = screenGui

    local dialogFrame = Instance.new("Frame")
    dialogFrame.Name = "DialogFrame"
    dialogFrame.Size = UDim2.new(0, 400, 0, 250)
    dialogFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
    dialogFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    dialogFrame.BorderSizePixel = 0
    dialogFrame.Parent = bgFrame

    local dialogCorner = Instance.new("UICorner")
    dialogCorner.CornerRadius = UDim.new(0, 12)
    dialogCorner.Parent = dialogFrame

    local dialogStroke = Instance.new("UIStroke")
    dialogStroke.Color = Color3.fromRGB(138, 43, 226)
    dialogStroke.Thickness = 3
    dialogStroke.Parent = dialogFrame

    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 50)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🔐 " .. CONFIG.PANEL_NAME
    titleLabel.TextColor3 = Color3.fromRGB(138, 43, 226)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = dialogFrame

    -- Texto de instrução
    local instructionLabel = Instance.new("TextLabel")
    instructionLabel.Size = UDim2.new(1, -20, 0, 40)
    instructionLabel.Position = UDim2.new(0, 10, 0, 50)
    instructionLabel.BackgroundTransparency = 1
    instructionLabel.Text = "Digite a chave para acessar:"
    instructionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    instructionLabel.TextScaled = true
    instructionLabel.Font = Enum.Font.Gotham
    instructionLabel.Parent = dialogFrame

    -- Input Box
    local inputBox = Instance.new("TextBox")
    inputBox.Name = "InputBox"
    inputBox.Size = UDim2.new(1, -20, 0, 40)
    inputBox.Position = UDim2.new(0, 10, 0, 95)
    inputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    inputBox.PlaceholderText = "Insira a chave..."
    inputBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    inputBox.TextScaled = true
    inputBox.Font = Enum.Font.Gotham
    inputBox.BorderSizePixel = 0
    inputBox.Parent = dialogFrame

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = inputBox

    -- Button Enter
    local enterButton = Instance.new("TextButton")
    enterButton.Name = "EnterButton"
    enterButton.Size = UDim2.new(0.5, -5, 0, 40)
    enterButton.Position = UDim2.new(0, 10, 0, 145)
    enterButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    enterButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    enterButton.Text = "✓ ENTRAR"
    enterButton.TextScaled = true
    enterButton.Font = Enum.Font.GothamBold
    enterButton.BorderSizePixel = 0
    enterButton.Parent = dialogFrame

    local enterCorner = Instance.new("UICorner")
    enterCorner.CornerRadius = UDim.new(0, 8)
    enterCorner.Parent = enterButton

    -- Button Exit
    local exitButton = Instance.new("TextButton")
    exitButton.Name = "ExitButton"
    exitButton.Size = UDim2.new(0.5, -5, 0, 40)
    exitButton.Position = UDim2.new(0.5, 5, 0, 145)
    exitButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    exitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    exitButton.Text = "✗ SAIR"
    exitButton.TextScaled = true
    exitButton.Font = Enum.Font.GothamBold
    exitButton.BorderSizePixel = 0
    exitButton.Parent = dialogFrame

    local exitCorner = Instance.new("UICorner")
    exitCorner.CornerRadius = UDim.new(0, 8)
    exitCorner.Parent = exitButton

    -- Error Label
    local errorLabel = Instance.new("TextLabel")
    errorLabel.Name = "ErrorLabel"
    errorLabel.Size = UDim2.new(1, -20, 0, 20)
    errorLabel.Position = UDim2.new(0, 10, 0, 190)
    errorLabel.BackgroundTransparency = 1
    errorLabel.Text = ""
    errorLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    errorLabel.TextScaled = true
    errorLabel.Font = Enum.Font.Gotham
    errorLabel.Parent = dialogFrame

    local validated = false

    enterButton.MouseButton1Click:Connect(function()
        if inputBox.Text == CONFIG.KEY then
            CONFIG.VALID = true
            validated = true
            screenGui:Destroy()
            createUI()
        else
            errorLabel.Text = "❌ Chave incorreta!"
            inputBox.Text = ""
        end
    end)

    exitButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    -- Detectar Enter no InputBox
    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            enterButton:TriggerEvent("MouseButton1Click")
        end
    end)

    inputBox:CaptureFocus()
end

-- ╔═ FUNÇÃO: ESP ═╗
local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = player.Character:FindFirstChild("Humanoid")

            if humanoidRootPart and humanoid and humanoid.Health > 0 then
                -- Cria Box SE não existe
                if not espBoxes[player] then
                    espBoxes[player] = {}
                    for i = 1, 12 do
                        local line = Instance.new("Part")
                        line.Shape = Enum.PartType.Cylinder
                        line.Material = Enum.Material.Neon
                        line.CanCollide = false
                        line.CFrame = humanoidRootPart.CFrame
                        line.Parent = workspace
                        espBoxes[player][i] = line
                    end
                end

                if CONFIG.ESP_ENABLED then
                    local pos = humanoidRootPart.Position
                    local size = humanoidRootPart.Size
                    local boxes = espBoxes[player]

                    -- Top
                    boxes[1].Size = Vector3.new(size.X, 0.1, size.Z)
                    boxes[1].CFrame = CFrame.new(pos + Vector3.new(0, size.Y/2, 0)) * CFrame.Angles(0, 0, 0)
                    boxes[1].Color = Color3.fromRGB(255, 0, 0)

                    -- Bottom
                    boxes[2].Size = Vector3.new(size.X, 0.1, size.Z)
                    boxes[2].CFrame = CFrame.new(pos - Vector3.new(0, size.Y/2, 0)) * CFrame.Angles(0, 0, 0)
                    boxes[2].Color = Color3.fromRGB(255, 0, 0)

                    -- Left
                    boxes[3].Size = Vector3.new(0.1, size.Y, size.Z)
                    boxes[3].CFrame = CFrame.new(pos - Vector3.new(size.X/2, 0, 0)) * CFrame.Angles(0, 0, 0)
                    boxes[3].Color = Color3.fromRGB(255, 0, 0)

                    -- Right
                    boxes[4].Size = Vector3.new(0.1, size.Y, size.Z)
                    boxes[4].CFrame = CFrame.new(pos + Vector3.new(size.X/2, 0, 0)) * CFrame.Angles(0, 0, 0)
                    boxes[4].Color = Color3.fromRGB(255, 0, 0)

                    -- Front
                    boxes[5].Size = Vector3.new(size.X, size.Y, 0.1)
                    boxes[5].CFrame = CFrame.new(pos + Vector3.new(0, 0, size.Z/2)) * CFrame.Angles(0, 0, 0)
                    boxes[5].Color = Color3.fromRGB(255, 0, 0)

                    -- Back
                    boxes[6].Size = Vector3.new(size.X, size.Y, 0.1)
                    boxes[6].CFrame = CFrame.new(pos - Vector3.new(0, 0, size.Z/2)) * CFrame.Angles(0, 0, 0)
                    boxes[6].Color = Color3.fromRGB(255, 0, 0)

                    -- Diagonal lines
                    for i = 7, 12 do
                        boxes[i].Size = Vector3.new(0.1, 0.1, 0.1)
                        boxes[i].Color = Color3.fromRGB(255, 0, 0)
                    end

                    for _, box in pairs(boxes) do
                        box.Transparency = 0.3
                    end
                else
                    for _, box in pairs(espBoxes[player]) do
                        box.Transparency = 1
                    end
                end

                -- ESP NAME
                if CONFIG.NAME_ENABLED then
                    if not humanoidRootPart:FindFirstChild("NameEsp") then
                        local bill = Instance.new("BillboardGui")
                        bill.Name = "NameEsp"
                        bill.Size = UDim2.new(4, 0, 2, 0)
                        bill.MaxDistance = 100
                        bill.Parent = humanoidRootPart

                        local textLabel = Instance.new("TextLabel")
                        textLabel.Size = UDim2.new(1, 0, 1, 0)
                        textLabel.BackgroundTransparency = 1
                        textLabel.Text = player.Name
                        textLabel.TextColor3 = Color3.fromRGB(138, 43, 226)
                        textLabel.TextScaled = true
                        textLabel.Font = Enum.Font.GothamBold
                        textLabel.Parent = bill
                    end
                else
                    local nameEsp = humanoidRootPart:FindFirstChild("NameEsp")
                    if nameEsp then nameEsp:Destroy() end
                end
            end
        end
    end
end

-- ╔═ FUNÇÃO: FLY ═╗
local function startFlying()
    if flying then return end
    flying = true

    local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Parent = humanoidRootPart

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 10000
    bodyGyro.Parent = humanoidRootPart

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not flying then connection:Disconnect() return end

        local humanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then connection:Disconnect() flying = false return end

        local moveDirection = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - LocalPlayer.Character.HumanoidRootPart.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + LocalPlayer.Character.HumanoidRootPart.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDirection = moveDirection - Vector3.new(0, 1, 0) end

        bodyVelocity.Velocity = moveDirection.Unit * CONFIG.FLY_SPEED
        bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + Mouse.Hit.LookVector)
    end)
end

local function stopFlying()
    flying = false
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
end

-- ╔═ FUNÇÃO: INVISIBILIDADE ═╗
local function toggleInvisibility(state)
    local character = LocalPlayer.Character
    if not character then return end

    if state then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 1
            end
        end
    else
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0
            end
        end
    end
end

-- ╔═ FUNÇÃO: SPEED ═╗
local function updateSpeed()
    if CONFIG.SPEED_ENABLED then
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = CONFIG.PLAYER_SPEED
        end
    end
end

-- ╔═ FUNÇÃO: KILL ALL ═╗
local function killAll()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.Health = 0
            end
        end
    end
end

-- ╔═ INICIALIZAÇÃO ═╗
createKeyDialog()

RunService.RenderStepped:Connect(function()
    if CONFIG.VALID then
        updateESP()
        updateSpeed()
    end
end)

print("✅ SpiritHub carregado com sucesso!")