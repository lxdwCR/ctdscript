if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local placeTower = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PlaceTower")

-- REMOVE OLD GUI
pcall(function()
	playerGui:FindFirstChild("CTD_GUI"):Destroy()
end)

-- CREATE SCREEN GUI
local gui = Instance.new("ScreenGui")
gui.Name = "CTD_GUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- MAIN FRAME
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 280, 0, 460) -- large enough for spinner + buttons
main.Position = UDim2.new(0.05, 0, 0.4, 0)
main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
main.BorderSizePixel = 0
main.Parent = gui

-- TITLE
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Lxdw's CTD Script"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSans
title.TextSize = 16
title.Parent = main

-- SPINNER CONTAINER FOR TEXT
local spinner = Instance.new("Frame")
spinner.Size = UDim2.new(0, 160, 0, 160)
spinner.Position = UDim2.new(0.5, -80, 0, 40)
spinner.BackgroundTransparency = 1
spinner.ClipsDescendants = true
spinner.Parent = main

-- TEXT LABEL FOR "I LOVE MANGOS"
local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(0, 200, 0, 50)
textLabel.Position = UDim2.new(0.5, -100, 0.5, -25)  -- center the text
textLabel.BackgroundTransparency = 1
textLabel.Text = "SS NAZI PARTY ON TOP 1488 WP"
textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)  -- Start with red
textLabel.TextStrokeTransparency = 0.8
textLabel.Font = Enum.Font.SourceSans
textLabel.TextSize = 20
textLabel.Parent = spinner

-- RAINBOW EFFECT (for flashing text color)
local colors = {Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0)} -- red, white, black
local colorIndex = 1
local timeElapsed = 0
local flashSpeed = 0.1  -- Change this to make it flash faster or slower

-- SPINNING AND COLOR CHANGING LOGIC
RunService.RenderStepped:Connect(function(delta)
	-- Make the text flash between red, white, and black
	timeElapsed = timeElapsed + delta
	if timeElapsed >= flashSpeed then
		colorIndex = (colorIndex % #colors) + 1
		textLabel.TextColor3 = colors[colorIndex]
		timeElapsed = 0
	end
	
	-- Spin the text
	spinner.Rotation = (spinner.Rotation + delta * 90) % 360  -- degrees per second
end)

-- BUTTON CREATOR FUNCTION
local buttons = {}
local function makeButton(text, index, callback)
	local spacing = 10
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -20, 0, 35)
	-- Position buttons below spinner
	local yPos = spinner.Position.Y.Offset + spinner.Size.Y.Offset + spacing + (index - 1) * (35 + spacing)
	b.Position = UDim2.new(0, 10, 0, yPos)
	b.BackgroundColor3 = Color3.fromHSV(0,1,1)
	b.TextColor3 = Color3.new(1,1,1)
	b.Text = text
	b.Font = Enum.Font.SourceSans
	b.TextSize = 14
	b.BorderSizePixel = 0
	b.Parent = main
	b.MouseButton1Click:Connect(callback)
	table.insert(buttons, b)
end

-- FUNCTION TO SPAWN TOWER AT PLAYER
local function spawnTowerAtPlayer(towerName)
	local character = player.Character or player.CharacterAdded:Wait()
	local hrp = character:WaitForChild("HumanoidRootPart")
	placeTower:InvokeServer(
		towerName,
		CFrame.new(hrp.Position + Vector3.new(0,0,5)),
		Instance.new("Model")
	)
end

-- BUTTONS (positioned below spiral)
local towerNames = {"Elixir Pump+", "Wizard", "Inferno Tower", "Inferno Tower+", "Ice Wizard"}
for i, name in ipairs(towerNames) do
	makeButton(name, i, function() spawnTowerAtPlayer(name) end)
end

-- DRAGGING FUNCTIONALITY
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
	local delta = input.Position - dragStart
	main.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end

main.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = main.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

main.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and input == dragInput then
		update(input)
	end
end)

print("CTD GUI LOADED: Title, Spinning Text 'I love mangos', Rainbow Buttons, and Player Towers!")
