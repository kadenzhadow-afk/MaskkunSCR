-- Volleyball Legends — Ball Hitbox Expander v1.7 (Find Everything + Visual Hitbox)
-- ════════════════════════════════════════════════════
 
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
 
local Config = {
    HitboxExpand = true,
    HitboxSize = 12,
    HitboxTransparency = 0.5,
    Debug = true,
}
 
local CurrentBall = nil
local OriginalBallSize = nil
local HitboxPart = nil
local isDraggingSlider = false
 
-- ═══ FIND BALL — AGGRESSIVE SEARCH ═══
local function FindBall()
    -- Search 1: Any BasePart or MeshPart with "ball" in the name
    for _, v in pairs(workspace:GetDescendants()) do
        if (v:IsA("BasePart") or v:IsA("MeshPart")) then
            local name = v.Name:lower()
            if name:find("ball") and not name:find("shadow") and not name:find("indicator") then
                return v
            end
        end
    end
    -- Search 2: Sphere-shaped parts
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Shape == Enum.PartType.Ball then
            return v
        end
    end
    -- Search 3: Any small part moving fast (ball in play)
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("MeshPart") then
            local size = v.Size.Magnitude
            if size > 1 and size < 15 then
                local vel = v.AssemblyLinearVelocity or v.Velocity or Vector3.new(0,0,0)
                if vel.Magnitude > 3 then
                    return v
                end
            end
        end
    end
    -- Search 4: Any part inside folders named ball-related
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Folder") or v:IsA("Model") then
            local name = v.Name:lower()
            if name:find("ball") or name:find("game") or name:find("match") or name:find("court") then
                for _, child in pairs(v:GetDescendants()) do
                    if (child:IsA("BasePart") or child:IsA("MeshPart")) and child.Size.Magnitude > 1 and child.Size.Magnitude < 15 then
                        return child
                    end
                end
            end
        end
    end
    -- Search 5: EVERYTHING small in workspace
    for _, v in pairs(workspace:GetDescendants()) do
        if (v:IsA("BasePart") or v:IsA("MeshPart")) and v.Size.Magnitude >= 1 and v.Size.Magnitude <= 8 then
            return v
        end
    end
    return nil
end
 
-- ═══ CREATE VISUAL HITBOX (blue sphere you can SEE) ═══
local function CreateVisualHitbox(ball)
    if HitboxPart then HitboxPart:Destroy() end
 
    local hitbox = Instance.new("Part")
    hitbox.Name = "VisualHitbox"
    hitbox.Shape = Enum.PartType.Ball
    hitbox.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
    hitbox.Anchored = false
    hitbox.CanCollide = false
    hitbox.CanTouch = false
    hitbox.Material = Enum.Material.ForceField
    hitbox.Color = Color3.fromRGB(0, 150, 255)
    hitbox.Transparency = Config.HitboxTransparency
    hitbox.CastShadow = false
    hitbox.Parent = workspace.CurrentCamera
 
    -- Weld to ball so it follows
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = ball
    weld.Part1 = hitbox
    weld.Parent = hitbox
 
    HitboxPart = hitbox
end
 
local function RemoveVisualHitbox()
    if HitboxPart then
        HitboxPart:Destroy()
        HitboxPart = nil
    end
end
 
-- ═══ UI ═══
local SG = Instance.new("ScreenGui")
SG.Name = "VBHelper"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.Parent = LocalPlayer:WaitForChild("PlayerGui")
 
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
 
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -24, 0, 160)
Content.Position = UDim2.new(0, 12, 0, 48)
Content.BackgroundTransparency = 1
Content.ZIndex = 11
Content.Parent = Main
local layout = Instance.new("UIListLayout", Content)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 8)
 
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
        local x = math.clamp((inputX - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        local val = math.floor((min + x * (max - min)) * 100) / 100
        Fill.Size = UDim2.new(x, 0, 1, 0)
        Knob.Position = UDim2.new(x, -10, 0.5, -10)
        Val.Text = string.format("%.2f", val)
        callback(val)
    end
    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; isDraggingSlider = true; UpdateSlider(input.Position.X)
        end
    end)
    Knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; isDraggingSlider = true
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false; isDraggingSlider = false
        end
    end)
    callback(default)
end
 
-- ═══ BUILD UI ═══
MakeToggle("Ball Hitbox", true, 1, function(v)
    Config.HitboxExpand = v
    if not v then RemoveVisualHitbox() end
end)
MakeSlider("Hitbox Size", 3, 30, Config.HitboxSize, 2, function(v)
    Config.HitboxSize = v
    if HitboxPart then HitboxPart.Size = Vector3.new(v, v, v) end
end)
MakeSlider("Transparency", 0, 1, Config.HitboxTransparency, 3, function(v)
    Config.HitboxTransparency = v
    if HitboxPart then HitboxPart.Transparency = v end
end)
MakeToggle("Debug", true, 4, function(v) Config.Debug = v end)
 
-- ═══ STATUS ═══
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 30)
Status.Position = UDim2.new(0, 10, 1, -35)
Status.BackgroundTransparency = 1
Status.Text = "Searching..."
Status.TextColor3 = Color3.fromRGB(255, 220, 100)
Status.TextSize = 16
Status.Font = Enum.Font.GothamBold
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.ZIndex = 11
Status.Parent = Main
 
-- ═══ DEBUG PANEL ═══
local DebugPanel = Instance.new("Frame")
DebugPanel.Size = UDim2.new(0, 380, 0, 250)
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
DebugTitle.Size = UDim2.new(1, -16, 0, 28)
DebugTitle.Position = UDim2.new(0, 8, 0, 4)
DebugTitle.BackgroundTransparency = 1
DebugTitle.Text = "DEBUG - ALL PARTS IN WORKSPACE"
DebugTitle.TextColor3 = Color3.fromRGB(0, 255, 180)
DebugTitle.TextSize = 18
DebugTitle.Font = Enum.Font.GothamBold
DebugTitle.TextXAlignment = Enum.TextXAlignment.Left
DebugTitle.ZIndex = 11
DebugTitle.Parent = DebugPanel
 
