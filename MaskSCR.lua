-- Volleyball Legends — Ball Hitbox Expander v1.5 (Fixed Debug)
-- ════════════════════════════════════════════════════
 
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
 
local Config = {
    HitboxExpand = true,
    HitboxSize = 12,
    HitboxTransparency = 0.7,
    Debug = true,
}
 
local OriginalBallSize = nil
local CurrentBall = nil
local isDraggingSlider = false
 
-- ═══ FIND THE BALL (improved) ═══
local function FindBall()
    -- Strategy 1: Exact name "Ball" (most volleyball games)
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name == "Ball" then
            if v.Size.Magnitude > 1 and v.Size.Magnitude < 50 then
                return v
            end
        end
    end
    -- Strategy 2: Name contains "ball" but NOT "shadow" or "indicator"
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local name = v.Name:lower()
            if name:find("ball") and not name:find("shadow") and not name:find("indicator") then
                if v.Size.Magnitude > 1 and v.Size.Magnitude < 50 then
                    return v
                end
            end
        end
    end
    -- Strategy 3: Sphere shape
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Shape == Enum.PartType.Ball then
            if v.Size.Magnitude > 1 and v.Size.Magnitude < 30 then
                return v
            end
        end
    end
    -- Strategy 4: Moving fast (velocity)
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Size.Magnitude > 1 and v.Size.Magnitude < 10 then
            local vel = v.AssemblyLinearVelocity or Vector3.new(0, 0, 0)
            if vel.Magnitude > 5 then
                return v
            end
        end
    end
    return nil
end
 
-- ═══ EXPAND BALL ═══
local function ExpandBall(ball)
    if not ball then return end
    if not OriginalBallSize then
        OriginalBallSize = ball.Size
    end
    local expandFactor = Config.HitboxSize / math.max(OriginalBallSize.Magnitude, 1)
    local newSize = OriginalBallSize * expandFactor
    newSize = Vector3.new(math.clamp(newSize.X, 1, 50), math.clamp(newSize.Y, 1, 50), math.clamp(newSize.Z, 1, 50))
    ball.Size = newSize
    ball.Transparency = Config.HitboxTransparency
    ball.Material = Enum.Material.ForceField
    ball.Color = Color3.fromRGB(0, 200, 255)
end
 
local function RestoreBall(ball)
    if ball and OriginalBallSize then
        ball.Size = OriginalBallSize
        ball.Transparency = 0
        ball.Material = Enum.Material.Plastic
        OriginalBallSize = nil
    end
end
 
-- ═══ UI — FULL SCREEN DEBUG ═══
local SG = Instance.new("ScreenGui")
SG.Name = "VBHelper"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.Parent = LocalPlayer:WaitForChild("PlayerGui")
 
-- Main panel
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 380, 0, 280)
Main.Position = UDim2.new(0, 20, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.ZIndex = 10
Main.Parent = SG
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", Main)
stroke.Color = Color3.fromRGB(0, 180, 255)
stroke.Thickness = 2
 
-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 40)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "Volleyball Helper"
Title.TextColor3 = Color3.fromRGB(220, 240, 255)
Title.TextSize = 24
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 11
Title.Parent = Main
 
-- Content
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -24, 0, 160)
Content.Position = UDim2.new(0, 12, 0, 48)
Content.BackgroundTransparency = 1
Content.ZIndex = 11
Content.Parent = Main
local layout = Instance.new("UIListLayout", Content)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 8)
 
-- ═══ TOGGLE ═══
local function MakeToggle(label, default, order, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 36)
    Row.BackgroundTransparency = 1
    Row.LayoutOrder = order
    Row.ZIndex = 12
    Row.Parent = Content
 
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(0.6, 0, 1, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = label
    Lbl.TextColor3 = Color3.fromRGB(200, 200, 220)
    Lbl.TextSize = 18
    Lbl.Font = Enum.Font.GothamBold
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.ZIndex = 13
    Lbl.Parent = Row
 
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 70, 0, 30)
    Btn.Position = UDim2.new(1, -75, 0.5, -15)
    Btn.BorderSizePixel = 0
    Btn.Text = default and "ON" or "OFF"
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 16
    Btn.Font = Enum.Font.GothamBold
    Btn.ZIndex = 13
    Btn.Parent = Row
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
 
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
    Row.Size = UDim2.new(1, 0, 0, 50)
    Row.BackgroundTransparency = 1
    Row.LayoutOrder = order
    Row.ZIndex = 12
    Row.Parent = Content
 
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(0.55, 0, 0, 20)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = label
    Lbl.TextColor3 = Color3.fromRGB(200, 200, 220)
    Lbl.TextSize = 16
    Lbl.Font = Enum.Font.GothamBold
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.ZIndex = 13
    Lbl.Parent = Row
 
    local Val = Instance.new("TextLabel")
    Val.Size = UDim2.new(0.45, 0, 0, 20)
    Val.BackgroundTransparency = 1
    Val.Text = string.format("%.2f", default)
    Val.TextColor3 = Color3.fromRGB(0, 200, 255)
    Val.TextSize = 16
    Val.Font = Enum.Font.GothamBold
    Val.TextXAlignment = Enum.TextXAlignment.Right
    Val.ZIndex = 13
    Val.Parent = Row
 
    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, 0, 0, 8)
    Track.Position = UDim2.new(0, 0, 0, 26)
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
    Knob.Size = UDim2.new(0, 20, 0, 20)
    Knob.Position = UDim2.new((default - min) / (max - min), -10, 0.5, -10)
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
        Knob.Position = UDim2.new(x, -10, 0.5, -10)
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
    if not v and CurrentBall then RestoreBall(CurrentBall) end
