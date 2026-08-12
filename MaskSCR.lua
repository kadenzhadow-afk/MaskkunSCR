-- AimAssist + ESP v1.3 — Arsenal compatible
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
 
local Config = {
    Enabled = false,
    FOVRadius = 150,
    Smoothness = 1.0,
    MaxDistance = 300,
    WallCheck = true,
    TargetPart = "Head",
    ESP = true,
}
 
local CurrentTarget = nil
local ESPCache = {}
 
-- ═══ TEAM CHECK (Arsenal = FFA, everyone is enemy) ═══
local function IsEnemy(player)
    if player == LocalPlayer then return false end
    if not player.Character then return false end
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    -- Arsenal is FFA — everyone else is enemy
    if not LocalPlayer.Team or not player.Team then return true end
    return player.Team ~= LocalPlayer.Team
end
 
-- ═══ UI ═══
local SG = Instance.new("ScreenGui")
SG.Name = "UI"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.Parent = LocalPlayer:WaitForChild("PlayerGui")
 
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 220, 0, 280)
Main.Position = UDim2.new(0, 15, 0.5, -140)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.ZIndex = 10
Main.Parent = SG
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", Main)
stroke.Color = Color3.fromRGB(80, 80, 120)
stroke.Thickness = 1.5
 
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -10, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Maskkun"
Title.TextColor3 = Color3.fromRGB(220, 220, 240)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 11
Title.Parent = Main
 
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -70)
Content.Position = UDim2.new(0, 10, 0, 35)
Content.BackgroundTransparency = 1
Content.ZIndex = 11
Content.Parent = Main
local layout = Instance.new("UIListLayout", Content)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 8)
 
local function MakeSlider(name, label, min, max, default, order)
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
    Val.TextColor3 = Color3.fromRGB(130, 200, 255)
    Val.TextSize = 11
    Val.Font = Enum.Font.GothamBold
    Val.TextXAlignment = Enum.TextXAlignment.Right
    Val.ZIndex = 13
    Val.Parent = Row
 
    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, 0, 0, 5)
    Track.Position = UDim2.new(0, 0, 0, 20)
    Track.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    Track.BorderSizePixel = 0
    Track.ZIndex = 13
    Track.Parent = Row
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)
 
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(100, 160, 255)
    Fill.BorderSizePixel = 0
    Fill.ZIndex = 14
    Fill.Parent = Track
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
 
    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 12, 0, 12)
    Knob.Position = UDim2.new((default-min)/(max-min), -6, 0.5, -6)
    Knob.BackgroundColor3 = Color3.fromRGB(180, 210, 255)
    Knob.BorderSizePixel = 0
    Knob.ZIndex = 15
    Knob.Parent = Track
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
 
    local dragging = false
    local function Update(x)
        local r = math.clamp((x - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        local v = min + r * (max - min)
        Fill.Size = UDim2.new(r, 0, 1, 0)
        Knob.Position = UDim2.new(r, -6, 0.5, -6)
        Val.Text = string.format("%.2f", v)
        return v
    end
 
    Track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local v = Update(i.Position.X)
            if name == "FOV" then Config.FOVRadius = v
            elseif name == "Smooth" then Config.Smoothness = v end
        end
    end)
    Knob.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local v = Update(i.Position.X)
            if name == "FOV" then Config.FOVRadius = v
            elseif name == "Smooth" then Config.Smoothness = v end
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end
 
MakeSlider("FOV", "FOV Radius", 50, 400, Config.FOVRadius, 1)
MakeSlider("Smooth", "Smoothness", 0.01, 1.0, Config.Smoothness, 2)
 
local function MakeToggle(label, configKey, order)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 30)
    Btn.BackgroundColor3 = Config[configKey] and Color3.fromRGB(40, 140, 80) or Color3.fromRGB(60, 60, 80)
    Btn.BorderSizePixel = 0
    Btn.Text = (Config[configKey] and "ON" or "OFF") .. "  " .. label
    Btn.TextColor3 = Color3.fromRGB(200, 200, 220)
    Btn.TextSize = 12
    Btn.Font = Enum.Font.GothamBold
    Btn.LayoutOrder = order
    Btn.ZIndex = 12
    Btn.Parent = Content
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
 
    Btn.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        Btn.BackgroundColor3 = Config[configKey] and Color3.fromRGB(40, 140, 80) or Color3.fromRGB(60, 60, 80)
        Btn.Text = (Config[configKey] and "ON" or "OFF") .. "  " .. label
    end)
