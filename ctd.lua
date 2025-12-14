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

-- CREATE MAIN GUI
local gui = Instance.new("ScreenGui")
gui.Name = "CTD_GUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- MAIN FRAME (Increased height to accommodate all buttons)
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 280, 0, 650) -- Adjusted height for buttons and dropdowns + spawn button
main.Position = UDim2.new(0.05, 0, 0.4, 0)
main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
main.BorderSizePixel = 0
main.Parent = gui

-- TITLE
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Lxdw's CTD Script"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSans
title.TextSize = 16
title.Parent = main

-- SPINNER CONTAINER FOR TEXT
local spinner = Instance.new("Frame")
spinner.Size = UDim2.new(0, 160, 0, 160)
spinner.Position = UDim2.new(0.5, -80, 0, 40) -- Slightly adjusted position
spinner.BackgroundTransparency = 1
spinner.ClipsDescendants = true
spinner.Parent = main

-- TEXT LABEL FOR "I LOVE MANGOS"
local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(0, 200, 0, 50)
textLabel.Position = UDim2.new(0.5, -100, 0.5, -25)  -- center the text
textLabel.BackgroundTransparency = 1
textLabel.Text = "I love mangos"
textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)  -- Start with red
textLabel.TextStrokeTransparency = 0.8
textLabel.Font = Enum.Font.SourceSans
textLabel.TextSize = 20
textLabel.Parent = spinner

-- RAINBOW EFFECT for Spinning Text (No Glow)
local colors = {Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 255, 0), Color3.fromRGB(0, 255, 0), 
               Color3.fromRGB(0, 0, 255), Color3.fromRGB(75, 0, 130), Color3.fromRGB(238, 130, 238)} -- rainbow colors
local colorIndex = 1
local timeElapsed = 0
local flashSpeed = 0.1  -- Change this to make it flash faster or slower

-- SPINNING AND COLOR CHANGING LOGIC for the text
RunService.RenderStepped:Connect(function(delta)
	-- Make the text flash between rainbow colors
	timeElapsed = timeElapsed + delta
	if timeElapsed >= flashSpeed then
		colorIndex = (colorIndex % #colors) + 1
		textLabel.TextColor3 = colors[colorIndex]
		timeElapsed = 0
	end
	
	-- Spin the text
	spinner.Rotation = (spinner.Rotation + delta * 90) % 360  -- degrees per second
end)

-- Function to spawn tower based on selected level
local function spawnTowerAtPlayer(towerName, level)
	local character = player.Character or player.CharacterAdded:Wait()
	local hrp = character:WaitForChild("HumanoidRootPart")
	
	-- Adjust spawn position slightly above the player
	local spawnPosition = hrp.Position + Vector3.new(0, 5, 0)  -- Slightly above the player

	-- Create tower name with level (e.g., "Wizard", "Wizard+", "Wizard++")
	local towerNameWithLevel
	if level == "1" then
		towerNameWithLevel = towerName  -- No "+" for level 1
	else
		towerNameWithLevel = towerName .. string.rep("+", tonumber(level) - 1)  -- Add "+" for higher levels
	end

	-- Debugging to check if the correct tower and level are being passed
	print("Spawning Tower: " .. towerNameWithLevel)

	-- Make sure the correct server function is called
	local success, message = pcall(function()
		local args = {
			towerNameWithLevel,  -- Tower Name with Level (e.g., "Wizard+" for level 2)
			CFrame.new(spawnPosition),  -- Spawn position based on player location
			-- No model being passed directly here, only the name and position
		}

		placeTower:InvokeServer(unpack(args))  -- Call the server with the tower model and position
	end)

	if not success then
		print("Error spawning tower: " .. message)
	else
		print("Successfully spawned " .. towerNameWithLevel)
	end
end

-- BUTTONS (positioned below spinner)
local towerNames = {"Elixir Pump", "Wizard", "Inferno Tower", "Ice Wizard", "Rune Giant", "Lumberjack"}

local yPosition = 130
local towerLevelInput = {}

for i, name in ipairs(towerNames) do
	-- Create a button for each tower
	local towerButton = Instance.new("TextButton")
	towerButton.Size = UDim2.new(1, -20, 0, 40)
	towerButton.Position = UDim2.new(0, 10, 0, yPosition)
	towerButton.BackgroundColor3 = Color3.fromRGB(53, 53, 53) -- Dark background for buttons
	towerButton.Text = name
	towerButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text
	towerButton.Font = Enum.Font.SourceSans
	towerButton.TextSize = 16
	towerButton.TextStrokeTransparency = 0.5
	towerButton.TextStrokeColor3 = Color3.fromRGB(0, 0, 0) -- Button text shadow
	towerButton.Parent = main
	
	-- Create a TextBox for level input
	local levelInput = Instance.new("TextBox")
	levelInput.Size = UDim2.new(0, 200, 0, 30)
	levelInput.Position = UDim2.new(0, 10, 0, yPosition + 45)
	levelInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	levelInput.PlaceholderText = "Enter level (1-5+)"
	levelInput.TextColor3 = Color3.fromRGB(0, 0, 0)
	levelInput.Font = Enum.Font.SourceSans
	levelInput.TextSize = 14
	levelInput.Parent = main
	
	-- Store level input for the tower
	towerLevelInput[name] = levelInput
	
	-- When tower button is clicked, check the input and spawn the tower
	towerButton.MouseButton1Click:Connect(function()
		local selectedLevel = towerLevelInput[name].Text
		print("Level input for " .. name .. ": " .. selectedLevel)
		
		-- Validate level input and ensure it's in the correct format
		if selectedLevel:match("^[1-5]%+?$") then
			-- Determine the level from the input
			local level = selectedLevel
			if level == "1" then
				level = "1"
			elseif level == "2" then
				level = "2"
			elseif level == "3" then
				level = "3"
			elseif level == "4" then
				level = "4"
			elseif level == "5" or level == "5+" then
				level = "5+"
			else
				level = "Basic"
			end
			
			-- Call function to spawn tower with the selected level
			spawnTowerAtPlayer(name, level)
		else
			print("Invalid level input! Please enter a level between 1-5+.")
		end
	end)
	
	-- Increase yPosition to properly space out the buttons and input fields
	yPosition = yPosition + 80
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

print("CTD GUI LOADED: Title, Spinning Text 'I love mangos', Tower Level Input, and Spawn Button!")