local DebugScroll = Instance.new("ScrollingFrame")
DebugScroll.Size = UDim2.new(1, -16, 1, -36)
DebugScroll.Position = UDim2.new(0, 8, 0, 34)
DebugScroll.BackgroundTransparency = 1
DebugScroll.ZIndex = 11
DebugScroll.Parent = DebugPanel
DebugScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
DebugScroll.ScrollBarThickness = 6
DebugScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 150)
 
local DebugLabel = Instance.new("TextLabel")
DebugLabel.Size = UDim2.new(1, -4, 0, 0)
DebugLabel.Position = UDim2.new(0, 0, 0, 0)
DebugLabel.BackgroundTransparency = 1
DebugLabel.Text = "Scanning..."
DebugLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
DebugLabel.TextSize = 14
DebugLabel.Font = Enum.Font.Code
DebugLabel.TextXAlignment = Enum.TextXAlignment.Left
DebugLabel.TextYAlignment = Enum.TextYAlignment.Top
DebugLabel.TextWrapped = true
DebugLabel.ZIndex = 12
DebugLabel.Parent = DebugScroll
DebugLabel.AutomaticSize = Enum.AutomaticSize.Y
 
-- ═══ DUMP EVERYTHING ═══
local function DumpWorkspace()
    local ok, err = pcall(function()
        local lines = {}
 
        if CurrentBall and CurrentBall.Parent then
            table.insert(lines, ">> BALL FOUND: " .. CurrentBall.Name)
            table.insert(lines, "    Class: " .. CurrentBall.ClassName)
            table.insert(lines, "    Size: " .. tostring(CurrentBall.Size))
            table.insert(lines, "")
        else
            table.insert(lines, ">> NO BALL DETECTED")
            table.insert(lines, "")
        end
 
        table.insert(lines, "=== ALL PARTS (first 30) ===")
        table.insert(lines, "")
 
        local count = 0
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("MeshPart") then
                count = count + 1
                if count <= 30 then
                    local sz = tostring(v.Size)
                    local vel = ""
                    local ok2, v2 = pcall(function() return v.AssemblyLinearVelocity end)
                    if ok2 and v2 and v2.Magnitude > 1 then
                        vel = " [MOVING:" .. tostring(math.floor(v2.Magnitude)) .. "]"
                    end
                    table.insert(lines, count .. ". " .. v.Name .. " (" .. v.ClassName .. ")" .. vel)
                    table.insert(lines, "   Size: " .. sz)
                    table.insert(lines, "")
                end
            end
        end
        table.insert(lines, "Total parts: " .. tostring(count))
 
        DebugLabel.Text = table.concat(lines, "\n")
        DebugScroll.CanvasSize = UDim2.new(0, 0, 0, DebugLabel.AbsoluteSize.Y + 20)
    end)
    if not ok then
        DebugLabel.Text = "ERROR: " .. tostring(err)
    end
end
 
-- ═══ MAIN LOOP ═══
local frameCount = 0
RunService.Heartbeat:Connect(function()
    frameCount = frameCount + 1
 
    local ok, err = pcall(function()
        -- Find ball
        if not CurrentBall or not CurrentBall.Parent then
            CurrentBall = FindBall()
            OriginalBallSize = nil
            if CurrentBall then
                OriginalBallSize = CurrentBall.Size
                Status.Text = "BALL: " .. CurrentBall.Name
                Status.TextColor3 = Color3.fromRGB(100, 255, 150)
                RemoveVisualHitbox()
            else
                Status.Text = "No ball found..."
                Status.TextColor3 = Color3.fromRGB(255, 220, 100)
            end
        end
 
        -- Create/update visual hitbox
        if Config.HitboxExpand and CurrentBall and CurrentBall.Parent then
            if not HitboxPart or not HitboxPart.Parent then
                CreateVisualHitbox(CurrentBall)
            end
            if HitboxPart then
                HitboxPart.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                HitboxPart.Transparency = Config.HitboxTransparency
            end
            Status.Text = "BALL: " .. CurrentBall.Name .. " | VISUAL HITBOX ACTIVE"
        end
 
        -- Also try to resize the actual ball directly
        if Config.HitboxExpand and CurrentBall and CurrentBall.Parent and OriginalBallSize then
            local expandFactor = Config.HitboxSize / math.max(OriginalBallSize.Magnitude, 1)
            local newSize = OriginalBallSize * expandFactor
            newSize = Vector3.new(math.clamp(newSize.X, 1, 50), math.clamp(newSize.Y, 1, 50), math.clamp(newSize.Z, 1, 50))
            CurrentBall.Size = newSize
            CurrentBall.Transparency = Config.HitboxTransparency
            CurrentBall.Material = Enum.Material.ForceField
            CurrentBall.Color = Color3.fromRGB(0, 200, 255)
        end
 
        -- Update debug every 60 frames
        if frameCount % 60 == 0 and Config.Debug then
            DumpWorkspace()
        end
    end)
    if not ok then
        Status.Text = "ERROR: " .. tostring(err)
        Status.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end)
 
workspace.DescendantRemoving:Connect(function(v)
    if v == CurrentBall then
        CurrentBall = nil
        OriginalBallSize = nil
        RemoveVisualHitbox()
    end
end)
 
-- Initial dump after 2 seconds
task.delay(2, function() DumpWorkspace() end)
 
print("[Volleyball Helper] v1.7 loaded")
