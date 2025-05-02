-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

-- Variáveis
local FOV = 100
local AimbotEnabled = true
local ESPEnabled = false
local espCache = {}
local isMinimized = false

-- GUI Setup
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "BazHub"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 200)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

-- Notificação
local notification = Instance.new("Frame", gui)
notification.Size = UDim2.new(0, 300, 0, 60)
notification.Position = UDim2.new(1, -310, 1, -80)
notification.AnchorPoint = Vector2.new(0, 0)
notification.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
notification.BorderSizePixel = 0
notification.Visible = true
Instance.new("UICorner", notification).CornerRadius = UDim.new(0, 10)

local welcomeLabel = Instance.new("TextLabel", notification)
welcomeLabel.Size = UDim2.new(1, -10, 0, 30)
welcomeLabel.Position = UDim2.new(0, 5, 0, 5)
welcomeLabel.BackgroundTransparency = 1
welcomeLabel.Text = "Bem Vindo Ao BazHub"
welcomeLabel.Font = Enum.Font.GothamBold
welcomeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
welcomeLabel.TextSize = 16
welcomeLabel.TextXAlignment = Enum.TextXAlignment.Left

local loadedLabel = Instance.new("TextLabel", notification)
loadedLabel.Size = UDim2.new(1, -10, 0, 20)
loadedLabel.Position = UDim2.new(0, 5, 0, 35)
loadedLabel.BackgroundTransparency = 1
loadedLabel.Text = "BazHub Completamente Carregado"
loadedLabel.Font = Enum.Font.Gotham
loadedLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
loadedLabel.TextSize = 14
loadedLabel.TextXAlignment = Enum.TextXAlignment.Left

task.delay(5, function()
	if notification then
		notification:Destroy()
	end
end)

-- Draggable
local function makeDraggable(frame)
	local dragging, dragStart, startPos
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end
makeDraggable(frame)

-- Título
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 25)
title.Position = UDim2.new(0, 30, 0, 0)
title.Text = "BazHub"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left

-- FOV Label
local fovLabel = Instance.new("TextLabel", frame)
fovLabel.Position = UDim2.new(0, 10, 0, 30)
fovLabel.Size = UDim2.new(1, 0, 0, 20)
fovLabel.Text = "FOV: 100"
fovLabel.TextColor3 = Color3.new(1, 1, 1)
fovLabel.BackgroundTransparency = 1
fovLabel.Font = Enum.Font.SourceSansBold
fovLabel.TextScaled = true

-- Botões
local function createButton(text, position)
	local btn = Instance.new("TextButton", frame)
	btn.Text = text
	btn.Position = position
	btn.Size = UDim2.new(0, 200, 0, 30)
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	return btn
end

local incFOV = createButton("Aumentar FOV", UDim2.new(0, 10, 0, 55))
local decFOV = createButton("Diminuir FOV", UDim2.new(0, 10, 0, 90))
local toggleAimbot = createButton("Aimbot: ON", UDim2.new(0, 10, 0, 125))
toggleAimbot.TextColor3 = Color3.new(0, 1, 0)

local toggleESP = createButton("ESP: OFF", UDim2.new(0, 10, 0, 160))
toggleESP.TextColor3 = Color3.new(1, 0, 0)

local minimizeButton = Instance.new("TextButton", frame)
minimizeButton.Text = "-"
minimizeButton.Size = UDim2.new(0, 30, 0, 25)
minimizeButton.Position = UDim2.new(0, 190, 0, 0)
minimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
minimizeButton.TextColor3 = Color3.new(1, 0, 0)
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextSize = 18
Instance.new("UICorner", minimizeButton).CornerRadius = UDim.new(0, 8)

local restoreButton = Instance.new("TextButton", gui)
restoreButton.Text = "+"
restoreButton.Position = UDim2.new(0, 190, 0, 150)
restoreButton.Size = UDim2.new(0, 30, 0, 30)
restoreButton.TextColor3 = Color3.new(0, 1, 0)
restoreButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
restoreButton.Font = Enum.Font.GothamBold
restoreButton.TextSize = 18
restoreButton.Visible = false
Instance.new("UICorner", restoreButton).CornerRadius = UDim.new(0, 8)

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Thickness = 1
fovCircle.NumSides = 64
fovCircle.Filled = false
fovCircle.Visible = true

