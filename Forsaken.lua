-- โหลด UI Library
local XDLuaUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/XDLua/XDLuaUI/refs/heads/main/XDLuaUI.lua"))()

-- สร้างหน้าต่าง
local window = XDLuaUI:CreateWindow("🔹 FORSAKEN 🔹")

-- เพิ่มแท็บ
local homeTab = window:AddTab("🏠 หน้าหลัก")
local espTab = window:AddTab("👁️ บอกตำแหน่ง")
local playerTab = window:AddTab("🧑‍💻 ผู้เล่น")
local aimTab = window:AddTab("🔒 ล็อคเป้า")
local repairTab = window:AddTab("🔧 ซ่อม")
local emoteTab = window:AddTab("🕺 พิเศษ")

window:AddTabDescription(homeTab, "🏠 หน้าหลัก")
window:AddTabDescription(espTab, "ฟังก์ชั่นบอกตำแหน่งต่างๆ")
window:AddTabDescription(playerTab, "ฟังก์ชั่นเกี่ยวกับผู้เล่น")
window:AddTabDescription(aimTab, "ฟังก์ชั่นเกี่ยวกับล็อคเป้า")
window:AddTabDescription(repairTab, "ฟังก์ชั่นเกี่ยวกับการซ่อม")
window:AddTabDescription(emoteTab, "ฟังก์ชั่นเกี่ยวกับท่าเต้น")


-- เพิ่มคำอธิบายและเครดิต
window:AddDescription(homeTab, "ยินดีต้อนรับสู่ สคริปต์ของผม\nสคริปต์นี้คือสคริปต์แมพ FORSAKEN", "พัฒนาโดย: IronFang\nเวอร์ชัน: 1.0.0 (ทดสอบ)")

-- เพิ่มปุ่มคัดลอกลิงค์ YouTube
window:Youtube(homeTab, "https://www.youtube.com/@IronFang2008")

-- เพิ่มปุ่มคัดลอกลิงค์ดิสคอร์ด
window:Discord(homeTab)

-- ประกาศตัวแปร
local player = game.Players.LocalPlayer
local isHighlightActive = false
local isSurvivorHighlightActive = false
local isKillerHighlightActive = false
local run = false
local delay = 1.7
local chanceaim = false
local chanceaimbotLoop
local connections = {}

-- ฟอนต์
local font = Enum.Font.GothamBlack

-- ฟังก์ชันคำนวณระยะห่าง (แปลงเป็นเมตร)
local function calculateDistance(position1, position2)
    return math.floor((position1 - position2).Magnitude / 3.5714285714)
end

-- ฟังก์ชันสร้างข้อความสวยๆ
local function createStyledTextLabel(parent, text, color, size, position)
    local textLabel = Instance.new("TextLabel", parent)
    textLabel.Size = UDim2.new(1, 0, 0.5, 0)
    textLabel.Position = position
    textLabel.Text = text
    textLabel.TextColor3 = color
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Font = font
    textLabel.TextSize = size
    textLabel.TextWrapped = true
    return textLabel
end

