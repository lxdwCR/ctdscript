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
main.Size = UDim2.new(0, 260, 0, 220)
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

-- BUTTON CREATOR FUNCTION
local buttons = {}
local function makeButton(text, y, callback)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -20, 0, 35)
	b.Position = UDim2.new(0, 10, 0, y)
	b.BackgroundColor3 = Color3.fromHSV(0,1,1) -- start with red
	b.TextColor3 = Color3.new(1,1,1)
	b.Text = text
	b.Font = Enum.Font.SourceSans
	b.TextSize = 14
	b.BorderSizePixel = 0
	b.Parent = main
	b.MouseButton1Click:Connect(callback)
	table.insert(buttons, b) -- add to rainbow list
end

-- BUTTONS
makeButton("Elixir Pump+", 40, function()
	placeTower:InvokeServer(
		"Elixir Pump+",
		CFrame.new(-330.56,67.13,-125.39,-0.56,0.07,-0.81,0,0.99,0.09,0.82,0.05,-0.56),
		Instance.new("Model")
	)
end)

makeButton("Wizard", 80, function()
	placeTower:InvokeServer(
		"Wizard",
		CFrame.new(-335.56,67.13,-130.39,-0.56,0.07,-0.81,0,0.99,0.09,0.82,0.05,-0.56),
		Instance.new("Model")
	)
end)

makeButton("Inferno Tower", 120, function()
	placeTower:InvokeServer(
		"Inferno Tower",
		CFrame.new(-335.56,67.13,-130.39,-0.56,0.07,-0.81,0,0.99,0.09,0.82,0.05,-0.56),
		Instance.new("Model")
	)
end)

makeButton("Inferno Tower+", 160, function()
	placeTower:InvokeServer(
		"Inferno Tower+",
		CFrame.new(-335.56,67.13,-130.39,-0.56,0.07,-0.81,0,0.99,0.09,0.82,0.05,-0.56),
		Instance.new("Model")
	)
end)

-- RAINBOW EFFECT
local hue = 0
RunService.RenderStepped:Connect(function(delta)
	hue = (hue + delta*0.2) % 1 -- speed of rainbow
	for _, b in pairs(buttons) do
		b.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
	end
end)

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

print("CTD GUI LOADED WITH RAINBOW BUTTONS")
