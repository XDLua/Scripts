local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local isWarping = false
local originalState = {}
local warpSpeed = 10
local isMinimized = false

-- สร้าง GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Name = "WarpGUI"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 200)
Frame.Position = UDim2.new(0.5, -110, 0.5, -100)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Frame

-- ระบบลาก
local dragging, dragInput, dragStart, startPos
Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input == dragInput) then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- หัวข้อ
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 180, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "กลับรถไฟ"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
Title.Parent = Frame

-- ปุ่มย่อ (-)
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 20, 0, 20)
MinimizeButton.Position = UDim2.new(1, -40, 0, 5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.Text = "-"
MinimizeButton.TextSize = 14
MinimizeButton.Font = Enum.Font.SourceSans
MinimizeButton.Parent = Frame

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 5)
MinCorner.Parent = MinimizeButton

-- ปุ่มปิด (X)
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Position = UDim2.new(1, -20, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Text = "X"
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.SourceSans
CloseButton.Parent = Frame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 5)
CloseCorner.Parent = CloseButton

-- แสดงระยะ
local DistanceLabel = Instance.new("TextLabel")
DistanceLabel.Size = UDim2.new(0, 200, 0, 20)
DistanceLabel.Position = UDim2.new(0, 10, 0, 35)
DistanceLabel.BackgroundTransparency = 1
DistanceLabel.Text = "ระยะ: 0 เมตร"
DistanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
DistanceLabel.TextSize = 14
DistanceLabel.Font = Enum.Font.SourceSans
DistanceLabel.Parent = Frame

-- ปุ่มวาร์ป
local WarpButton = Instance.new("TextButton")
WarpButton.Size = UDim2.new(0, 180, 0, 40)
WarpButton.Position = UDim2.new(0.5, -90, 0, 60)
WarpButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
WarpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
WarpButton.Text = "กลับรถไฟ"
WarpButton.TextSize = 16
WarpButton.Font = Enum.Font.SourceSans
WarpButton.Parent = Frame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = WarpButton

-- ปุ่มเลือกความเร็ว
local speeds = {10, 12, 14, 16}
local speedButtons = {}
for i, speed in ipairs(speeds) do
    local SpeedButton = Instance.new("TextButton")
    SpeedButton.Size = UDim2.new(0, 40, 0, 30)
    SpeedButton.Position = UDim2.new(0, 10 + (i-1)*50, 0, 110)
    SpeedButton.BackgroundColor3 = speed == warpSpeed and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(100, 100, 100)
    SpeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedButton.Text = tostring(speed)
    SpeedButton.TextSize = 14
    SpeedButton.Font = Enum.Font.SourceSans
    SpeedButton.Parent = Frame
    
    local SpeedCorner = Instance.new("UICorner")
    SpeedCorner.CornerRadius = UDim.new(0, 6)
    SpeedCorner.Parent = SpeedButton
    
    table.insert(speedButtons, SpeedButton)
    
    SpeedButton.MouseButton1Click:Connect(function()
        warpSpeed = speed
        for _, btn in pairs(speedButtons) do
            btn.BackgroundColor3 = tonumber(btn.Text) == warpSpeed and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(100, 100, 100)
        end
    end)
end

-- ฟังก์ชันตั้งค่า Noclip
local function setNoclip(state)
    for _, part in pairs(Character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = not state
        end
    end
end

-- ฟังก์ชันบันทึกและคืนค่าสถานะ
local function saveOriginalState()
    originalState.WalkSpeed = Humanoid.WalkSpeed
    originalState.JumpPower = Humanoid.JumpPower
end

local function restoreOriginalState()
    Humanoid.WalkSpeed = originalState.WalkSpeed or 16
    Humanoid.JumpPower = originalState.JumpPower or 50
    setNoclip(false)
end

-- ฟังก์ชันลอยไปช้าๆ และปิดเมื่อถึง
local function floatWarp(targetPosition)
    saveOriginalState()
    Humanoid.WalkSpeed = 0
    Humanoid.JumpPower = 0
    setNoclip(true)
    
    local startPosition = HumanoidRootPart.Position
    local distance = (targetPosition - startPosition).Magnitude
    local duration = distance / warpSpeed
    local elapsed = 0
    
    while isWarping and elapsed < duration do
        elapsed = elapsed + task.wait()
        local t = elapsed / duration
        local newPosition = startPosition:Lerp(targetPosition, t)
        HumanoidRootPart.CFrame = CFrame.new(newPosition)
        DistanceLabel.Text = "ระยะ: " .. math.floor((targetPosition - HumanoidRootPart.Position).Magnitude / 3) .. " เมตร"
    end
    
    if isWarping then
        HumanoidRootPart.CFrame = CFrame.new(targetPosition)
        for _ = 1, 5 do -- ยึด 0.5 วินาที
            if not isWarping then break end
            HumanoidRootPart.CFrame = CFrame.new(targetPosition)
            task.wait(0.1)
        end
        isWarping = false
        WarpButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
        restoreOriginalState()
    end
end

-- อัพเดทระยะแบบเรียลไทม์
spawn(function()
    while true do
        if not isWarping then
            local target = workspace:FindFirstChild("Train") and workspace.Train:FindFirstChild("Platform") and workspace.Train.Platform:GetChildren()[4]
            if target then
                DistanceLabel.Text = "ระยะ: " .. math.floor((target.Position - HumanoidRootPart.Position).Magnitude / 3) .. " เมตร"
            else
                DistanceLabel.Text = "ระยะ: ไม่พบเป้าหมาย"
            end
        end
        task.wait(0.5)
    end
end)

-- ฟังก์ชันย่อ/ขยาย
local function updateUIVisibility()
    if isMinimized then
        Frame.Size = UDim2.new(0, 220, 0, 40) -- ขนาดย่อ
        DistanceLabel.Visible = false
        WarpButton.Visible = false
        for _, btn in pairs(speedButtons) do
            btn.Visible = false
        end
    else
        Frame.Size = UDim2.new(0, 220, 0, 200) -- ขนาดเต็ม
        DistanceLabel.Visible = true
        WarpButton.Visible = true
        for _, btn in pairs(speedButtons) do
            btn.Visible = true
        end
    end
end

MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    updateUIVisibility()
end)

-- ฟังก์ชันปิด
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ฟังก์ชันสลับสถานะ
local function toggleWarp()
    isWarping = not isWarping
    WarpButton.BackgroundColor3 = isWarping and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(0, 120, 215)
    
    if isWarping then
        local target = workspace:WaitForChild("Train"):WaitForChild("Platform"):GetChildren()[4]
        if target then
            local targetPosition = target.Position + Vector3.new(0, 3, 0)
            spawn(function()
                floatWarp(targetPosition)
            end)
        else
            warn("Platform[4] not found!")
            isWarping = false
            WarpButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
        end
    else
        restoreOriginalState()
    end
end

-- ผูกปุ่มวาร์ป
WarpButton.MouseButton1Click:Connect(toggleWarp)

-- อัพเดท Character เมื่อเกิดใหม่
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = newCharacter:WaitForChild("Humanoid")
    HumanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
    if not isWarping then
        restoreOriginalState()
    end
end)

-- ตั้งค่าเริ่มต้น
updateUIVisibility()
