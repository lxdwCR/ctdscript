-- CTD Script (STABLE + LEVEL BY NAME)
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

-- GLOBAL LEVEL (1–5)
local GLOBAL_LEVEL = 1 -- Default to 1 (no "+") instead of string "1"

-- GUI ROOT
local gui = Instance.new("ScreenGui")
gui.Name = "CTD_GUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0,280,0,650)
main.Position = UDim2.new(0.05,0,0.4,0)
main.BackgroundColor3 = Color3.fromRGB(0,0,0)
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui

-- TITLE
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "Lxdw's CTD Script"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.Parent = main

-- SPINNER
local spinner = Instance.new("Frame")
spinner.Size = UDim2.new(0,160,0,160)
spinner.Position = UDim2.new(0.5,-80,0,35)
spinner.BackgroundTransparency = 1
spinner.Parent = main

local spinText = Instance.new("TextLabel")
spinText.Size = UDim2.new(1,0,1,0)
spinText.BackgroundTransparency = 1
spinText.Text = "卐"
spinText.Font = Enum.Font.SourceSans
spinText.TextSize = 60
spinText.Parent = spinner

local colors = {
    Color3.fromRGB(255,0,0),
    Color3.fromRGB(255,255,0),
    Color3.fromRGB(0,255,0),
    Color3.fromRGB(0,0,255),
    Color3.fromRGB(138,43,226)
}