-- ฟังก์ชันไฮไลท์เครื่องปั่นไฟ
local function toggleHighlightGen(state)
    isHighlightActive = state 
    
    local function applyGeneratorHighlight(generator)
        if generator.Name == "Generator" then
            local existingHighlight = generator:FindFirstChild("GeneratorHighlight")
            local progress = generator:FindFirstChild("Progress")
            
            if isHighlightActive then
                if not existingHighlight then
                    local genhighlight = Instance.new("Highlight")
                    genhighlight.Parent = generator
                    genhighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    genhighlight.Name = "GeneratorHighlight"
                    
                    -- เพิ่ม BillboardGui เพื่อแสดงข้อความและระยะห่าง
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "DistanceBillboard"
                    billboard.Size = UDim2.new(0, 150, 0, 40)
                    billboard.StudsOffset = Vector3.new(0, 2, 0)
                    billboard.AlwaysOnTop = true
                    billboard.Parent = generator
                    
                    -- สร้างข้อความชื่อและระยะห่าง
                    local nameLabel = createStyledTextLabel(billboard, "เครื่องปั่นไฟ", Color3.new(1, 1, 1), 16, UDim2.new(0, 0, 0, 0))
                    local distanceLabel = createStyledTextLabel(billboard, "[กำลังคำนวณ...]", Color3.new(1, 1, 1), 12, UDim2.new(0, 0, 0.5, 0))
                    
                    -- อัพเดทข้อความและสีทุกๆ 0.1 วินาที
                    spawn(function()
                        while genhighlight.Parent do
                            task.wait(0.1)
                            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and generator:FindFirstChild("Main") then
                                local distance = calculateDistance(player.Character.HumanoidRootPart.Position, generator.Main.Position)
                                if progress and progress.Value < 100 then
                                    genhighlight.FillColor = Color3.fromRGB(255, 255, 0)
                                    distanceLabel.Text = "[" .. distance .. " เมตร]"
                                    distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                                else
                                    genhighlight.FillColor = Color3.fromRGB(0, 255, 0)
                                    distanceLabel.Text = "[ซ่อมแล้ว]"
                                    distanceLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                                end
                            end
                        end
                    end)
                end
            else
                if existingHighlight then
                    existingHighlight:Destroy()
                end
                return
            end

            if progress then
                if progress.Value == 100 then
                    local highlight = generator:FindFirstChild("GeneratorHighlight")
                    if highlight then
                        highlight:Destroy()
                    end
                    return
                end

                progress:GetPropertyChangedSignal("Value"):Connect(function()
                    if progress.Value == 100 then
                        local highlight = generator:FindFirstChild("GeneratorHighlight")
                        if highlight then
                            highlight:Destroy()
                        end
                    elseif isHighlightActive and not generator:FindFirstChild("GeneratorHighlight") then
                        local genhighlight = Instance.new("Highlight")
                        genhighlight.Parent = generator
                        genhighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        genhighlight.Name = "GeneratorHighlight"
                    end
                end)
            end
        end
    end

    -- ตรวจจับเมื่อเครื่องปั่นไฟถูกสร้างใหม่
    for _, v in pairs(game.Workspace.Map.Ingame.Map:GetChildren()) do
        applyGeneratorHighlight(v)
    end

    game.Workspace.Map.Ingame.Map.ChildAdded:Connect(function(child)
        applyGeneratorHighlight(child)
    end)
end

-- ฟังก์ชันไฮไลท์ผู้รอดชีวิต
local function survivorHighlighter(state)
    isSurvivorHighlightActive = state

    local function applySurvivorHighlight(model)
        if model:IsA("Model") and model:FindFirstChild("Head") and model ~= player.Character then
            local existingBillboard = model.Head:FindFirstChild("billboard")
            local existingHighlight = model:FindFirstChild("HiThere")
            
            if isSurvivorHighlightActive then
                if not existingBillboard then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "billboard"
                    billboard.Size = UDim2.new(0, 150, 0, 40)
                    billboard.StudsOffset = Vector3.new(0, 2, 0)
                    billboard.AlwaysOnTop = true
                    billboard.Parent = model.Head
                    
                    -- สร้างข้อความชื่อและระยะห่าง
                    local nameLabel = createStyledTextLabel(billboard, model.Name, Color3.fromRGB(0, 255, 255), 16, UDim2.new(0, 0, 0, 0))
                    local distanceLabel = createStyledTextLabel(billboard, "[กำลังคำนวณ...]", Color3.fromRGB(0, 255, 255), 12, UDim2.new(0, 0, 0.5, 0))
                    
                    -- อัพเดทระยะห่างทุกๆ 0.1 วินาที
                    spawn(function()
                        while billboard.Parent do
                            task.wait(0.1)
                            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                local distance = calculateDistance(player.Character.HumanoidRootPart.Position, model.PrimaryPart.Position)
                                distanceLabel.Text = "[" .. distance .. " เมตร]"
                            end
                        end
                    end)
                end

                if not existingHighlight then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "HiThere"
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.FillColor = Color3.fromRGB(0, 255, 255)
                    highlight.Parent = model
                end
            else
                if existingBillboard then
                    existingBillboard:Destroy()
                end
                if existingHighlight then
                    existingHighlight:Destroy()
                end
            end
        end
    end

    for _, v in pairs(game.Workspace.Players.Survivors:GetChildren()) do
        applySurvivorHighlight(v)
    end

    game.Workspace.Players.Survivors.ChildAdded:Connect(function(child)
        applySurvivorHighlight(child)
    end)
