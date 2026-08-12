-- Volleyball Legends — Ball Hitbox Expander v1.3 (Actually Works)
-- ════════════════════════════════════════════════════
 
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
 
local Config = {
    HitboxExpand = true,
    HitboxSize = 12,
    HitboxTransparency = 0.7,
    Debug = true,  -- shows what the script finds
}
 
local OriginalBallSize = nil
local CurrentBall = nil
local isDraggingSlider = false
 
-- ═══ FIND THE BALL (multiple strategies) ═══
local function FindBall()
    -- Strategy 1: Search by name
    local nameKeywords = {"ball", "volleyball", "gameball", "matchball", "volley"}
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local name = v.Name:lower()
            for _, kw in pairs(nameKeywords) do
                if name == kw or name:find(kw) then
                    if v.Size.Magnitude > 1 and v.Size.Magnitude < 30 then
                        return v
                    end
                end
            end
        end
    end
 
    -- Strategy 2: Find sphere-shaped parts (volleyballs are spheres)
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Shape == Enum.PartType.Ball then
            if v.Size.Magnitude > 1 and v.Size.Magnitude < 30 then
                return v
            end
        end
    end
 
    -- Strategy 3: Find any small part that moves frequently (velocity check)
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Size.Magnitude > 1 and v.Size.Magnitude < 10 then
            local vel = v.Velocity or Vector3.new(0, 0, 0)
            if vel.Magnitude > 5 then  -- moving fast = likely ball
                return v
            end
        end
    end
 
    -- Strategy 4: Check common folder names
    local folderNames = {"Balls", "Game", "Match", "Court", "BallFolder", "Ball", 
                         "Effects", "Assets", "ReplicatedStorage"}
    for _, folderName in pairs(folderNames) do
        local folder = workspace:FindFirstChild(folderName, true)
        if folder then
            for _, v in pairs(folder:GetDescendants()) do
                if v:IsA("BasePart") and v.Size.Magnitude > 1 and v.Size.Magnitude < 20 then
                    return v
                end
            end
        end
    end
 
    return nil
end
 
-- ═══ EXPAND THE BALL DIRECTLY ═══
local function ExpandBall(ball)
    if not ball then return end
    
    -- Store original size so we can restore it
    if not OriginalBallSize then
        OriginalBallSize = ball.Size
    end
    
    -- Directly resize the ball — this actually affects hitbox
    local expandFactor = Config.HitboxSize / math.max(OriginalBallSize.Magnitude, 1)
    local newSize = OriginalBallSize * expandFactor
    
    -- Cap it so it doesn't get insanely huge
    newSize = Vector3.new(
        math.clamp(newSize.X, 1, 50),
        math.clamp(newSize.Y, 1, 50),
        math.clamp(newSize.Z, 1, 50)
    )
    
    ball.Size = newSize
    ball.Transparency = Config.HitboxTransparency
    ball.Material = Enum.Material.ForceField
    ball.Color = Color3.fromRGB(0, 200, 255)
end
 
-- ═══ RESTORE BALL ═══
local function RestoreBall(ball)
    if ball and OriginalBallSize then
        ball.Size = OriginalBallSize
        ball.Transparency = 0
        ball.Material = Enum.Material.Plastic
        OriginalBallSize = nil
    end
end
 
-- ═══ UI ═══
local SG = Instance.new("ScreenGui")
SG.Name = "VBHelper"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.Parent = LocalPlayer:WaitForChild("PlayerGui")
 
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 230, 0, 220)
Main.Position = UDim2.new(0, 15, 0.5, -110)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.ZIndex = 10
Main.Parent = SG
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", Main)
stroke.Color = Color3.fromRGB(0, 180, 255)
stroke.Thickness = 1.5
 
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -10, 0, 28)
Title.Position = UDim2.new(0, 10, 0, 2)
Title.BackgroundTransparency = 1
Title.Text = "Volleyball Helper"
Title.TextColor3 = Color3.fromRGB(220, 240, 255)
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 11
Title.Parent = Main
 
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -16, 1, -38)
Content.Position = UDim2.new(0, 8, 0, 34)
Content.BackgroundTransparency = 1
Content.ZIndex = 11
Content.Parent = Main
local layout = Instance.new("UIListLayout", Content)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 6)
 