local ci = 1
RunService.RenderStepped:Connect(function(dt)
    ci = (ci % #colors) + 1
    spinText.TextColor3 = colors[ci]
    spinText.Rotation = (spinText.Rotation + dt * 90) % 360
end)

-- CONTENT OFFSET
local contentY = 130  -- Space for level button

-- PAGE 1
local page1 = Instance.new("Frame")
page1.Size = UDim2.new(1,0,1,-(contentY+50))
page1.Position = UDim2.new(0,0,0,contentY)
page1.BackgroundColor3 = Color3.fromRGB(0,0,0)
page1.Parent = main

-- PAGE 2 (this will be dynamically created later)
local pages = {page1}  -- Start with the first page

-- PAGE NAV
local page = 1
local totalPages = 1

local nav = Instance.new("Frame")
nav.Size = UDim2.new(1,0,0,50)
nav.Position = UDim2.new(0,0,1,-50)
nav.BackgroundColor3 = Color3.fromRGB(53,53,53)
nav.Parent = main

local prev = Instance.new("TextButton")
prev.Size = UDim2.new(0.2,0,1,0)
prev.Text = "<"
prev.Font = Enum.Font.SourceSansBold
prev.TextSize = 24
prev.TextColor3 = Color3.new(1,1,1)
prev.BackgroundColor3 = Color3.fromRGB(128,0,128)
prev.Parent = nav

local counter = Instance.new("TextLabel")
counter.Size = UDim2.new(0.6,0,1,0)
counter.Position = UDim2.new(0.2,0,0,0)
counter.BackgroundTransparency = 1
counter.TextColor3 = Color3.new(1,1,1)
counter.Font = Enum.Font.SourceSans
counter.TextSize = 22
counter.Parent = nav

local nextb = prev:Clone()
nextb.Position = UDim2.new(0.8,0,0,0)
nextb.Text = ">"
nextb.Parent = nav

local function updatePages()
    for i, pageFrame in ipairs(pages) do
        pageFrame.Visible = (i == page)
    end
    counter.Text = "Page "..page.." of "..totalPages
end

prev.MouseButton1Click:Connect(function()
    if page > 1 then page = page - 1 updatePages() end
end)

nextb.MouseButton1Click:Connect(function()
    if page < totalPages then page = page + 1 updatePages() end
end)

updatePages()

-- GLOBAL LEVEL UI (Visible on all pages, BELOW NAVIGATION)
local levelButton = Instance.new("TextButton")
levelButton.Size = UDim2.new(1,-20,0,35)
levelButton.Position = UDim2.new(0,10,1,-85)  -- Positioned just above the bottom (nav height + padding)
levelButton.Text = "Level: "..GLOBAL_LEVEL
levelButton.TextColor3 = Color3.new(1,1,1)
levelButton.BackgroundColor3 = Color3.fromRGB(80,80,80)
levelButton.Font = Enum.Font.SourceSansBold
levelButton.TextSize = 16
levelButton.Parent = main

local levelBox = Instance.new("TextBox")
levelBox.Size = UDim2.new(1,-20,0,35)
levelBox.Position = UDim2.new(0,10,1,-45)  -- Right above the level button when it opens
levelBox.PlaceholderText = "Enter level (1-5)"
levelBox.Visible = false
levelBox.TextColor3 = Color3.new(0,0,0)
levelBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
levelBox.Font = Enum.Font.SourceSans
levelBox.TextSize = 16
levelBox.Parent = main

levelButton.MouseButton1Click:Connect(function()
    levelBox.Visible = not levelBox.Visible
end)

levelBox.FocusLost:Connect(function()
    local n = tonumber(levelBox.Text)
    if n and n >= 1 and n <= 5 then
        GLOBAL_LEVEL = n  -- Set GLOBAL_LEVEL to the entered value
        levelButton.Text = "Level: "..GLOBAL_LEVEL
        levelBox.Visible = false
    else
        levelBox.Text = ""
        levelBox.PlaceholderText = "Invalid!"
    end
end)

-- SPAWN FUNCTION (LEVEL VIA + IN NAME)
local function spawnTowerAtPlayer(baseName)
    if not player.Character then return end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local cf = hrp.CFrame * CFrame.new(0,0,-6)

    -- Use GLOBAL_LEVEL to determine the number of + symbols
    local lvl = GLOBAL_LEVEL  -- Set level based on the GLOBAL_LEVEL value
    local finalName = baseName .. string.rep("+", lvl - 1)  -- Append the appropriate number of "+" for the level

    placeTower:InvokeServer(finalName, cf)
end

-- Grab tower names from the folder
local towersFolder = ReplicatedStorage:WaitForChild("Towers")
local towers = {}

for _, tower in pairs(towersFolder:GetChildren()) do
    if not string.find(tower.Name, "+") then
        table.insert(towers, tower.Name)
    end
end

-- Create search bar (above the page navigation)
local searchBar = Instance.new("TextBox")
searchBar.Size = UDim2.new(1,-20,0,35)
searchBar.Position = UDim2.new(0,10,0,contentY - 90)  -- Adjust the vertical offset here
searchBar.PlaceholderText = "Search Towers..."
searchBar.TextColor3 = Color3.new(1,1,1)
searchBar.BackgroundColor3 = Color3.fromRGB(80,80,80)
searchBar.Font = Enum.Font.SourceSans
searchBar.TextSize = 16
searchBar.Parent = main

-- Function to update tower buttons
local function updateTowerButtons(filteredTowers)
    if not filteredTowers then
        filteredTowers = {}
    end

    for _, pageFrame in ipairs(pages) do
        for _, child in ipairs(pageFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
    end

    totalPages = math.ceil(#filteredTowers / 6)

    for pageIndex = 1, totalPages do
        if pageIndex > #pages then
            local newPage = page1:Clone()
            newPage.Visible = false
            newPage.Parent = main
            table.insert(pages, newPage)
        end

        local currentPageFrame = pages[pageIndex]
        local pageStart = (pageIndex - 1) * 6 + 1
        local pageEnd = math.min(pageStart + 5, #filteredTowers)

        local buttonY = 90
        for i = pageStart, pageEnd do
            local name = filteredTowers[i]

            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1,-20,0,40)
            b.Position = UDim2.new(0,10,0,buttonY)
            b.Text = name
            b.TextColor3 = Color3.new(1,1,1)
            b.BackgroundColor3 = Color3.fromRGB(53,53,53)
            b.Font = Enum.Font.SourceSans
            b.TextSize = 16
            b.Parent = currentPageFrame

            b.MouseButton1Click:Connect(function()
                spawnTowerAtPlayer(name)
            end)

            buttonY = buttonY + 50
        end
    end

    updatePages()
end

updateTowerButtons(towers)

searchBar:GetPropertyChangedSignal("Text"):Connect(function()
    local searchText = searchBar.Text:lower()
    local filteredTowers = {}

    for _, name in ipairs(towers) do
        if name:lower():find(searchText) then
            table.insert(filteredTowers, name)
        end
    end

    updateTowerButtons(filteredTowers)
end)

-- DRAGGING
local dragging = false
local dragStart
local startPos

main.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = i.Position
        startPos = main.Position
    end
end)

main.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = i.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

print("Never streSS your script has loaded!! TOTAL NIGGER DEATH WILL NOW OCCUR卐卐卐卐")