end

-- ฟังก์ชันไฮไลท์ฆาตกร
local function killerHighlighter(state)
    isKillerHighlightActive = state

    local function applyKillerHighlight(model)
        if model:IsA("Model") and model:FindFirstChild("Head") and model ~= player.Character then
            local existingBillboard = model.Head:FindFirstChild("billboard")
            local existingHighlight = model:FindFirstChild("HiThere")
            
            if isKillerHighlightActive then
                if not existingBillboard then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "billboard"
                    billboard.Size = UDim2.new(0, 150, 0, 40)
                    billboard.StudsOffset = Vector3.new(0, 2, 0)
                    billboard.AlwaysOnTop = true
                    billboard.Parent = model.Head
                    
                    -- สร้างข้อความชื่อและระยะห่าง
                    local nameLabel = createStyledTextLabel(billboard, model.Name, Color3.fromRGB(255, 0, 0), 16, UDim2.new(0, 0, 0, 0))
                    local distanceLabel = createStyledTextLabel(billboard, "[กำลังคำนวณ...]", Color3.fromRGB(255, 0, 0), 12, UDim2.new(0, 0, 0.5, 0))
                    
                    -- อัพเดทระยะห่างทุกๆ 0.1 วินาที
                    spawn(function()
                        while billboard.Parent do
                            task.wait(0.1)
                            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                local distance = calculateDistance(player.Character.HumanoidRootPart.Position, model.PrimaryPart.Position)
                                distanceLabel.Text = "[" .. distance .. " เมตร]"
                            end
                        end
                    end)
                end

                if not existingHighlight then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "HiThere"
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.Parent = model
                end
            else
                if existingBillboard then
                    existingBillboard:Destroy()
                end
                if existingHighlight then
                    existingHighlight:Destroy()
                end
            end
        end
    end

    for _, v in pairs(game.Workspace.Players.Killers:GetChildren()) do
        applyKillerHighlight(v)
    end

    game.Workspace.Players.Killers.ChildAdded:Connect(function(child)
        applyKillerHighlight(child)
    end)
end

-- ฟังก์ชันแก้ปริศนาเครื่องปั่นไฟทุกๆ 1.7 วินาที
local function autoSolveGen()
    while run do
        task.wait(delay)
        for _, v in pairs(game.Workspace.Map.Ingame.Map:GetChildren()) do
            if v.Name == "Generator" then
                v:WaitForChild("Remotes"):WaitForChild("RE"):FireServer()
            end
        end
    end
end

-- ฟังก์ชัน Aimbot สำหรับ Chance
local function chanceaimbot(state)
    chanceaim = state
    if game.Players.LocalPlayer.Character.Name ~= "Chance" and state then
        window:Notification("Wrong Character", "Oops, your current character isn't Chance, this POSSIBLY can bug out, so untoggle unless you're on Chance!", 5)
        return 
    end
    if state then
        chanceaimbotLoop = game.Players.LocalPlayer.Character.HumanoidRootPart.ChildAdded:Connect(function(child)
            if not chanceaim then return end
            for _, v in pairs({"rbxassetid://201858045", "rbxassetid://139012439429121"}) do
                if child.Name == v  then
                    local killer = game.Workspace.Players:FindFirstChild("Killers"):FindFirstChildOfClass("Model")
                    if killer and killer:FindFirstChild("HumanoidRootPart") then
                        local killerHRP = killer.HumanoidRootPart
                        local playerHRP = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if playerHRP then
                            local direction = (killerHRP.Position - playerHRP.Position).Unit
                            local num = 1
                            local maxIterations = 100
                        
                            while num <= maxIterations do
                                task.wait(0.01)
                                num = num + 1
                                workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, killerHRP.Position)
                                playerHRP.CFrame = CFrame.lookAt(playerHRP.Position, Vector3.new(killerHRP.Position.X, killerHRP.Position.Y, killerHRP.Position.Z))
                            end
                        end
                    end
                end
            end
        end)
    else
        if chanceaimbotLoop then
            chanceaimbotLoop:Disconnect()
            chanceaimbotLoop = nil
        end
    end