-- ═══ TOGGLE ═══
local function MakeToggle(label, default, order, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 28)
    Row.BackgroundTransparency = 1
    Row.LayoutOrder = order
    Row.ZIndex = 12
    Row.Parent = Content
 
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(0.6, 0, 1, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = label
    Lbl.TextColor3 = Color3.fromRGB(180, 180, 200)
    Lbl.TextSize = 11
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.ZIndex = 13
    Lbl.Parent = Row
 
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 50, 0, 22)
    Btn.Position = UDim2.new(1, -55, 0.5, -11)
    Btn.BorderSizePixel = 0
    Btn.Text = default and "ON" or "OFF"
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 10
    Btn.Font = Enum.Font.GothamBold
    Btn.ZIndex = 13
    Btn.Parent = Row
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
 
    local state = default
    local function UpdateVisual()
        Btn.BackgroundColor3 = state and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(80, 80, 90)
    end
    UpdateVisual()
 
    Btn.MouseButton1Click:Connect(function()
        state = not state
        UpdateVisual()
        Btn.Text = state and "ON" or "OFF"
        callback(state)
    end)
end
 
-- ═══ SLIDER ═══
local function MakeSlider(label, min, max, default, order, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 38)
    Row.BackgroundTransparency = 1
    Row.LayoutOrder = order
    Row.ZIndex = 12
    Row.Parent = Content
 
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(0.55, 0, 0, 14)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = label
    Lbl.TextColor3 = Color3.fromRGB(180, 180, 200)
    Lbl.TextSize = 11
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.ZIndex = 13
    Lbl.Parent = Row
 
    local Val = Instance.new("TextLabel")
    Val.Size = UDim2.new(0.45, 0, 0, 14)
    Val.BackgroundTransparency = 1
    Val.Text = string.format("%.2f", default)
    Val.TextColor3 = Color3.fromRGB(0, 200, 255)
    Val.TextSize = 11
    Val.Font = Enum.Font.GothamBold
    Val.TextXAlignment = Enum.TextXAlignment.Right
    Val.ZIndex = 13
    Val.Parent = Row
 
    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, 0, 0, 5)
    Track.Position = UDim2.new(0, 0, 0, 22)
    Track.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    Track.BorderSizePixel = 0
    Track.ZIndex = 13
    Track.Active = true
    Track.Parent = Row
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)
 
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    Fill.BorderSizePixel = 0
    Fill.ZIndex = 14
    Fill.Parent = Track
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
 
    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.ZIndex = 15
    Knob.Active = true
    Knob.Parent = Track
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
 
    local dragging = false
 
    local function UpdateSlider(inputX)
        local absPos = Track.AbsolutePosition.X
        local absSize = Track.AbsoluteSize.X
        local x = math.clamp((inputX - absPos) / absSize, 0, 1)
        local val = min + x * (max - min)
        val = math.floor(val * 100) / 100
        Fill.Size = UDim2.new(x, 0, 1, 0)
        Knob.Position = UDim2.new(x, -8, 0.5, -8)
        Val.Text = string.format("%.2f", val)
        callback(val)
    end
 
    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            isDraggingSlider = true
            UpdateSlider(input.Position.X)
        end
    end)
    Knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            isDraggingSlider = true
        end
    end)
    Knob.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            isDraggingSlider = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then dragging = false isDraggingSlider = false end
        end
    end)
 
    callback(default)
end
 
-- ═══ BUILD UI ═══
MakeToggle("Ball Hitbox", true, 1, function(v)
    Config.HitboxExpand = v
    if not v and CurrentBall then
        RestoreBall(CurrentBall)
    end
end)
 