end)
 
MakeSlider("Hitbox Size", 3, 30, Config.HitboxSize, 2, function(v)
    Config.HitboxSize = v
end)
 
MakeSlider("Transparency", 0, 1, Config.HitboxTransparency, 3, function(v)
    Config.HitboxTransparency = v
    if CurrentBall and Config.HitboxExpand then CurrentBall.Transparency = v end
end)
 
MakeToggle("Debug", true, 4, function(v) Config.Debug = v end)
 
-- ═══ STATUS — BIG READABLE TEXT ═══
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 30)
Status.Position = UDim2.new(0, 10, 1, -35)
Status.BackgroundTransparency = 1
Status.Text = "Searching for ball..."
Status.TextColor3 = Color3.fromRGB(255, 220, 100)
Status.TextSize = 16
Status.Font = Enum.Font.GothamBold
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.ZIndex = 11
Status.Parent = Main
 
-- ═══ HUGE DEBUG PANEL ═══
local DebugPanel = Instance.new("Frame")
DebugPanel.Size = UDim2.new(0, 380, 0, 200)
DebugPanel.Position = UDim2.new(0, 20, 0.3, 290)
DebugPanel.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
DebugPanel.BorderSizePixel = 0
DebugPanel.ZIndex = 10
DebugPanel.Parent = SG
Instance.new("UICorner", DebugPanel).CornerRadius = UDim.new(0, 12)
local dbgStroke = Instance.new("UIStroke", DebugPanel)
dbgStroke.Color = Color3.fromRGB(0, 255, 180)
dbgStroke.Thickness = 2
 
local DebugTitle = Instance.new("TextLabel")
DebugTitle.Size = UDim2.new(1, -16, 0, 30)
DebugTitle.Position = UDim2.new(0, 8, 0, 4)
DebugTitle.BackgroundTransparency = 1
DebugTitle.Text = "DEBUG INFO"
DebugTitle.TextColor3 = Color3.fromRGB(0, 255, 180)
DebugTitle.TextSize = 20
DebugTitle.Font = Enum.Font.GothamBold
DebugTitle.TextXAlignment = Enum.TextXAlignment.Left
DebugTitle.ZIndex = 11
DebugTitle.Parent = DebugPanel
 
local DebugLabel = Instance.new("TextLabel")
DebugLabel.Size = UDim2.new(1, -16, 1, -40)
DebugLabel.Position = UDim2.new(0, 8, 0, 36)
DebugLabel.BackgroundTransparency = 1
DebugLabel.Text = "Loading..."
DebugLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
DebugLabel.TextSize = 16
DebugLabel.Font = Enum.Font.Code
DebugLabel.TextXAlignment = Enum.TextXAlignment.Left
DebugLabel.TextYAlignment = Enum.TextYAlignment.Top
DebugLabel.TextWrapped = true
DebugLabel.ZIndex = 11
DebugLabel.Parent = DebugPanel
 
-- ═══ DEBUG FUNCTION ═══
local function GetDebugInfo()
    if not Config.Debug then
        DebugPanel.Visible = false
        return
    end
    DebugPanel.Visible = true
 
    local lines = {}
 
    -- Ball info
    if CurrentBall and CurrentBall.Parent then
        local origStr = OriginalBallSize and tostring(OriginalBallSize) or "unknown"
        table.insert(lines, "BALL: " .. CurrentBall.Name)
        table.insert(lines, "  Size now: " .. tostring(CurrentBall.Size))
        table.insert(lines, "  Orig size: " .. origStr)
        table.insert(lines, "  Transparency: " .. tostring(CurrentBall.Transparency))
        table.insert(lines, "  Position: " .. tostring(math.floor(CurrentBall.Position.X)) .. "," .. tostring(math.floor(CurrentBall.Position.Y)) .. "," .. tostring(math.floor(CurrentBall.Position.Z)))
    else
        table.insert(lines, "BALL: NOT FOUND")
    end
 
    table.insert(lines, "")
    table.insert(lines, "--- PARTS IN WORKSPACE ---")
 
    local count = 0
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Size.Magnitude > 0.5 and v.Size.Magnitude < 50 then
            count = count + 1
            if count <= 5 then
                table.insert(lines, v.Name .. " [" .. tostring(math.floor(v.Size.Magnitude)) .. "]")
            end
        end
    end
    table.insert(lines, "Total parts: " .. tostring(count))
 
    DebugLabel.Text = table.concat(lines, "\n")
end
 
-- ═══ MAIN LOOP ═══
RunService.Heartbeat:Connect(function()
    if not CurrentBall or not CurrentBall.Parent then
        CurrentBall = FindBall()
        OriginalBallSize = nil
        if CurrentBall then
            OriginalBallSize = CurrentBall.Size
            Status.Text = "BALL FOUND: " .. CurrentBall.Name
            Status.TextColor3 = Color3.fromRGB(100, 255, 150)
        else
            Status.Text = "Searching for ball..."
            Status.TextColor3 = Color3.fromRGB(255, 220, 100)
        end
    end
 
    if Config.HitboxExpand and CurrentBall and CurrentBall.Parent then
        ExpandBall(CurrentBall)
        Status.Text = "BALL: " .. CurrentBall.Name .. " | SIZE: " .. tostring(math.floor(CurrentBall.Size.Magnitude))
    end
 
    GetDebugInfo()
end)
 
workspace.DescendantRemoving:Connect(function(v)
    if v == CurrentBall then
        CurrentBall = nil
        OriginalBallSize = nil
    end
end)
 
print("[Volleyball Helper] v1.5 loaded")