end

-- ฟังก์ชัน Popup 1x1x1x1
local function Do1x1x1x1Popups(state)
    if not state then return end

    while true do
        task.wait(0.05) -- ลดระยะเวลา wait เพื่อให้ทำงานเร็วขึ้น
        local player = game:GetService("Players").LocalPlayer
        local gui = player.PlayerGui:FindFirstChild("TemporaryUI")
        if gui then
            for _, popup in ipairs(gui:GetChildren()) do
                if popup.Name == "1x1x1x1Popup" then
                    local centerX = popup.AbsolutePosition.X + (popup.AbsoluteSize.X / 2)
                    local centerY = popup.AbsolutePosition.Y + (popup.AbsoluteSize.Y / 2)
                    mouse1click(centerX, centerY)
                    popup:Destroy()
                end
            end
        end
    end
end

-- ฟังก์ชันจำลองการคลิกเมาส์
local function mouse1click(x, y)
    local UserInputService = game:GetService("UserInputService")
    UserInputService:SendMouseButtonEvent(x, y, 0, true, game, 1)
    task.wait()
    UserInputService:SendMouseButtonEvent(x, y, 0, false, game, 1)
end

-- ฟังก์ชัน Teleport พิซซ่า
local function teleportPizza(state)
    if not state then
        for _, v in pairs(connections) do
            v:Disconnect()
        end
        table.clear(connections)
        return
    end

    local function tp(child)
        if child:IsA("BasePart") and child.Name == "Pizza" then
            local player = game.Players.LocalPlayer
            if player and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    child.CFrame = hrp.CFrame
                end
            end
        end
    end

    local function watchtower()
        local map = workspace:FindFirstChild("Map")
        local insession = map and map:FindFirstChild("Ingame")

        if insession then
            for _, child in pairs(insession:GetChildren()) do
                tp(child)
            end
            table.insert(connections, insession.ChildAdded:Connect(tp))
        end
    end

    watchtower()
end

-- ฟังก์ชันแก้ปริศนา 1 ครั้ง
local function solveGenOnce()
    for _, v in pairs(game.Workspace.Map.Ingame.Map:GetChildren()) do
        if v.Name == "Generator" then
            local remote = v:FindFirstChild("Remotes")
            if remote then
                local re = remote:FindFirstChild("RE")
                if re then
                    re:FireServer()
                end
            end
        end
    end
end

-- ฟังก์ชันซ่อมทันที
local function instantsolvegen()
    for _, v in pairs(game.Workspace.Map.Ingame.Map:GetChildren()) do
        if v.Name == "Generator" then
            local remote = v:FindFirstChild("Remotes")
            if remote then
                local re = remote:FindFirstChild("RE")
                if re then
                    for i = 1, 4 do
                        re:FireServer()
                        task.wait(0.1) -- เพิ่ม delay เพื่อป้องกันการ spam
                    end
                end
            end
        end
    end
end

