-- Volleyball Legends — Ball Hitbox Expander v1.1 (Fixed Slider)
-- ════════════════════════════════════════════════════
 
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
 
local Config = {
    HitboxExpand = true,
    HitboxSize = 12,
    HitboxTransparency = 0.7,
}
 
local ExpanderPart = nil
local CurrentBall = nil
local isDraggingSlider = false  -- FIX: flag to block frame drag while sliding
 
-- ═══ FIND THE BALL ═══
local function FindBall()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local name = v.Name:lower()
            if (name == "ball" or name == "volleyball" or name == "gameball"
                or (name:find("ball") and v.Size.Magnitude < 20 and v.Size.Magnitude > 1)) then
                return v
            end
        end
    end
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Shape == Enum.PartType.Ball
            and v.Size.Magnitude < 15 and v.Size.Magnitude > 1 then
            return v
        end
    end
    return nil
end
 
-- ═══ CREATE HITBOX EXPANDER ═══
local function CreateExpander(ball)
    if ExpanderPart then ExpanderPart:Destroy() end
 
    local exp = Instance.new("Part")
    exp.Name = "HitboxExpander"
    exp.Anchored = false
    exp.CanCollide = false
    exp.CanTouch = true
    exp.CanQuery = true
    exp.Material = Enum.Material.ForceField
    exp.Color = Color3.fromRGB(0, 200, 255)
    exp.Transparency = Config.HitboxTransparency
    exp.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
    exp.CastShadow = false
    exp.Parent = workspace.CurrentCamera
 
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = ball
    weld.Part1 = exp
    weld.Parent = exp
 
    ExpanderPart = exp
    return exp
end
 
-- ═══ UI ═══
local SG = Instance.new("ScreenGui")
SG.Name = "VBHelper"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.Parent = LocalPlayer:WaitForChild("PlayerGui")
 
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 230, 0, 180)
Main.Position = UDim2.new(0, 15, 0.5, -90)
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
 
-- FIX: Disable frame dragging when mouse is over the slider area
Main.InputBegan:Connect(function(input)
    if isDraggingSlider then return end
end)
 
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
 
-- ═══ TOGGLE BUTTON ═══
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
 
-- ═══ SLIDER (FIXED — no frame drag conflict) ═══
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
    Val.Text = tostring(default)
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
    Track.Parent = Row
    Track.Active = true  -- FIX: make track consume input
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
    Knob.Parent = Track
    Knob.Active = true  -- FIX: knob consumes input
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
 
    local dragging = false
 
    local function UpdateSlider(inputX)
        local absPos = Track.AbsolutePosition.X
        local absSize = Track.AbsoluteSize.X
        local x = math.clamp((inputX - absPos) / absSize, 0, 1)
        local val = min + x * (max - min)
        val = math.floor(val * 10) / 10
        Fill.Size = UDim2.new(x, 0, 1, 0)
        Knob.Position = UDim2.new(x, -8, 0.5, -8)
        Val.Text = tostring(val)
        callback(val)
    end
 
    -- FIX: Use Track.InputBegan so clicking the track also works
    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            isDraggingSlider = true  -- FIX: tell frame to stop dragging
            UpdateSlider(input.Position.X)
        end
    end)
 
    Knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            isDraggingSlider = true  -- FIX: tell frame to stop dragging
        end
    end)
 
    Knob.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            isDraggingSlider = false  -- FIX: re-enable frame drag
        end
    end)
 
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input.Position.X)
        end
    end)
 
    -- FIX: Global input end catches edge cases where mouse leaves the knob
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                isDraggingSlider = false  -- FIX: always re-enable frame drag
            end
        end
    end)
 
    callback(default)
end
 
-- ═══ BUILD UI ═══
MakeToggle("Ball Hitbox", true, 1, function(v) Config.HitboxExpand = v end)
MakeSlider("Hitbox Size", 3, 30, Config.HitboxSize, 2, function(v)
    Config.HitboxSize = v
end)
MakeToggle("Invisible Ball", false, 3, function(v)
    Config.HitboxTransparency = v and 1 or 0.7
    if ExpanderPart then ExpanderPart.Transparency = Config.HitboxTransparency end
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
 
-- ═══ MAIN LOOP ═══
RunService.Heartbeat:Connect(function()
    if not CurrentBall or not CurrentBall.Parent then
        CurrentBall = FindBall()
        if CurrentBall then
            Status.Text = "Ball found!"
            Status.TextColor3 = Color3.fromRGB(100, 255, 150)
        else
            Status.Text = "Searching for ball..."
            Status.TextColor3 = Color3.fromRGB(255, 220, 100)
            return
        end
    end
 
    if Config.HitboxExpand and CurrentBall and CurrentBall.Parent then
        if not ExpanderPart or not ExpanderPart.Parent then
            CreateExpander(CurrentBall)
        end
        if ExpanderPart then
            local targetSize = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
            if ExpanderPart.Size ~= targetSize then
                ExpanderPart.Size = targetSize
            end
            ExpanderPart.Transparency = Config.HitboxTransparency
        end
    elseif not Config.HitboxExpand and ExpanderPart then
        ExpanderPart:Destroy()
        ExpanderPart = nil
    end
 
    if ExpanderPart and CurrentBall then
        Status.Text = "Hitbox: " .. Config.HitboxSize .. " studs"
    end
end)
 
workspace.DescendantRemoving:Connect(function(v)
    if v == CurrentBall then
        CurrentBall = nil
        if ExpanderPart then
            ExpanderPart:Destroy()
            ExpanderPart = nil
        end
    end
end)
 
print("[Volleyball Helper] v1.1 loaded — slider fix applied")