-- Função para verificar se há linha de visão (WallCheck)
local function isVisible(targetPart)
	local origin = Camera.CFrame.Position
	local direction = (targetPart.Position - origin)
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	rayParams.IgnoreWater = true

	local result = workspace:Raycast(origin, direction, rayParams)
	if result then
		return result.Instance:IsDescendantOf(targetPart.Parent)
	end
	return false
end

-- Função para pegar o jogador mais próximo com WallCheck
local function getClosestPlayer()
	local closestPlayer = nil
	local shortestDistance = FOV

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
			local head = player.Character.Head
			local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)

			if onScreen then
				local distance = (Vector2.new(screenPos.X, screenPos.Y) - Camera.ViewportSize / 2).Magnitude

				if distance < shortestDistance and isVisible(head) then
					shortestDistance = distance
					closestPlayer = player
				end
			end
		end
	end

	return closestPlayer
end

-- Botões
incFOV.MouseButton1Click:Connect(function()
	FOV += 25
	fovLabel.Text = "FOV: " .. FOV
end)

decFOV.MouseButton1Click:Connect(function()
	FOV = math.max(25, FOV - 25)
	fovLabel.Text = "FOV: " .. FOV
end)

toggleAimbot.MouseButton1Click:Connect(function()
	AimbotEnabled = not AimbotEnabled
	toggleAimbot.Text = "Aimbot: " .. (AimbotEnabled and "ON" or "OFF")
	toggleAimbot.TextColor3 = AimbotEnabled and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
end)

toggleESP.MouseButton1Click:Connect(function()
	ESPEnabled = not ESPEnabled
	toggleESP.Text = "ESP: " .. (ESPEnabled and "ON" or "OFF")
	toggleESP.TextColor3 = ESPEnabled and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
end)

minimizeButton.MouseButton1Click:Connect(function()
	isMinimized = true
	frame.Visible = false
	restoreButton.Visible = true
end)

restoreButton.MouseButton1Click:Connect(function()
	isMinimized = false
	frame.Visible = true
	restoreButton.Visible = false
end)

-- Atualização contínua
RunService.RenderStepped:Connect(function()
	fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	fovCircle.Radius = FOV
	fovCircle.Visible = not isMinimized

	if AimbotEnabled then
		local target = getClosestPlayer()
		if target and target.Character and target.Character:FindFirstChild("Head") then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
		end
	end

	if ESPEnabled then
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
				local head = player.Character.Head
				local humanoid = player.Character.Humanoid
				local pos, onScreen = Camera:WorldToViewportPoint(head.Position)

				if not espCache[player] then
					espCache[player] = {
						Name = Instance.new("TextLabel", gui),
						Distance = Instance.new("TextLabel", gui),
						Health = Instance.new("TextLabel", gui)
					}
					for _, lbl in pairs(espCache[player]) do
						lbl.BackgroundTransparency = 1
						lbl.Font = Enum.Font.SourceSansBold
						lbl.TextColor3 = Color3.new(1, 1, 1)
						lbl.TextSize = 14
						lbl.ZIndex = 10
					end
				end

				local data = espCache[player]
				if onScreen then
					local distance = math.floor((head.Position - Camera.CFrame.Position).Magnitude)
					local health = math.floor(humanoid.Health)
					data.Name.Text = player.Name
					data.Name.Position = UDim2.new(0, pos.X, 0, pos.Y - 20)
					data.Name.Visible = true

					data.Distance.Text = "Distância: " .. distance
					data.Distance.Position = UDim2.new(0, pos.X, 0, pos.Y)
					data.Distance.Visible = true

					data.Health.Text = "Vida: " .. health
					data.Health.Position = UDim2.new(0, pos.X, 0, pos.Y + 20)
					data.Health.Visible = true
				else
					for _, lbl in pairs(data) do
						lbl.Visible = false
					end
				end
			elseif espCache[player] then
				for _, lbl in pairs(espCache[player]) do
					lbl.Visible = false
				end
			end
		end
	else
		for _, data in pairs(espCache) do
			for _, lbl in pairs(data) do
				lbl.Visible = false
			end
		end
	end
end)

-- Limpeza
Players.PlayerRemoving:Connect(function(player)
	if espCache[player] then
		for _, label in pairs(espCache[player]) do
			label:Destroy()
		end
		espCache[player] = nil
	end
end)

Players.PlayerAdded:Connect(function(player)
	player.CharacterRemoving:Connect(function()
		if espCache[player] then
			for _, label in pairs(espCache[player]) do
				label:Destroy()
			end
			espCache[player] = nil
		end
	end)
end)