MakeSlider("Hitbox Size", 3, 30, Config.HitboxSize, 2, function(v)
    Config.HitboxSize = v
end)
 
MakeSlider("Transparency", 0, 1, Config.HitboxTransparency, 3, function(v)
    Config.HitboxTransparency = v
    if CurrentBall and Config.HitboxExpand then
        CurrentBall.Transparency = v
    end
end)
 
MakeToggle("Debug Mode", true, 4, function(v)
    Config.Debug = v
end)
 
-- ═══ STATUS ═══
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 16)
Status.BackgroundTransparency = 1
Status.Text = "Searching for ball..."
Status.TextColor3 = Color3.fromRGB(255, 220, 100)
Status.TextSize = 10
Status.Font = Enum.Font.Gotham
Status.ZIndex = 11
Status.Parent = Main
 
-- ═══ DEBUG PANEL ═══
local Debug = Instance.new("TextLabel")
Debug.Size = UDim2.new(1, 0, 0, 50)
Debug.Position = UDim2.new(0, 0, 1, -55)
Debug.BackgroundTransparency = 1
Debug.Text = ""
Debug.TextColor3 = Color3.fromRGB(150, 150, 180)
Debug.TextSize = 9
Debug.Font = Enum.Font.Code
Debug.TextXAlignment = Enum.TextXAlignment.Left
Debug.TextYAlignment = Enum.TextYAlignment.Top
Debug.TextWrapped = true
Debug.ZIndex = 11
Debug.Parent = Main
 
-- ═══ DEBUG: LIST ALL PARTS ═══
local function GetDebugInfo()
    if not Config.Debug then
        Debug.Text = ""
        return
    end
    
    local parts = {}
    local count = 0
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Size.Magnitude > 1 and v.Size.Magnitude < 30 then
            count = count + 1
            if count <= 8 then
                table.insert(parts, string.format("%s [%s] %s",
                    v.Name,
                    v.Shape == Enum.PartType.Ball and "BALL" or "part",
                    tostring(math.floor(v.Size.Magnitude))
                ))
            end
        end
    end
    
    Debug.Text = string.format("Parts found: %d\n%s%s",
        count,
        CurrentBall and ("Ball: " .. CurrentBall.Name .. " (" .. tostring(CurrentBall.Size) .. ")") or "No ball found",
        #parts > 0 and ("\n---\n" .. table.concat(parts, "\n")) or ""
    )
end
 
-- ═══ MAIN LOOP ═══
RunService.Heartbeat:Connect(function()
    -- Find ball if we don't have one
    if not CurrentBall or not CurrentBall.Parent then
        CurrentBall = FindBall()
        OriginalBallSize = nil  -- reset so we capture new original size
        
        if CurrentBall then
            -- Store original size BEFORE expanding
            OriginalBallSize = CurrentBall.Size
            Status.Text = "Ball found: " .. CurrentBall.Name
            Status.TextColor3 = Color3.fromRGB(100, 255, 150)
        else
            Status.Text = "Searching for ball..."
            Status.TextColor3 = Color3.fromRGB(255, 220, 100)
        end
    end
 
    -- Expand ball if enabled
    if Config.HitboxExpand and CurrentBall and CurrentBall.Parent then
        ExpandBall(CurrentBall)
        Status.Text = "Ball: " .. CurrentBall.Name .. " | Size: " .. tostring(math.floor(CurrentBall.Size.Magnitude))
    end
 
    -- Update debug
    GetDebugInfo()
end)
 
-- ═══ CLEANUP ON ROUND END ═══
workspace.DescendantRemoving:Connect(function(v)
    if v == CurrentBall then
        CurrentBall = nil
        OriginalBallSize = nil
    end
end)
 
print("[Volleyball Helper] v1.3 loaded — DEBUG MODE ON")
print("[Volleyball Helper] Look at the debug panel to see what parts exist in workspace")
