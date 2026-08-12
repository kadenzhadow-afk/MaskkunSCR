-- Volleyball Legends — Ball Hitbox Expander + Utility
-- Paste this in your executor
-- ════════════════════════════════════════════════════
 
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
 
-- ═══ CONFIG ═══
local Config = {
    HitboxExpand = true,
    HitboxSize = 12,        -- how big the hitbox is (default ball is ~2-3)
    HitboxTransparency = 0.7, -- 0 = visible, 1 = invisible
    AutoCollect = false,     -- auto-collect stray balls
}
 
local ExpanderPart = nil
local Tracking = false
 
-- ═══ FIND THE BALL ═══
local function FindBall()
    -- Check common ball locations in Roblox volleyball games
    local workspace = workspace
    
    -- Method 1: Find by name patterns
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local name = v.Name:lower()
            if name == "ball" or name == "volleyball" or name == "gameball" 
                or name:find("ball") and v.Size.Magnitude < 20 
                and v.Size.Magnitude > 1 then
                return v
            end
        end
    end
    
    -- Method 2: Find a small sphere in workspace (volleyball is usually a sphere)
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Shape == Enum.PartType.Ball 
            and v.Size.Magnitude < 15 and v.Size.Magnitude > 1 then
            return v
        end
    end
    
    -- Method 3: Find parts inside common containers
    local containers = {"Balls", "Game", "Match", "Court", "BallFolder"}
    for _, name in pairs(containers) do
        local folder = workspace:FindFirstChild(name, true)
        if folder then
            for _, v in pairs(folder:GetDescendants()) do
                if v:IsA("BasePart") and v.Size.Magnitude < 15 and v.Size.Magnitude > 1 then
                    return v
                end
            end
        end
    end
    
    return nil
end
 
-- ═══ CREATE HITBOX EXPANDER ═══
local function CreateExpander(ball)
    if ExpanderPart then
        ExpanderPart:Destroy()
    end
    
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
    
    -- Weld to ball so it follows
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = ball
    weld.Part1 = exp
    weld.Parent = exp
    
    -- Make it detect touches
    exp.Touched:Connect(function(hit)
        -- Expand the ball's touch detection
        local hum = hit.Parent:FindFirstChildOfClass("Humanoid")
        if hum and hit.Parent ~= LocalPlayer.Character then
            -- Register touch with the ball
            ball.Touched:FireServer(hit, ball.Position)
        end
    end)
    
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
Main.Size = UDim2.new(0, 230, 0, 200)
Main.Position = UDim2.new(0, 15, 0.5, -100)
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
Title.Text = "🏐 Volleyball Helper"
Title.TextColor3 = Color3.fromRGB(220, 240, 255)
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 11
Title.Parent = Main
 
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -16, 1, -40)
Content.Position = UDim2.new(0, 8, 0, 34)
Content.BackgroundTransparency = 1
Content.ZIndex = 11
Content.Parent = Main
local layout = Instance.new("UIListLayout", Content)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 6)
 
-- ═══ TOGGLE BUTTON HELPER ═══
local function MakeToggle(label, default, order, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 30)
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
    
    local btnCorner = Instance.new("UICorner", Btn)
    btnCorner.CornerRadius = UDim.new(0, 6)
    
    local state = default
    local function UpdateVisual()
        if state then
            Btn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
        else
            Btn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
        end
    end
    UpdateVisual()
    
    Btn.MouseButton1Click:Connect(function()
        state = not state
        UpdateVisual()
        Btn.Text = state and "ON" or "OFF"
        callback(state)
    end)
    
    return function() return state end
end
 
-- ═══ SLIDER HELPER ═══
local function MakeSlider(label, min, max, default, order, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 38)
    Row.BackgroundTransparency = 1
    Row.LayoutOrder = order
    Row.ZIndex = 12
    Row.Parent = Content
 
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(0.6, 0, 0, 14)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = label
    Lbl.TextColor3 = Color3.fromRGB(180, 180, 200)
    Lbl.TextSize = 11
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.ZIndex = 13
    Lbl.Parent = Row
 
    local Val = Instance.new("TextLabel")
    Val.Size = UDim2.new(0.4, 0, 0, 14)
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
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)
 
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    Fill.BorderSizePixel = 0
    Fill.ZIndex = 14
    Fill.Parent = Track
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
 
    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 14, 0, 14)
    Knob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.ZIndex = 15
    Knob.Parent = Track
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
 
    local dragging = false
    Knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    Knob.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local absPos = Track.AbsolutePosition.X
            local absSize = Track.AbsoluteSize.X
            local x = math.clamp((input.Position.X - absPos) / absSize, 0, 1)
            local val = min + x * (max - min)
            val = math.floor(val * 10) / 10
            
            Fill.Size = UDim2.new(x, 0, 1, 0)
            Knob.Position = UDim2.new(x, -7, 0.5, -7)
            Val.Text = tostring(val)
            callback(val)
        end
    end)
    
    callback(default)
end
 
-- ═══ BUILD UI ═══
MakeToggle("Ball Hitbox", true, 1, function(v) Config.HitboxExpand = v end)
MakeSlider("Hitbox Size", 3, 30, Config.HitboxSize, 2, function(v) Config.HitboxSize = v end)
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
local CurrentBall = nil
 
RunService.Heartbeat:Connect(function()
    -- Find ball if we don't have one
    if not CurrentBall or not CurrentBall.Parent then
        CurrentBall = FindBall()
        if CurrentBall then
            Status.Text = "Ball found! Size: " .. tostring(CurrentBall.Size)
            Status.TextColor3 = Color3.fromRGB(100, 255, 150)
        else
            Status.Text = "Searching for ball..."
            Status.TextColor3 = Color3.fromRGB(255, 220, 100)
            return
        end
    end
    
    -- Update hitbox expander
    if Config.HitboxExpand and CurrentBall and CurrentBall.Parent then
        if not ExpanderPart or not ExpanderPart.Parent then
            CreateExpander(CurrentBall)
        end
        -- Update size live
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
    
    -- Status update
    if ExpanderPart and CurrentBall then
        Status.Text = "Hitbox: " .. Config.HitboxSize .. " studs"
    end
end)
 
-- ═══ REJOIN DETECTION ═══
-- If ball disappears (round ended), clear and search again
workspace.DescendantRemoving:Connect(function(v)
    if v == CurrentBall then
        CurrentBall = nil
        if ExpanderPart then
            ExpanderPart:Destroy()
            ExpanderPart = nil
        end
    end
end)
 
print("[Volleyball Helper] Loaded!")
