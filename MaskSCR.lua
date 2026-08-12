-- AimAssist + ESP v1.2 — Fixed team check & ESP
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
local ESPObjects = {}
 
-- ═══ TEAM CHECK ═══
local function IsEnemy(player)
    -- If no team system, everyone is an enemy
    if not LocalPlayer.Team or not player.Team then
        return player ~= LocalPlayer
    end
    -- Different teams = enemy
    return player.Team ~= LocalPlayer.Team
end
 
-- ═══ UI ═══
local SG = Instance.new("ScreenGui")
SG.Name = "UI"
SG.ResetOnSpawn = false
SG.Parent = LocalPlayer:WaitForChild("PlayerGui")
 
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 220, 0, 290)
Main.Position = UDim2.new(0, 15, 0.5, -145)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
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
Title.Parent = Main
 
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -70)
Content.Position = UDim2.new(0, 10, 0, 35)
Content.BackgroundTransparency = 1
Content.Parent = Main
local layout = Instance.new("UIListLayout", Content)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 8)
 
local function MakeSlider(name, label, min, max, default, order)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 38)
    Row.BackgroundTransparency = 1
    Row.LayoutOrder = order
    Row.Parent = Content
 
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(0.55, 0, 0, 14)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = label
    Lbl.TextColor3 = Color3.fromRGB(180, 180, 200)
    Lbl.TextSize = 11
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Row
 
    local Val = Instance.new("TextLabel")
    Val.Size = UDim2.new(0.45, 0, 0, 14)
    Val.BackgroundTransparency = 1
    Val.Text = string.format("%.2f", default)
    Val.TextColor3 = Color3.fromRGB(130, 200, 255)
    Val.TextSize = 11
    Val.Font = Enum.Font.GothamBold
    Val.TextXAlignment = Enum.TextXAlignment.Right
    Val.Parent = Row
 
    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, 0, 0, 5)
    Track.Position = UDim2.new(0, 0, 0, 20)
    Track.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    Track.BorderSizePixel = 0
    Track.Parent = Row
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)
 
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(100, 160, 255)
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
 
    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 12, 0, 12)
    Knob.Position = UDim2.new((default-min)/(max-min), -6, 0.5, -6)
    Knob.BackgroundColor3 = Color3.fromRGB(180, 210, 255)
    Knob.BorderSizePixel = 0
    Knob.ZIndex = 2
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
 
-- ═══ ESP ═══
local function CreateESP(player)
    if ESPObjects[player] then return end
 
    -- Use BillboardGui instead of Drawing for better compatibility
    local head = player.Character and player.Character:FindFirstChild("Head")
    if not head then return end
 
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Billboard"
    billboard.Size = UDim2.new(0, 120, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.Adornee = head
    billboard.Parent = head
 
    -- Name label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 18)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Parent = billboard
 
    -- Distance label
    local distLabel = Instance.new("TextLabel")
    distLabel.Name = "Dist"
    distLabel.Size = UDim2.new(1, 0, 0, 14)
    distLabel.Position = UDim2.new(0, 0, 0, 18)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "0m"
    distLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    distLabel.TextSize = 12
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextStrokeTransparency = 0
    distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distLabel.Parent = billboard
 
    -- Box frame around character
    local boxFrame = Instance.new("Frame")
    boxFrame.Name = "ESP_Box"
    boxFrame.Size = UDim2.new(0, 60, 0, 80)
    boxFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    boxFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    boxFrame.BackgroundTransparency = 1
    boxFrame.BorderSizePixel = 0
    boxFrame.Parent = billboard
    Instance.new("UICorner", boxFrame).CornerRadius = UDim.new(0, 4)
    local boxStroke = Instance.new("UIStroke", boxFrame)
    boxStroke.Color = Color3.fromRGB(255, 50, 50)
    boxStroke.Thickness = 2
    boxStroke.Transparency = 0.3
 
    ESPObjects[player] = {Billboard = billboard, Name = nameLabel, Dist = distLabel, Box = boxFrame, BoxStroke = boxStroke}
end
 
local function RemoveESP(player)
    if ESPObjects[player] then
        ESPObjects[player].Billboard:Destroy()
        ESPObjects[player] = nil
    end
end
 
-- Clean ESP on death
local function SetupPlayer(player)
    if player == LocalPlayer then return end
 
    local function OnCharacter(char)
        RemoveESP(player)
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then
            hum.Died:Connect(function()
                RemoveESP(player)
            end)
        end
    end
 
    if player.Character then OnCharacter(player.Character) end
    player.CharacterAdded:Connect(OnCharacter)
    player.AncestryChanged:Connect(function(_, parent)
        if not parent then RemoveESP(player) end
    end)
end
 
for _, p in ipairs(Players:GetPlayers()) do SetupPlayer(p) end
Players.PlayerAdded:Connect(SetupPlayer)
Players.PlayerRemoving:Connect(RemoveESP)
 
-- ═══ CORE ═══
local function GetClosest()
    local sc = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local best, bestDist = nil, Config.FOVRadius
 
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if not IsEnemy(p) then continue end  -- TEAM CHECK
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
    -- FOV Circle
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
                Status.Text = "SCANNING..."
                Status.TextColor3 = Color3.fromRGB(255, 220, 100)
            end
        else
            CurrentTarget = nil
            Status.Text = Config.Enabled and "SCANNING..." or "OFF"
            Status.TextColor3 = Config.Enabled and Color3.fromRGB(255, 220, 100) or Color3.fromRGB(140, 140, 160)
        end
    else
        CurrentTarget = nil
        Status.Text = "OFF"
        Status.TextColor3 = Color3.fromRGB(140, 140, 160)
    end
 
    -- ESP Update
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
 
        if Config.ESP and IsEnemy(p) and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            local head = p.Character:FindFirstChild("Head")
 
            if hum and root and head and hum.Health > 0 then
                local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myRoot then
                    local dist = (root.Position - myRoot.Position).Magnitude
                    if dist <= Config.MaxDistance and IsVisible(head) then
                        CreateESP(p)
                        local obj = ESPObjects[p]
                        if obj then
                            obj.Dist.Text = math.floor(dist) .. "m"
                            -- Color based on distance
                            if dist < 50 then
                                obj.BoxStroke.Color = Color3.fromRGB(255, 50, 50)  -- red = close
                            elseif dist < 150 then
                                obj.BoxStroke.Color = Color3.fromRGB(255, 165, 0)  -- orange = mid
                            else
                                obj.BoxStroke.Color = Color3.fromRGB(255, 255, 0)  -- yellow = far
                            end
                        end
                    else
                        RemoveESP(p)
                    end
                end
            else
                RemoveESP(p)
            end
        else
            RemoveESP(p)
        end
    end
end)
 
print("[Maskkun] Loaded v1.2")