end
 
MakeToggle("Aim Assist", "Enabled", 3)
MakeToggle("ESP", "ESP", 4)
MakeToggle("Wall Check", "WallCheck", 5)
 
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 20)
Status.Position = UDim2.new(0, 0, 1, -25)
Status.BackgroundTransparency = 1
Status.Text = "OFF"
Status.TextColor3 = Color3.fromRGB(140, 140, 160)
Status.TextSize = 11
Status.Font = Enum.Font.Gotham
Status.ZIndex = 11
Status.Parent = Main
 
-- FOV Circle
local ok, Circle = pcall(function() return Drawing.new("Circle") end)
if ok and Circle then
    Circle.Visible = false
    Circle.Thickness = 1.5
    Circle.Color = Color3.fromRGB(100, 180, 255)
    Circle.Transparency = 0.6
    Circle.Filled = false
    Circle.NumSides = 64
end
 
-- ═══ ESP (ScreenGui approach — works everywhere) ═══
local function CreateESP(player)
    if ESPCache[player] then return end
 
    local espFrame = Instance.new("Frame")
    espFrame.Name = "ESP_" .. player.Name
    espFrame.Size = UDim2.new(0, 80, 0, 40)
    espFrame.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    espFrame.BackgroundTransparency = 0.7
    espFrame.BorderSizePixel = 0
    espFrame.AnchorPoint = Vector2.new(0.5, 1)
    espFrame.Visible = false
    espFrame.ZIndex = 5
    espFrame.Parent = SG
    Instance.new("UICorner", espFrame).CornerRadius = UDim.new(0, 4)
    local boxStroke = Instance.new("UIStroke", espFrame)
    boxStroke.Color = Color3.fromRGB(255, 50, 50)
    boxStroke.Thickness = 2
 
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 16)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    nameLabel.TextSize = 12
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextStrokeTransparency = 0
    nameLabel.ZIndex = 6
    nameLabel.Parent = espFrame
 
    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0, 14)
    distLabel.Position = UDim2.new(0, 0, 0, 16)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "0m"
    distLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    distLabel.TextSize = 10
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextStrokeTransparency = 0
    distLabel.ZIndex = 6
    distLabel.Parent = espFrame
 
    ESPCache[player] = {Frame = espFrame, Name = nameLabel, Dist = distLabel, Stroke = boxStroke}
end
 
local function RemoveESP(player)
    if ESPCache[player] then
        ESPCache[player].Frame:Destroy()
        ESPCache[player] = nil
    end
end
 
local function SetupPlayer(player)
    if player == LocalPlayer then return end
    local function OnCharacter(char)
        RemoveESP(player)
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then hum.Died:Connect(function() RemoveESP(player) end) end
    end
    if player.Character then OnCharacter(player.Character) end
    player.CharacterAdded:Connect(OnCharacter)
end
 
for _, p in ipairs(Players:GetPlayers()) do SetupPlayer(p) end
Players.PlayerAdded:Connect(SetupPlayer)
Players.PlayerRemoving:Connect(RemoveESP)
 
