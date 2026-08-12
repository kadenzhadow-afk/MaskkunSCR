-- DEBUG ONLY — find the ball
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
 
local SG = Instance.new("ScreenGui")
SG.Name = "DB"
SG.ResetOnSpawn = false
SG.Parent = LocalPlayer:WaitForChild("PlayerGui")
 
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 500, 0, 400)
Frame.Position = UDim2.new(0.5, -250, 0.5, -200)
Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Frame.BackgroundTransparency = 0.3
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = SG
 
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -10)
Scroll.Position = UDim2.new(0, 5, 0, 5)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.ScrollBarThickness = 8
Scroll.Parent = Frame
 
local Label = Instance.new("TextLabel")
Label.Size = UDim2.new(1, -4, 0, 0)
Label.BackgroundTransparency = 1
Label.TextColor3 = Color3.fromRGB(0, 255, 100)
Label.TextSize = 14
Label.Font = Enum.Font.Code
Label.TextXAlignment = Enum.TextXAlignment.Left
Label.TextYAlignment = Enum.TextYAlignment.Top
Label.TextWrapped = true
Label.AutomaticSize = Enum.AutomaticSize.Y
Label.Parent = Scroll
 
local lines = {"SCANNING...\n"}
 
-- Dump workspace children
table.insert(lines, "=== WORKSPACE TOP-LEVEL ===")
for _, v in pairs(workspace:GetChildren()) do
    local ok, cn = pcall(function() return v.ClassName end)
    local name = pcall(function() return v.Name end) and v.Name or "?"
    table.insert(lines, name .. " (" .. (cn or "?") .. ")")
end
 
-- Dump workspace descendants
table.insert(lines, "\n=== WORKSPACE ALL PARTS (size 1-30) ===")
local count = 0
for _, v in pairs(workspace:GetDescendants()) do
    local ok = pcall(function()
        if (v:IsA("Part") or v:IsA("MeshPart")) then
            local sz = v.Size.Magnitude
            if sz >= 1 and sz <= 30 then
                count = count + 1
                if count <= 40 then
                    local vel = pcall(function() return v.AssemblyLinearVelocity.Magnitude end)
                    local velStr = ""
                    if vel then
                        local ok2, vm = pcall(function() return v.AssemblyLinearVelocity.Magnitude end)
                        if ok2 and vm > 1 then velStr = " [MOV:" .. math.floor(vm) .. "]" end
                    end
                    table.insert(lines, count .. ". " .. v.Name .. " | " .. v.ClassName .. " | " .. tostring(v.Size) .. velStr)
                    table.insert(lines, "   Parent: " .. (v.Parent and v.Parent.Name or "?"))
                end
            end
        end
    end)
end
table.insert(lines, "Total small parts: " .. count)
 
-- Also check ReplicatedStorage
table.insert(lines, "\n=== REPLICATEDSTORAGE ===")
for _, v in pairs(RS:GetDescendants()) do
    local ok = pcall(function()
        if (v:IsA("Part") or v:IsA("MeshPart")) then
            table.insert(lines, v.Name .. " | " .. v.ClassName .. " | " .. tostring(v.Size))
        end
    end)
end
 
Label.Text = table.concat(lines, "\n")
Scroll.CanvasSize = UDim2.new(0, 0, 0, Label.AbsoluteSize.Y + 20)
 
print("[DEBUG] Done scanning")