-- ฟังก์ชันไฮไลท์เครื่องมือ
local function highlightTools(state)
    local toolHighlightActive = state

    local function applyToolHighlight(tool)
        if toolHighlightActive then
            local existingHighlight = tool:FindFirstChild("ToolHighlight")
            if not existingHighlight then
                local toolhighlight = Instance.new("Highlight")
                toolhighlight.Name = "ToolHighlight"
                toolhighlight.Parent = tool
                toolhighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

                -- กำหนดสีไฮไลท์ตามประเภทเครื่องมือ
                if tool.Name == "Medkit" then
                    toolhighlight.FillColor = Color3.fromRGB(0, 255, 0) -- สีเขียว (กล่องยา)
                elseif tool.Name == "BloxyCola" then
                    toolhighlight.FillColor = Color3.fromRGB(88, 57, 39) -- สีน้ำตาล (กระป๋องน้ำ)
                elseif tool.Name == "Pizza" then
                    toolhighlight.FillColor = Color3.fromRGB(255, 165, 0) -- สีส้ม (พิซซ่า)
                end

                -- เพิ่ม BillboardGui เพื่อแสดงชื่อและระยะห่าง
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "ToolBillboard"
                billboard.Size = UDim2.new(0, 150, 0, 40)
                billboard.StudsOffset = Vector3.new(0, 2, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = tool

                -- สร้างข้อความชื่อและระยะห่าง
                local nameLabel = createStyledTextLabel(billboard, tool.Name, Color3.new(1, 1, 1), 16, UDim2.new(0, 0, 0, 0))
                local distanceLabel = createStyledTextLabel(billboard, "[กำลังคำนวณ...]", Color3.new(1, 1, 1), 12, UDim2.new(0, 0, 0.5, 0))

                -- อัพเดทระยะห่างทุกๆ 0.1 วินาที
                spawn(function()
                    while toolhighlight.Parent do
                        task.wait(0.1)
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local toolPosition = tool:GetPivot().Position -- ใช้ตำแหน่งของไอเทม
                            local distance = calculateDistance(player.Character.HumanoidRootPart.Position, toolPosition)
                            distanceLabel.Text = "[" .. distance .. " เมตร]"
                        end
                    end
                end)
            end
        else
            local existingHighlight = tool:FindFirstChild("ToolHighlight")
            if existingHighlight then
                existingHighlight:Destroy()
            end
        end
    end

    for _, v in pairs(game.Workspace.Map.Ingame:GetChildren()) do
        if v:IsA("Tool") then
            applyToolHighlight(v)
        end
    end

    game.Workspace.Map.Ingame.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            applyToolHighlight(child)
        end
    end)
end

-- เชื่อมต่อกับเหตุการณ์เมื่อเริ่มรอบใหม่
local function onRoundStart()
    toggleHighlightGen(isHighlightActive)
    survivorHighlighter(isSurvivorHighlightActive)
    killerHighlighter(isKillerHighlightActive)
    run = true
    autoSolveGen()
    chanceaimbot(chanceaim)
end

-- ตรวจจับเมื่อเริ่มรอบใหม่
game:GetService("Players").LocalPlayer.CharacterAdded:Connect(onRoundStart)

-- แท็บ ESP
window:AddToggle(espTab, "ตำแหน่งฆาตกร", false, function(state)
    killerHighlighter(state)
end)

window:AddToggle(espTab, "ตำแหน่งผู้รอดชีวิต", false, function(state)
    survivorHighlighter(state)
end)

window:AddToggle(espTab, "ตำแหน่งไอเทมในแมพ", false, function(state)
    highlightTools(state)
end)

window:AddToggle(espTab, "ตำแหน่งเครื่องปั่นไฟ\n(ปิดแล้วเปิดอีกเมื่อเริ่มรอบใหม่)", false, function(state)
    toggleHighlightGen(state)
end)

-- แท็บซ่อม
window:AddToggle(repairTab, "ออโต้ซ่อมเครื่องปั่นไฟ\n(ปิดแล้วเปิดอีกเมื่อเริ่มรอบใหม่)", false, function(state)
    run = state
    autoSolveGen(state)
end)
window:AddButton(repairTab, "ซ่อมเครื่องปั่นไฟ1ครั้ง\n(อย่ากดรัวนะ)", false, function()
    solveGenOnce()
end)
window:AddButton(repairTab, "ซ่อมเครื่องปั่นไฟทันที\n(ระวังโดนเตะนะ)", false, function()
    instantsolvegen()
end)

-- แท็บล็อคเป้า
window:AddToggle(aimTab, "ล็อคเป้าตัวละคร Chance\n(ปิดแล้วเปิดอีกเมื่อเริ่มรอบใหม่)", false, function(state)
    chanceaimbot(state)
end)

--แท็บผู้เล่น
window:AddToggle(playerTab, "ปิดpopup1x1x1x1ออโต้", false, function(state)
    Do1x1x1x1Popups(state)
end)
window:AddToggle(playerTab, "วาร์ปพิซซ่ามาหา", false, function(state)
    teleportPizza(state)
end)

-- รันฟังก์ชันทั้งหมดทันทีเมื่อสคริปต์เริ่มทำงาน
onRoundStart()