-- ═══ CORE ═══
local function GetClosest()
    local sc = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local best, bestDist = nil, Config.FOVRadius
 
    for _, p in ipairs(Players:GetPlayers()) do
        if not IsEnemy(p) then continue end
        if not p.Character then continue end
        local hum = p.Character:FindFirstChildOfClass("Humanoid")
        local root = p.Character:FindFirstChild("HumanoidRootPart")
        local part = p.Character:FindFirstChild(Config.TargetPart)
        if not hum or not root or not part or hum.Health <= 0 then continue end
 
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then continue end
        if (root.Position - myRoot.Position).Magnitude > Config.MaxDistance then continue end
 
        local sp, onScr = Camera:WorldToViewportPoint(part.Position)
        if not onScr then continue end
 
        local sd = (Vector2.new(sp.X, sp.Y) - sc).Magnitude
        if sd <= Config.FOVRadius and sd < bestDist then
            if Config.WallCheck then
                local rp = RaycastParams.new()
                rp.FilterDescendantsInstances = {LocalPlayer.Character, p.Character}
                rp.FilterType = Enum.RaycastFilterType.Exclude
                if workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, rp) then
                    continue
                end
            end
            bestDist = sd
            best = p
        end
    end
    return best
end
 
local function IsVisible(targetPart)
    local rp = RaycastParams.new()
    rp.FilterDescendantsInstances = {LocalPlayer.Character}
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(Camera.CFrame.Position, targetPart.Position - Camera.CFrame.Position, rp)
    return result == nil
end
 
-- ═══ MAIN LOOP ═══
RunService.Heartbeat:Connect(function()
    if ok and Circle then
        Circle.Visible = Config.Enabled
        Circle.Radius = Config.FOVRadius
        Circle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    end
 
    -- Aim Assist
    if Config.Enabled then
        CurrentTarget = GetClosest()
        if CurrentTarget and CurrentTarget.Character then
            local hum = CurrentTarget.Character:FindFirstChildOfClass("Humanoid")
            local part = CurrentTarget.Character:FindFirstChild(Config.TargetPart)
            if hum and hum.Health > 0 and part then
                Camera.CFrame = Camera.CFrame:Lerp(
                    CFrame.new(Camera.CFrame.Position, part.Position),
                    Config.Smoothness
                )
                Status.Text = "LOCKED > " .. CurrentTarget.Name
                Status.TextColor3 = Color3.fromRGB(100, 255, 150)
            else
                CurrentTarget = nil
            end
        else
            CurrentTarget = nil
        end
 
        if not CurrentTarget then
            Status.Text = "SCANNING..."
            Status.TextColor3 = Color3.fromRGB(255, 220, 100)
        end
    else
        CurrentTarget = nil
        Status.Text = "OFF"
        Status.TextColor3 = Color3.fromRGB(140, 140, 160)
    end
 
    -- ESP Update
    for _, p in ipairs(Players:GetPlayers()) do
        if Config.ESP and IsEnemy(p) and p.Character then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            local head = p.Character:FindFirstChild("Head")
 
            if root and head then
                local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myRoot then
                    local dist = (root.Position - myRoot.Position).Magnitude
                    if dist <= Config.MaxDistance and IsVisible(head) then
                        CreateESP(p)
                        local obj = ESPCache[p]
                        if obj then
                            local sp, onScr = Camera:WorldToViewportPoint(root.Position)
                            if onScr then
                                obj.Frame.Position = UDim2.new(0, sp.X, 0, sp.Y - 50)
                                obj.Frame.Visible = true
                                obj.Dist.Text = math.floor(dist) .. "m"
                                obj.Name.Text = p.Name
                                if dist < 50 then
                                    obj.Stroke.Color = Color3.fromRGB(255, 50, 50)
                                elseif dist < 150 then
                                    obj.Stroke.Color = Color3.fromRGB(255, 165, 0)
                                else
                                    obj.Stroke.Color = Color3.fromRGB(255, 255, 0)
                                end
                            else
                                obj.Frame.Visible = false
                            end
                        end
                    else
                        RemoveESP(p)
                    end
                end
            end
        else
            RemoveESP(p)
        end
    end
end)
 
print("[Maskkun] v1.3 loaded")
