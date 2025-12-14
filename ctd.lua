if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local placeTower = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PlaceTower")

pcall(function()
	playerGui:FindFirstChild("CTD_GUI"):Destroy()
end)

local gui = Instance.new("ScreenGui")
gui.Name = "CTD_GUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 280, 0, 650)
main.Position = UDim2.new(0.05, 0, 0.4, 0)
main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
main.BorderSizePixel = 0
main.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Lxdw's CTD Script"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSans
title.TextSize = 16
title.Parent = main

local spinner = Instance.new("Frame")
spinner.Size = UDim2.new(0, 160, 0, 160)
spinner.Position = UDim2.new(0.5, -80, 0, 40)
spinner.BackgroundTransparency = 1
spinner.ClipsDescendants = true
spinner.Parent = main

local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(0, 200, 0, 50)
textLabel.Position = UDim2.new(0.5, -100, 0.5, -25)
textLabel.BackgroundTransparency = 1
textLabel.Text = "I love mangos"
textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
textLabel.TextStrokeTransparency = 0.8
textLabel.Font = Enum.Font.SourceSans
textLabel.TextSize = 20
textLabel.Parent = spinner

local colors = {Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 255, 0), Color3.fromRGB(0, 255, 0), 
               Color3.fromRGB(0, 0, 255), Color3.fromRGB(75, 0, 130), Color3.fromRGB(238, 130, 238)}
local colorIndex = 1
local timeElapsed = 0
local flashSpeed = 0.1

RunService.RenderStepped:Connect(function(delta)
	timeElapsed = timeElapsed + delta
	if timeElapsed >= flashSpeed then
		colorIndex = (colorIndex % #colors) + 1
		textLabel.TextColor3 = colors[colorIndex]
		timeElapsed = 0
	end
	
	spinner.Rotation = (spinner.Rotation + delta * 90) % 360
end)

local function spawnTowerAtPlayer(towerName, level)
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    local spawnPosition = hrp.Position - Vector3.new(0, 3, 0)

    local towerNameWithLevel
    if level == "1" then
        towerNameWithLevel = towerName
    else
        towerNameWithLevel = towerName .. string.rep("+", tonumber(level) - 1)
    end

    print("Spawning Tower: " .. towerNameWithLevel)

    local success, message = pcall(function()
        local args = {
            towerNameWithLevel,
            CFrame.new(spawnPosition),
        }

        placeTower:InvokeServer(unpack(args))
    end)

    if not success then
        print("Error spawning tower: " .. message)
    else
        print("Successfully spawned " .. towerNameWithLevel)
    end
end

local towerNames = {"Elixir Pump", "Wizard", "Inferno Tower", "Ice Wizard", "Rune Giant", "Lumberjack"}

local yPosition = 130
local towerLevelInput = {}

for i, name in ipairs(towerNames) do
	local towerButton = Instance.new("TextButton")
	towerButton.Size = UDim2.new(1, -20, 0, 40)
	towerButton.Position = UDim2.new(0, 10, 0, yPosition)
	towerButton.BackgroundColor3 = Color3.fromRGB(53, 53, 53)
	towerButton.Text = name
	towerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	towerButton.Font = Enum.Font.SourceSans
	towerButton.TextSize = 16
	towerButton.TextStrokeTransparency = 0.5
	towerButton.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	towerButton.Parent = main
	
	local levelInput = Instance.new("TextBox")
	levelInput.Size = UDim2.new(0, 200, 0, 30)
	levelInput.Position = UDim2.new(0, 10, 0, yPosition + 45)
	levelInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	levelInput.PlaceholderText = "Enter level (1-5+)"
	levelInput.TextColor3 = Color3.fromRGB(0, 0, 0)
	levelInput.Font = Enum.Font.SourceSans
	levelInput.TextSize = 14
	levelInput.Parent = main
	
	towerLevelInput[name] = levelInput
	
	towerButton.MouseButton1Click:Connect(function()
		local selectedLevel = towerLevelInput[name].Text
		print("Level input for " .. name .. ": " .. selectedLevel)
		
		if selectedLevel:match("^[1-5]%+?$") then
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
			
			spawnTowerAtPlayer(name, level)
		else
			print("Invalid level input! Please enter a level between 1-5+.") 
		end
	end)
	
	yPosition = yPosition + 80
end

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
